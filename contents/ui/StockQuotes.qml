import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.12 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.quickcharts 1.0 as Charts


import org.kde.plasma.extras as PlasmaExtras

Kirigami.AbstractCard {
    id: widget

    property var stockData: []

    width: parent.width
    height: parent.height
    onStockDataChanged: {
        stockDataFlat.clear();
        const keys = plasmoid.configuration.selectedSymbols;
        for (const key of keys) {
            stockDataFlat.append({
                "value": key,
                "isSymbol": true
            });

            // Handle case where data doesn't exist for this symbol
            if (!stockData || !(key in stockData)) {
                stockDataFlat.append({
                    "value": "N/A",
                    "isSymbol": false
                });
                continue;
            }

            // Extract value safely with fallbacks
            let stockValue = "N/A";
            try {
                if (stockData[key] && stockData[key].vw !== undefined) {
                    stockValue = stockData[key].vw.toLocaleString(Qt.locale(), 'f', 2);
                }
            } catch (e) {
                console.log("Error formatting stock value for " + key + ": " + e);
            }

            stockDataFlat.append({
                "value": stockValue,
                "isSymbol": false
            });
        }
    }

    ListModel {
        id: stockDataFlat
    }

    PlasmaComponents.Label {
        id: noDataLabel
        anchors.centerIn: parent
        text: "No stock data available.\nAdd symbols in the settings."
        visible: stockDataFlat.count === 0
        horizontalAlignment: Text.AlignHCenter
        opacity: 0.6
        font.italic: true
    }

    // Use GridView to render the table
    GridView {
        id: gridView

        Layout.fillWidth: true
        height: parent.height
        cellWidth: parent.width / 2
        cellHeight: Kirigami.Theme.defaultFont.pointSize * 2.2
        anchors.fill: parent
        model: stockDataFlat
        clip: true

        delegate: Rectangle {
            id: gridCell
            width: gridView.cellWidth
            height: gridView.cellHeight
            color: "transparent"

            property string value: model.value
            property bool isSymbol: model.isSymbol
            property bool isError: false

            Text {
//                color: value === "N/A" ? Kirigami.Theme.negativeTextColor :
//                       isSymbol ? Kirigami.Theme.disabledTextColor :
//                       Kirigami.Theme.highlightColor
                color: Kirigami.Theme.textColor
                font.pointSize: Kirigami.Theme.defaultFont.pointSize
                font.bold: isSymbol
                text: parent.value
                anchors.fill: parent
                anchors.rightMargin: 10
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

}
