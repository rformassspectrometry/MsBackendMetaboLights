alist_ms <- .mtbls_assay_list("MTBLS2")
Sys.sleep(4)
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
    Sys.sleep(4)
    res <- mtbls_list_files("MTBLS8735", pattern = "^a_")
    expect_true(length(res) == 2)
    expect_error(mtbls_list_files("AAA"), "Failed to connect")
})

test_that(".mtbls_assay_list works", {
    Sys.sleep(4)
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

test_that(".mtbls_data_files and .mtbls_data_files_offline works", {
    ## error
    expect_error(.mtbls_data_files(mtblsId = "MTBLS2",
                                   assayName = "does not exist"),
                 "Not all assay names")
    expect_error(.mtbls_data_files(mtblsId = "MTBLS100"), "No files matching")

    mtbls_delete_cache("MTBLS39")
    ## bfc <- BiocFileCache::BiocFileCache()
    ## BiocFileCache::cleanbfc(bfc, days = -10, ask = FALSE)
    ## BiocFileCache::bfcmetaremove(bfc, "MTBLS")

    ## Error if no cache available
    with_mocked_bindings(
        ".mtbls_has_mtbls_table" = function() FALSE,
        code = expect_error(.mtbls_data_files_offline("MTBLS39"),
                            "No local MetaboLights cache")
    )

    ## Cache the data: MTBLS39 contains small cdf files, but they are listed
    ## in the Raw Spectral Data File column. Will use a specfic pattern to
    ## just load 3 files.
    a <- .mtbls_data_files("MTBLS39", pattern = "63A.cdf")
    expect_true(is.data.frame(a))
    expect_true(nrow(a) == 3)
    expect_true(all(a$mtbls_id == "MTBLS39"))
    ## Re-call function the data.
    Sys.sleep(4)
    b <- .mtbls_data_files("MTBLS39", pattern = "63A.cdf")
    expect_true(is.data.frame(b))
    expect_true(nrow(b) == 3)
    expect_true(all(b$mtbls_id == "MTBLS39"))
    expect_equal(a$rpath, b$rpath)

    ## with fileNames
    expect_error(.mtbls_data_files("MTBLS39", pattern = "63A.cdf",
                                   fileName = c("a", "b")), "None of the ")

    ## with assayName
    Sys.sleep(4)
    b <- .mtbls_data_files(
        "MTBLS39", pattern = "63A.cdf",
        assayName = paste0("a_MTBLS39_the_plasticity_of_the_grapevine_berry",
                           "_transcriptome_metabolite_profiling_mass",
                           "_spectrometry.txt"))
    expect_true(is.data.frame(b))
    expect_true(nrow(b) == 3)
    expect_true(all(b$mtbls_id == "MTBLS39"))
    expect_equal(a$rpath, b$rpath)

    expect_true(.mtbls_has_mtbls_table())

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


test_that("mtbls_delete_cache works", {
    bfc <- BiocFileCache()
    l <- length(bfc)
    mtbls_delete_cache()
    expect_equal(length(bfc), l)

    mtbls_delete_cache("MTBLS39")
    i <- bfcinfo(bfc)
    expect_true(!any(i$mtbls_id %in% "MTBLS39"))
})

test_that("mtbls_assay_data works", {
    id <- "MTBLS2"
    res <- mtbls_assay_data()
    expect_true(is.data.frame(res))
    expect_true(nrow(res) == 0L)

    expect_error(mtbls_assay_data(id, "aaaa"), "does not exist")
    res <- mtbls_assay_data(id)
    expect_true(is.data.frame(res))
    expect_true(nrow(res) > 0)
})

test_that("mtbls_sample_data works", {
    id <- "MTBLS2"
    res <- mtbls_sample_data()
    expect_true(is.data.frame(res))
    expect_true(nrow(res) == 0L)

    res <- mtbls_sample_data(id)
    expect_true(is.data.frame(res))
    expect_true(nrow(res) > 0)
})

test_that("mtbls_metadata works", {
    res <- mtbls_metadata()
    expect_true(is.data.frame(res))
    expect_true(nrow(res) == 0L)

    res <- mtbls_metadata("MTBLS2")
    expect_true(is.data.frame(res))
    expect_true(nrow(res) > 0)
    res_2 <- mtbls_metadata("MTBLS2", keepProtocol = FALSE)
    expect_true(ncol(res) > ncol(res_2))
})

test_that(".clean_merged function works correctly", {
    tbc <- data.frame(
        Protocol_A = c(1, 2, 3),
        Term_B = c("ontology1", "ontology2", "ontology3"),
        Parameter_C = c(10, 20, 30),
        Term_D = c("ontology1", "ontology2", "ontology3"),
        Data_E = c(NA, NA, NA),
        Duplicate_F = c(1, 2, 3),
        stringsAsFactors = FALSE
    )
    result <- .clean_merged(tbc, keepProtocol = TRUE,
                            keepOntology = TRUE,
                            simplify = FALSE)
    expect_equal(names(result), names(tbc))

    result <- .clean_merged(tbc, keepProtocol = TRUE,
                            keepOntology = FALSE, simplify = FALSE)
    expect_equal(names(result), c("Protocol_A", "Parameter_C", "Data_E",
                                  "Duplicate_F"))

    result <- .clean_merged(tbc, keepProtocol = FALSE,
                            keepOntology = TRUE, simplify = FALSE)
    expect_equal(names(result), c("Term_B", "Term_D", "Data_E", "Duplicate_F"))

    result <- .clean_merged(tbc, keepProtocol = FALSE, keepOntology = FALSE,
                            simplify = FALSE)
    expect_equal(names(result), c("Data_E", "Duplicate_F"))

    result <- .clean_merged(tbc, keepProtocol = TRUE, keepOntology = TRUE,
                            simplify = TRUE)
    expect_equal(names(result), c("Protocol_A", "Term_B", "Parameter_C"))


    result <- .clean_merged(tbc, keepProtocol = FALSE, keepOntology = FALSE,
                            simplify = TRUE)
    expect_equal(names(result), "Duplicate_F")
})

test_that(".sleep_mult works", {
    expect_equal(.sleep_mult(), 7L)
})

test_that(".bfc_cache_files works", {
    bfc <- BiocFileCache()
    p <- "ftp://ftp.ebi.ac.uk/pub/databases/metabolights/studies/public/MTBLS39/"
    fls <- c("FILES/CS073B.cdf", "FILES/MN063A.cdf")
    res <- .bfc_cache_files(paste0(p, fls), bfc)
    expect_true(all(file.exists(res)))
})
