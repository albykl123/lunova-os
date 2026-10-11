#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QtGlobal>
#include "systeminfo.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QApplication app(argc, argv);

    app.setApplicationName("Lunova Welcome");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("LunovaOS");
    app.setWindowIcon(QIcon(":/icons/lunova-icon.svg"));

    qmlRegisterType<SystemInfo>("Lunova.System", 1, 0, "SystemInfo");

    QQmlApplicationEngine engine;
    SystemInfo sysInfo;
    engine.rootContext()->setContextProperty("systemInfo", &sysInfo);

    const QUrl url(QStringLiteral("qrc:/qml/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
