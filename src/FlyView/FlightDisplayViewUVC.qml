import QtQuick
import QtMultimedia

import QGroundControl

Rectangle {
    id:                 _root
    width:              parent.width
    height:             parent.height
    implicitWidth:      videoOutput.implicitWidth
    implicitHeight:     videoOutput.implicitHeight
    color:              QGroundControl.settingsManager.videoSettings.transparentVideoBackground.rawValue ? "transparent" : Qt.rgba(0,0,0,0.75)
    clip:               true
    anchors.centerIn:   parent
    visible:            _videoManager.isUvc

    property var _videoManager: QGroundControl.videoManager

    function adjustAspectRatio() {
        if (QGroundControl.settingsManager.videoSettings.numberOfCameras.rawValue > 1) {
            _root.height = Qt.binding(function() { return parent.height })
            return
        }
        //-- Set aspect ratio
        var resolution = camera.cameraFormat.resolution
        if (resolution.height > 0 && resolution.width > 0) {
            var aspectRatio = resolution.width / resolution.height
            _root.height = parent.height * aspectRatio
        }
    }

    MediaDevices {
        id: mediaDevices

        function findCameraDevice(cameraId) {
            var videoInputs = mediaDevices.videoInputs
            for (var i = 0; i < videoInputs.length; i++) {
                if (videoInputs[i].description === cameraId) {
                    return videoInputs[i]
                }
            }
            return mediaDevices.defaultVideoInput
        }
    }

    CaptureSession {
        camera: Camera {
            id:             camera
            cameraDevice:   mediaDevices.findCameraDevice(_videoManager.uvcVideoSourceID)
            active:         _videoManager.isUvc

            onCameraDeviceChanged: {
                if (active) {
                    adjustAspectRatio()
                }
            }

            onActiveChanged: {
                if (active) {
                    adjustAspectRatio()
                }
            }
        }
        videoOutput: videoOutput
    }

    VideoOutput {
        id:             videoOutput
        transform: Translate {
            y: QGroundControl.settingsManager.videoSettings.numberOfCameras.rawValue > 1 ? -Math.max(0, videoOutput.contentRect.y) : 0
        }
        anchors.fill:   parent
        fillMode:       VideoOutput.PreserveAspectCrop
    }
}
