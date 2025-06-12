import QtQuick 2.15
import "js/config.js" as Config
import "js/fetch.js" as Fetch
import "js/apiService.js" as ApiServiceModule
import "js/alpacaApiService.js" as AlpacaApiServiceModule

import "js/global.js" as Global

import QtQuick.Layouts 1.15
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.12 as Kirigami

//import org.kde.plasma.networkmanagement as PlasmaNM

PlasmoidItem {
    id: root

    width: 10 * Kirigami.Units.gridUnit
    height: 20 * Kirigami.Units.gridUnit

    property bool isOnline: false

    Component.onCompleted: {
        Global.init({
            "config": Config,
            "fetch": Fetch,
            "apiService": ApiServiceModule.ApiService,
            "alpacaApiService": AlpacaApiServiceModule.AlpacaApiService
        });

        Global.backOnline.then(() => {
            root.isOnline = true;
        });

        Global.onBackOnline();
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
                running: !root.isOnline
                visible: !root.isOnline
                Layout.preferredHeight: 4 * Kirigami.Units.gridUnit
                Layout.preferredWidth: 4 * Kirigami.Units.gridUnit
            }

            StockLoader {
                id: stockLoader
                global: Global
                anchors.fill: parent
                opacity: !root.isOnline ? 0.6 : 1.0
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
                stockLoader.refreshData();
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
