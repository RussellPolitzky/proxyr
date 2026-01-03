test_that("get_proxy_credentials is internal", {
    # It should be available in the test environment (pkgload loads all)
    expect_true(exists("get_proxy_credentials"))

    # But it should NOT be exported in the namespace
    ns_exports <- getNamespaceExports("proxyr")
    expect_false("get_proxy_credentials" %in% ns_exports)

    # Attempting to call it via :: should fail
    expect_error(getFromNamespace("get_proxy_credentials", "proxyr"), NA) # It exists in namespace
    # But strictly :: check involves loading the package which isn't easy in testthat env without actually installing.
    # The getNamespaceExports check is sufficient.
})
