#include "controlbackend.h"

ControlBackend::ControlBackend(QObject *parent)
    : QObject(parent), m_volume(70), m_brightness(80), m_powerProfile("balanced")
{
    updateStatus();
}

void ControlBackend::updateStatus()
{
    // Try to query power profile
    QProcess proc;
    proc.start("powerprofilesctl", QStringList() << "get");
    if (proc.waitForFinished(500)) {
        QString out = QString::fromUtf8(proc.readAllStandardOutput()).trimmed();
        if (!out.isEmpty()) m_powerProfile = out;
    }
}

int ControlBackend::volume() const { return m_volume; }

void ControlBackend::setVolume(int vol)
{
    if (m_volume == vol) return;
    m_volume = qBound(0, vol, 100);
    // Set via wpctl or pactl
    QProcess::startDetached("wpctl", QStringList() << "set-volume" << "@DEFAULT_AUDIO_SINK@" << QString::number(m_volume / 100.0, 'f', 2));
    emit volumeChanged();
}

int ControlBackend::brightness() const { return m_brightness; }

void ControlBackend::setBrightness(int b)
{
    if (m_brightness == b) return;
    m_brightness = qBound(5, b, 100);
    QProcess::startDetached("brightnessctl", QStringList() << "s" << QString::number(m_brightness) + "%");
    emit brightnessChanged();
}

QString ControlBackend::powerProfile() const { return m_powerProfile; }

void ControlBackend::setPowerProfile(const QString &profile)
{
    if (m_powerProfile == profile) return;
    m_powerProfile = profile;
    QProcess::startDetached("powerprofilesctl", QStringList() << "set" << profile);
    emit powerProfileChanged();
}

void ControlBackend::openModule(const QString &moduleName)
{
    // Try kcmshell6 first for direct module launch in KDE Plasma 6, fallback to systemsettings
    bool started = QProcess::startDetached("kcmshell6", QStringList() << moduleName);
    if (!started) {
        QProcess::startDetached("systemsettings", QStringList() << moduleName);
    }
}

void ControlBackend::openApp(const QString &appName)
{
    QProcess::startDetached(appName, QStringList());
}
