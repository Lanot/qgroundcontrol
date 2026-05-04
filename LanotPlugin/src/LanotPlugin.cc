// src/LanotPlugin.cpp

#include "LanotPlugin.h"

#include "QmlComponentInfo.h"
#include "QGCLoggingCategory.h"
#include "QGCPalette.h"
#include "QGCMAVLink.h"
#include "AppSettings.h"

#include <QtCore/QApplicationStatic>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlFile>

#include <iostream>


QGC_LOGGING_CATEGORY(LanotPluginLog, "QGC.LanotPlugin");

Q_APPLICATION_STATIC(LanotPlugin, _LanotPlugin);

/* ================================================================================================================== */

LanotPlugin::LanotPlugin(QObject *parent)
    : ::QGCCorePlugin(parent)
{}

LanotPlugin *LanotPlugin::instance()
{
    return _LanotPlugin();
}

QQmlApplicationEngine* LanotPlugin::createQmlApplicationEngine(QObject* parent)
{
    _qmlEngine = QGCCorePlugin::createQmlApplicationEngine(parent);
    _qmlEngine->addImportPath("qrc:/qml/Lanot/Widgets");
    // TODO: Investigate _qmlEngine->setExtraSelectors({"custom"}) //@todo: remove it

    _selector = new LanotOverrideInterceptor();
    _qmlEngine->addUrlInterceptor(_selector);

    return _qmlEngine;
}


/* ================================================================================================================== */

LanotOverrideInterceptor::LanotOverrideInterceptor(): QQmlAbstractUrlInterceptor()
{}

QUrl LanotOverrideInterceptor::intercept(const QUrl &url, QQmlAbstractUrlInterceptor::DataType type)
{
    switch (type) {
        case QQmlAbstractUrlInterceptor::QmlFile:
        case QQmlAbstractUrlInterceptor::UrlString:
            if (url.scheme() == QStringLiteral("qrc")) {
                const QString origPath = url.path();
                const QString overrideRes = QStringLiteral(":/Lanot%1").arg(origPath);
                if (QFile::exists(overrideRes)) {
                    std::cout << "\noverride path from : " << origPath.toStdString() << std::endl; //@todo: remove it

                    const QString relPath = overrideRes.mid(2);
                    QUrl result;
                    result.setScheme(QStringLiteral("qrc"));
                    result.setPath('/' + relPath);
                    return result;
                }
            }
            break;
        default:
            break;
    }

    return url;
}
