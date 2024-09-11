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
