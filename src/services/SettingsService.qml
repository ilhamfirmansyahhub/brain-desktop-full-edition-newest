pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // =========================================================================
    // Appearance settings
    // =========================================================================

    property real barOpacity: 0.85

    property string interfaceFont: "Adwaita Sans"
    property string monospaceFont: "Adwaita Mono"
    property int fontSize: 11

    property var availableFonts: []

    signal settingsChanged()
    signal fontsChanged()

    readonly property string settingsPath:
        Quickshell.env("HOME")
        + "/.config/Brain_Shell/src/user_data/brain_desktop_settings.json"

    readonly property string fontconfigPath:
        Quickshell.env("HOME")
        + "/.config/fontconfig/fonts.conf"


    // =========================================================================
    // Load settings
    // =========================================================================

    property var loadProc: Process {
        command: [
            "bash",
            "-c",
            "mkdir -p \"$(dirname '" + root.settingsPath + "')\"; " +
            "if [ -f '" + root.settingsPath + "' ]; then " +
            "cat '" + root.settingsPath + "'; " +
            "else " +
            "echo '{}'; " +
            "fi"
        ]

        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text.trim() || "{}")

                    if (data.barOpacity !== undefined) {
                        root.barOpacity = Math.max(
                            0.0,
                            Math.min(1.0, Number(data.barOpacity))
                        )
                    }

                    if (data.interfaceFont !== undefined &&
                        String(data.interfaceFont).trim() !== "") {
                        root.interfaceFont = String(data.interfaceFont)
                    }

                    if (data.monospaceFont !== undefined &&
                        String(data.monospaceFont).trim() !== "") {
                        root.monospaceFont = String(data.monospaceFont)
                    }

                    if (data.fontSize !== undefined) {
                        root.fontSize = Math.max(
                            8,
                            Math.min(32, Number(data.fontSize))
                        )
                    }

                } catch (e) {
                    console.warn(
                        "SettingsService: failed to load settings:",
                        e
                    )
                }

                root.refreshFonts()
            }
        }
    }


    // =========================================================================
    // Save settings
    // =========================================================================

    property var saveProc: Process {
        command: []
        running: false
    }

    function save() {
        var json = JSON.stringify({
            barOpacity: root.barOpacity,
            interfaceFont: root.interfaceFont,
            monospaceFont: root.monospaceFont,
            fontSize: root.fontSize
        })

        saveProc.command = [
            "bash",
            "-c",
            "mkdir -p \"$(dirname '" +
            root.settingsPath +
            "')\" && " +
            "printf '%s' \"$1\" > '" +
            root.settingsPath +
            "'",
            "bash",
            json
        ]

        saveProc.running = false
        saveProc.running = true
    }


    // =========================================================================
    // Font discovery
    // =========================================================================

    property var fontListProc: Process {
        command: [
            "bash",
            "-c",
            "fc-list : family | " +
            "sed 's/,.*//' | " +
            "sort -fu"
        ]

        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                var result = []

                for (var i = 0; i < lines.length; i++) {
                    var font = lines[i].trim()

                    if (font === "")
                        continue

                    if (result.indexOf(font) === -1)
                        result.push(font)
                }

                result.sort(function(a, b) {
                    return a.localeCompare(b)
                })

                root.availableFonts = result
                root.fontsChanged()
            }
        }
    }

    function refreshFonts() {
        fontListProc.running = false
        fontListProc.running = true
    }


    // =========================================================================
    // Apply font settings
    // =========================================================================

    property var fontApplyProc: Process {
        command: []
        running: false
    }

    function applyFonts() {
        var interfaceSetting =
            root.interfaceFont + " " + root.fontSize
    
        var monoSetting =
            root.monospaceFont + " " + root.fontSize
    
        var fontconfigDir =
            Quickshell.env("HOME") + "/.config/fontconfig"
    
        var fontconfigXml =
            "<?xml version=\"1.0\"?>\n" +
            "<!DOCTYPE fontconfig SYSTEM \"fonts.dtd\">\n" +
            "<fontconfig>\n" +
            "  <alias>\n" +
            "    <family>sans-serif</family>\n" +
            "    <prefer>\n" +
            "      <family>" +
            root.interfaceFont +
            "</family>\n" +
            "    </prefer>\n" +
            "  </alias>\n" +
            "  <alias>\n" +
            "    <family>sans</family>\n" +
            "    <prefer>\n" +
            "      <family>" +
            root.interfaceFont +
            "</family>\n" +
            "    </prefer>\n" +
            "  </alias>\n" +
            "  <alias>\n" +
            "    <family>monospace</family>\n" +
            "    <prefer>\n" +
            "      <family>" +
            root.monospaceFont +
            "</family>\n" +
            "    </prefer>\n" +
            "  </alias>\n" +
            "</fontconfig>\n"
    
        var escapedXml =
            fontconfigXml
                .replace(/\\/g, "\\\\")
                .replace(/'/g, "'\\''")
    
        fontApplyProc.command = [
            "bash",
            "-c",
            "mkdir -p '" +
            fontconfigDir +
            "' && " +
    
            "printf '%s' '" +
            escapedXml +
            "' > '" +
            root.fontconfigPath +
            "' && " +
    
            "gsettings set org.gnome.desktop.interface font-name " +
            "'" + interfaceSetting.replace(/'/g, "'\\''") + "' 2>/dev/null || true; " +
    
            "gsettings set org.gnome.desktop.interface monospace-font-name " +
            "'" + monoSetting.replace(/'/g, "'\\''") + "' 2>/dev/null || true; " +
    
            "fc-cache -f >/dev/null 2>&1 || true"
        ]
    
        fontApplyProc.running = false
        fontApplyProc.running = true
    
        root.save()
        root.settingsChanged()
        root.fontsChanged()
    }


    // =========================================================================
    // Individual setters
    // =========================================================================

    function setBarOpacity(value) {
        root.barOpacity = Math.max(
            0.0,
            Math.min(1.0, Number(value))
        )

        root.save()
        root.settingsChanged()
    }

    function setInterfaceFont(value) {
        if (!value || String(value).trim() === "")
            return

        root.interfaceFont = String(value).trim()
        root.save()
        root.settingsChanged()
    }

    function setMonospaceFont(value) {
        if (!value || String(value).trim() === "")
            return

        root.monospaceFont = String(value).trim()
        root.save()
        root.settingsChanged()
    }

    function setFontSize(value) {
        root.fontSize = Math.max(
            8,
            Math.min(32, Number(value))
        )

        root.save()
        root.settingsChanged()
    }


    // =========================================================================
    // Initialisation
    // =========================================================================

    Component.onCompleted: {
        loadProc.running = true
    }
}
