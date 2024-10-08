import QtQuick 2.15
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents

import "js/fetch.js" as Fetch
import "js/config.js" as Config
import "js/main.js" as Main
//import "js/polygon-dist.js" as PolygonJS

PlasmoidItem {
	id: root
    width: 400
    height: 200

    //property string stocks:

	StockQuotes {
		id: stockQuotes
	}

    Component.onCompleted: {
        Main.init({config: Config, fetch: Fetch})
        //Main.loadData()
    }
}


