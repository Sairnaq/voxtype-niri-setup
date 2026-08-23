pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: theme

    // Dynamic Omarchy theme color properties
    property color bgColor: Qt.rgba(0.08, 0.10, 0.13, 0.88)
    property color accentColor: "#7fa961"
    property color idleColor: "#abb2bf"
    property color recordingColor: accentColor
    property color streamingColor: "#caeda8"
    property color transcribingColor: "#e5c07b"
    property color textColor: "#dcdfe4"
    property color waveformColor: theme.accentColor
    property color waveformPeakColor: "#FCFBF8"
    property color meterLowColor: Qt.rgba(0.30, 0.85, 0.45, 1.0)
    property color meterMidColor: Qt.rgba(0.95, 0.80, 0.30, 1.0)
    property color meterHighColor: Qt.rgba(0.95, 0.35, 0.30, 1.0)

    property int cornerRadius: 26
    property int padding: 14
    property int marginPx: 24
    property int defaultWidthPx: 320
    property int defaultHeightPx: 52
    property real defaultOpacity: 0.95
    property real waveformWindowSecs: 3.0
    property real peakDecayDbPerSec: 6.0
    property real waveformGain: 10.0
    property real meterFloorDbfs: -60.0

    // Dynamic Color Watcher: Reads active Omarchy colors in real time
    property var colorWatcher: Process {
        id: colorProc
        command: ["bash", "-c", "cat $HOME/.local/state/omarchy/current/theme/colors.toml 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                if (!text) return
                var lines = text.split("\n")
                var colMap = {}
                for (var i = 0; i < lines.length; i++) {
                    var l = lines[i].trim()
                    if (l.indexOf("=") !== -1) {
                        var parts = l.split("=")
                        var k = parts[0].trim()
                        var v = parts[1].trim().replace(/[\"']/g, "")
                        colMap[k] = v
                    }
                }
                if (colMap.accent) {
                    theme.accentColor = colMap.accent
                    theme.recordingColor = colMap.accent
                    theme.waveformColor = colMap.accent
                }
                if (colMap.background) {
                    theme.bgColor = Qt.rgba(Qt.color(colMap.background).r, Qt.color(colMap.background).g, Qt.color(colMap.background).b, 0.90)
                }
                if (colMap.foreground) {
                    theme.textColor = colMap.foreground
                }
                if (colMap.bright_green || colMap.green) {
                    theme.streamingColor = colMap.bright_green || colMap.green
                }
            }
        }
    }

    // Check on state changes or periodic refresh
    property var stateWatch: Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: {
            if (!colorProc.running) colorProc.running = true
        }
    }
}
