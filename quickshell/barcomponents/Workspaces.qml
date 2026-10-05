import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    id: workspaces

    implicitWidth: row.implicitWidth
    implicitHeight: 20

    // ---- Constants matching the original dot size --------------------
    readonly property int dotWidth: 32
    readonly property int dotHeight: 20
    readonly property int dotSpacing: 6

    // ---- Currently focused workspace id ------------------------------
    readonly property int focusedId: {
        if (Hyprland.focusedWorkspace === null) return -1
        return Hyprland.focusedWorkspace.id
    }

    // ---- Index of the focused workspace among the *visible* dots -----
    // The original static model [1..10] hid some dots with `visible:`,
    // which means the visual position of a dot is not its array index.
    // We need the visual position to place the sliding highlight.
    readonly property int focusedVisualIndex: {
        const list = visibleIds
        for (let i = 0; i < list.length; i++) {
            if (list[i] === focusedId) return i
        }
        return -1
    }

    // ---- List of workspace ids that are actually visible -------------
    readonly property var visibleIds: {
        const ids = []
        const liveWorkspaces = Hyprland.workspaces.values
        for (let n = 1; n <= 10; n++) {
            let ws = null
            for (let i = 0; i < liveWorkspaces.length; i++) {
                if (liveWorkspaces[i].id === n) { ws = liveWorkspaces[i]; break }
            }
            const occupied = ws !== null
            const focused = n === focusedId
            if (n <= 1 || occupied || focused) ids.push(n)
        }
        return ids
    }

    // =================================================================
    // SLIDING HIGHLIGHT
    // One rectangle that represents the focused workspace. It floats
    // behind the dots and slides between positions when focus changes.
    // Same color as the original "focused" branch.
    // =================================================================
    Rectangle {
        id: highlight

        width: workspaces.dotWidth
        height: workspaces.dotHeight
        radius: 4

        // Same color as the original `focused` branch.
        color: Qt.rgba(255, 255, 255, 0.9)

        visible: workspaces.focusedVisualIndex >= 0
        opacity: visible ? 1.0 : 0.0

        // X position = visualIndex × (dotWidth + dotSpacing).
        x: workspaces.focusedVisualIndex >= 0
            ? workspaces.focusedVisualIndex * (workspaces.dotWidth + workspaces.dotSpacing)
            : 0

        // ---- The slide ---------------------------------------------
        Behavior on x {
            NumberAnimation {
                duration: 280
                easing.type: Easing.OutCubic
            }
        }

        // ---- Appear/disappear fade ---------------------------------
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    // =================================================================
    // DOT ROW
    // Same logic as the original file. Only difference: `focused`
    // is no longer painted by the dot itself (the highlight does it),
    // and `visible` uses the shared visibleIds list so the ordering
    // matches the highlight's position calculation.
    // =================================================================
    Row {
        id: row
        spacing: workspaces.dotSpacing

        Repeater {
            model: workspaces.visibleIds

            delegate: Rectangle {
                required property int modelData

                readonly property var workspace: {
                    const list = Hyprland.workspaces.values
                    for (let i = 0; i < list.length; i++) {
                        if (list[i].id === modelData) return list[i]
                    }
                    return null
                }

                readonly property bool occupied: workspace !== null
                readonly property bool focused: Hyprland.focusedWorkspace !== null
                                                && Hyprland.focusedWorkspace.id === modelData
                readonly property bool urgent: workspace !== null && workspace.urgent

                width: workspaces.dotWidth
                height: workspaces.dotHeight
                radius: 4

                // ---- Colors (unchanged from original, except the
                // focused branch is now drawn by the highlight) ------
                color: {
                    if (urgent) return '#fa3f74'
                    if (occupied) return Qt.rgba(255, 255, 255, 0.2)
                    return "#313244"
                }

                Behavior on color {
                    ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
                }

                // ---- Urgent pulse (unchanged) -----------------------
                opacity: 1.0

                SequentialAnimation on opacity {
                    running: urgent && !focused
                    loops: Animation.Infinite
                    NumberAnimation {
                        to: 0.4; duration: 400
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        to: 1.0; duration: 400
                        easing.type: Easing.InOutQuad
                    }
                }

                Behavior on opacity {
                    enabled: !(urgent && !focused)
                    NumberAnimation { duration: 140 }
                }

                // ---- Label (unchanged colors) -----------------------
                Text {
                    anchors.centerIn: parent
                    text: modelData
                    font.pixelSize: 12
                    font.bold: true
                    color: workspacesDelegate.focused || workspacesDelegate.urgent
                           ? Qt.rgba(0, 0, 0, 0.9)
                           : Qt.rgba(255, 255, 255, 0.9)

                    // Smoothly fade the label color when focus moves
                    // to or away from this dot.
                    Behavior on color {
                        ColorAnimation { duration: 240; easing.type: Easing.OutCubic }
                    }
                }

                id: workspacesDelegate

                // ---- Click to switch (unchanged) --------------------
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (workspacesDelegate.workspace !== null) {
                            Hyprland.dispatch("workspace " + modelData)
                        }
                    }
                }
            }
        }
    }
}