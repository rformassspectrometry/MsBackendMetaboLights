alist_ms <- .mtbls_assay_list("MTBLS2")
alist_nmr <- .mtbls_assay_list("MTBLS123")

test_that("mtbls_ftp_path works", {
    res <- mtbls_ftp_path("A", mustWork = FALSE)
    expect_true(grepl("^ftp://", res))
    expect_true(grepl("A/$", res))

    expect_error(mtbls_ftp_path("A", mustWork = TRUE), "Failed to connect")

    res <- mtbls_ftp_path("MTBLS1")
    expect_true(grepl("MTBLS1/$", res))

    expect_error(mtbls_ftp_path(c("A", "B")), "single ID")
})

test_that("mtbls_list_files works", {
    res <- mtbls_list_files("MTBLS8735", pattern = "^a_")
    expect_true(length(res) == 2)
    expect_error(mtbls_list_files("AAA"), "Failed to connect")
})

test_that(".mtbls_assay_list works", {
    res <- .mtbls_assay_list("MTBLS8735")
    expect_true(is.list(res))
    expect_true(length(res) == 2L)
    expect_true(is.data.frame(res[[1L]]))
})

test_that(".mtbls_derived_data_file works", {
    res <- .mtbls_derived_data_file(alist_ms[[1L]])
    expect_true(is.character(res))
    expect_true(length(res) == 16)

    ## check the second column containing mzData files
    res <- .mtbls_derived_data_file(alist_ms[[1L]], pattern = "mzData")
    expect_true(is.character(res))
    expect_true(length(res) == 16)

    res <- .mtbls_derived_data_file(alist_nmr[[1L]])
    expect_true(is.character(res))
    expect_true(length(res) == 0)
})
