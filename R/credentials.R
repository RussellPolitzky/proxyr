#' Set Proxy Credentials
#'
#' Stores the username and password for a specific proxy server in the Windows
#' Credential Manager using the keyring package.
#'
#' @param proxy_url The URL of the proxy server (e.g., "http://proxy.example.com:8080").
#'   This is used as the service name in keyring.
#' @param username The username for the proxy.
#' @param password The password for the proxy.
#'
#' @examples
#' \dontrun{
#' set_proxy_credentials("http://my.proxy.com:8080", "myuser", "mypass")
#' }
#' @export
set_proxy_credentials <- function(proxy_url, username, password) {
  if (missing(proxy_url) || missing(username) || missing(password)) {
    stop("proxy_url, username, and password are required.")
  }
  keyring::key_set_with_value(
    service = proxy_url,
    username = username,
    password = password
  )
  message("Credentials stored for ", proxy_url)
}

#' Get Proxy Credentials
#'
#' Retrieves the credentials for a specific proxy server.
#'
#' @param proxy_url The URL of the proxy server.
#'
#' @return A list containing `username` and `password`, or NULL if not found.
#' @examples
#' \dontrun{
#' get_proxy_credentials("http://my.proxy.com:8080")
#' }
#' @export
get_proxy_credentials <- function(proxy_url) {
  # keyring::key_list returns specific service/user pairs.
  # We assume one user per proxy for simplicity or find the first one.
  keys <- keyring::key_list(service = proxy_url)

  if (nrow(keys) == 0) {
    return(NULL)
  }

  # For this implementation, we take the first user found for this service.
  # Ideally, we might handle multiple users, but usually there's one.
  usr <- keys$username[1]
  pwd <- keyring::key_get(service = proxy_url, username = usr)

  list(username = usr, password = pwd)
}

#' Remove Proxy Credentials
#'
#' Removes the stored credentials for a specific proxy server.
#'
#' @param proxy_url The URL of the proxy server.
#'
#' @examples
#' \dontrun{
#' remove_proxy_credentials("http://my.proxy.com:8080")
#' }
#' @export
remove_proxy_credentials <- function(proxy_url) {
  keys <- keyring::key_list(service = proxy_url)
  if (nrow(keys) == 0) {
    message("No credentials found for ", proxy_url)
    return(invisible(NULL))
  }

  for (usr in keys$username) {
    keyring::key_delete(service = proxy_url, username = usr)
  }
  message("Credentials removed for ", proxy_url)
}

#' List Proxy Credentials
#'
#' Lists all proxy credentials stored by this package (or matching services).
#' Since keyring stores by service name, this lists all services, or we relies on user knowing.
#'
#' Note: This function lists ALL keys in the keyring if we don't filter.
#' To make this safer, we might only list those that look like urls or just wrap key_list.
#'
#' @return A data frame of keys.
#' @examples
#' \dontrun{
#' list_proxy_credentials()
#' }
#' @export
list_proxy_credentials <- function() {
  # Listing all might be noisy, but keyring::key_list() is the way.
  # We return it directly.
  keyring::key_list()
}
