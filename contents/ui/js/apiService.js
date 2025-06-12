/**
 * Service class that wraps fetch functionality for making API requests
 *
 * @example
 * // Import or require the necessary fetch function
 * // const fetch = require('./fetch.js');
 *
 * // Create a new service instance with the fetch function injected
 * const apiService = new Service(fetch, 'https://api.example.com');
 *
 * // Make a GET request
 * apiService.get('users')
 *   .then(data => {
 *     console.log('Users:', data);
 *   })
 *   .catch(error => {
 *     console.error('Error fetching users:', error);
 *   });
 */
class ApiService {
  /**
   * Creates a new Service instance
   * @param {Function} fetchFn - The fetch function to use for requests
   * @param {string} baseUrl - Base URL for all requests
   * @param {Object} defaultHeaders - Default headers to include in all requests
   *
   * @example
   * // Basic usage
   * const service = new Service(fetch);
   *
   * // With base URL
   * const apiService = new Service(fetch, 'https://api.example.com');
   *
   * // With base URL and custom headers
   * const authService = new Service(
   *   fetch,
   *   'https://api.example.com',
   *   { 'Authorization': 'Bearer token123' }
   * );
   */
  constructor(fetchFn, baseUrl = "", defaultHeaders = {}) {
    this.fetch = fetchFn;
    this.baseUrl = baseUrl;
    this.defaultHeaders = Object.assign(
      { "Content-Type": "application/json" },
      defaultHeaders,
    );
  }

  /**
   * Creates a full URL from the given path
   * @param {string} path - The path to append to the base URL
   * @returns {string} The complete URL
   *
   * @example
   * // With base URL = 'https://api.example.com'
   * service.buildUrl('users'); // Returns 'https://api.example.com/users'
   * service.buildUrl('/users'); // Returns 'https://api.example.com/users'
   *
   * // If path is already a full URL, it's returned as-is
   * service.buildUrl('https://other-api.com/data'); // Returns 'https://other-api.com/data'
   */
  buildUrl(path) {
    // If path is already a full URL, return it
    if (path.startsWith("http://") || path.startsWith("https://")) {
      return path;
    }

    // Ensure there's a slash between baseUrl and path
    const normalizedBase = this.baseUrl.endsWith("/")
      ? this.baseUrl
      : `${this.baseUrl}/`;
    const normalizedPath = path.startsWith("/") ? path.substring(1) : path;

    return `${normalizedBase}${normalizedPath}`;
  }

  /**
   * Performs a fetch request with the given options
   * @param {string} path - The path to fetch from
   * @param {Object} options - Fetch options
   * @returns {Promise} A promise that resolves to the fetch response
   */
  request(path, options = {}) {
    const url = this.buildUrl(path);
    const headers = Object.assign({}, this.defaultHeaders, options.headers);

    const fetchOptions = Object.assign({}, options, {
      headers: headers,
    });

    console.debug(`Requesting ${url}`);

    return this.fetch(url, fetchOptions).then((response) => {
      if (!response.ok) {
        throw new Error(
          `HTTP error ${response.status}: ${response.statusText}`,
        );
      }

      // Check the content type to determine how to parse the response
      const contentType = response.headers.get("content-type");
      if (contentType && contentType.includes("application/json")) {
        return response.json();
      }

      return response.text();
    });
  }

  /**
   * Performs a GET request
   * @param {string} path - The path to fetch from
   * @param {Object} options - Additional fetch options
   * @returns {Promise} A promise that resolves to the fetch response
   *
   * @example
   * // Basic GET request
   * service.get('users')
   *   .then(data => console.log(data))
   *   .catch(error => console.error(error));
   *
   * // GET request with query parameters and custom headers
   * service.get('users', {
   *   headers: { 'Cache-Control': 'no-cache' },
   *   params: { page: 1, limit: 10 }
   * });
   */
  get(path, options = {}) {
    return this.request(
      path,
      Object.assign(
        {
          method: "GET",
        },
        options,
      ),
    );
  }

  /**
   * Performs a POST request
   * @param {string} path - The path to fetch from
   * @param {Object} data - The data to send
   * @param {Object} options - Additional fetch options
   * @returns {Promise} A promise that resolves to the fetch response
   *
   * @example
   * // Create a new user
   * service.post('users', {
   *   name: 'John Doe',
   *   email: 'john@example.com'
   * })
   *   .then(response => console.log('User created:', response))
   *   .catch(error => console.error('Error:', error));
   *
   * // POST with custom headers
   * service.post('auth/login',
   *   { username: 'user', password: 'pass' },
   *   { headers: { 'X-Custom-Header': 'value' } }
   * );
   */
  post(path, data, options = {}) {
    return this.request(
      path,
      Object.assign(
        {
          method: "POST",
          body: JSON.stringify(data),
        },
        options,
      ),
    );
  }

  /**
   * Performs a PUT request
   * @param {string} path - The path to fetch from
   * @param {Object} data - The data to send
   * @param {Object} options - Additional fetch options
   * @returns {Promise} A promise that resolves to the fetch response
   */
  put(path, data, options = {}) {
    return this.request(
      path,
      Object.assign(
        {
          method: "PUT",
          body: JSON.stringify(data),
        },
        options,
      ),
    );
  }

  /**
   * Performs a DELETE request
   * @param {string} path - The path to fetch from
   * @param {Object} options - Additional fetch options
   * @returns {Promise} A promise that resolves to the fetch response
   */
  delete(path, options = {}) {
    return this.request(
      path,
      Object.assign(
        {
          method: "DELETE",
        },
        options,
      ),
    );
  }

  /**
   * Sets a new base URL
   * @param {string} baseUrl - The new base URL
   *
   * @example
   * // Change API endpoint
   * service.setBaseUrl('https://new-api.example.com');
   *
   * // Switch between development and production
   * if (isDevelopment) {
   *   service.setBaseUrl('https://dev-api.example.com');
   * } else {
   *   service.setBaseUrl('https://prod-api.example.com');
   * }
   */
  setBaseUrl(baseUrl) {
    this.baseUrl = baseUrl;
  }

  /**
   * Sets or updates default headers
   * @param {Object} headers - The headers to set
   * @param {boolean} replace - Whether to replace all existing headers
   *
   * @example
   * // Add authorization header
   * service.setHeaders({
   *   'Authorization': 'Bearer token123'
   * });
   *
   * // Replace all headers
   * service.setHeaders({
   *   'Content-Type': 'application/xml',
   *   'Accept': 'application/xml'
   * }, true);
   */
  setHeaders(headers, replace = false) {
    if (replace) {
      this.defaultHeaders = Object.assign({}, headers);
    } else {
      this.defaultHeaders = Object.assign({}, this.defaultHeaders, headers);
    }
  }
}

// Export the Service class if using CommonJS modules
// module.exports = Service;

// Or for ES modules
// export default Service;
