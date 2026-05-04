#pragma once

#include <QtCore/QTranslator>
#include <QtQml/QQmlAbstractUrlInterceptor>

#include "QGCCorePlugin.h"
#include "QGCOptions.h"
#include "QtCore/QLoggingCategory"

Q_DECLARE_LOGGING_CATEGORY(LanotPluginLog);


/* ================================================================================================================== */

class LanotPlugin : public QGCCorePlugin {
    Q_OBJECT
public:
    LanotPlugin(QObject *parent = nullptr);

    static LanotPlugin *instance();

    /// We override this so we can get access to QQmlApplicationEngine and use it to register our qml module
    QQmlApplicationEngine *createQmlApplicationEngine(QObject *parent) final;

private:
    QQmlApplicationEngine *_qmlEngine = nullptr;
    class LanotOverrideInterceptor *_selector = nullptr;
};


/* ================================================================================================================== */

class LanotOverrideInterceptor : public QQmlAbstractUrlInterceptor
{
public:
    LanotOverrideInterceptor();

    QUrl intercept(const QUrl &url, QQmlAbstractUrlInterceptor::DataType type) final;
};
