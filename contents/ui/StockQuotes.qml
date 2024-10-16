pragma ComponentBehavior: Bound  // Enable bound component behavior

import QtQuick
import QtQuick.Layouts
import org.kde.quickcharts as Charts

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: widget
    height: 4000
    width: 400

    property var stockData: []


    ListModel {
        id: stockDataFlat
        // Pre-defined items in the ListModel
        ListElement { value: "Item 1" }
        ListElement { value: "Item 2" }
        ListElement { value: "Item 3" }
        ListElement { value: "Item 4" }
        ListElement { value: "Item 5" }
    }

    // Use GridView to render the table
    GridView {
        id: gridView
        anchors.fill: parent
        model: stockDataFlat


        delegate: Text {

            required property string value
                anchors.centerIn: parent
                text: value  // Access the text role directly
            }
    }



    onStockDataChanged: {
        stockDataFlat.clear()
        for (const key of Object.keys(stockData)) {
            stockDataFlat.append({value: key})
            stockDataFlat.append({value: `${stockData[key].vw}`})
        }

        console.log("Stock Data Changed:", JSON.stringify(stockDataFlat));
    }

}

