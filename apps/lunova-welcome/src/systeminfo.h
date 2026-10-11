#ifndef SYSTEMINFO_H
#define SYSTEMINFO_H

#include <QObject>
#include <QString>
#include <QProcess>

class SystemInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString osName READ osName CONSTANT)
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(QString codename READ codename CONSTANT)
    Q_PROPERTY(QString kernelRelease READ kernelRelease CONSTANT)
    Q_PROPERTY(QString hostname READ hostname CONSTANT)
    Q_PROPERTY(bool autostartEnabled READ autostartEnabled WRITE setAutostartEnabled NOTIFY autostartChanged)

public:
    explicit SystemInfo(QObject *parent = nullptr);

    QString osName() const;
    QString version() const;
    QString codename() const;
    QString kernelRelease() const;
    QString hostname() const;

    bool autostartEnabled() const;
    void setAutostartEnabled(bool enabled);

    Q_INVOKABLE void launchCommand(const QString &command);
    Q_INVOKABLE void openUrl(const QString &url);
    Q_INVOKABLE void switchTheme(bool dark);

signals:
    void autostartChanged();

private:
    QString m_osName;
    QString m_version;
    QString m_codename;
    QString m_kernelRelease;
    QString m_hostname;
    bool m_autostartEnabled;

    void loadSystemData();
};

#endif // SYSTEMINFO_H
