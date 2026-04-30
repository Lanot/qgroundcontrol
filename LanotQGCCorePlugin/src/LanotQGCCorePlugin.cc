// src/LanotQGCCorePlugin.cpp

#include "LanotQGCCorePlugin.h"

#include <iostream>

#include "QGCLoggingCategory.h"

QGC_LOGGING_CATEGORY(LanotQGCCorePluginLog, "QGC.LanotQGCCorePlugin");

Q_APPLICATION_STATIC(LanotQGCCorePlugin, _secondaryVideoPluginInstance);

LanotQGCCorePlugin::LanotQGCCorePlugin(QObject *parent)
    : ::QGCCorePlugin(parent)
{
    std::cout << "\n\n\n\n\n\nSTARTED LanotQGCCorePlugin\n\n\n\n\n\n" << std::endl;
    qCDebug(LanotQGCCorePluginLog) << this;
}

QGCCorePlugin *LanotQGCCorePlugin::instance()
{
    return _secondaryVideoPluginInstance();
}

// QString LanotQGCCorePlugin::overrideFlyViewQmlSource() const {
//     return "qrc:/LanotQGCCorePlugin/MyFlyView.qml";
// }
