#ifndef ASSISTANTBACKEND_H
#define ASSISTANTBACKEND_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class AssistantBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString provider READ provider WRITE setProvider NOTIFY providerChanged)
    Q_PROPERTY(QString endpointUrl READ endpointUrl WRITE setEndpointUrl NOTIFY endpointChanged)
    Q_PROPERTY(QString modelName READ modelName WRITE setModelName NOTIFY modelChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusChanged)
    Q_PROPERTY(bool isProcessing READ isProcessing NOTIFY isProcessingChanged)
    Q_PROPERTY(QVariantList messages READ messages NOTIFY messagesChanged)
    Q_PROPERTY(QString pendingCommand READ pendingCommand NOTIFY pendingCommandChanged)

public:
    explicit AssistantBackend(QObject *parent = nullptr);

    QString provider() const;
    void setProvider(const QString &p);

    QString endpointUrl() const;
    void setEndpointUrl(const QString &url);

    QString modelName() const;
    void setModelName(const QString &m);

    QString statusMessage() const;
    bool isProcessing() const;
    QVariantList messages() const;
    QString pendingCommand() const;

    Q_INVOKABLE void setApiKey(const QString &key);
    Q_INVOKABLE QString getApiKey() const;
    Q_INVOKABLE void sendMessage(const QString &userText);
    Q_INVOKABLE void clearHistory();
    Q_INVOKABLE void approvePendingCommand();
    Q_INVOKABLE void rejectPendingCommand();

signals:
    void providerChanged();
    void endpointChanged();
    void modelChanged();
    void statusChanged();
    void isProcessingChanged();
    void messagesChanged();
    void pendingCommandChanged();
    void commandExecuted(const QString &output);

private slots:
    void onNetworkReply(QNetworkReply *reply);

private:
    QString m_provider;
    QString m_endpointUrl;
    QString m_modelName;
    QString m_apiKey;
    QString m_statusMessage;
    bool m_isProcessing;
    QVariantList m_messages;
    QString m_pendingCommand;

    QNetworkAccessManager *m_netManager;

    void loadSettings();
    void saveSettings();
    void loadHistory();
    void saveHistory();
    void appendMessage(const QString &sender, const QString &text, const QString &command = QString());
};

#endif // ASSISTANTBACKEND_H
