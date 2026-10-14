#include "hardwareinfo.h"
#include <QFile>
#include <QTextStream>
#include <QProcess>
#include <QStorageInfo>
#include <sys/utsname.h>
#include <sys/sysinfo.h>

HardwareInfo::HardwareInfo(QObject *parent)
    : QObject(parent), m_cpuCores(1)
{
    probeSystem();
}

void HardwareInfo::probeSystem()
{
    m_osVersion = "Lunova OS 1.0.1 Aurora";
    m_debianBase = "Debian GNU/Linux 13 (Trixie)";
    m_licenseNotice = "Lunova OS components are licensed under GPLv3, LGPLv3, and MIT. Based on Debian GNU/Linux.";

    // 1. Architecture and Kernel Release
    struct utsname buf;
    if (uname(&buf) == 0) {
        m_kernelVersion = QString::fromLatin1(buf.release);
        m_architecture = QString::fromLatin1(buf.machine);
    } else {
        m_kernelVersion = "Linux 6.12.0-amd64";
        m_architecture = "x86_64";
    }

    // 2. CPU Probe via /proc/cpuinfo
    QFile cpuFile("/proc/cpuinfo");
    if (cpuFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&cpuFile);
        int cores = 0;
        while (!in.atEnd()) {
            QString line = in.readLine();
            if (line.startsWith("model name") && m_cpuModel.isEmpty()) {
                QStringList parts = line.split(":");
                if (parts.size() > 1) {
                    m_cpuModel = parts[1].trimmed();
                }
            }
            if (line.startsWith("processor")) {
                cores++;
            }
        }
        if (cores > 0) m_cpuCores = cores;
        cpuFile.close();
    }
    if (m_cpuModel.isEmpty()) {
        m_cpuModel = "x86-64 Compatible Processor";
    }

    // 3. RAM Probe via /proc/meminfo or sysinfo
    struct sysinfo s_info;
    if (sysinfo(&s_info) == 0) {
        double totalGb = (double)s_info.totalram * s_info.mem_unit / (1024.0 * 1024.0 * 1024.0);
        m_totalRam = QString::number(totalGb, 'f', 1) + " GB RAM";
    } else {
        m_totalRam = "8.0 GB RAM";
    }

    // 4. Storage Probe via QStorageInfo
    QStorageInfo rootStorage = QStorageInfo::root();
    if (rootStorage.isValid()) {
        double totalGb = (double)rootStorage.bytesTotal() / (1024.0 * 1024.0 * 1024.0);
        double freeGb = (double)rootStorage.bytesAvailable() / (1024.0 * 1024.0 * 1024.0);
        m_storageSize = QString("%1 GB total (%2 GB available)")
                        .arg(QString::number(totalGb, 'f', 1))
                        .arg(QString::number(freeGb, 'f', 1));
    } else {
        m_storageSize = "64.0 GB Root Storage";
    }

    // 5. Plasma Version Check
    QProcess plasmaProc;
    plasmaProc.start("plasmashell", QStringList() << "--version");
    if (plasmaProc.waitForFinished(1000)) {
        QString out = QString::fromUtf8(plasmaProc.readAllStandardOutput()).trimmed();
        if (!out.isEmpty()) {
            m_plasmaVersion = out.replace("plasmashell ", "KDE Plasma ");
        } else {
            m_plasmaVersion = "KDE Plasma 6.3+";
        }
    } else {
        m_plasmaVersion = "KDE Plasma 6.3+";
    }

    // 6. GPU Probe via lspci (structured process execution without shell)
    m_gpuRenderer = "Mesa / Generic KMS Acceleration";
    QProcess lspciProc;
    lspciProc.start("lspci", QStringList());
    if (lspciProc.waitForFinished(1000)) {
        QString gpuOut = QString::fromUtf8(lspciProc.readAllStandardOutput());
        const QStringList lines = gpuOut.split('\n');
        for (const QString &line : lines) {
            if (line.contains("vga", Qt::CaseInsensitive) ||
                line.contains("3d", Qt::CaseInsensitive) ||
                line.contains("display", Qt::CaseInsensitive)) {
                QStringList parts = line.split(':');
                if (parts.size() >= 3) {
                    m_gpuRenderer = parts[2].trimmed();
                } else {
                    m_gpuRenderer = line.trimmed();
                }
                break;
            }
        }
    }
}

QString HardwareInfo::osVersion() const { return m_osVersion; }
QString HardwareInfo::debianBase() const { return m_debianBase; }
QString HardwareInfo::kernelVersion() const { return m_kernelVersion; }
QString HardwareInfo::plasmaVersion() const { return m_plasmaVersion; }
QString HardwareInfo::architecture() const { return m_architecture; }
QString HardwareInfo::cpuModel() const { return m_cpuModel; }
int HardwareInfo::cpuCores() const { return m_cpuCores; }
QString HardwareInfo::totalRam() const { return m_totalRam; }
QString HardwareInfo::gpuRenderer() const { return m_gpuRenderer; }
QString HardwareInfo::storageSize() const { return m_storageSize; }
QString HardwareInfo::licenseNotice() const { return m_licenseNotice; }
