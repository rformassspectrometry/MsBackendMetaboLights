## Note: clean BiocFileCache with cleanbfc(days = -10, ask = FALSE)
## MTBLS10555: lists files in assay column that don't exist. Will result in an
##             error when we try to download the data. The data set contains
##             small data files. maybe use pattern sham-1-10.mzML
## MTBLS39: cdf files listed in Raw Spectral Data File column. Maybe use a
##          specific pattern to load/cache only some files.
## MTBLS243: mzML.gz files. Can eventually use an additional filter.

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
    expect_equal(res@mtblsId, "MTBLS39")
    expect_true(all(c("mtbls_id", "mtbls_assay_name",
                      "derived_spectral_data_file") %in%
                    Spectra::spectraVariables(res)))
})

test_that(".mtbls_data_files and .mtbls_data_files_offline works", {
    ## error
    expect_error(.mtbls_data_files(mtblsId = "MTBLS2",
                                   assayId = "does not exist"),
                 "Not all assay names")
    expect_error(.mtbls_data_files(mtblsId = "MTBLS100"), "No files matching")

    ## Cache the data: MTBLS39 contains small cdf files, but they are listed
    ## in the Raw Spectral Data File column. Will use a specfic pattern to
    ## just load 3 files.
    a <- .mtbls_data_files("MTBLS39", pattern = "63A.cdf")
    expect_true(is.data.frame(a))
    expect_true(nrow(a) == 3)
    expect_true(all(a$mtbls_id == "MTBLS39"))
    ## Re-call function the data.
    b <- .mtbls_data_files("MTBLS39", pattern = "63A.cdf")
    expect_true(is.data.frame(a))
    expect_true(nrow(a) == 3)
    expect_true(all(a$mtbls_id == "MTBLS39"))
    expect_equal(a$rpath, b$rpath)

    ## Use offline
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
