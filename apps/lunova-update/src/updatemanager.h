#ifndef UPDATEMANAGER_H
#define UPDATEMANAGER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QProcess>

class UpdateManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusChanged)
    Q_PROPERTY(bool isBusy READ isBusy NOTIFY isBusyChanged)
    Q_PROPERTY(int updateCount READ updateCount NOTIFY updateListChanged)
    Q_PROPERTY(QVariantList updates READ updates NOTIFY updateListChanged)
    Q_PROPERTY(int progressPercent READ progressPercent NOTIFY progressChanged)
    Q_PROPERTY(bool rebootRequired READ rebootRequired NOTIFY rebootRequiredChanged)

public:
    explicit UpdateManager(QObject *parent = nullptr);

    QString statusText() const;
    bool isBusy() const;
    int updateCount() const;
    QVariantList updates() const;
    int progressPercent() const;
    bool rebootRequired() const;

    Q_INVOKABLE void checkForUpdates();
    Q_INVOKABLE void applyUpdates();
    Q_INVOKABLE void rebootSystem();

signals:
    void statusChanged();
    void isBusyChanged();
    void updateListChanged();
    void progressChanged();
    void rebootRequiredChanged();

private slots:
    void onCheckFinished(int exitCode);
    void onInstallFinished(int exitCode);
    void onProcessOutput();

private:
    QString m_statusText;
    bool m_isBusy;
    QVariantList m_updates;
    int m_progressPercent;
    bool m_rebootRequired;

    QProcess *m_process;

    void parseAptOutput(const QString &output);
    void checkRebootRequired();
};

#endif // UPDATEMANAGER_H
