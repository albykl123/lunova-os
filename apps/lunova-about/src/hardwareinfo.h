#ifndef HARDWAREINFO_H
#define HARDWAREINFO_H

#include <QObject>
#include <QString>

class HardwareInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString osVersion READ osVersion CONSTANT)
    Q_PROPERTY(QString debianBase READ debianBase CONSTANT)
    Q_PROPERTY(QString kernelVersion READ kernelVersion CONSTANT)
    Q_PROPERTY(QString plasmaVersion READ plasmaVersion CONSTANT)
    Q_PROPERTY(QString architecture READ architecture CONSTANT)
    Q_PROPERTY(QString cpuModel READ cpuModel CONSTANT)
    Q_PROPERTY(int cpuCores READ cpuCores CONSTANT)
    Q_PROPERTY(QString totalRam READ totalRam CONSTANT)
    Q_PROPERTY(QString gpuRenderer READ gpuRenderer CONSTANT)
    Q_PROPERTY(QString storageSize READ storageSize CONSTANT)
    Q_PROPERTY(QString licenseNotice READ licenseNotice CONSTANT)

public:
    explicit HardwareInfo(QObject *parent = nullptr);

    QString osVersion() const;
    QString debianBase() const;
    QString kernelVersion() const;
    QString plasmaVersion() const;
    QString architecture() const;
    QString cpuModel() const;
    int cpuCores() const;
    QString totalRam() const;
    QString gpuRenderer() const;
    QString storageSize() const;
    QString licenseNotice() const;

private:
    QString m_osVersion;
    QString m_debianBase;
    QString m_kernelVersion;
    QString m_plasmaVersion;
    QString m_architecture;
    QString m_cpuModel;
    int m_cpuCores;
    QString m_totalRam;
    QString m_gpuRenderer;
    QString m_storageSize;
    QString m_licenseNotice;

    void probeSystem();
};

#endif // HARDWAREINFO_H
