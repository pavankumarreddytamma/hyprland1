//@ pragma IconTheme Papirus

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "barcomponents"
import "components"

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 32
            color: Qt.rgba(0, 0, 0, 0.6)
            exclusionMode: ExclusionMode.Auto

            // Left section: workspaces
            RowLayout {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 8
                }
                spacing: 8

                Workspaces {}
            }

            // Center section: clock
            Clock {
                anchors.centerIn: parent
            }

            // Right section: system modules
            RowLayout {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: 8
                }
                spacing: 8

                Network {}
                Audio {}
                Brightness {}
                Battery {}
            }
        }
    }

    // App launcher: created on demand, destroyed when closed
    Loader {
        id: launcherLoader
        active: false
        source: "components/AppLauncher.qml"
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            launcherLoader.active = !launcherLoader.active
        }

        function open(): void {
            launcherLoader.active = true
        }

        function close(): void {
            launcherLoader.active = false
        }
    }

    NotificationPopup {}

}