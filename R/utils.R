#' Normalize Proxy URL
#'
#' Internal helper to normalize proxy URLs ensuring keys are consistent.
#'
#' @param url The proxy URL string.
#' @return A normalized URL string.
#' @keywords internal
normalize_proxy_url <- function(url) {
    if (is.null(url) || is.na(url)) {
        return(NULL)
    }

    # Remove trailing slash
    url <- sub("/$", "", url)

    # Add http:// if no scheme is present
    # Checks for "scheme://" pattern
    if (!grepl("://", url)) {
        url <- paste0("http://", url)
    }

    url
}
