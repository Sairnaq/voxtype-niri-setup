pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: theme

    // Dynamic theme color properties (frosted glass 0.60 alpha)
    property color bgColor: Qt.rgba(0.06, 0.08, 0.10, 0.60)
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

    // Universal Dynamic Color Resolver (Omarchy, Pywal, Matugen, Wallust, Noctalia, Kitty)
    property var colorWatcher: Process {
        id: colorProc
        command: [
            "python3", "-c",
            "import json, os\n" +
            "res = {'accent': '#7fa961', 'background': '#00070d', 'foreground': '#ecf0e9', 'green': '#71ad43'}\n" +
            "om = os.path.expanduser('~/.local/state/omarchy/current/theme/colors.toml')\n" +
            "if os.path.exists(om):\n" +
            "    try:\n" +
            "        with open(om) as f:\n" +
            "            for l in f:\n" +
            "                if '=' in l:\n" +
            "                    k, v = [x.strip().strip('\"\'') for x in l.split('=', 1)]\n" +
            "                    if k == 'accent': res['accent'] = v\n" +
            "                    elif k == 'background': res['background'] = v\n" +
            "                    elif k == 'foreground': res['foreground'] = v\n" +
            "                    elif k in ('bright_green', 'green'): res['green'] = v\n" +
            "        print(json.dumps(res)); exit(0)\n" +
            "    except Exception: pass\n" +
            "wal = os.path.expanduser('~/.cache/wal/colors.json')\n" +
            "if os.path.exists(wal):\n" +
            "    try:\n" +
            "        with open(wal) as f:\n" +
            "            d = json.load(f)\n" +
            "            if 'special' in d:\n" +
            "                res['background'] = d['special'].get('background', res['background'])\n" +
            "                res['foreground'] = d['special'].get('foreground', res['foreground'])\n" +
            "            if 'colors' in d:\n" +
            "                res['accent'] = d['colors'].get('color4', res['accent'])\n" +
            "                res['green'] = d['colors'].get('color2', res['green'])\n" +
            "        print(json.dumps(res)); exit(0)\n" +
            "    except Exception: pass\n" +
            "for p in ['~/.config/matugen/colors.json', '~/.cache/matugen/colors.json', '~/.config/wallust/colors.json', '~/.config/noctalia/colors.json']:\n" +
            "    exp = os.path.expanduser(p)\n" +
            "    if os.path.exists(exp):\n" +
            "        try:\n" +
            "            with open(exp) as f:\n" +
            "                d = json.load(f)\n" +
            "                if 'primary' in d: res['accent'] = d['primary']\n" +
            "                elif 'accent' in d: res['accent'] = d['accent']\n" +
            "                if 'background' in d: res['background'] = d['background']\n" +
            "                elif 'surface' in d: res['background'] = d['surface']\n" +
            "                if 'on_surface' in d: res['foreground'] = d['on_surface']\n" +
            "                elif 'foreground' in d: res['foreground'] = d['foreground']\n" +
            "            print(json.dumps(res)); exit(0)\n" +
            "        except Exception: pass\n" +
            "print(json.dumps(res))"
        ]
        running: true
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                if (!text) return
                try {
                    var data = JSON.parse(text)
                    if (data.accent) {
                        theme.accentColor = data.accent
                        theme.recordingColor = data.accent
                        theme.waveformColor = data.accent
                    }
                    if (data.background) {
                        var c = Qt.color(data.background)
                        theme.bgColor = Qt.rgba(c.r, c.g, c.b, 0.60)
                    }
                    if (data.foreground) {
                        theme.textColor = data.foreground
                    }
                    if (data.green) {
                        theme.streamingColor = data.green
                    }
                } catch (e) {}
            }
        }
    }

    // Dynamic Refresh Timer (updates colors when theme changes)
    property var stateWatch: Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: {
            if (!colorProc.running) colorProc.running = true
        }
    }
}
