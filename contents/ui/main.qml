import QtQuick 2.15
import "js/config.js" as Config
import "js/fetch.js" as Fetch
import "js/main.js" as Main

import QtQuick.Layouts
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid

PlasmoidItem {
    //property string stocks:
    //Plasmoid.internalAction("configure").trigger()

    id: root

    width: 200
    height: 400 //Kirigami.Units.gridUnit * 1400

    Component.onCompleted: {
        Main.init({
            "config": Config,
            "fetch": Fetch
        });
        Main.loadData().then((data) => {
            console.log(data._bodyInit);
            const body = JSON.parse(data._bodyInit);
            const bars = body?.bars || [];
            //const symbols = Object.keys(bars)
            stockQuotes.stockData = (bars);
        });
    }

        ColumnLayout{
            width: parent.width
            height: parent.height

            PlasmaComponents.ToolButton {
                text: "Tools"
                onClicked: {
                    contextMenu.open()
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                StockQuotes {
                    //signal stockDataChanged(var stockData)
                    id: stockQuotes
                }
            }
        }
    

    ListModel {
        id: menuModel
        ListElement { name: "Item 1" }
        ListElement { name: "Item 2" }
        ListElement { name: "Item 3" }
    }

    PlasmaExtras.ModelContextMenu {
        id: contextMenu
        model: menuModel
        onTriggered: action=>{
            console.log("Action triggered: " + action.id)
        }
    }
     
}
