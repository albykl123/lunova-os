#ifndef CONTROLBACKEND_H
#define CONTROLBACKEND_H

#include <QObject>
#include <QString>
#include <QProcess>

class ControlBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(int brightness READ brightness WRITE setBrightness NOTIFY brightnessChanged)
    Q_PROPERTY(QString powerProfile READ powerProfile WRITE setPowerProfile NOTIFY powerProfileChanged)

public:
    explicit ControlBackend(QObject *parent = nullptr);

    int volume() const;
    void setVolume(int vol);

    int brightness() const;
    void setBrightness(int b);

    QString powerProfile() const;
    void setPowerProfile(const QString &profile);

    Q_INVOKABLE void openModule(const QString &moduleName);
    Q_INVOKABLE void openApp(const QString &appName);

signals:
    void volumeChanged();
    void brightnessChanged();
    void powerProfileChanged();

private:
    int m_volume;
    int m_brightness;
    QString m_powerProfile;

    void updateStatus();
};

#endif // CONTROLBACKEND_H
