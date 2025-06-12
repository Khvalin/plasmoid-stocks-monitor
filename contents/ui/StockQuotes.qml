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

            // Extract value safely with fallbacks
            let stockValue = "N/A";
            let stockHistoricalPrice = [];
            try {
                if (stockData?.[key] && Number.isFinite(stockData[key]?.currentWeightedPrice)) {
                    stockValue = stockData[key].currentWeightedPrice.toLocaleString(Qt.locale(), 'f', 2);
                    stockHistoricalPrice = stockData[key].historicalWeightedPrice;
                }
            } catch (e) {
                console.log("Error formatting stock value for " + key + ": " + e);
            }

            stockDataFlat.append({
                symbol: key,
                "value": stockValue,
                "historicalPrice": stockHistoricalPrice || []
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

    ListView {
        id: listView
        anchors.fill: parent
        model: stockDataFlat
        spacing: 5
        clip: true

        delegate: ColumnLayout {
            width: listView.width
            RowLayout {
                width: parent.width
                spacing: Kirigami.Units.smallSpacing

                Text {
                    id: symbolText
                    Layout.minimumWidth: 80
                    Layout.preferredWidth: implicitWidth + 20
                    Layout.maximumWidth: parent.width / 2

                    text: model.symbol
                    color: Kirigami.Theme.textColor
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize
                    font.bold: true
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter

                    leftPadding: Kirigami.Units.mediumSpacing
                    rightPadding: Kirigami.Units.mediumSpacing
                    topPadding: Kirigami.Units.mediumSpacing / 2
                    bottomPadding: Kirigami.Units.mediumSpacing / 2
                }

                Text {
                    id: valueText
                    Layout.fillWidth: true  // Takes remaining space

                    text: model.value
                    color: Kirigami.Theme.textColor
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter

                    leftPadding: Kirigami.Units.mediumSpacing
                    rightPadding: Kirigami.Units.mediumSpacing
                    topPadding: Kirigami.Units.mediumSpacing / 2
                    bottomPadding: Kirigami.Units.mediumSpacing / 2
                }
            }

            RowLayout {
                width: parent.width
                spacing: Kirigami.Units.smallSpacing

                MiniGraphPlotter {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    dataPoints: model.historicalPrice
                    lineColor: Kirigami.Theme.highlightColor
                    showFill: true
                }
            }
        }
    }
}
