import QtQuick
import QtQuick.Layouts
import "../themes"
import "../components"

Rectangle {
    id: root

    color: Theme.base
    radius: 12
    border.color: Theme.surface0
    border.width: 1

    readonly property var today: new Date()

    // The month/year currently being *viewed* — independent from "today",
    // so browsing doesn't lose track of the real current date.
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth() // 0-11

    // The day the user clicked, if any: {year, month, day}. Cleared
    // implicitly by never matching once you browse to a different month.
    property var selected: null

    readonly property var weekdayLabels: ["S", "M", "T", "W", "T", "F", "S"]

    function daysInGrid(year, month) {
        const first = new Date(year, month, 1);
        const startDay = first.getDay();
        const daysInMonth = new Date(year, month + 1, 0).getDate();

        const grid = [];
        for (let i = 0; i < startDay; i++) grid.push(0);
        for (let d = 1; d <= daysInMonth; d++) grid.push(d);
        while (grid.length % 7 !== 0) grid.push(0);
        return grid;
    }

    readonly property var monthGrid: daysInGrid(viewYear, viewMonth)
    readonly property bool viewingCurrentMonth:
        viewYear === today.getFullYear() && viewMonth === today.getMonth()

    function prevMonth() {
        if (viewMonth === 0) { viewMonth = 11; viewYear -= 1; }
        else viewMonth -= 1;
    }
    function nextMonth() {
        if (viewMonth === 11) { viewMonth = 0; viewYear += 1; }
        else viewMonth += 1;
    }
    function prevYear() { viewYear -= 1; }
    function nextYear() { viewYear += 1; }

    function selectDay(day) {
        selected = { year: viewYear, month: viewMonth, day: day };
    }

    function resetToToday() {
        viewYear = today.getFullYear();
        viewMonth = today.getMonth();
        selected = null;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 2

            NavButton { label: "«"; onActivated: root.prevYear() }
            NavButton { label: "‹"; onActivated: root.prevMonth() }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Qt.formatDate(new Date(root.viewYear, root.viewMonth, 1), "MMMM yyyy")
                color: Theme.text
                font.pixelSize: 19
                font.bold: true
            }

            NavButton { label: "›"; onActivated: root.nextMonth() }
            NavButton { label: "»"; onActivated: root.nextYear() }
        }

        GridLayout {
            // Deliberately NOT Layout.fillWidth — that stretched this
            // item's box to the full column width while its 7 fixed-width
            // cells stayed left-packed inside it, dumping all the slack on
            // the right. Sizing to content + centering the box gives even
            // margins on both sides instead.
            Layout.alignment: Qt.AlignHCenter
            columns: 7
            rowSpacing: 6
            columnSpacing: 0

            Repeater {
                model: root.weekdayLabels
                Text {
                    Layout.preferredWidth: 38
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: Theme.overlay1
                    font.pixelSize: 15
                }
            }

            Repeater {
                model: root.monthGrid
                Item {
                    id: dayCell
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 38

                    property bool isToday: root.viewingCurrentMonth && modelData === root.today.getDate()
                    property bool isSelected: root.selected !== null
                        && root.selected.year === root.viewYear
                        && root.selected.month === root.viewMonth
                        && root.selected.day === modelData

                    Rectangle {
                        anchors.centerIn: parent
                        width: 30
                        height: 30
                        radius: 15
                        visible: modelData !== 0
                        color: dayCell.isToday ? Theme.blue
                            : dayCell.isSelected ? Theme.surface2
                            : "transparent"
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData === 0 ? "" : modelData
                        color: dayCell.isToday ? Theme.base : Theme.text
                        font.pixelSize: 15
                    }

                    TapHandler {
                        enabled: modelData !== 0
                        onTapped: root.selectDay(modelData)
                    }
                }
            }
        }
    }
}
