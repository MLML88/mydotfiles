import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../themes"
import "../services"

Rectangle {
    id: root

    color: Theme.base
    radius: 12
    border.color: Theme.surface0
    border.width: 1

    // Exposed so ClockPill can grab keyboard focus into the search field
    // the moment the launcher opens.
    property alias searchField: searchInput

    readonly property var apps: DesktopEntries.applications ? DesktopEntries.applications.values : []

    function matchScore(entry, needle) {
        const name = (entry.name || "").toLowerCase();
        if (name === needle) return 100;
        if (name.startsWith(needle)) return 80;
        if (name.includes(needle)) return 60;

        const generic = (entry.genericName || "").toLowerCase();
        if (generic.includes(needle)) return 40;

        const kws = entry.keywords || [];
        for (let i = 0; i < kws.length; i++) {
            if (String(kws[i]).toLowerCase().includes(needle)) return 30;
        }
        return 0;
    }

    function filterApps(text) {
        const visible = root.apps.filter(a => !a.noDisplay);
        if (text.length === 0) {
            return visible.slice().sort((a, b) => a.name.localeCompare(b.name));
        }
        const needle = text.toLowerCase();
        return visible
            .map(a => ({ entry: a, score: root.matchScore(a, needle) }))
            .filter(x => x.score > 0)
            .sort((a, b) => b.score - a.score)
            .map(x => x.entry);
    }

    readonly property var results: filterApps(searchInput.text)
    property int currentIndex: 0

    onResultsChanged: currentIndex = 0

    function launch(entry) {
        entry.execute();
        LauncherState.hide();
    }

    function launchCurrent() {
        if (root.results.length === 0) return;
        root.launch(root.results[root.currentIndex]);
    }

    // Called by ClockPill when the launcher closes, so it opens fresh
    // next time instead of showing the last search.
    function reset() {
        searchInput.text = "";
        currentIndex = 0;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 38
            radius: 8
            color: Theme.crust

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "Search apps…"
                color: Theme.surface2
                font.pixelSize: 14
                visible: searchInput.text.length === 0
            }

            TextInput {
                id: searchInput
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.text
                font.pixelSize: 14
                clip: true

                Keys.onDownPressed: root.currentIndex = Math.min(root.currentIndex + 1, root.results.length - 1)
                Keys.onUpPressed: root.currentIndex = Math.max(root.currentIndex - 1, 0)
                Keys.onReturnPressed: root.launchCurrent()
                Keys.onEnterPressed: root.launchCurrent()
                Keys.onEscapePressed: LauncherState.hide()
            }
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.results
            currentIndex: root.currentIndex
            highlightMoveDuration: 100

            delegate: Rectangle {
                id: row
                required property var modelData
                required property int index

                width: list.width
                height: 44
                radius: 8
                color: index === root.currentIndex ? Theme.surface0 : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 10

                    IconImage {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        source: row.modelData.icon ? Quickshell.iconPath(row.modelData.icon, "application-x-executable") : ""
                    }

                    Text {
                        Layout.fillWidth: true
                        text: row.modelData.name
                        color: Theme.text
                        font.pixelSize: 14
                        elide: Text.ElideRight
                    }
                }

                HoverHandler {
                    onHoveredChanged: if (hovered) root.currentIndex = row.index
                }

                TapHandler {
                    onTapped: root.launch(row.modelData)
                }
            }

            Text {
                anchors.centerIn: parent
                visible: root.results.length === 0
                text: "No apps found"
                color: Theme.surface2
                font.pixelSize: 13
            }
        }
    }
}
