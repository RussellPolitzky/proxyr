#' Set Default Proxy URL
#'
#' Sets the default proxy URL to be used by \code{\link{with_proxy}}.
#'
#' @param proxy_url The URL of the proxy server (e.g., "http://proxy.example.com:8080").
#'
#' @examples
#' \dontrun{
#' set_default_proxy_url("http://proxy.example.com:8080")
#' }
#' @export
set_default_proxy_url <- function(proxy_url) {
    options(proxyr.url = proxy_url)
    invisible(proxy_url)
}

#' Get Default Proxy URL
#'
#' Retrieves the default proxy URL. Checks the R option `proxyr.url` first,
#' then the `PROXY_URL` environment variable.
#'
#' On Windows, if no configuration is found, it attempts to retrieve the
#' system proxy settings using `curl::ie_get_proxy_for_url`.
#'
#' @return The default proxy URL, or NULL if not set.
#' @examples
#' get_default_proxy_url()
#' @export
get_default_proxy_url <- function() {
    url <- getOption("proxyr.url")
    if (!is.null(url)) {
        return(url)
    }

    url <- Sys.getenv("PROXY_URL", unset = NA)
    if (!is.na(url) && url != "") {
        return(url)
    }

    # Fallback to system proxy on Windows
    if (
        .Platform$OS.type == "windows" &&
            requireNamespace("curl", quietly = TRUE)
    ) {
        # We need a target URL to check the proxy for.
        # We use a generic one.
        target <- "http://www.google.com"
        sys_proxy <- tryCatch(
            curl::ie_get_proxy_for_url(target),
            error = function(e) NULL
        )
        # ie_get_proxy_for_url returns NULL if no proxy, or the proxy URL string
        if (!is.null(sys_proxy)) {
            return(sys_proxy)
        }
    }

    NULL
}

#' Set Default No Proxy String
#'
#' Sets the default no_proxy string to be used by \code{\link{with_proxy}}.
#'
#' @param no_proxy The no_proxy string (e.g., "localhost,127.0.0.1").
#'
#' @export
set_default_no_proxy <- function(no_proxy) {
    options(proxyr.no_proxy = no_proxy)
    invisible(no_proxy)
}

#' Get Default No Proxy String
#'
#' Retrieves the default no_proxy string. Checks the R option `proxyr.no_proxy` first,
#' then the `NO_PROXY` environment variable.
#'
#' @return The default no_proxy string, or NULL if not set.
#' @examples
#' get_default_no_proxy()
#' @export
get_default_no_proxy <- function() {
    np <- getOption("proxyr.no_proxy")
    if (is.null(np)) {
        np <- Sys.getenv("NO_PROXY", unset = NA)
        if (is.na(np) || np == "") {
            # Try lowercase too just in case
            np <- Sys.getenv("no_proxy", unset = NA)
            if (is.na(np) || np == "") {
                return(NULL)
            }
        }
    }
    np
}
