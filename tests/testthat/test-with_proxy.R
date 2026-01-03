test_that("with_proxy sets environment variables correctly", {
    proxy <- "http://proxy.local:8080"

    # Test without credentials
    with_proxy(
        {
            expect_equal(Sys.getenv("http_proxy"), proxy)
            expect_equal(Sys.getenv("https_proxy"), proxy)
        },
        proxy_url = proxy
    )

    # Ensure restoration
    expect_equal(Sys.getenv("http_proxy"), "")
    expect_equal(Sys.getenv("https_proxy"), "")
})

test_that("with_proxy handles credentials", {
    proxy <- "http://proxy.local:8080"
    user <- "user"
    pass <- "pass"
    expected <- "http://user:pass@proxy.local:8080"

    with_proxy(
        {
            expect_equal(Sys.getenv("http_proxy"), expected)
        },
        proxy_url = proxy,
        username = user,
        password = pass
    )
})

test_that("with_proxy retrieves credentials from keyring", {
    skip_on_cran()

    proxy <- "http://auth.proxy.local"
    user <- "k_user"
    pass <- "k_pass"

    set_proxy_credentials(proxy, user, pass)
    on.exit(remove_proxy_credentials(proxy))

    expected <- "http://k_user:k_pass@auth.proxy.local"

    with_proxy(
        {
            expect_equal(Sys.getenv("http_proxy"), expected)
        },
        proxy_url = proxy
    )
})

test_that("with_proxy restores environment on error", {
    proxy <- "http://proxy.local:8080"

    old_http <- Sys.getenv("http_proxy")

    try(
        with_proxy(
            {
                stop("Validation error")
            },
            proxy_url = proxy
        ),
        silent = TRUE
    )

    expect_equal(Sys.getenv("http_proxy"), old_http)
})

# Real connectivity test (skipped unless configured)
test_that("real proxy connection works", {
    # To run this test, set PROXYR_TEST_PROXY env var to a valid proxy
    # e.g. PROXYR_TEST_PROXY="http://MyProxy:8080"
    test_proxy <- Sys.getenv("PROXYR_TEST_PROXY")
    if (test_proxy == "") {
        skip("PROXYR_TEST_PROXY not set")
    }

    with_proxy(
        {
            # Simple check: can we verify our IP or headers through the proxy?
            # This depends on the proxy type.
            # For now, just ensure no error on a simple request (if curl/httr installed)
            if (requireNamespace("curl", quietly = TRUE)) {
                req <- try(
                    curl::curl_fetch_memory("http://google.com"),
                    silent = TRUE
                )
                expect_false(inherits(req, "try-error"))
            }
        },
        proxy_url = test_proxy
    )
})

test_that("with_proxy sets no_proxy matches", {
    proxy <- "http://test.proxy:8080"
    np <- "localhost,127.0.0.1"

    with_proxy(
        {
            expect_equal(Sys.getenv("http_proxy"), proxy)
            expect_equal(Sys.getenv("no_proxy"), np)
            expect_equal(Sys.getenv("NO_PROXY"), np)
        },
        proxy_url = proxy,
        no_proxy = np
    )
})
