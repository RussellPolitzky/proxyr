test_that("credential management works", {
    skip_on_cran() # Keyring might not work on CRAN machines

    proxy <- "http://test.proxy.local"
    user <- "testuser"
    pass <- "testpass"

    # Ensure clean state
    try(remove_proxy_credentials(proxy), silent = TRUE)

    # Set
    expect_message(
        set_proxy_credentials(proxy, user, pass),
        "Credentials stored"
    )

    # Get
    creds <- get_proxy_credentials(proxy)
    expect_equal(creds$username, user)
    expect_equal(creds$password, pass)

    # List (basic check that we get a dataframe)
    expect_true(is.data.frame(list_proxy_credentials()))

    # Remove
    expect_message(remove_proxy_credentials(proxy), "Credentials removed")
    expect_null(get_proxy_credentials(proxy))
})
