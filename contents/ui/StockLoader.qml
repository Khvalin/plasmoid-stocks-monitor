import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

Item {
    id: stockLoader

    property var global: null
    property bool isLoading: false

    function refreshData() {
        isLoading = true;

        const symbols = plasmoid.configuration.selectedSymbols;
        const endDate = (new Date());
        const startDate = new Date(endDate);
        startDate.setHours(startDate.getHours() - 24);

        const stocksApi = global.DIContainer.stocksApi;

        const loadAllData = () => Promise.all([stocksApi.getHistoricalData(symbols, '20Min', startDate, undefined), stocksApi.getLatestMarketData(symbols)]) //cr
            .then(([historicalData, latestData]) => {
                const stocksData = {};
                for (const symbol in latestData.bars) {
                    // Convert historical data to a Qt6-compatible format
                    let historicalPrices = [];
                    if (historicalData?.bars[symbol]) {
                        for (let i = 0; i < historicalData.bars[symbol].length; i++) {
                            if (historicalData.bars[symbol][i] &&
                                historicalData.bars[symbol][i].vw !== undefined) {
                                historicalPrices.push({
                                    value: historicalData.bars[symbol][i].vw
                                });
                            }
                        }
                    }

                    stocksData[symbol] = {
                        currentWeightedPrice: latestData.bars[symbol].vw,
                        historicalWeightedPrice: historicalPrices,
                        historicalDateTime: historicalData?.bars[symbol]?.map(data => data.t)
                    };
                }
                console.debug("loaded data for Qt6 charts", JSON.stringify(stocksData));

                return stocksData;
            }).catch(error => {
                console.error("Failed to load data:", error);
            });

        global.backOnline.then(loadAllData().then(data => {
            stockQuotes.stockData = data;
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
