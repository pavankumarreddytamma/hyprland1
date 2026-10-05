import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: brightness

    implicitWidth: brightnessRow.implicitWidth
    implicitHeight: 20

    // --- Live brightness percentage via brightnessctl ---
    property int liveBrightness: 0

    Process {
        id: brightnessProc
        // Extract the percentage inside parentheses from brightnessctl info
        command: ["sh", "-c", "brightnessctl -d amdgpu_bl1 info | grep -oP '\\(\\K[0-9]+(?=%)'"]
        running: false

        stdout: SplitParser {
            onRead: (line) => {
                const v = parseInt(line.trim())
                if (!isNaN(v)) brightness.liveBrightness = v
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: brightnessProc.running = true
    }

    readonly property string iconName: {
        if (liveBrightness < 10) return "brightness-display-low"
        if (liveBrightness < 60) return "brightness-display-medium"
        return "brightness-display-high"
    }

    Row {
        id: brightnessRow
        anchors.centerIn: parent
        spacing: 4

        Image {
            id: brightnessIcon
            anchors.verticalCenter: parent.verticalCenter
            source: Quickshell.iconPath(brightness.iconName, true)
            sourceSize.width: 16
            sourceSize.height: 16
            width: 16
            height: 16
        }

        //Text {
        //    id: brightnessText
        //    anchors.verticalCenter: parent.verticalCenter
        //    text: brightness.liveBrightness + "%"
        //    color: "#cdd6f4"
        //    font.pixelSize: 12
        //    font.bold: true
        //}
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onWheel: (wheel) => {
            const delta = wheel.angleDelta.y > 0 ? "5%+" : "5%-"
            Quickshell.execDetached(["brightnessctl", "-d", "amdgpu_bl1", "set", delta])
            refreshTimer.restart()
        }
    }

    Timer {
        id: refreshTimer
        interval: 80
        running: false
        repeat: false
        onTriggered: brightnessProc.running = true
    }
}
