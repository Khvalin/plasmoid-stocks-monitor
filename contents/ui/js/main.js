

const dbgprint = () => {
}

const fetchJsonFromInternet = (getUrl, successCallback, failureCallback) => {
    dbgprint("fetchJsonFromInternet")
    var xhr = new XMLHttpRequest()
    //xhr.timeout = loadingData.loadingDataTimeoutMs;
    dbgprint('GET url opening: ' + getUrl)
    xhr.open('GET', getUrl)
    xhr.setRequestHeader("User-Agent","Mozilla/5.0 (X11; Linux x86_64) Gecko/20100101 ")
    dbgprint('GET url sending: ' + getUrl)
    xhr.send()

    xhr.ontimeout = () => {
        dbgprint('ERROR - timeout: ' + xhr.status)
        failureCallback()
    }

    xhr.onerror = (event) => {
        dbgprint('ERROR - status: ' + xhr.status)
        dbgprint('ERROR - responseText: ' + xhr.responseText)
        failureCallback()
    }

    xhr.onload =  (event) => {
        dbgprint('status: ' + xhr.status)
        // dbgprint('responseText: ' + xhr.responseText)
    };

    // success
    xhr.onload = () => {
        dbgprint('successfully loaded from the internet')
        dbgprint('successfully of url-call: ' + getUrl)
        // dbgprint('responseText: ' + xhr.responseText)

        var jsonString = xhr.responseText
        if (!isJsonString(jsonString)) {
            dbgprint('incoming jsonString is not valid: ' + jsonString)
            return
        }
        dbgprint('incoming text seems to be valid')

        successCallback(jsonString)
    }
    dbgprint('GET called for url: ' + getUrl)
    return xhr
}

function isJsonString(str) {
    try {
        JSON.parse(str)
    } catch (e) {
        return false
    }
    return true
}

const init = ({config, fetch}) => {
    this.fetch = fetch;
    this.config = config;
};

const loadData = () => {
    const initData = {
        method: "GET",
        headers: {
            "Content-Type": "application/json"
        },
    }

    if (this.config?.ALPACA_CONFIG?.headers) {
        initData.headers = Object.assign({}, initData.headers, this.config.ALPACA_CONFIG.headers);
    }

    return this.fetch.fetch("https://data.alpaca.markets/v2/stocks/bars/latest?symbols=AAPL%2CTSLA&feed=iex", initData)
    //     .then((data) => {
    //         console.log(JSON.stringify(data));
    //     }
    // );
}
