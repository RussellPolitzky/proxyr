#' Execute Code with a Proxy
#'
#' Sets the proxy environment variables for the duration of the expression.
#'
#' @param expr The code to execute.
#' @param proxy_url The URL of the proxy server (e.g., "http://proxy.example.com:8080").
#'   Defaults to \code{\link{get_default_proxy_url}()}.
#' @param username Optional. The username for the proxy. If not provided, attempts to retrieve from credentials.
#' @param password Optional. The password for the proxy. If not provided, attempts to retrieve from credentials.
#'
#' @export
with_proxy <- function(
    expr,
    proxy_url = get_default_proxy_url(),
    username = NULL,
    password = NULL
) {
    if (is.null(proxy_url)) {
        stop("proxy_url must be provided or set via set_default_proxy_url()")
    }

    # 1. Capture current ambient proxy settings
    old_http <- Sys.getenv("http_proxy", unset = NA)
    old_https <- Sys.getenv("https_proxy", unset = NA)

    # 2. Setup restoration (finally block logic)
    on.exit(
        {
            if (!is.na(old_http)) {
                Sys.setenv(http_proxy = old_http)
            } else {
                Sys.unsetenv("http_proxy")
            }

            if (!is.na(old_https)) {
                Sys.setenv(https_proxy = old_https)
            } else {
                Sys.unsetenv("https_proxy")
            }
        },
        add = TRUE
    )

    # 3. Resolve Credentials
    if (is.null(username) || is.null(password)) {
        creds <- get_proxy_credentials(proxy_url)
        if (!is.null(creds)) {
            username <- creds$username
            password <- creds$password
        }
    }

    # 4. Construct Proxy String
    # Format: scheme://user:pass@host:port (or similar)
    # parsing proxy_url to insert auth if needed

    # Check if proxy_url has scheme
    if (!grepl("://", proxy_url)) {
        # Assume http if no scheme, or just append
        # But usually proxy_url should include it.
        # If the user passed "proxy.com:8080", we might prepend http://
        full_proxy <- paste0("http://", proxy_url)
    } else {
        full_proxy <- proxy_url
    }

    if (!is.null(username) && !is.null(password)) {
        # Encode credentials
        enc_user <- utils::URLencode(username, reserved = TRUE)
        enc_password <- utils::URLencode(password, reserved = TRUE)

        # Split scheme and rest
        parts <- strsplit(full_proxy, "://")[[1]]
        if (length(parts) == 2) {
            scheme <- parts[1]
            rest <- parts[2]
            proxy_string <- sprintf(
                "%s://%s:%s@%s",
                scheme,
                enc_user,
                enc_password,
                rest
            )
        } else {
            # Fallback if parsing fails (should unlikely if checked above)
            proxy_string <- sprintf(
                "http://%s:%s@%s",
                enc_user,
                enc_password,
                full_proxy
            )
        }
    } else {
        proxy_string <- full_proxy
    }

    # 5. Set Environment Variables
    Sys.setenv(http_proxy = proxy_string)
    Sys.setenv(https_proxy = proxy_string)

    # 6. Execute Expression
    force(expr)
}
