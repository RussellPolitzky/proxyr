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

### Credential Management

You can store proxy credentials securely using the Windows Credential Manager (via the `keyring` package).

```r
# Store credentials for a proxy
set_proxy_credentials("http://my.proxy.com:8080", "username", "password")

# Use them automatically in with_proxy
with_proxy({
  # ...
}, proxy_url = "http://my.proxy.com:8080")
# proxyr retrieves the username/password automatically
```

### Other Functions

- `set_proxy_credentials(proxy_url, username, password)`
- `get_proxy_credentials(proxy_url)`
- `remove_proxy_credentials(proxy_url)`
- `list_proxy_credentials()`
