#include "systeminfo.h"
#include <QFile>
#include <QTextStream>
#include <QDesktopServices>
#include <QUrl>
#include <QDir>
#include <QStandardPaths>
#include <sys/utsname.h>

SystemInfo::SystemInfo(QObject *parent)
    : QObject(parent), m_autostartEnabled(true)
{
    loadSystemData();
}

void SystemInfo::loadSystemData()
{
    m_osName = "Lunova OS";
    m_version = "1.0.1";
    m_codename = "Aurora";

    // Read /etc/os-release
    QFile osRelease("/etc/os-release");
    if (osRelease.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&osRelease);
        while (!in.atEnd()) {
            QString line = in.readLine();
            if (line.startsWith("PRETTY_NAME=")) {
                m_osName = line.mid(12).remove('"');
            } else if (line.startsWith("VERSION_ID=")) {
                m_version = line.mid(11).remove('"');
            } else if (line.startsWith("VERSION_CODENAME=")) {
                m_codename = line.mid(17).remove('"');
            }
        }
        osRelease.close();
    }

    // Read kernel release via uname
    struct utsname buf;
    if (uname(&buf) == 0) {
        m_kernelRelease = QString::fromLatin1(buf.release);
        m_hostname = QString::fromLatin1(buf.nodename);
    } else {
        m_kernelRelease = "Linux 6.1+";
        m_hostname = "lunova-desktop";
    }

    // Check autostart desktop file in ~/.config/autostart
    QString autostartPath = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) 
                            + "/autostart/org.lunova.welcome.desktop";
    m_autostartEnabled = QFile::exists(autostartPath);
}

QString SystemInfo::osName() const { return m_osName; }
QString SystemInfo::version() const { return m_version; }
QString SystemInfo::codename() const { return m_codename; }
QString SystemInfo::kernelRelease() const { return m_kernelRelease; }
QString SystemInfo::hostname() const { return m_hostname; }

bool SystemInfo::autostartEnabled() const { return m_autostartEnabled; }

void SystemInfo::setAutostartEnabled(bool enabled)
{
    if (m_autostartEnabled == enabled) return;
    m_autostartEnabled = enabled;

    QString autostartDir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/autostart";
    QDir().mkpath(autostartDir);
    QString filePath = autostartDir + "/org.lunova.welcome.desktop";

    if (enabled) {
        QFile::copy("/usr/share/applications/org.lunova.welcome.desktop", filePath);
    } else {
        QFile::remove(filePath);
    }
    emit autostartChanged();
}

void SystemInfo::launchCommand(const QString &command)
{
    QProcess::startDetached("/bin/sh", QStringList() << "-c" << command);
}

void SystemInfo::openUrl(const QString &url)
{
    QDesktopServices::openUrl(QUrl(url));
}

void SystemInfo::switchTheme(bool dark)
{
    QString themePkg = dark ? "org.lunova.aurora.desktop" : "org.kde.breeze.desktop";
    QString colorScheme = dark ? "LunovaAuroraDark" : "LunovaAuroraLight";
    
    QProcess::startDetached("plasma-apply-lookandfeel", QStringList() << "-a" << themePkg);
    QProcess::startDetached("plasma-apply-colorscheme", QStringList() << colorScheme);
}
