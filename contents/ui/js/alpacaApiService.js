/**
 * AlpacaApiService class specifically for interacting with Alpaca Markets API
 */
class AlpacaApiService {
  /**
   * Creates a new AlpacaApiService instance
   * @param {Function} fetchFn - The fetch function to use for requests
   * @param {Object} config - Configuration for Alpaca API
   */
  constructor(apiService, fetchFn, config = {}) {
    // Create an instance of ApiService to delegate to
    this.apiService = new apiService(
      fetchFn,
      "https://data.alpaca.markets/v2",
      config.headers || {},
    );
    this.config = config;
  }

  /**
   *  Gets the latest market data for specified symbol
   * @param {string} symbols - Comma-separated list of stock symbols to fetch
   * @param {string} feed - The data feed to use (default: 'iex')
   * @returns {Promise} A promise that resolves to the stock data
   */
  getLatestMarketData(symbols, feed = "iex") {
    // Build the query parameters
    const queryParams = new URLSearchParams();
    queryParams.set("symbols", symbols);
    queryParams.set("feed", feed);

    // Make the API request
    return this.apiService
      .get(`stocks/bars/latest?${queryParams.toString()}`)
      .then((response) => {
        // Return the formatted response

        return {
          bars: response?.bars ?? [],
        };
      });
  }

  /**
   * Gets historical data for a specific symbol
   * @param {string} symbol - The stock symbol
   * @param {string} timeframe - Timeframe for the data (e.g., '1D', '1H', etc.)
   * @param {Date} start - Start date in ISO format
   * @param {Date} end - End date in ISO format
   * @returns {Promise} A promise that resolves to historical data
   */
  getHistoricalData(symbols, timeframe = "1D", start, end) {
    const queryParams = new URLSearchParams();
    queryParams.set("symbols", symbols);
    queryParams.set("feed", "iex");
    queryParams.set("timeframe", timeframe);

    if (start) {
      queryParams.set("start", start.toISOString());
    }

    if (end) {
      queryParams.set("end", end.toISOString());
    }

    console.log(start.toISOString());

    return this.apiService.get(`stocks/bars?${queryParams.toString()}`);
  }

  /**
   * Gets information about specific stocks
   * @param {string} symbols - Comma-separated list of stock symbols
   * @returns {Promise} A promise that resolves to stock information
   */
  getStockInfo(symbols) {
    return this.apiService.get(`stocks?symbols=${symbols}`);
  }

  /**
   * Sets Alpaca API credentials
   * @param {string} apiKey - The Alpaca API key
   * @param {string} apiSecret - The Alpaca API secret
   */
  setCredentials(apiKey, apiSecret) {
    this.apiService.setHeaders({
      "APCA-API-KEY-ID": apiKey,
      "APCA-API-SECRET-KEY": apiSecret,
    });
  }
}
