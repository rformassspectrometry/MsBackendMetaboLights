## MTBLS10555: lists files in assay column that don't exist. Will result in an
##             error when we try to download the data. The data set contains
##             small data files. maybe use pattern sham-1-10.mzML
## MTBLS39: cdf files listed in Raw Spectral Data File column. Maybe use a
##          specific pattern to load/cache only some files.
## MTBLS243: mzML.gz files. Can eventually use an additional filePattern?

test_that("MsBackendMetaboLights works", {
    res <- MsBackendMetaboLights()
    expect_s4_class(res, "MsBackendMetaboLights")
    expect_true(inherits(res, "MsBackendMzR"))
})

test_that("backendInitialize,MsBackendMetaboLights works", {
    ## Test errors
    expect_error(backendInitialize(MsBackendMetaboLights(),
                                   data = data.frame(a = 3)),
                 "Parameter 'data' is not supported")
    expect_error(backendInitialize(MsBackendMetaboLights(),
                                   mtblsId = c("a", "b")),
                 "Parameter 'mtblsId' is required and can")
    expect_error(backendInitialize(MsBackendMetaboLights(), mtblsId = "a"),
                 "Failed to connect")

    ## Test NMR data set
    expect_error(backendInitialize(MsBackendMetaboLights(),
                                   mtblsId = "MTBLS100"), "No files matching")
    ## Test real data set.
    res <- backendInitialize(MsBackendMetaboLights(), mtblsId = "MTBLS39",
                             filePattern = "63A.cdf")
    expect_s4_class(res, "MsBackendMetaboLights")
    expect_true(all(c("mtbls_id", "mtbls_assay_name",
                      "derived_spectral_data_file") %in%
                    Spectra::spectraVariables(res)))
    expect_true(all(res$mtbls_id == "MTBLS39"))

    ## Offline
    res_o <- backendInitialize(MsBackendMetaboLights(), mtblsId = "MTBLS39",
                               filePattern = "63A.cdf", offline = TRUE)
    expect_equal(Spectra::rtime(res), Spectra::rtime(res_o))
})

test_that("backendRequiredSpectraVariables,MsBackendMetaboLights works", {
    expect_equal(backendRequiredSpectraVariables(MsBackendMetaboLights()),
                 c("dataStorage", "scanIndex", "mtbls_id", "mtbls_assay_name",
                   "derived_spectral_data_file"))
})

test_that("mtbls_sync works", {
    expect_error(mtbls_sync(3, offline = TRUE), "'x' is expected to be")

    x <- backendInitialize(MsBackendMetaboLights(), mtblsId = "MTBLS39",
                           filePattern = "63A.cdf", offline = TRUE)
    res <- mtbls_sync(x, offline = TRUE)
    expect_equal(rtime(x), rtime(res))
    expect_equal(mz(x[1:50]), mz(res[1:50]))

    ## Remove local content.
    mtbls_delete_cache("MTBLS39")
    expect_error(mtbls_sync(x, offline = TRUE), "No locally cached data files")

    Sys.sleep(4)

    ## Re-add content
    res <- mtbls_sync(x, offline = FALSE)
    expect_equal(rtime(x), rtime(res))
    expect_equal(mz(x[1:50]), mz(res[1:50]))

    ## Error.
    with_mocked_bindings(
        "mtbls_cached_data_files" = function(mtblsId, ...) {
            data.frame(rid = c("1", "2"),
                       derived_spectral_data_file = c("a", "b"),
                       rpath = "tmp")
        },
        code = expect_error(mtbls_sync(x, offline = TRUE), "not available")
    )
})

test_that(".valid_mtbls_required_columns works", {
    x <- MsBackendMetaboLights()
    expect_equal(.valid_mtbls_required_columns(x), character())
    x@spectraData <- DataFrame(a = 1:4, b = "c")
    expect_match(.valid_mtbls_required_columns(x), "One or more")
    x@spectraData$mtbls_id <- 3
    x@spectraData$mtbls_assay_name <- "a"
    x@spectraData$derived_spectral_data_file <- "b"
    expect_equal(.valid_mtbls_required_columns(x), character())
})

test_that(".valid_files_local works", {
    x <- MsBackendMetaboLights()
    expect_equal(.valid_files_local(x), character())
    x@spectraData <- DataFrame(a = 1:4, b = "c", dataStorage = "d")
    expect_match(.valid_files_local(x), "One or more of the data files")
})

test_that("backendMerge,MsBackendMetaboLights works", {
    ## Online mode
    be <- backendInitialize(MsBackendMetaboLights(), mtblsId = "MTBLS39",
                            filePattern = "A.cdf")
    l <- split(be, factor(be$dataOrigin, levels = unique(be$dataOrigin)))
    res <- backendMerge(l)

    expect_equal(rtime(be), rtime(res))
    expect_equal(dataOrigin(be), dataOrigin(res))
    expect_equal(mz(be), mz(res))

    ## Offline data
    a <- backendInitialize(MsBackendMetaboLights(), mtblsId = "MTBLS39",
                           filePattern = "63A.cdf", offline = TRUE)
    b <- backendInitialize(MsBackendMetaboLights(), mtblsId = "MTBLS8735",
                           filePattern = "2_E_POS.mzML")

    d <- backendMerge(a, b)
    expect_true(length(d) == (length(a) + length(b)))
    expect_equal(rtime(d), c(rtime(a), rtime(b)))
})
