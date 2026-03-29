import QtQuick
import qs.Commons

Item {
    id: root

    // Required properties
    property var pluginApi: null
    property var launcher: null
    property string name: "Update Widget"

    // Check if this provider handles the command
    function handleCommand(searchText) {
        return searchText.startsWith(">refresh")
    }

    // Return available commands when user types ">"
    function commands() {
        return [
            {
                "name": ">refresh",
                "description": pluginApi.tr("launcher.refreshDesc"),
                "icon": "refresh",
                "isTablerIcon": true,
                "onActivate": function() {
                    root.pluginApi.mainInstance.refresh()
                }
            },
            {
                "name": ">update",
                "description": pluginApi.tr("launcher.updateDesc"),
                "icon": "arrow-big-down-lines",
                "isTablerIcon": true,
                "onActivate": function() {
                    root.pluginApi.mainInstance.update()
                }
            }
        ]
    }
}