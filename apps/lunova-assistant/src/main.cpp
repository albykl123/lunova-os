#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QtGlobal>
#include "assistantbackend.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QApplication app(argc, argv);

    app.setApplicationName("Lunova Assistant");
    app.setApplicationVersion("1.0.2");
    app.setOrganizationName("LunovaOS");
    app.setWindowIcon(QIcon(":/icons/lunova-icon.svg"));

    QQmlApplicationEngine engine;
    AssistantBackend backend;
    engine.rootContext()->setContextProperty("assistantBackend", &backend);

    const QUrl url(QStringLiteral("qrc:/qml/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
