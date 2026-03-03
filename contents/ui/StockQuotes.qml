import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid


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
            let histPrice = [];
            try {
                if (stockData?.[key] && Number.isFinite(stockData[key]?.currentWeightedPrice)) {
                    stockValue = stockData[key].currentWeightedPrice.toLocaleString(Qt.locale(), 'f', 2);
                }
                if (stockData?.[key] && Array.isArray(stockData[key]?.historicalWeightedPrice)) {
                    histPrice = stockData[key].historicalWeightedPrice;
                }
            } catch (e) {
                console.log("Error formatting stock value for " + key + ": " + e);
            }

            stockDataFlat.append({
                symbol: key,
                "value": stockValue,
                "historicalPrice": histPrice
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
            id: stockItem
            width: listView.width

            property bool graphExpanded: false
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

                PlasmaComponents.ToolButton {
                    id: expandButton
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small

                    icon.name: stockItem.graphExpanded ? "arrow-up" : "arrow-down"

                    onClicked: {
                        stockItem.graphExpanded = !stockItem.graphExpanded;
                    }

                    PlasmaComponents.ToolTip {
                        text: stockItem.graphExpanded ? "Hide graph" : "Show graph"
                    }
                }
            }

            RowLayout {
                id: graphRow
                width: parent.width
                spacing: Kirigami.Units.smallSpacing
                visible: stockItem.graphExpanded
                opacity: stockItem.graphExpanded ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                MiniGraphPlotter {
                    Layout.fillWidth: true
                    Layout.preferredHeight: stockItem.graphExpanded ? 30 : 0
                    dataPoints: model.historicalPrice || []
                    lineColor: Kirigami.Theme.highlightColor
                    showFill: true

                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }
    }
}
