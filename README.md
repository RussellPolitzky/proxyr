# proxyr

The `proxyr` package provides tools to manage proxy settings and credentials in R.

## Installation

You can install `proxyr` from this repository.

## Usage

### Using `with_proxy`

The `with_proxy` function executes code with temporary proxy environment variables set. It ensures that proxy settings are restored after execution, even if an error occurs.

```r
library(proxyr)

# Execute code with a proxy
with_proxy({
  # code that needs proxy access
  # e.g., curl::curl_fetch_memory("http://example.com")
}, proxy_url = "http://my.proxy.com:8080")
```

### Default Configuration & Windows Fallback

You can set a default proxy URL to avoid passing it every time.

```r
set_default_proxy_url("http://my.proxy.com:8080")
```

**Windows System Proxy**: If you are running on Windows and have **not** configured a default proxy URL (and `PROXY_URL` env var is not set), `proxyr` will automatically detect and use your system proxy settings (via `curl::ie_get_proxy_for_url`).

### Bypassing Proxy (`no_proxy`)

You can specify domains to bypass the proxy using the `no_proxy` argument or configuration.

```r
# Set a default no_proxy string
set_default_no_proxy("localhost,127.0.0.1,.internal.net")

# Or pass it explicitly
with_proxy({
  # ...
}, no_proxy = "localhost")
```

### Credential Management

You can store proxy credentials securely using the Windows Credential Manager (via the `keyring` package).

> **SECURITY WARNING**: Never hardcode your username and password in your scripts. Run `set_proxy_credentials` **once** interactively to store them.

**Smart URL Handling**: `proxyr` normalizes URLs, so `proxy.com:8080`, `http://proxy.com:8080` and `http://proxy.com:8080/` are treated as the same key.

```r
# Run ONCE in the console, do not save in a script!
set_default_proxy_url("http://my.proxy.com:8080")
set_proxy_credentials("http://my.proxy.com:8080", "username", "password")

# Use them automatically
with_proxy({
  # proxyr retrieves the username/password and sets environment variables
})
```

### Functions

-   **Execution**: `with_proxy`
-   **Configuration**:
    -   `set_default_proxy_url` / `get_default_proxy_url`
    -   `set_default_no_proxy` / `get_default_no_proxy`
-   **Credentials**:
    -   `set_proxy_credentials`
    -   `remove_proxy_credentials`
    -   `list_proxy_credentials`
    -   *(Note: `get_proxy_credentials` is internal for security)*
