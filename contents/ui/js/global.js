let _onBackOnline = null;
let alpacaService = null;

const DIContainer = {};

const backOnline = new Promise((resolve) => {
  _onBackOnline = resolve;
});

const onBackOnline = () => {
  _onBackOnline();
};

const init = ({ config, fetch, apiService, alpacaApiService }) => {
  // Initialize the AlpacaApiService with fetch and config
  const stocksApi = new alpacaApiService(
    apiService,
    fetch.fetch,
    config.ALPACA_CONFIG,
  );

  console.log(alpacaApiService, stocksApi, stocksApi.loadData);

  DIContainer.stocksApi = stocksApi;
  DIContainer.fetch = fetch;
  DIContainer.config = config;
};
