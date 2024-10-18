import QtQuick 2.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents

import "js/fetch.js" as Fetch
import "js/config.js" as Config
import "js/main.js" as Main

PlasmoidItem {
	id: root
    width: 200
    height: 400

    //property string stocks:

	StockQuotes {
		id: stockQuotes
		//signal stockDataChanged(var stockData)
	}

    Component.onCompleted: {
        Main.init({config: Config, fetch: Fetch})
        Main.loadData().then((data)=> {
            const body = JSON.parse(data._bodyInit);
            const bars = body?.bars || [];
            //const symbols = Object.keys(bars)
            stockQuotes.stockData = (bars);
        })
        //Plasmoid.internalAction("configure").trigger()
    }
}


