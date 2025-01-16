## Note: clean BiocFileCache with cleanbfc(days = -10, ask = FALSE)
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
    bfc <- BiocFileCache::BiocFileCache()
    BiocFileCache::cleanbfc(bfc, days = -10, ask = FALSE)
    expect_error(mtbls_sync(x, offline = TRUE), "No locally cached data files")

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

test_that(".mtbls_data_files and .mtbls_data_files_offline works", {
    ## error
    expect_error(.mtbls_data_files(mtblsId = "MTBLS2",
                                   assayName = "does not exist"),
                 "Not all assay names")
    expect_error(.mtbls_data_files(mtblsId = "MTBLS100"), "No files matching")

    bfc <- BiocFileCache::BiocFileCache()
    BiocFileCache::cleanbfc(bfc, days = -10, ask = FALSE)
    BiocFileCache::bfcmetaremove(bfc, "MTBLS")

    ## Error if no cache available
    expect_error(.mtbls_data_files_offline("MTBLS39"),
                 "No local MetaboLights cache")

    ## Cache the data: MTBLS39 contains small cdf files, but they are listed
    ## in the Raw Spectral Data File column. Will use a specfic pattern to
    ## just load 3 files.
    a <- .mtbls_data_files("MTBLS39", pattern = "63A.cdf")
    expect_true(is.data.frame(a))
    expect_true(nrow(a) == 3)
    expect_true(all(a$mtbls_id == "MTBLS39"))
    ## Re-call function the data.
    b <- .mtbls_data_files("MTBLS39", pattern = "63A.cdf")
    expect_true(is.data.frame(b))
    expect_true(nrow(b) == 3)
    expect_true(all(b$mtbls_id == "MTBLS39"))
    expect_equal(a$rpath, b$rpath)

    ## with fileNames
    expect_error(.mtbls_data_files("MTBLS39", pattern = "63A.cdf",
                                   fileName = c("a", "b")), "None of the ")

    ## with assayName
    b <- .mtbls_data_files(
        "MTBLS39", pattern = "63A.cdf",
        assayName = paste0("a_MTBLS39_the_plasticity_of_the_grapevine_berry",
                           "_transcriptome_metabolite_profiling_mass",
                           "_spectrometry.txt"))
    expect_true(is.data.frame(b))
    expect_true(nrow(b) == 3)
    expect_true(all(b$mtbls_id == "MTBLS39"))
    expect_equal(a$rpath, b$rpath)

    ## Use offline
    expect_error(.mtbls_data_files_offline("MTBLS39", assayName = "something"),
                 "No locally cached data files")

    d <- .mtbls_data_files_offline("MTBLS39", pattern = "63A.cdf")
    expect_true(is.data.frame(a))
    expect_true(nrow(a) == 3)
    expect_true(all(a$mtbls_id == "MTBLS39"))
    expect_equal(a$rpath, d$rpath)
})

test_that("mtbls_sync_data_files works", {
    expect_error(mtbls_sync_data_files(), "No MetaboLights data")
    res <- mtbls_sync_data_files("MTBLS39", pattern = "*",
                                 fileName = c("AM063A.cdf"))
    expect_true(is.data.frame(res))
    expect_equal(nrow(res), 1L)
    expect_equal(res$mtbls_id, "MTBLS39")
})

test_that("mtbls_cached_data_files works", {
    res <- mtbls_cached_data_files()
    expect_true(is.data.frame(res))
    expect_true(nrow(res) > 0)

    res <- mtbls_cached_data_files(fileName = "otehr")
    expect_true(is.data.frame(res))
    expect_true(nrow(res) == 0)
})

test_that("backendMerge,MsBackendMetaboLights fails", {
    b <- MsBackendMetaboLights()
    expect_error(backendMerge(b, b), "Merging of backends")
})

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

test_that(".mtbls_data_file_from_assay works", {
    res <- .mtbls_data_file_from_assay(alist_ms[[1L]])
    expect_true(is.character(res))
    expect_true(length(res) == 16)

    ## check the second column containing mzData files
    res <- .mtbls_data_file_from_assay(alist_ms[[1L]], pattern = "mzData")
    expect_true(is.character(res))
    expect_true(length(res) == 16)

    res <- .mtbls_data_file_from_assay(alist_nmr[[1L]])
    expect_true(is.character(res))
    expect_true(length(res) == 0)
})