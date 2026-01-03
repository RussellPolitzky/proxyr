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
#' @return The default proxy URL, or NULL if not set.
#' @examples
#' get_default_proxy_url()
#' @export
get_default_proxy_url <- function() {
    url <- getOption("proxyr.url")
    if (is.null(url)) {
        url <- Sys.getenv("PROXY_URL", unset = NA)
        if (is.na(url) || url == "") {
            return(NULL)
        }
    }
    url
}
