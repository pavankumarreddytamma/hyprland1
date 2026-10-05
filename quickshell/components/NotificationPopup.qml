import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: notificationRoot
        required property var modelData
        screen: modelData

        // =============================================================
        // WINDOW SETUP
        // Anchored to the top-right corner. The window's height
        // is fixed, but a mask limits input to just the popup area.
        // =============================================================
        anchors {
            top: true
            right: true
        }

        implicitWidth: 380
        implicitHeight: 700

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        mask: Region {
            item: popupList
        }

        // =============================================================
        // NOTIFICATION SERVER
        // =============================================================
        NotificationServer {
            id: server
            keepOnReload: true
            bodySupported: true
            bodyMarkupSupported: true
            imageSupported: true
            actionsSupported: true
        }

        Connections {
            target: server
            function onNotification(notification) {
                notification.tracked = true
            }
        }

        // =============================================================
        // POPUP LIST
        // Positioned below the bar. Bar height is 32px, plus 12px
        // gap so the first card doesn't touch the bar's bottom edge.
        // =============================================================
        Column {
            id: popupList
            anchors {
                top: parent.top
                right: parent.right
                topMargin: 44   // 32 (bar height) + 12 (gap)
                rightMargin: 12
            }
            spacing: 10
            width: 360

            Repeater {
                model: server.trackedNotifications

                delegate: Rectangle {
                    id: notificationCard
                    required property var modelData

                    width: popupList.width
                    height: contentLayout.implicitHeight + 24
                    radius: 12
                    color: Qt.rgba(0, 0, 0, 1)
                    border.width: 2

                    // -------------------------------------------------
                    // URGENCY COLOR
                    // -------------------------------------------------
                    property string urgencyColor: {
                        if (modelData.urgency === NotificationUrgency.Critical) return "#ff2f6a"
                        if (modelData.urgency === NotificationUrgency.Low) return "#6c7086"
                        return Qt.rgba(255, 255, 255, 1)
                    }
                    border.color: urgencyColor
                    clip: true

                    // -------------------------------------------------
                    // ENTRY ANIMATION STATE
                    // Card starts invisible and offset to the right.
                    // On completion, it animates to opacity 1 and x 0.
                    // -------------------------------------------------
                    opacity: 0
                    property real slideX: 40
                    x: slideX

                    Component.onCompleted: entryAnim.start()

                    ParallelAnimation {
                        id: entryAnim

                        NumberAnimation {
                            target: notificationCard
                            property: "slideX"
                            from: 40
                            to: 0
                            duration: 320
                            easing.type: Easing.OutQuint
                        }

                        NumberAnimation {
                            target: notificationCard
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 240
                            easing.type: Easing.OutCubic
                        }
                    }

                    // -------------------------------------------------
                    // HOVER STATE
                    // Slight scale and color change on mouse hover.
                    // -------------------------------------------------
                    property bool hovered: false

                    Behavior on color {
                        ColorAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    scale: hovered ? 1.01 : 1.0

                    // Change background on hover, but keep urgency border.
                    color: hovered ? Qt.rgba(255, 255, 255, 1) : Qt.rgba(255, 255, 255, 1)

                    // -------------------------------------------------
                    // AUTO-DISMISS
                    // Critical notifications persist.
                    // -------------------------------------------------
                    property int dismissMs: {
                        if (modelData.urgency === NotificationUrgency.Critical) return 0
                        if (modelData.expireTimeout > 0) return modelData.expireTimeout
                        return 7000
                    }

                    Timer {
                        interval: notificationCard.dismissMs
                        running: notificationCard.dismissMs > 0
                        repeat: false
                        onTriggered: notificationCard.modelData.dismiss()
                    }

                    ColumnLayout {
                        id: contentLayout
                        anchors {
                            fill: parent
                            margins: 12
                        }
                        spacing: 8

                        // ---------------------------------------------
                        // HEADER
                        // ---------------------------------------------
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Image {
                                visible: modelData.appIcon !== ""
                                source: Quickshell.iconPath(modelData.appIcon, true)
                                sourceSize.width: 20
                                sourceSize.height: 20
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                            }

                            Text {
                                text: modelData.appName || "Notification"
                                color: Qt.rgba(255, 255, 255, 0.6)
                                font.pixelSize: 12
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            // Close button
                            Rectangle {
                                id: closeButton
                                width: 20
                                height: 20
                                radius: 4
                                color: closeHover.hovered ? Qt.rgba(255, 255, 255, 0.2) : "transparent"

                                Behavior on color {
                                    ColorAnimation { duration: 120 }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    color: closeHover.hovered ? Qt.rgba(255, 255, 255, 1) : Qt.rgba(255, 255, 255, 1)
                                    font.pixelSize: 11

                                    Behavior on color {
                                        ColorAnimation { duration: 120 }
                                    }
                                }

                                HoverHandler { id: closeHover }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: notificationCard.modelData.dismiss()
                                }
                            }
                        }

                        // ---------------------------------------------
                        // SUMMARY
                        // ---------------------------------------------
                        Text {
                            Layout.fillWidth: true
                            text: modelData.summary
                            color: Qt.rgba(255, 255, 255, 1)
                            font.pixelSize: 14
                            font.bold: true
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        // ---------------------------------------------
                        // BODY
                        // ---------------------------------------------
                        Text {
                            Layout.fillWidth: true
                            text: modelData.body
                            color: Qt.rgba(255, 255, 255, 1)
                            font.pixelSize: 13
                            wrapMode: Text.Wrap
                            maximumLineCount: 5
                            elide: Text.ElideRight
                            textFormat: Text.StyledText
                        }

                        // ---------------------------------------------
                        // ACTIONS
                        // ---------------------------------------------
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            visible: modelData.actions.length > 0

                            Repeater {
                                model: modelData.actions

                                delegate: Rectangle {
                                    required property var modelData

                                    height: 28
                                    width: actionText.implicitWidth + 20
                                    radius: 6
                                    color: actionHover.hovered ? "#45475a" : "#313244"

                                    Behavior on color {
                                        ColorAnimation { duration: 120 }
                                    }

                                    Text {
                                        id: actionText
                                        anchors.centerIn: parent
                                        text: modelData.text
                                        color: Qt.rgba(255, 255, 255, 1)
                                        font.pixelSize: 12
                                    }

                                    HoverHandler { id: actionHover }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: modelData.invoke()
                                    }
                                }
                            }
                        }
                    }

                    // -------------------------------------------------
                    // HOVER DETECTION
                    // Toggles the `hovered` property used by color and
                    // scale above. Uses HoverHandler so it doesn't
                    // consume clicks meant for the close button or
                    // action buttons.
                    // -------------------------------------------------
                    HoverHandler {
                        id: cardHover
                        onHoveredChanged: notificationCard.hovered = hovered
                    }
                }
            }
        }

        // =============================================================
        // IPC
        // =============================================================
        IpcHandler {
            target: "notifications"

            function dismiss_all(): void {
                for (let i = 0; i < server.trackedNotifications.values.length; i++) {
                    server.trackedNotifications.values[i].dismiss()
                }
            }

            function dnd_toggle(): void {
                server.doNotDisturb = !server.doNotDisturb
            }
        }
    }
}