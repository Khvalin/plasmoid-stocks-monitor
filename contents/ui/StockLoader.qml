import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.12 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

import "js/global.js" as Global

Item {
    id: stockLoader

    property bool isLoading: false

    function refreshData() {
        isLoading = true;
        Global.backOnline.then(Global.loadData().then(data => {
            console.log(data._bodyInit);
            const body = JSON.parse(data._bodyInit);
            const bars = body?.bars || [];
            stockQuotes.stockData = bars;
            stockLoader.isLoading = false;
        }).catch(error => {
            console.error("Failed to load stock data:", error);
            isLoading = false;
        }));
    }

    Component.onCompleted: {
        refreshData();
    }

    PlasmaComponents.BusyIndicator {
        anchors.centerIn: parent
        running: stockLoader.isLoading
        visible: stockLoader.isLoading
        width: 4 * Kirigami.Units.gridUnit
        height: 4 * Kirigami.Units.gridUnit
    }

    StockQuotes {
        id: stockQuotes
        anchors.fill: parent
        opacity: stockLoader.isLoading ? 0.6 : 1.0
        Behavior on opacity {
            NumberAnimation {
                duration: 250
            }
        }
    }
}
