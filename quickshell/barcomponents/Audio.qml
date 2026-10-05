import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Item {
    id: audio

    implicitWidth: audioRow.implicitWidth
    implicitHeight: 20

    // --- Live volume and mute state via wpctl -------------------------
    property int liveVolume: 0
    property bool liveMuted: false

    Process {
        id: volumeProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: false

        stdout: SplitParser {
            onRead: (line) => {
                // Output format: "Volume: 0.45" or "Volume: 0.45 [MUTED]"
                const match = line.match(/Volume:\s*([\d.]+)/)
                if (match) {
                    audio.liveVolume = Math.round(parseFloat(match[1]) * 100)
                }
                audio.liveMuted = line.includes("[MUTED]")
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volumeProc.running = true
    }

    // --- Icon selection ----------------------------------------------
    // Tela theme icon names for audio.
    readonly property string iconName: {
        if (liveMuted) return "audio-volume-muted"
        if (liveVolume === 0) return "audio-volume-muted"
        if (liveVolume < 34) return "audio-volume-low"
        if (liveVolume < 67) return "audio-volume-medium"
        return "audio-volume-high"
    }

    Row {
        id: audioRow
        anchors.centerIn: parent
        spacing: 4

        Image {
            id: audioIcon
            anchors.verticalCenter: parent.verticalCenter
            source: Quickshell.iconPath(audio.iconName, true)
            sourceSize.width: 16
            sourceSize.height: 16
            width: 16
            height: 16
        }

        // Optional: show volume percentage. Remove this Text if you
        // prefer an icon-only display.
        //Text {
            //id: volumeText
            //anchors.verticalCenter: parent.verticalCenter
            //text: audio.liveMuted ? "--" : audio.liveVolume + "%"
            //color: audio.liveMuted ? "#6c7086" : "#cdd6f4"
            //font.pixelSize: 12
            //font.bold: true
        //}
    }

    // --- Interaction --------------------------------------------------
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                // Toggle mute.
                Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
                // Refresh immediately so the UI updates without waiting for the timer.
                refreshTimer.restart()
            } else if (mouse.button === Qt.RightButton) {
                // Open a graphical volume mixer.
                Quickshell.execDetached(["pavucontrol"])
            }
        }

        onWheel: (wheel) => {
            // Scroll up = increase volume, scroll down = decrease.
            const delta = wheel.angleDelta.y > 0 ? "5%+" : "5%-"
            Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", delta])
            // Refresh immediately so the UI updates without waiting for the timer.
            refreshTimer.restart()
        }
    }

    // A short timer to refresh state right after a user action, so the
    // icon and percentage update without waiting for the next 2s poll.
    Timer {
        id: refreshTimer
        interval: 80
        running: false
        repeat: false
        onTriggered: volumeProc.running = true
    }
}