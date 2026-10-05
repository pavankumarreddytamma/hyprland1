import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: launcherRoot

    anchors { top: true; left: true; right: true; bottom: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    // =============================================================
    // TIMING — short, snappy, no sluggish curves
    // =============================================================
    readonly property int durSpatial: 200
    readonly property int durColor: 140
    readonly property int durList: 180

    // =============================================================
    // DATA
    // =============================================================
    property var allApps: DesktopEntries.applications.values
    property string searchQuery: ""
    property var filteredApps: []

    onSearchQueryChanged: updateFilteredApps()

    Component.onCompleted: {
        updateFilteredApps()
        searchInput.forceActiveFocus()
    }

    // =============================================================
    // FILTERING
    // =============================================================
    function updateFilteredApps() {
        if (!allApps) return
        let query = searchQuery.toLowerCase()
        let results = []
        for (let i = 0; i < allApps.length; i++) {
            let app = allApps[i]
            if (query === "" ||
                (app.name || "").toLowerCase().includes(query) ||
                (app.genericName || "").toLowerCase().includes(query) ||
                (app.comment || "").toLowerCase().includes(query)) {
                results.push(app)
            }
        }
        filteredApps = results
    }

    // =============================================================
    // LAUNCH
    // =============================================================
    function launchApp(app) {
        if (app.runInTerminal) {
            Quickshell.execDetached(["kitty", "-e", ...app.command])
        } else {
            app.execute()
        }
        closeLauncher()
    }

    // =============================================================
    // CLOSING
    // =============================================================
    function closeLauncher() {
        Quickshell.execDetached(["qs", "ipc", "call", "launcher", "close"])
    }

    Shortcut {
        sequence: "Escape"
        onActivated: launcherRoot.closeLauncher()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: launcherRoot.closeLauncher()
    }

    // =============================================================
    // LAUNCHER BOX
    // =============================================================
    Rectangle {
        id: launcherBox
        width: 300

        // Anchors instead of manual y — removes the parent override
        // conflict that was fighting the animations.
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        // ---------------------------------------------------------
        // SIZING — up to 5 rows
        // ---------------------------------------------------------
        readonly property int outerPadding: 18
        readonly property int rowHeight: 40
        readonly property int visibleRows: 5
        readonly property int maxListHeight: rowHeight * visibleRows
        readonly property int actualListHeight: Math.min(maxListHeight, filteredApps.length * rowHeight)

        height: outerPadding + 40 + 8 + actualListHeight + outerPadding

        // Fast start, smooth landing. OutQuad is snappy without
        // being abrupt.
        Behavior on height {
            NumberAnimation {
                duration: launcherRoot.durSpatial
                easing.type: Easing.OutQuad
            }
        }

        // ---------------------------------------------------------
        // CORNERS — kept exactly as you had them
        // ---------------------------------------------------------
        readonly property real dynamicRadius: {
            const rows = Math.min(8, filteredApps.length)
            return 10 + (rows / 8) * 4
        }
        radius: dynamicRadius

        Behavior on radius {
            NumberAnimation {
                duration: launcherRoot.durSpatial
                easing.type: Easing.OutQuad
            }
        }

        // ---------------------------------------------------------
        // BORDER — kept exactly as you had them
        // ---------------------------------------------------------
        readonly property real dynamicBorderWidth: {
            const rows = Math.min(8, filteredApps.length)
            return 1.6 - (rows / 8) * 0.6
        }
        border.width: dynamicBorderWidth

        Behavior on border.width {
            NumberAnimation {
                duration: launcherRoot.durSpatial
                easing.type: Easing.OutQuad
            }
        }

        readonly property color dynamicBorderColor: {
            const rows = Math.min(8, filteredApps.length)
            const t = rows / 8
            return Qt.rgba(
                0x31/255 + (0x45/255 - 0x31/255) * (1 - t),
                0x32/255 + (0x47/255 - 0x32/255) * (1 - t),
                0x44/255 + (0x5a/255 - 0x44/255) * (1 - t),
                1.0
            )
        }
        border.color: dynamicBorderColor

        Behavior on border.color {
            ColorAnimation {
                duration: launcherRoot.durColor
                easing.type: Easing.OutQuad
            }
        }

        // Background — kept exactly as you had it
        color: Qt.rgba(0, 0, 0, 0.9)

        // ---------------------------------------------------------
        // APPEARING — short scale + fade, no slide
        // ---------------------------------------------------------
        opacity: 0
        scale: 0.97

        ParallelAnimation {
            running: true

            NumberAnimation {
                target: launcherBox
                property: "opacity"
                from: 0
                to: 1
                duration: launcherRoot.durSpatial
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: launcherBox
                property: "scale"
                from: 0.97
                to: 1.0
                duration: launcherRoot.durSpatial
                easing.type: Easing.OutQuad
            }
        }

        MouseArea {
            anchors.fill: parent
        }

        // =========================================================
        // CONTENT
        // =========================================================
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: launcherBox.outerPadding
            spacing: 12

            // -----------------------------------------------------
            // SEARCH BAR — colors kept exactly as you had them
            // -----------------------------------------------------
            Rectangle {
                id: searchContainer
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: Qt.rgba(255, 255, 255, 0.1)
                radius: 6
                border.color: searchInput.activeFocus
                    ? Qt.rgba(255, 255, 255, 0.4)
                    : "transparent"
                border.width: 1
                clip: true

                Behavior on border.color {
                    ColorAnimation {
                        duration: launcherRoot.durColor
                        easing.type: Easing.OutQuad
                    }
                }

                // No slide-in, no stagger. Just appears with the box.
                opacity: 0

                NumberAnimation on opacity {
                    from: 0
                    to: 1
                    duration: launcherRoot.durSpatial
                    easing.type: Easing.OutQuad
                    running: true
                }

                Item {
                    id: searchWrapper
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    TextInput {
                        id: searchInput
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: searchWrapper.height

                        verticalAlignment: TextInput.AlignVCenter
                        color: Qt.rgba(255, 255, 255, 1)
                        font.pixelSize: 16
                        onTextChanged: launcherRoot.searchQuery = text

                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Down) {
                                if (appList.currentIndex < filteredApps.length - 1)
                                    appList.currentIndex++
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up) {
                                if (appList.currentIndex > 0)
                                    appList.currentIndex--
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (appList.currentIndex >= 0 && appList.currentIndex < filteredApps.length) {
                                    launcherRoot.launchApp(filteredApps[appList.currentIndex])
                                }
                                event.accepted = true
                            }
                        }

                        Text {
                            anchors.fill: parent
                            text: "Search applications..."
                            color: Qt.rgba(255, 255, 255, 0.5)
                            visible: parent.text.length === 0
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // -----------------------------------------------------
            // RESULTS LIST
            // -----------------------------------------------------
            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.preferredHeight: launcherBox.actualListHeight
                clip: true
                model: launcherRoot.filteredApps
                currentIndex: 0

                // Match the box's height easing so they move in sync.
                Behavior on Layout.preferredHeight {
                    NumberAnimation {
                        duration: launcherRoot.durSpatial
                        easing.type: Easing.OutQuad
                    }
                }

                // Rows fade in cleanly. No drift, no scale — those
                // were causing the "stops and starts" perception.
                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: launcherRoot.durList
                        easing.type: Easing.OutQuad
                    }
                }

                remove: Transition {
                    NumberAnimation {
                        property: "opacity"
                        to: 0
                        duration: 120
                        easing.type: Easing.InQuad
                    }
                }

                displaced: Transition {
                    NumberAnimation {
                        property: "y"
                        duration: launcherRoot.durList
                        easing.type: Easing.OutQuad
                    }
                }

                highlightMoveDuration: 160
                highlightResizeDuration: 120

                opacity: 0

                NumberAnimation on opacity {
                    from: 0
                    to: 1
                    duration: launcherRoot.durSpatial
                    easing.type: Easing.OutQuad
                    running: true
                }

                // Selection highlight — kept exactly as you had it
                highlight: Rectangle {
                    color: "#3a3333"
                    radius: 6

                    Behavior on y {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.OutQuad
                        }
                    }
                    Behavior on height {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutQuad
                        }
                    }
                }
                highlightFollowsCurrentItem: true

                // -------------------------------------------------
                // ONE ROW — colors kept exactly as you had them
                // -------------------------------------------------
                delegate: Rectangle {
                    width: appList.width
                    height: launcherBox.rowHeight
                    color: "transparent"
                    radius: 6

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Image {
                            source: Quickshell.iconPath(modelData.icon || "application-x-executable", true)
                            sourceSize.width: 24
                            sourceSize.height: 24
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                        }

                        Text {
                            text: modelData.name || "Unknown"
                            color: ListView.isCurrentItem
                                ? Qt.rgba(255, 255, 255, 1)
                                : Qt.rgba(255, 255, 255, 0.75)
                            font.pixelSize: 14
                            font.bold: ListView.isCurrentItem
                            Layout.fillWidth: true
                            elide: Text.ElideRight

                            Behavior on color {
                                ColorAnimation {
                                    duration: launcherRoot.durColor
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: appList.currentIndex = index
                        onClicked: launcherRoot.launchApp(modelData)
                    }
                }
            }
        }
    }
}
