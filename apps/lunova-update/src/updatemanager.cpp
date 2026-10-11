#include "updatemanager.h"
#include <QFile>
#include <QRegularExpression>

UpdateManager::UpdateManager(QObject *parent)
    : QObject(parent),
      m_statusText("System is ready. Click 'Check for Updates' to search Debian repositories."),
      m_isBusy(false),
      m_progressPercent(0),
      m_rebootRequired(false),
      m_process(new QProcess(this))
{
    checkRebootRequired();
}

QString UpdateManager::statusText() const { return m_statusText; }
bool UpdateManager::isBusy() const { return m_isBusy; }
int UpdateManager::updateCount() const { return m_updates.size(); }
QVariantList UpdateManager::updates() const { return m_updates; }
int UpdateManager::progressPercent() const { return m_progressPercent; }
bool UpdateManager::rebootRequired() const { return m_rebootRequired; }

void UpdateManager::checkRebootRequired()
{
    bool req = QFile::exists("/var/run/reboot-required");
    if (m_rebootRequired != req) {
        m_rebootRequired = req;
        emit rebootRequiredChanged();
    }
}

void UpdateManager::checkForUpdates()
{
    if (m_isBusy) return;

    m_isBusy = true;
    m_progressPercent = 10;
    m_statusText = "Refreshing package indices and checking for updates...";
    m_updates.clear();
    emit isBusyChanged();
    emit statusChanged();
    emit updateListChanged();
    emit progressChanged();

    disconnect(m_process, nullptr, nullptr, nullptr);
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this](int exitCode) { onCheckFinished(exitCode); });

    // Use apt update simulation or pkcon
    m_process->start("/bin/sh", QStringList() << "-c" << "apt-get update -qq && apt-get --just-print dist-upgrade");
}

void UpdateManager::onCheckFinished(int exitCode)
{
    m_isBusy = false;
    m_progressPercent = 100;
    emit isBusyChanged();
    emit progressChanged();

    if (exitCode != 0) {
        m_statusText = "Unable to check updates. Please check network connection or repository access.";
        emit statusChanged();
        return;
    }

    QString out = QString::fromUtf8(m_process->readAllStandardOutput());
    parseAptOutput(out);
}

void UpdateManager::parseAptOutput(const QString &output)
{
    m_updates.clear();
    QStringList lines = output.split('\n');
    QRegularExpression instRegex("^Inst\\s+([^\\s]+)\\s+\\[([^]]+)\\]\\s+\\(([^\\s]+)");

    for (const QString &line : lines) {
        QRegularExpressionMatch match = instRegex.match(line.trimmed());
        if (match.hasMatch()) {
            QVariantMap item;
            item["package"] = match.captured(1);
            item["currentVersion"] = match.captured(2);
            item["newVersion"] = match.captured(3);
            item["isSecurity"] = line.contains("security", Qt::CaseInsensitive);
            m_updates.append(item);
        }
    }

    if (m_updates.isEmpty()) {
        m_statusText = "Your system is up to date! No updates available.";
    } else {
        m_statusText = QString("%1 package updates available.").arg(m_updates.size());
    }

    emit statusChanged();
    emit updateListChanged();
    checkRebootRequired();
}

void UpdateManager::applyUpdates()
{
    if (m_isBusy || m_updates.isEmpty()) return;

    m_isBusy = true;
    m_progressPercent = 20;
    m_statusText = "Applying system updates. Please authenticate if prompted...";
    emit isBusyChanged();
    emit statusChanged();
    emit progressChanged();

    disconnect(m_process, nullptr, nullptr, nullptr);
    connect(m_process, &QProcess::readyReadStandardOutput, this, &UpdateManager::onProcessOutput);
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this](int exitCode) { onInstallFinished(exitCode); });

    // Execute via pkexec ensuring proper policykit authentication
    m_process->start("pkexec", QStringList() << "apt-get" << "dist-upgrade" << "-y");
}

void UpdateManager::onProcessOutput()
{
    QString out = QString::fromUtf8(m_process->readAllStandardOutput());
    if (out.contains("Unpacking")) {
        m_progressPercent = 50;
        m_statusText = "Unpacking packages...";
    } else if (out.contains("Setting up")) {
        m_progressPercent = 80;
        m_statusText = "Configuring system packages...";
    }
    emit progressChanged();
    emit statusChanged();
}

void UpdateManager::onInstallFinished(int exitCode)
{
    m_isBusy = false;
    m_progressPercent = 100;
    emit isBusyChanged();
    emit progressChanged();

    if (exitCode == 0) {
        m_statusText = "All updates installed successfully!";
        m_updates.clear();
        emit updateListChanged();
    } else {
        m_statusText = "Installation failed or was cancelled by user.";
    }

    emit statusChanged();
    checkRebootRequired();
}

void UpdateManager::rebootSystem()
{
    QProcess::startDetached("systemctl", QStringList() << "reboot");
}
