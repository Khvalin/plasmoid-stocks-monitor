let _onBackOnline = null;

const backOnline = new Promise((resolve) => {
  _onBackOnline = resolve;
});

const onBackOnline = () => {
  _onBackOnline();
};

const init = ({ config, fetch }) => {
  this.fetch = fetch;
  this.config = config;
};

const loadData = () => {
  const initData = {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
    },
  };

  if (this.config?.ALPACA_CONFIG?.headers) {
    initData.headers = Object.assign(
      {},
      initData.headers,
      this.config.ALPACA_CONFIG.headers,
    );
  }

  const url = new URL("https://data.alpaca.markets/v2/stocks/bars/latest");

  url.searchParams.set("symbols", plasmoid.configuration.selectedSymbols);
  url.searchParams.set("feed", "iex");

  return this.fetch.fetch(url.toString(), initData);
};
