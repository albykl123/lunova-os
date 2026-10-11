#include "assistantbackend.h"
#include <QSettings>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QProcess>
#include <QDir>
#include <QStandardPaths>
#include <QRegularExpression>

AssistantBackend::AssistantBackend(QObject *parent)
    : QObject(parent),
      m_provider("Local (Ollama / Llama.cpp)"),
      m_endpointUrl("http://localhost:11434/api/generate"),
      m_modelName("mistral"),
      m_statusMessage("Ready. AI assistant requires configured provider or local server."),
      m_isProcessing(false),
      m_netManager(new QNetworkAccessManager(this))
{
    loadSettings();
    loadHistory();
    connect(m_netManager, &QNetworkAccessManager::finished, this, &AssistantBackend::onNetworkReply);
}

void AssistantBackend::loadSettings()
{
    QString confPath = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/lunova/assistant.conf";
    QSettings settings(confPath, QSettings::IniFormat);
    m_provider = settings.value("provider", "Local (Ollama / Llama.cpp)").toString();
    m_endpointUrl = settings.value("endpoint", "http://localhost:11434/api/generate").toString();
    m_modelName = settings.value("model", "mistral").toString();
    m_apiKey = settings.value("apiKey", "").toString();
}

void AssistantBackend::saveSettings()
{
    QString confDir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/lunova";
    QDir().mkpath(confDir);
    QString confPath = confDir + "/assistant.conf";
    QSettings settings(confPath, QSettings::IniFormat);
    settings.setValue("provider", m_provider);
    settings.setValue("endpoint", m_endpointUrl);
    settings.setValue("model", m_modelName);
    settings.setValue("apiKey", m_apiKey);
}

void AssistantBackend::loadHistory()
{
    QString histPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/lunova/assistant_history.json";
    QFile file(histPath);
    if (file.open(QIODevice::ReadOnly)) {
        QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
        if (doc.isArray()) {
            m_messages = doc.array().toVariantList();
            emit messagesChanged();
        }
        file.close();
    }
    if (m_messages.isEmpty()) {
        appendMessage("assistant", "Hello! I am Lunova Assistant. You can configure local or cloud AI models in Settings. System modifications will always ask for your explicit approval.");
    }
}

void AssistantBackend::saveHistory()
{
    QString histDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/lunova";
    QDir().mkpath(histDir);
    QString histPath = histDir + "/assistant_history.json";
    QFile file(histPath);
    if (file.open(QIODevice::WriteOnly)) {
        QJsonArray arr = QJsonArray::fromVariantList(m_messages);
        file.write(QJsonDocument(arr).toJson());
        file.close();
    }
}

void AssistantBackend::appendMessage(const QString &sender, const QString &text, const QString &command)
{
    QVariantMap msg;
    msg["sender"] = sender;
    msg["text"] = text;
    msg["command"] = command;
    msg["timestamp"] = QDateTime::currentDateTime().toString("hh:mm AP");
    m_messages.append(msg);
    emit messagesChanged();
    saveHistory();
}

QString AssistantBackend::provider() const { return m_provider; }
void AssistantBackend::setProvider(const QString &p) { m_provider = p; saveSettings(); emit providerChanged(); }

QString AssistantBackend::endpointUrl() const { return m_endpointUrl; }
void AssistantBackend::setEndpointUrl(const QString &url) { m_endpointUrl = url; saveSettings(); emit endpointChanged(); }

QString AssistantBackend::modelName() const { return m_modelName; }
void AssistantBackend::setModelName(const QString &m) { m_modelName = m; saveSettings(); emit modelChanged(); }

QString AssistantBackend::statusMessage() const { return m_statusMessage; }
bool AssistantBackend::isProcessing() const { return m_isProcessing; }
QVariantList AssistantBackend::messages() const { return m_messages; }
QString AssistantBackend::pendingCommand() const { return m_pendingCommand; }

void AssistantBackend::setApiKey(const QString &key) { m_apiKey = key; saveSettings(); }
QString AssistantBackend::getApiKey() const { return m_apiKey; }

void AssistantBackend::sendMessage(const QString &userText)
{
    if (userText.trimmed().isEmpty() || m_isProcessing) return;

    appendMessage("user", userText);
    m_isProcessing = true;
    m_statusMessage = "Connecting to " + m_provider + "...";
    emit isProcessingChanged();
    emit statusChanged();

    // Prepare HTTP Request
    QUrl targetUrl(m_endpointUrl);
    QNetworkRequest request(targetUrl);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    if (!m_apiKey.isEmpty()) {
        request.setRawHeader("Authorization", ("Bearer " + m_apiKey).toUtf8());
    }

    QJsonObject body;
    if (m_endpointUrl.contains("11434")) {
        // Ollama schema
        body["model"] = m_modelName;
        body["prompt"] = userText;
        body["stream"] = false;
    } else {
        // Generic OpenAI chat completions schema
        body["model"] = m_modelName;
        QJsonArray msgs;
        QJsonObject umsg;
        umsg["role"] = "user";
        umsg["content"] = userText;
        msgs.append(umsg);
        body["messages"] = msgs;
    }

    m_netManager->post(request, QJsonDocument(body).toJson());
}

void AssistantBackend::onNetworkReply(QNetworkReply *reply)
{
    m_isProcessing = false;
    emit isProcessingChanged();

    if (reply->error() != QNetworkReply::NoError) {
        m_statusMessage = "Connection Error: " + reply->errorString();
        appendMessage("assistant", "Unable to connect to AI provider: " + reply->errorString() + ". Verify that the local model runner or API credentials are functioning properly.");
        emit statusChanged();
        reply->deleteLater();
        return;
    }

    QByteArray data = reply->readAll();
    reply->deleteLater();

    QJsonDocument doc = QJsonDocument::fromJson(data);
    QString replyText;

    if (doc.isObject()) {
        QJsonObject obj = doc.object();
        if (obj.contains("response")) {
            replyText = obj["response"].toString();
        } else if (obj.contains("choices")) {
            QJsonArray choices = obj["choices"].toArray();
            if (!choices.isEmpty()) {
                replyText = choices[0].toObject()["message"].toObject()["content"].toString();
            }
        }
    }

    if (replyText.isEmpty()) {
        replyText = "Received empty response from provider.";
    }

    // Check if the response contains shell commands needing user approval
    QRegularExpression cmdRegex("```(?:bash|sh)?\\s*([\\s\\S]*?)```");
    QRegularExpressionMatch match = cmdRegex.match(replyText);
    QString extractedCommand;
    if (match.hasMatch()) {
        extractedCommand = match.captured(1).trimmed();
        m_pendingCommand = extractedCommand;
        emit pendingCommandChanged();
    }

    appendMessage("assistant", replyText, extractedCommand);
    m_statusMessage = "Ready.";
    emit statusChanged();
}

void AssistantBackend::approvePendingCommand()
{
    if (m_pendingCommand.isEmpty()) return;

    QString cmd = m_pendingCommand;
    m_pendingCommand.clear();
    emit pendingCommandChanged();

    appendMessage("system", "Executing authorized command: " + cmd);

    QProcess proc;
    proc.start("/bin/sh", QStringList() << "-c" << cmd);
    proc.waitForFinished(10000);
    QString out = QString::fromUtf8(proc.readAllStandardOutput());
    QString err = QString::fromUtf8(proc.readAllStandardError());

    QString result = out.isEmpty() ? err : out;
    if (result.isEmpty()) result = "Command completed successfully (no stdout).";
    appendMessage("system", "Result:\n" + result);
    emit commandExecuted(result);
}

void AssistantBackend::rejectPendingCommand()
{
    m_pendingCommand.clear();
    emit pendingCommandChanged();
    appendMessage("system", "System command was cancelled by user.");
}

void AssistantBackend::clearHistory()
{
    m_messages.clear();
    appendMessage("assistant", "Conversation history cleared.");
    saveHistory();
}
