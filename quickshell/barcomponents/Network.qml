import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Item {
    id: network

    implicitWidth: networkRow.implicitWidth
    implicitHeight: 20

    // --- Live Wi-Fi signal strength via nmcli -------------------------
    // Quickshell's WifiNetwork.signalStrength goes stale because it is
    // derived from scan results, which pause while the panel is closed.
    // Polling nmcli gives a live value that matches Waybar.
    property real liveWifiSignal: 0

    Process {
        id: signalProc
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null | grep '^\\*' | cut -d: -f2"]
        running: false

        stdout: SplitParser {
            onRead: (line) => {
                const v = parseInt(line.trim())
                if (!isNaN(v)) network.liveWifiSignal = v / 100
                else network.liveWifiSignal = 0
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: signalProc.running = true
    }

    // --- Device access ------------------------------------------------
    readonly property var wiredDevice: {
        const devices = Networking.devices.values
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].type === DeviceType.Wired) return devices[i]
        }
        return null
    }

    readonly property var wifiDevice: {
        const devices = Networking.devices.values
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].type === DeviceType.Wifi) return devices[i]
        }
        return null
    }

    // --- Connection state ---------------------------------------------
    readonly property bool ethernetConnected: wiredDevice !== null && wiredDevice.connected
    readonly property bool wifiConnected: wifiDevice !== null && wifiDevice.connected
    readonly property bool wifiEnabled: Networking.wifiEnabled

    // --- Icon selection -----------------------------------------------
    // Priority: Ethernet > Wi-Fi > Disconnected
    // Papirus naming: no "-symbolic" suffix on panel icons; use
    // "signal-weak" instead of "signal-low".
    readonly property string iconName: {
        if (ethernetConnected) return "network-wired"

        if (wifiConnected) {
            if (liveWifiSignal > 0.75) return "network-wireless-signal-excellent"
            if (liveWifiSignal > 0.50) return "network-wireless-signal-good"
            if (liveWifiSignal > 0.25) return "network-wireless-signal-ok"
            return "network-wireless-signal-weak"
        }

        if (!wifiEnabled) return "network-wireless-offline"
        return "network-wireless-signal-none"
    }

    Row {
        id: networkRow
        anchors.centerIn: parent
        spacing: 4

        Image {
            id: networkIcon
            anchors.verticalCenter: parent.verticalCenter
            source: Quickshell.iconPath(network.iconName, true)
            sourceSize.width: 16
            sourceSize.height: 16
            width: 16
            height: 16
        }
    }

    // --- Interaction --------------------------------------------------
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                // Only toggle Wi-Fi when Ethernet is not the active link.
                if (!network.ethernetConnected && network.wifiDevice !== null) {
                    Networking.wifiEnabled = !Networking.wifiEnabled
                }
            } else if (mouse.button === Qt.RightButton) {
                Quickshell.execDetached(["nm-connection-editor"])
            }
        }
    }
}