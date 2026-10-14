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
    m_statusText = "Checking Debian repositories for available updates...";
    m_updates.clear();
    emit isBusyChanged();
    emit statusChanged();
    emit updateListChanged();
    emit progressChanged();

    disconnect(m_process, nullptr, nullptr, nullptr);
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this](int exitCode) { onCheckFinished(exitCode); });

    // Execute structured apt-get simulation directly without invoking /bin/sh shell
    m_process->start("/usr/bin/apt-get", QStringList() << "-s" << "-V" << "upgrade" << "--with-new-pkgs");
}

void UpdateManager::onCheckFinished(int exitCode)
{
    m_isBusy = false;
    m_progressPercent = 100;
    emit isBusyChanged();
    emit progressChanged();

    QString stdErr = QString::fromUtf8(m_process->readAllStandardError());

    if (exitCode != 0) {
        if (stdErr.contains("dpkg was interrupted", Qt::CaseInsensitive) || stdErr.contains("lock", Qt::CaseInsensitive)) {
            m_statusText = "Package manager lock detected. Please run 'sudo dpkg --configure -a' in Konsole to resolve.";
        } else {
            m_statusText = "Unable to check updates. Verify your network connection and repository mirrors.";
        }
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
        m_statusText = "Your system is up to date! All packages are at their latest versions.";
    } else {
        m_statusText = QString("%1 package update(s) ready to install.").arg(m_updates.size());
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
    m_statusText = "Applying system updates. Please authenticate when prompted...";
    emit isBusyChanged();
    emit statusChanged();
    emit progressChanged();

    disconnect(m_process, nullptr, nullptr, nullptr);
    connect(m_process, &QProcess::readyReadStandardOutput, this, &UpdateManager::onProcessOutput);
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this](int exitCode) { onInstallFinished(exitCode); });

    // Execute safe non-destructive upgrade via pkexec directly without shell wrapper
    // Uses 'upgrade --with-new-pkgs -y' to prevent removing essential desktop packages
    m_process->start("/usr/bin/pkexec", QStringList() << "/usr/bin/apt-get" << "upgrade" << "--with-new-pkgs" << "-y");
}

void UpdateManager::onProcessOutput()
{
    QString out = QString::fromUtf8(m_process->readAllStandardOutput());
    if (out.contains("Unpacking")) {
        m_progressPercent = 50;
        m_statusText = "Unpacking package updates...";
    } else if (out.contains("Setting up")) {
        m_progressPercent = 80;
        m_statusText = "Configuring upgraded packages...";
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
    } else if (exitCode == 126 || exitCode == 127) {
        m_statusText = "Installation cancelled: Authentication was not completed.";
    } else {
        m_statusText = "Update installation failed or was interrupted. Check system logs for details.";
    }

    emit statusChanged();
    checkRebootRequired();
}

void UpdateManager::rebootSystem()
{
    QProcess::startDetached("/usr/bin/systemctl", QStringList() << "reboot");
}
