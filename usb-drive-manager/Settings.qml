import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root
    spacing: Style.marginL

    property var pluginApi: null

    // ===== EDIT STATE =====

    property bool editAutoMount:
        pluginApi?.pluginSettings?.autoMount ??
        pluginApi?.manifest?.metadata?.defaultSettings?.autoMount ??
        false

    property string editFileBrowser:
        pluginApi?.pluginSettings?.fileBrowser ||
        pluginApi?.manifest?.metadata?.defaultSettings?.fileBrowser ||
        "yazi"

    property string editTerminalCommand:
        pluginApi?.pluginSettings?.terminalCommand ||
        pluginApi?.manifest?.metadata?.defaultSettings?.terminalCommand ||
        "kitty"

    property bool editShowNotifications:
        pluginApi?.pluginSettings?.showNotifications ??
        pluginApi?.manifest?.metadata?.defaultSettings?.showNotifications ??
        true

    property bool editHideWhenEmpty:
        pluginApi?.pluginSettings?.hideWhenEmpty ??
        pluginApi?.manifest?.metadata?.defaultSettings?.hideWhenEmpty ??
        false

    property bool editShowBadge:
        pluginApi?.pluginSettings?.showBadge ??
        pluginApi?.manifest?.metadata?.defaultSettings?.showBadge ??
        true

    // ===== SAVE =====

    function saveSettings() {
        if (!pluginApi) return

        pluginApi.pluginSettings.autoMount          = root.editAutoMount
        pluginApi.pluginSettings.fileBrowser        = root.editFileBrowser
        pluginApi.pluginSettings.terminalCommand    = root.editTerminalCommand
        pluginApi.pluginSettings.showNotifications  = root.editShowNotifications
        pluginApi.pluginSettings.hideWhenEmpty      = root.editHideWhenEmpty
        pluginApi.pluginSettings.showBadge          = root.editShowBadge

        pluginApi.savePluginSettings()
    }

    // ===== UI =====

    // ── Section: Bar Widget ───────────────────────────────────────────────────
    NText {
        text: pluginApi?.tr("settings.section-bar") || "Bar Widget"
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    // Hide when empty
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            NText {
                text: pluginApi?.tr("settings.hide-when-empty") || "Hide when no devices"
                pointSize: Style.fontSizeS
                color: Color.mOnSurface
            }
            NText {
                text: pluginApi?.tr("settings.hide-when-empty-desc") || "Hide the bar icon when no USB devices are connected"
                pointSize: Style.fontSizeXS
                color: Color.mOnSurfaceVariant
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        NToggle {
            checked: root.editHideWhenEmpty
            onToggled: checked => {
                root.editHideWhenEmpty = checked
                root.saveSettings()
            }
        }
    }

    // Show badge
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            NText {
                text: "Show count badge"
                pointSize: Style.fontSizeS
                color: Color.mOnSurface
            }
            NText {
                text: "Show the number of mounted devices as a badge on the icon"
                pointSize: Style.fontSizeXS
                color: Color.mOnSurfaceVariant
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        NToggle {
            checked: root.editShowBadge
            onToggled: checked => {
                root.editShowBadge = checked
                root.saveSettings()
            }
        }
    }

    NDivider { Layout.fillWidth: true }

    // ── Section: Behavior ─────────────────────────────────────────────────────
    NText {
        text: pluginApi?.tr("settings.section-behavior") || "Behavior"
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    // Auto-mount
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            NText {
                text: pluginApi?.tr("settings.auto-mount") || "Auto-mount"
                pointSize: Style.fontSizeS
                color: Color.mOnSurface
            }
            NText {
                text: pluginApi?.tr("settings.auto-mount-desc") || "Automatically mount USB drives when plugged in"
                pointSize: Style.fontSizeXS
                color: Color.mOnSurfaceVariant
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        NToggle {
            checked: root.editAutoMount
            onToggled: checked => {
                root.editAutoMount = checked
                root.saveSettings()
            }
        }
    }

    NDivider { Layout.fillWidth: true }

    // Show notifications
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            NText {
                text: pluginApi?.tr("settings.notifications") || "Notifications"
                pointSize: Style.fontSizeS
                color: Color.mOnSurface
            }
            NText {
                text: pluginApi?.tr("settings.notifications-desc") || "Show toast notifications for mount/unmount/eject events"
                pointSize: Style.fontSizeXS
                color: Color.mOnSurfaceVariant
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        NToggle {
            checked: root.editShowNotifications
            onToggled: checked => {
                root.editShowNotifications = checked
                root.saveSettings()
            }
        }
    }

    NDivider { Layout.fillWidth: true }

    // ── Section: File Browser ─────────────────────────────────────────────────
    NText {
        text: pluginApi?.tr("settings.section-browser") || "File Browser"
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    NText {
        text: pluginApi?.tr("settings.file-browser") || "File browser command"
        pointSize: Style.fontSizeS
        color: Color.mOnSurface
    }
    NText {
        text: pluginApi?.tr("settings.file-browser-desc") || "Command to open files (yazi, ranger, xdg-open, dolphin, thunar, nautilus)"
        pointSize: Style.fontSizeXS
        color: Color.mOnSurfaceVariant
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    // File browser presets
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginXS

        Repeater {
            model: ["yazi", "ranger", "xdg-open", "dolphin", "thunar", "nautilus"]

            delegate: NButton {
                text: modelData
                enabled: root.editFileBrowser !== modelData
                onClicked: {
                    root.editFileBrowser = modelData
                    root.saveSettings()
                }
            }
        }
    }

    NText {
        text: (pluginApi?.tr("settings.current-browser") || "Current:") + " " + root.editFileBrowser
        pointSize: Style.fontSizeXS
        color: Color.mPrimary
        font.weight: Font.Medium
    }

    NDivider { Layout.fillWidth: true }

    // Terminal command
    NText {
        text: pluginApi?.tr("settings.terminal") || "Terminal emulator"
        pointSize: Style.fontSizeS
        color: Color.mOnSurface
    }
    NText {
        text: pluginApi?.tr("settings.terminal-desc") || "Terminal used for terminal file managers (yazi, ranger, etc.)"
        pointSize: Style.fontSizeXS
        color: Color.mOnSurfaceVariant
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    // Terminal presets
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginXS

        Repeater {
            model: ["kitty", "foot", "alacritty", "wezterm", "ghostty"]

            delegate: NButton {
                text: modelData
                enabled: root.editTerminalCommand !== modelData
                onClicked: {
                    root.editTerminalCommand = modelData
                    root.saveSettings()
                }
            }
        }
    }

    NText {
        text: (pluginApi?.tr("settings.current-terminal") || "Current:") + " " + root.editTerminalCommand
        pointSize: Style.fontSizeXS
        color: Color.mPrimary
        font.weight: Font.Medium
    }

    NDivider { Layout.fillWidth: true }

    // ── Section: System Requirements ──────────────────────────────────────────
    NText {
        text: pluginApi?.tr("settings.section-requirements") || "System Requirements"
        pointSize: Style.fontSizeM
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    NText {
        Layout.fillWidth: true
        text: pluginApi?.tr("settings.requirements-desc") || "The following tools must be installed:"
        pointSize: Style.fontSizeS
        color: Color.mOnSurfaceVariant
        wrapMode: Text.WordWrap
    }

    Repeater {
        model: [
            { cmd: "udisksctl", pkg: "sys-fs/udisks" },
            { cmd: "udevadm",   pkg: "sys-fs/eudev or sys-apps/systemd-utils" },
            { cmd: "lsblk",     pkg: "sys-apps/util-linux" }
        ]

        delegate: RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            NText {
                text: "•"
                pointSize: Style.fontSizeS
                color: Color.mOnSurfaceVariant
            }

            NText {
                text: modelData.cmd
                pointSize: Style.fontSizeS
                color: Color.mOnSurface
                font.weight: Font.Medium
            }

            NText {
                Layout.fillWidth: true
                text: "(" + modelData.pkg + ")"
                pointSize: Style.fontSizeXS
                color: Color.mOnSurfaceVariant
                elide: Text.ElideRight
            }
        }
    }

    Item { Layout.fillHeight: true }
}
