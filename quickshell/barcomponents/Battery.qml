import QtQuick
import Quickshell
import Quickshell.Services.UPower

Item {
    id: battery

    implicitWidth: batteryRow.implicitWidth
    implicitHeight: 20

    // --- UPower device ---
    // displayDevice is the aggregate device UPower reports for the system.
    // It may not be ready immediately on launch, so we check .ready [citation:3][citation:10].
    readonly property var device: UPower.displayDevice
    readonly property bool available: device && device.ready && device.isLaptopBattery

    readonly property int percent: available ? Math.round(device.percentage * 100) : 0

    readonly property bool charging: available && (device.state === UPowerDeviceState.Charging
                                                   || device.state === UPowerDeviceState.FullyCharged)

    readonly property bool full: available && device.state === UPowerDeviceState.FullyCharged

    // --- Icon selection ---
    // Use UPower's own iconName when available; fall back to percentage tiers.
    readonly property string iconName: {
        if (!available) return "battery-missing-symbolic"
        if (device.iconName && device.iconName !== "") return device.iconName

        // Fallback tiers if UPower provides no icon name
        if (charging) {
            if (percent >= 90) return "battery-full-charging-symbolic"
            if (percent >= 60) return "battery-good-charging-symbolic"
            return "battery-low-charging-symbolic"
        }
        if (percent >= 90) return "battery-full-symbolic"
        if (percent >= 60) return "battery-good-symbolic"
        if (percent >= 20) return "battery-low-symbolic"
        return "battery-caution-symbolic"
    }

    Row {
        id: batteryRow
        anchors.centerIn: parent
        spacing: 4

        Image {
            id: batteryIcon
            anchors.verticalCenter: parent.verticalCenter
            source: Quickshell.iconPath(battery.iconName, true)
            sourceSize.width: 16
            sourceSize.height: 16
            width: 16
            height: 16
        }

        Text {
            id: batteryText
            anchors.verticalCenter: parent.verticalCenter
            text: battery.available ? battery.percent + "%" : "--"
            color: battery.available ? Qt.rgba(255, 255, 255, 0.9) : "#6c7086"
            font.pixelSize: 12
            font.bold: true
        }
    }
}