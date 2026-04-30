#pragma once

#include "QGCCorePlugin.h"
#include <QtCore/QLoggingCategory>

Q_DECLARE_LOGGING_CATEGORY(LanotQGCCorePluginLog);

class LanotQGCCorePlugin : public QGCCorePlugin {
    Q_OBJECT
public:
    LanotQGCCorePlugin(QObject *parent = nullptr);

    static QGCCorePlugin *instance();

    // Override Fly View
    //QString overrideFlyViewQmlSource() const override;
};
