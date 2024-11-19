pragma ComponentBehavior: Bound  // Enable bound component behavior

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.quickcharts as Charts

Kirigami.AbstractCard {
    //color: PlasmaCore.Theme.backgroundColor  // Background matches the theme

    id: widget

    property var stockData: []

    width: parent.width
    height: parent.height
    onStockDataChanged: {
        stockDataFlat.clear();
        for (const key of Object.keys(stockData)) {
            stockDataFlat.append({
                "value": key
            });
            stockDataFlat.append({
                "value": `${stockData[key].vw}`
            });
        }
        console.log("Stock Data Changed:", JSON.stringify(stockDataFlat));
    }

    ListModel {
        id: stockDataFlat
    }

    // Use GridView to render the table
    GridView {
        id: gridView

        Layout.fillWidth: true
        height: parent.height
        cellWidth: parent.width / 2
        cellHeight: Kirigami.Theme.defaultFont.pointSize * 1.6
        anchors.fill: parent
        model: stockDataFlat

        delegate: Rectangle {
            id: gridCell

            required property string value

            Text {
                color: Kirigami.Theme.textColor
                font.pointSize: Kirigami.Theme.defaultFont.pointSize
                text: parent.value
            }

        }

    }

}
