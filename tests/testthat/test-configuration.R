test_that("configuration functions work", {
    # Save original state
    old_opt <- getOption("proxyr.url")
    old_env <- Sys.getenv("PROXY_URL")

    on.exit({
        options(proxyr.url = old_opt)
        if (old_env != "") {
            Sys.setenv(PROXY_URL = old_env)
        } else {
            Sys.unsetenv("PROXY_URL")
        }
    })

    # Clean state
    options(proxyr.url = NULL)
    Sys.unsetenv("PROXY_URL")
    expect_null(get_default_proxy_url())

    # Test option
    set_default_proxy_url("http://opt.proxy")
    expect_equal(get_default_proxy_url(), "http://opt.proxy")

    # Test env var precedence (option should win)
    Sys.setenv(PROXY_URL = "http://env.proxy")
    expect_equal(get_default_proxy_url(), "http://opt.proxy")

    # Test env var fallback
    options(proxyr.url = NULL)
    expect_equal(get_default_proxy_url(), "http://env.proxy")
})

test_that("with_proxy uses default url", {
    # Clean state
    old_opt <- getOption("proxyr.url")
    on.exit(options(proxyr.url = old_opt))
    options(proxyr.url = NULL)

    # Should error if no proxy provided
    expect_error(with_proxy({}, proxy_url = NULL), "proxy_url must be provided")

    # Should use default
    proxy <- "http://default.proxy:8080"
    set_default_proxy_url(proxy)

    with_proxy({
        expect_equal(Sys.getenv("http_proxy"), proxy)
    })
})
