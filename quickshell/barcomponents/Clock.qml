import QtQuick
import Quickshell
import Quickshell.Io

Row {
    id: clock

    spacing: 12

    // SystemClock ticks automatically based on precision.
    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }

    // --- Time ---------------------------------------------------------
    Text {
        id: timeText
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(systemClock.date, "hh:mm AP")
        color: Qt.rgba(255, 255, 255, 0.9)
        font.pixelSize: 13
        font.bold: true
    }



    // --- Separator ----------------------------------------------------
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 14
        color: "#45475a"
    }

    // --- Date ---------------------------------------------------------
    Text {
        id: dateText
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(systemClock.date, "dd dddd MMM")
        color: Qt.rgba(255, 255, 255, 0.9)
        font.pixelSize: 13
        font.bold: true
    }

}