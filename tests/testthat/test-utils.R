test_that("normalization works", {
    expect_equal(normalize_proxy_url("http://proxy.com"), "http://proxy.com")
    expect_equal(normalize_proxy_url("proxy.com"), "http://proxy.com")
    expect_equal(normalize_proxy_url("https://proxy.com"), "https://proxy.com")
    expect_equal(normalize_proxy_url("proxy.com/"), "http://proxy.com")
    expect_equal(normalize_proxy_url("http://proxy.com/"), "http://proxy.com")
    expect_null(normalize_proxy_url(NULL))
})
