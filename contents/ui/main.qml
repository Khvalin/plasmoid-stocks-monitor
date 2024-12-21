import QtQuick 2.15
import "js/config.js" as Config
import "js/fetch.js" as Fetch
import "js/main.js" as Main
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    //property string stocks:
    //Plasmoid.internalAction("configure").trigger()

    id: root

    width: 200
    height: 400
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

    StockQuotes {
        //signal stockDataChanged(var stockData)

        id: stockQuotes
    }

    // Plasmoid.contextualActions: [
    //     PlasmaCore.Action {
    //         text: i18nc("@action", "Open System Monitor…")
    //         icon.name: "utilities-system-monitor"
    //         onTriggered: Plasmoid.openSystemMonitor()
    //     }
    // ]


}
