#' Execute Code with a Proxy
#'
#' Sets the proxy environment variables for the duration of the expression.
#'
#' @param expr The code to execute.
#' @param proxy_url The URL of the proxy server (e.g., "http://proxy.example.com:8080").
#'   Defaults to \code{\link{get_default_proxy_url}()}.
#' @param no_proxy Optional. A string designating domains to bypass the proxy
#'   (e.g., "localhost,127.0.0.1"). Defaults to \code{\link{get_default_no_proxy}()}.
#' @param username Optional. The username for the proxy. If not provided, attempts to retrieve from credentials.
#' @param password Optional. The password for the proxy. If not provided, attempts to retrieve from credentials.
#'
#' @examples
#' \dontrun{
#' set_default_proxy_url("http://my.proxy:8080")
#' set_proxy_credentials("http://my.proxy:8080", "user", "pass")
#'
#' with_proxy({
#'   # Code that requires proxy
#'   Sys.getenv("http_proxy")
#' })
#'
#' # With no_proxy
#' with_proxy({
#'   Sys.getenv("no_proxy")
#' }, no_proxy = "localhost")
#' }
#' @export
with_proxy <- function(
    expr,
    proxy_url = get_default_proxy_url(),
    no_proxy = get_default_no_proxy(),
    username = NULL,
    password = NULL
) {
    if (is.null(proxy_url)) {
        stop("proxy_url must be provided or set via set_default_proxy_url()")
    }

    # Normalize the proxy URL to ensure consistency with stored credentials
    proxy_url <- normalize_proxy_url(proxy_url)

    # 1. Capture current ambient proxy settings
    old_http <- Sys.getenv("http_proxy", unset = NA)
    old_https <- Sys.getenv("https_proxy", unset = NA)
    old_no_proxy <- Sys.getenv("no_proxy", unset = NA)
    old_NO_PROXY <- Sys.getenv("NO_PROXY", unset = NA)

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

            if (!is.na(old_no_proxy)) {
                Sys.setenv(no_proxy = old_no_proxy)
            } else {
                Sys.unsetenv("no_proxy")
            }
            if (!is.na(old_NO_PROXY)) {
                Sys.setenv(NO_PROXY = old_NO_PROXY)
            } else {
                Sys.unsetenv("NO_PROXY")
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
    if (!grepl("://", proxy_url)) {
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

    if (!is.null(no_proxy)) {
        Sys.setenv(no_proxy = no_proxy)
        Sys.setenv(NO_PROXY = no_proxy)
    }

    # 6. Execute Expression
    force(expr)
}
