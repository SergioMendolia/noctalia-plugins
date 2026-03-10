import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

Item {
    id: root

    property var pluginApi: null
    property ShellScreen currentScreen
    readonly property var geometryPlaceholder: panelContainer

    // ===== DATA =====
    readonly property var mainInstance: pluginApi?.mainInstance
    readonly property var devices: mainInstance?.devices ?? []
    readonly property int mountedCount: mainInstance?.mountedCount ?? 0

    property real contentPreferredWidth: 380 * Style.uiScaleRatio
    property real contentPreferredHeight: 480 * Style.uiScaleRatio

    Component.onCompleted: {
        mainInstance?.refreshDevices()
    }

    // ===== CLIPBOARD HELPER =====
    function copyToClipboard(text) {
        Quickshell.execDetached(["sh", "-c", "echo -n " + JSON.stringify(text) + " | wl-copy"])
        ToastService.showNotice(
            pluginApi?.tr("notifications.path-copied") || "Path copied",
            text
        )
    }

    // ===== UI =====
    MouseArea {
        anchors.fill: parent
        onClicked: pluginApi.closePanel()

        Rectangle {
            id: panelContainer
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Style.marginL
            anchors.rightMargin: Style.marginL
            width: root.contentPreferredWidth
            height: root.contentPreferredHeight

            color: Color.mSurface
            radius: Style.radiusL
            border.width: 1
            border.color: Color.mOutline

            MouseArea { anchors.fill: parent; onClicked: {} }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.marginL
                spacing: Style.marginM

                // ── Header ───────────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true

                    NIcon {
                        icon: "usb"
                        pointSize: Style.fontSizeL
                        color: Color.mOnSurface
                    }

                    NText {
                        Layout.fillWidth: true
                        text: pluginApi?.tr("panel.title") || "USB Devices"
                        pointSize: Style.fontSizeL
                        font.weight: Font.Medium
                        color: Color.mOnSurface
                        leftPadding: Style.marginXS
                    }

                    // Device count badge
                    Rectangle {
                        visible: mountedCount > 0
                        width: countLabel.implicitWidth + Style.marginS * 2
                        height: countLabel.implicitHeight + 4
                        radius: height / 2
                        color: Color.mPrimaryContainer

                        NText {
                            id: countLabel
                            anchors.centerIn: parent
                            text: mountedCount + " " + (pluginApi?.tr("panel.mounted") || "mounted")
                            pointSize: Style.fontSizeXS
                            color: Color.mOnPrimaryContainer
                            font.weight: Font.Medium
                        }
                    }

                    // Refresh button
                    NIconButton {
                        icon: "refresh"
                        tooltipText: pluginApi?.tr("panel.refresh") || "Refresh"
                        baseSize: 28
                        applyUiScale: false
                        onClicked: mainInstance?.refreshDevices()

                        RotationAnimation on rotation {
                            running: mainInstance?.loading ?? false
                            from: 0; to: 360
                            duration: 1000
                            loops: Animation.Infinite
                        }
                    }
                }

                NDivider { Layout.fillWidth: true }

                // ── Device List ───────────────────────────────────────────────
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Empty state
                    ColumnLayout {
                        visible: devices.length === 0
                        anchors.centerIn: parent
                        spacing: Style.marginS

                        NIcon {
                            Layout.alignment: Qt.AlignHCenter
                            icon: "usb"
                            pointSize: Style.fontSizeXXL
                            color: Color.mOnSurfaceVariant
                            opacity: 0.4
                        }

                        NText {
                            Layout.alignment: Qt.AlignHCenter
                            text: pluginApi?.tr("panel.empty") || "No USB devices detected"
                            pointSize: Style.fontSizeM
                            color: Color.mOnSurfaceVariant
                        }

                        NText {
                            Layout.alignment: Qt.AlignHCenter
                            text: pluginApi?.tr("panel.empty-hint") || "Plug in a USB drive to get started"
                            pointSize: Style.fontSizeS
                            color: Color.mOnSurfaceVariant
                            opacity: 0.7
                        }
                    }

                    // Device cards
                    ScrollView {
                        visible: devices.length > 0
                        anchors.fill: parent
                        clip: true

                        ColumnLayout {
                            width: parent.width
                            spacing: Style.marginS

                            Repeater {
                                model: devices

                                delegate: DeviceCard {
                                    Layout.fillWidth: true
                                    device: modelData
                                    pluginApi: root.pluginApi
                                    mainInstance: root.mainInstance

                                    onMountRequested: (path, label) => {
                                        mainInstance?.mountDevice(path, label)
                                    }
                                    onUnmountRequested: (path, label) => {
                                        mainInstance?.unmountDevice(path, label)
                                    }
                                    onEjectRequested: (path, parentPath, label) => {
                                        mainInstance?.ejectDevice(path, parentPath, label)
                                    }
                                    onOpenRequested: mountpoint => {
                                        mainInstance?.openInFileBrowser(mountpoint)
                                    }
                                    onCopyPathRequested: mountpoint => {
                                        root.copyToClipboard(mountpoint)
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Footer Actions ────────────────────────────────────────────
                ColumnLayout {
                    visible: devices.length > 0
                    Layout.fillWidth: true
                    spacing: Style.marginXS

                    NDivider { Layout.fillWidth: true }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS

                        NButton {
                            Layout.fillWidth: true
                            text: pluginApi?.tr("panel.unmount-all") || "Unmount All"
                            icon: "plug-connected-x"
                            enabled: mountedCount > 0
                            onClicked: mainInstance?.unmountAll()
                        }

                        NButton {
                            Layout.fillWidth: true
                            text: pluginApi?.tr("panel.eject-all") || "Eject All"
                            icon: "player-eject"
                            enabled: devices.length > 0
                            onClicked: mainInstance?.ejectAll()
                        }
                    }
                }
            }
        }
    }
}
