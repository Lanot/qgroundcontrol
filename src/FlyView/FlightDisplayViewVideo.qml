import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtMultimedia

import QGroundControl
import QGroundControl.FlyView
import QGroundControl.FlightMap
import QGroundControl.Controls

Item {
    id:     root
    clip:   true
    objectName: "cameraVideoView"

    property bool useSmallFont: true
    property bool mainVideoLayout: false
    property Item resizeOverlayParent: root
    property real previewWidthRatio: Math.max(1, _cameraCount - 1) * 0.16
    property real previewHeightRatio: -1
    readonly property real _previewRowWidth: Math.min(width * 0.98, Math.max(width * 0.1, width * previewWidthRatio))
    readonly property real _thumbnailHeight: mainVideoLayout && _cameraCount > 1
        ? Math.min(height * 0.5, Math.max(height * 0.05, previewHeightRatio < 0
            ? Math.min(height * 0.2, _previewRowWidth / (_cameraCount - 1) * 9 / 16)
            : height * previewHeightRatio)) : 0
    readonly property real _thumbnailWidth: _previewRowWidth / Math.max(1, _cameraCount - 1)

    function resizePreviewRow(rowWidth, rowHeight) {
        if (width <= 0 || height <= 0) return
        previewWidthRatio = Math.max(0.1, Math.min(0.98, rowWidth / width))
        previewHeightRatio = Math.max(0.05, Math.min(0.5, rowHeight / height))
    }

    function tileWidth(cameraNumber) {
        return mainVideoLayout ? (cameraNumber === 1 ? width : _thumbnailWidth) : width / _columns
    }
    function tileHeight(cameraNumber) {
        return mainVideoLayout ? (cameraNumber === 1 ? height - _thumbnailHeight : _thumbnailHeight) : height / _rows
    }
    function tileX(cameraNumber) {
        if (mainVideoLayout) {
            return cameraNumber === 1 ? 0 : (width - (_cameraCount - 1) * _thumbnailWidth) / 2 + (cameraNumber - 2) * _thumbnailWidth
        }
        return (cameraNumber - 1) % _columns * tileWidth(cameraNumber)
    }
    function tileY(cameraNumber) {
        return mainVideoLayout ? (cameraNumber === 1 ? 0 : height - _thumbnailHeight) : Math.floor((cameraNumber - 1) / _columns) * tileHeight(cameraNumber)
    }
    readonly property var _videoSettings: QGroundControl.settingsManager.videoSettings
    readonly property int _cameraCount: _videoSettings.numberOfCameras.rawValue
    readonly property bool _listMode: _videoSettings.cameraDisplayMode.rawValue === 1
    readonly property int _columns: _listMode ? _cameraCount : (_cameraCount > 1 ? 2 : 1)
    readonly property int _rows: _listMode ? 1 : (_cameraCount > 2 ? 2 : 1)
    readonly property color videoBackgroundColor: _videoSettings.transparentVideoBackground.rawValue ? "transparent" : "black"
    property alias primaryVideoItem: primaryTile

    property double _ar:                (cameraLoader.visible && cameraLoader.status === Loader.Ready)
                                            ? cameraLoader.item.implicitWidth / cameraLoader.item.implicitHeight
                                            : QGroundControl.videoManager.aspectRatio
    property bool   _showGrid:          QGroundControl.settingsManager.videoSettings.gridLines.rawValue
    property var    _dynamicCameras:    globals.activeVehicle ? globals.activeVehicle.cameraManager : null
    property bool   _connected:         globals.activeVehicle ? !globals.activeVehicle.communicationLost : false
    property int    _curCameraIndex:    _dynamicCameras ? _dynamicCameras.currentCamera : 0
    property bool   _isCamera:          _dynamicCameras ? _dynamicCameras.cameras.count > 0 : false
    property var    _camera:            _isCamera ? _dynamicCameras.cameras.get(_curCameraIndex) : null
    property bool   _hasZoom:           _camera && _camera.hasZoom
    property int    _fitMode:           QGroundControl.settingsManager.videoSettings.videoFit.rawValue
    property bool   _showStreamLoader:  QGroundControl.videoManager.decoding
    property bool   _showUvcLoader:     QGroundControl.videoManager.isUvc

    property bool   _isMode_FIT_WIDTH:  _fitMode === 0
    property bool   _isMode_FIT_HEIGHT: _fitMode === 1
    property bool   _isMode_FILL:       _fitMode === 2
    property bool   _isMode_NO_CROP:    _fitMode === 3

    function getWidth() {
        return videoBackground.getWidth()
    }
    function getHeight() {
        return videoBackground.getHeight()
    }

    property double _thermalHeightFactor: 0.85 //-- TODO

    Item {
        id: primaryTile
        objectName: "cameraTile1"
        width: primaryWindow.detached ? parent.width : root.tileWidth(1)
        height: primaryWindow.detached ? parent.height : root.tileHeight(1)
        clip: true

        CameraWindowButton { windowControl: primaryWindow }
        QGCLabel {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: ScreenTools.defaultFontPixelWidth
            visible: root._cameraCount > 1 || primaryWindow.detached
            text: qsTr("Camera #1")
            z: 10
        }

        Image {
            id:             noVideo
            anchors.fill:   parent
            source:         "/res/NoVideoBackground.jpg"
            fillMode:       Image.PreserveAspectCrop
            visible:        !_showStreamLoader && !_showUvcLoader && !root._videoSettings.transparentVideoBackground.rawValue

            Rectangle {
                anchors.centerIn:   parent
                width:              noVideoLabel.contentWidth + ScreenTools.defaultFontPixelHeight
                height:             noVideoLabel.contentHeight + ScreenTools.defaultFontPixelHeight
                radius:             ScreenTools.defaultFontPixelWidth / 2
                color:              "black"
                opacity:            0.5
            }

            QGCLabel {
                id:                 noVideoLabel
                text:               QGroundControl.settingsManager.videoSettings.streamEnabled.rawValue ? qsTr("WAITING FOR VIDEO") : qsTr("VIDEO DISABLED")
                font.bold:          true
                color:              "white"
                font.pointSize:     useSmallFont ? ScreenTools.smallFontPointSize : ScreenTools.largeFontPointSize
                anchors.centerIn:   parent
            }
        }

    Rectangle {
        id:             videoBackground
        anchors.fill:   parent
        color:          root.videoBackgroundColor
        visible:        _showStreamLoader || _showUvcLoader
        function getWidth() {
            if (root._cameraCount > 1) {
                return primaryTile.width
            }
            if(_ar != 0.0){
                if(_isMode_FIT_HEIGHT
                        || (_isMode_FILL && (primaryTile.width/primaryTile.height < _ar))
                        || (_isMode_NO_CROP && (primaryTile.width/primaryTile.height > _ar))){
                    // This return value has different implications depending on the mode
                    // For FIT_HEIGHT and FILL
                    //    makes so the video width will be larger than (or equal to) the screen width
                    // For NO_CROP Mode
                    //    makes so the video width will be smaller than (or equal to) the screen width
                    return primaryTile.height * _ar
                }
            }
            return primaryTile.width
        }
        function getHeight() {
            if (root._cameraCount > 1) {
                return primaryTile.height
            }
            if(_ar != 0.0){
                if(_isMode_FIT_WIDTH
                        || (_isMode_FILL && (primaryTile.width/primaryTile.height > _ar))
                        || (_isMode_NO_CROP && (primaryTile.width/primaryTile.height < _ar))){
                    // This return value has different implications depending on the mode
                    // For FIT_WIDTH and FILL
                    //    makes so the video height will be larger than (or equal to) the screen height
                    // For NO_CROP Mode
                    //    makes so the video height will be smaller than (or equal to) the screen height
                    return primaryTile.width * (1 / _ar)
                }
            }
            return primaryTile.height
        }
        Loader {
            id:                 videoStreamLoader
            anchors.fill:       videoContentArea
            visible:            _showStreamLoader
            sourceComponent:    videoOutputComponent

            property bool videoDisabled: QGroundControl.settingsManager.videoSettings.videoSource.rawValue === QGroundControl.settingsManager.videoSettings.disabledVideoSource
        }
        Component {
            id: videoOutputComponent
            FlightDisplayViewVideoOutput {
                alignTop: !root.mainVideoLayout && root._cameraCount > 1
            }
        }
        //-- UVC Video (USB Camera or Video Device)
        Loader {
            id:             cameraLoader
            anchors.fill:   videoContentArea
            visible:        _showUvcLoader
            source:         _showUvcLoader ? "qrc:/qml/QGroundControl/FlyView/FlightDisplayViewUVC.qml" : "qrc:/qml/QGroundControl/FlyView/FlightDisplayViewDummy.qml"
        }

        Item {
            id:                 videoContentArea
            objectName:         "primaryVideoContentArea"
            height:             parent.getHeight()
            width:              parent.getWidth()
            anchors.centerIn:   parent
            visible:           _showStreamLoader || _showUvcLoader

            // grid lines
            Item {
                anchors.fill:   parent
                visible:        _showGrid && !QGroundControl.videoManager.fullScreen

                Rectangle {
                    color:  Qt.rgba(1,1,1,0.5)
                    height: parent.height
                    width:  1
                    x:      parent.width * 0.33
                }
                Rectangle {
                    color:  Qt.rgba(1,1,1,0.5)
                    height: parent.height
                    width:  1
                    x:      parent.width * 0.66
                }
                Rectangle {
                    color:  Qt.rgba(1,1,1,0.5)
                    width:  parent.width
                    height: 1
                    y:      parent.height * 0.33
                }
                Rectangle {
                    color:  Qt.rgba(1,1,1,0.5)
                    width:  parent.width
                    height: 1
                    y:      parent.height * 0.66
                }
            }
        }

        //-- Thermal Image
        Item {
            id:                 thermalItem
            width:              height * QGroundControl.videoManager.thermalAspectRatio
            height:             _camera ? (_camera.thermalMode === MavlinkCameraControlInterface.THERMAL_FULL ? parent.height : (_camera.thermalMode === MavlinkCameraControlInterface.THERMAL_PIP ? ScreenTools.defaultFontPixelHeight * 12 : parent.height * _thermalHeightFactor)) : 0
            anchors.centerIn:   parent
            visible:            QGroundControl.videoManager.hasThermal && _camera && _camera.thermalMode !== MavlinkCameraControlInterface.THERMAL_OFF
            function pipOrNot() {
                if(_camera) {
                    if(_camera.thermalMode === MavlinkCameraControlInterface.THERMAL_PIP) {
                        anchors.centerIn    = undefined
                        anchors.top         = parent.top
                        anchors.topMargin   = mainWindow.header.height + (ScreenTools.defaultFontPixelHeight * 0.5)
                        anchors.left        = parent.left
                        anchors.leftMargin  = ScreenTools.defaultFontPixelWidth * 12
                    } else {
                        anchors.top         = undefined
                        anchors.topMargin   = undefined
                        anchors.left        = undefined
                        anchors.leftMargin  = undefined
                        anchors.centerIn    = parent
                    }
                }
            }
            Connections {
                target:                 _camera
                function onThermalModeChanged() { thermalItem.pipOrNot() }
            }
            onVisibleChanged: {
                thermalItem.pipOrNot()
            }
            Loader {
                id:             thermalVideo
                anchors.fill:   parent
                opacity:        _camera ? (_camera.thermalMode === MavlinkCameraControlInterface.THERMAL_BLEND ? _camera.thermalOpacity / 100 : 1.0) : 0
                sourceComponent: thermalOutputComponent
                onLoaded: { if (item) item.objectName = "thermalVideo" }

                Component {
                    id: thermalOutputComponent
                    FlightDisplayViewVideoOutput {}
                }
            }
        }
        //-- Zoom
        PinchArea {
            id:             pinchZoom
            enabled:        _hasZoom
            anchors.fill:   parent
            onPinchStarted: pinchZoom.zoom = 0
            onPinchUpdated: {
                if(_hasZoom) {
                    var z = 0
                    if(pinch.scale < 1) {
                        z = Math.round(pinch.scale * -10)
                    } else {
                        z = Math.round(pinch.scale)
                    }
                    if(pinchZoom.zoom != z) {
                        _camera.stepZoom(z)
                    }
                }
            }
            property int zoom: 0
        }
    }
    }

    component CameraWindow: Window {
        id: cameraWindow
        required property int cameraNumber
        required property Item videoItem
        required property Item homeParent
        property bool detached: false
        objectName: "cameraWindow" + cameraNumber
        title: qsTr("QGroundControl — Camera #%1").arg(cameraNumber)
        flags: Qt.Window
        transientParent: null
        color: root.videoBackgroundColor
        width: ScreenTools.defaultFontPixelHeight * 48
        height: ScreenTools.defaultFontPixelHeight * 27
        minimumWidth: ScreenTools.defaultFontPixelHeight * 12
        minimumHeight: ScreenTools.defaultFontPixelHeight * 8
        visible: false

        function popOut() {
            if (detached || ScreenTools.isMobile) {
                return
            }
            QGroundControl.videoManager.pauseCameraVideo(cameraNumber)
            detached = true
            videoItem.parent = contentItem
            show()
            resumeTimer.restart()
        }

        function dock() {
            if (!detached) {
                return
            }
            QGroundControl.videoManager.pauseCameraVideo(cameraNumber)
            detached = false
            videoItem.parent = homeParent
            hide()
            resumeTimer.restart()
        }

        onClosing: dock()
        Timer {
            id: resumeTimer
            // Match the existing native video window's graphics-context transition delay.
            interval: 2000
            onTriggered: QGroundControl.videoManager.resumeCameraVideo(cameraWindow.cameraNumber)
        }
        Connections {
            target: root._videoSettings.numberOfCameras
            function onRawValueChanged() {
                if (cameraWindow.cameraNumber > root._cameraCount) {
                    cameraWindow.dock()
                }
            }
        }
    }

    component CameraWindowButton: ToolButton {
        id: windowControlButton
        required property var windowControl
        objectName: "cameraWindowButton" + windowControl.cameraNumber
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: ScreenTools.defaultFontPixelWidth
        visible: !ScreenTools.isMobile && (root.mainVideoLayout || windowControl.detached)
        z: 100
        width: ScreenTools.defaultFontPixelHeight * 1.6
        height: width
        padding: ScreenTools.defaultFontPixelWidth * 0.3
        hoverEnabled: true
        Accessible.name: windowControl.detached ? qsTr("Return video to main window") : qsTr("Open video in separate window")
        ToolTip.visible: hovered
        ToolTip.text: Accessible.name
        ToolTip.delay: 600
        background: Rectangle {
            radius: ScreenTools.defaultFontPixelWidth * 0.4
            color: Qt.rgba(0, 0, 0, windowControlButton.hovered || windowControlButton.pressed ? 0.65 : 0.3)
            border.width: windowControlButton.activeFocus ? 1 : 0
            border.color: "white"
        }
        contentItem: Image {
            source: windowControlButton.windowControl.detached ? "/res/camera-dock.svg" : "/res/camera-undock.svg"
            fillMode: Image.PreserveAspectFit
            sourceSize.width: width
            sourceSize.height: height
        }
        onClicked: windowControl.detached ? windowControl.dock() : windowControl.popOut()
    }

    component DetachedPlaceholder: Item {
        required property var windowControl
        readonly property int cameraNumber: windowControl.cameraNumber
        objectName: "cameraPlaceholder" + cameraNumber
        visible: windowControl.detached && cameraNumber <= root._cameraCount
        x: root.tileX(cameraNumber)
        y: root.tileY(cameraNumber)
        width: root.tileWidth(cameraNumber)
        height: root.tileHeight(cameraNumber)
        Image {
            anchors.fill: parent
            source: "/res/NoVideoBackground.jpg"
            visible: !root._videoSettings.transparentVideoBackground.rawValue
            fillMode: Image.PreserveAspectCrop
        }
        QGCLabel {
            anchors.centerIn: parent
            text: qsTr("Camera #%1 in separate window").arg(parent.cameraNumber)
            wrapMode: Text.WordWrap
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }
        CameraWindowButton { windowControl: parent.windowControl }
    }

    CameraWindow {
        id: primaryWindow
        cameraNumber: 1
        videoItem: primaryTile
        homeParent: root
    }
    DetachedPlaceholder { windowControl: primaryWindow }

    // Receiver lookup follows QObject ownership; Repeater delegates are not window children.
    component CameraTile: Item {
        id: cameraTile
        required property int cameraNumber
        objectName: "cameraTile" + cameraNumber
        readonly property string sourceName: root._videoSettings.cameraFact("videoSource", cameraNumber).rawValue
        readonly property bool enabledCamera: cameraNumber <= root._cameraCount
            && root._videoSettings.streamEnabled.rawValue
            && !(root._videoSettings.disableWhenDisarmed.rawValue && globals.activeVehicle && !globals.activeVehicle.armed)
        readonly property var usbDevice: {
            const inputs = cameraDevices.videoInputs
            for (let i = 0; i < inputs.length; ++i) {
                if (inputs[i].description === sourceName) {
                    return inputs[i]
                }
            }
            return null
        }
        x: cameraWindow.detached ? 0 : root.tileX(cameraNumber)
        y: cameraWindow.detached ? 0 : root.tileY(cameraNumber)
        width: cameraWindow.detached ? parent.width : root.tileWidth(cameraNumber)
        height: cameraWindow.detached ? parent.height : root.tileHeight(cameraNumber)
        visible: cameraNumber <= root._cameraCount
        clip: true

        CameraWindow {
            id: cameraWindow
            cameraNumber: cameraTile.cameraNumber
            videoItem: cameraTile
            homeParent: root
        }
        CameraWindowButton { windowControl: cameraWindow }
        DetachedPlaceholder {
            parent: root
            windowControl: cameraWindow
        }

        Rectangle {
            anchors.fill: parent
            color: root.videoBackgroundColor
        }
        FlightDisplayViewVideoOutput {
            objectName: "cameraVideo" + cameraTile.cameraNumber
            anchors.fill: parent
            visible: !cameraTile.usbDevice
        }
        MediaDevices { id: cameraDevices }
        CaptureSession {
            camera: Camera {
                cameraDevice: cameraTile.usbDevice ? cameraTile.usbDevice : cameraDevices.defaultVideoInput
                active: cameraTile.enabledCamera && cameraTile.usbDevice !== null
            }
            videoOutput: usbOutput
        }
        VideoOutput {
            id: usbOutput
            transform: Translate { y: -Math.max(0, usbOutput.contentRect.y) }
            anchors.fill: parent
            visible: cameraTile.usbDevice !== null
            fillMode: VideoOutput.PreserveAspectFit
        }
        QGCLabel {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: ScreenTools.defaultFontPixelWidth
            text: qsTr("Camera #%1").arg(cameraTile.cameraNumber)
        }
    }

    Item {
        id: previewRowControls
        objectName: "cameraPreviewRow"
        parent: root.resizeOverlayParent
        visible: root.mainVideoLayout && root._cameraCount > 1
        x: root.mapToItem(parent, (root.width - width) / 2, root.height - height).x
        y: root.mapToItem(parent, (root.width - width) / 2, root.height - height).y
        width: root._previewRowWidth
        height: root._thumbnailHeight
        z: 200

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(0.8, 0.8, 0.8, 0.6)
        }
        component ResizeHandle: MouseArea {
            // 0: width, 1: height, 2: proportional corner.
            required property int resizeMode
            preventStealing: true
            cursorShape: resizeMode === 0 ? Qt.SizeHorCursor : (resizeMode === 1 ? Qt.SizeVerCursor : Qt.SizeBDiagCursor)
            property real startX
            property real startY
            property real startWidth
            property real startHeight
            onPressed: (mouse) => {
                var point = mapToItem(root, mouse.x, mouse.y)
                startX = point.x
                startY = point.y
                startWidth = previewRowControls.width
                startHeight = previewRowControls.height
            }
            onPositionChanged: (mouse) => {
                if (!pressed) return
                var point = mapToItem(root, mouse.x, mouse.y)
                if (resizeMode === 1) {
                    root.resizePreviewRow(startWidth, startHeight + startY - point.y)
                } else {
                    var newWidth = Math.max(root.width * 0.1, Math.min(root.width * 0.98, startWidth + 2 * (point.x - startX)))
                    if (resizeMode === 2) {
                        newWidth = Math.max(root.height * 0.05 * startWidth / startHeight,
                            Math.min(root.height * 0.5 * startWidth / startHeight, newWidth))
                    }
                    root.resizePreviewRow(newWidth, resizeMode === 2 ? startHeight * newWidth / startWidth : startHeight)
                }
            }
        }
        ResizeHandle {
            objectName: "cameraPreviewWidthHandle"
            resizeMode: 0
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: ScreenTools.defaultFontPixelWidth
            height: Math.max(ScreenTools.defaultFontPixelHeight, parent.height - ScreenTools.defaultFontPixelHeight * 4)
        }
        ResizeHandle {
            objectName: "cameraPreviewHeightHandle"
            resizeMode: 1
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.max(0, parent.width - ScreenTools.defaultFontPixelHeight * 4)
            height: ScreenTools.defaultFontPixelWidth
        }
        ResizeHandle {
            objectName: "cameraPreviewCornerHandle"
            resizeMode: 2
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: ScreenTools.defaultFontPixelHeight * 1.5
            height: width
            Image {
                anchors.fill: parent
                anchors.margins: 2
                source: "/qmlimages/pipResize.svg"
                fillMode: Image.PreserveAspectFit
                rotation: 90
            }
        }
    }

    CameraTile { cameraNumber: 2 }
    CameraTile { cameraNumber: 3 }
    CameraTile { cameraNumber: 4 }
}
