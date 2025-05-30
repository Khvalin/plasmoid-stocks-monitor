import QtQuick 2.15
import "js/config.js" as Config
import "js/fetch.js" as Fetch
import "js/main.js" as Main

import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.12 as Kirigami

PlasmoidItem {
    //property string stocks:
    //Plasmoid.internalAction("configure").trigger()

    id: root

    width: 10 * Kirigami.Units.gridUnit
    height: 20 * Kirigami.Units.gridUnit

    property bool isLoading: false

    function refreshData() {
        isLoading = true;
        Main.loadData().then(data => {
            console.log(data._bodyInit);
            const body = JSON.parse(data._bodyInit);
            const bars = body?.bars || [];
            stockQuotes.stockData = bars;
            isLoading = false;
        }).catch(error => {
            console.error("Failed to load stock data:", error);
            isLoading = false;
        });
    }

    Component.onCompleted: {
        Main.init({
            "config": Config,
            "fetch": Fetch
        });
        refreshData();
    }

    ColumnLayout {
        width: parent.width
        height: parent.height

        RowLayout {
            Layout.fillWidth: true

            PlasmaComponents.Button {
                text: "Tools"
                icon.name: "configure"
                onClicked: {
                    contextMenu.popup(this, 0, height);
                }
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            PlasmaComponents.BusyIndicator {
                anchors.centerIn: parent
                running: root.isLoading
                visible: root.isLoading
                Layout.preferredHeight: 4 * Kirigami.Units.gridUnit
                Layout.preferredWidth: 4 * Kirigami.Units.gridUnit
            }

            StockQuotes {
                id: stockQuotes
                anchors.fill: parent
                opacity: root.isLoading ? 0.6 : 1.0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                    }
                }
            }
        }
    }

    PlasmaComponents.Menu {
        id: contextMenu

        PlasmaComponents.MenuItem {
            text: "Refresh Data"
            icon.name: "view-refresh"
            enabled: !root.isLoading
            onClicked: {
                refreshData();
            }
        }

        PlasmaComponents.MenuItem {
            text: "Settings"
            icon.name: "configure"
            onClicked: {
                Plasmoid.internalAction("configure").trigger();
            }
        }
    }
}
