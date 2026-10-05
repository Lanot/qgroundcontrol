#include "VideoSettingsTest.h"

#include <QtCore/QScopeGuard>
#include <QtCore/QSettings>

#include "VideoSettings.h"

UT_REGISTER_TEST(VideoSettingsTest, TestLabel::Unit)

void VideoSettingsTest::_cameraMetadata()
{
    VideoSettings settings;
    QCOMPARE(settings.transparentVideoBackground()->rawDefaultValue().toBool(), false);
    QCOMPARE(settings.cameraDisplayMode()->rawDefaultValue().toUInt(), 0U);
    QCOMPARE(settings.cameraDisplayMode()->enumValues(), QVariantList({0U, 1U}));
    QCOMPARE(settings.numberOfCameras()->rawMin().toUInt(), 1U);
    QCOMPARE(settings.numberOfCameras()->rawMax().toUInt(), 4U);
    QCOMPARE(settings.cameraFact(QStringLiteral("videoSource"), 1), settings.videoSource());
    QVERIFY(!settings.cameraFact(QStringLiteral("videoSource"), 0));
    QVERIFY(!settings.cameraFact(QStringLiteral("videoSource"), 5));
    QVERIFY(!settings.cameraFact(QStringLiteral("unknown"), 1));
    for (int camera = 2; camera <= 4; ++camera) {
        Fact* source = settings.cameraFact(QStringLiteral("videoSource"), camera);
        QVERIFY(source);
        QCOMPARE(source->enumValues(), settings.videoSource()->enumValues());
        QCOMPARE(source->rawDefaultValue().toString(), QString(VideoSettings::videoDisabled));
        QCOMPARE(settings.cameraFact(QStringLiteral("udpUrl"), camera)->rawDefaultValue().toString(),
                 QStringLiteral("0.0.0.0:%1").arg(5599 + camera));
    }
}

void VideoSettingsTest::_independentConnectionsPersist()
{
    VideoSettings settings;
    Fact* first = settings.cameraFact(QStringLiteral("rtspUrl"), 1);
    Fact* second = settings.cameraFact(QStringLiteral("rtspUrl"), 2);
    const QVariant savedFirst = first->rawValue();
    const QVariant savedSecond = second->rawValue();
    const auto restore = qScopeGuard([&]() {
        first->setRawValue(savedFirst);
        second->setRawValue(savedSecond);
    });
    first->setRawValue(QStringLiteral("rtsp://192.0.2.1/first"));
    second->setRawValue(QStringLiteral("rtsp://192.0.2.2/second"));
    QCOMPARE(first->rawValue().toString(), QStringLiteral("rtsp://192.0.2.1/first"));
    QCOMPARE(second->rawValue().toString(), QStringLiteral("rtsp://192.0.2.2/second"));

    // SettingsFacts intentionally ignore saved values during unit tests; inspect their persisted keys directly.
    QSettings persisted;
    persisted.beginGroup(VideoSettings::settingsGroup);
    QCOMPARE(persisted.value(VideoSettings::rtspUrlName).toString(), QStringLiteral("rtsp://192.0.2.1/first"));
    QCOMPARE(persisted.value(VideoSettings::rtspUrl2Name).toString(), QStringLiteral("rtsp://192.0.2.2/second"));
}
