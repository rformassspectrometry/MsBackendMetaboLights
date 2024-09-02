################################################################################
## Utility functions for MetaboLights
##
################################################################################

#' @title Utility functions for the MetaboLights repository
#'
#' @name MetaboLights-utils
#'
#' @description
#'
#' [MetaboLights](https://www.ebi.ac.uk/metabolights/) is one of the main
#' public repositories for deposition of metabolomics experiments including
#' (raw) mass spectrometry (MS) and NMR data files and experimental/analysis
#' results. The experimental metadata and results are stored as plain text
#' files in ISA-tab format. Each MetaboLights experiment must provide a
#' file describing the samples analyzed and at least one *assay* file that
#' links between the experimental samples and the (raw and processed) data
#' files with quantification of metabolites/features in these samples.
#'
#' Each experiment in MetaboLights is identified with its unique identifier,
#' starting with *MTBLS* followed by a number. The data (metadata files and
#' MS/NMR data files) of an experiment are available through the repository's
#' ftp server.
#'
#' The functions listed here allow to query and retrieve information of an
#' experiment from MetaboLights.
#'
#' - `mtbls_ftp_path()`: return the FTP path for a provided MetaboLights ID.
#'   With `mustWork = TRUE` (the default) the function throws an error if
#'   the path is not accessible (either because the data set does not exist or
#'   no internet connection is available). The function returns a
#'   `character(1)` with the FTP path to the data set folder.
#'
#' - `mtbls_assay_list()`: retrieves and reads the/all assay data file(s) for a
#'   given MetaboLights data set and returns it/them as a `list` of
#'   `data.frame`s. The file names of the respective assay data file(s) are
#'   reported as `names()` of the returned `list`.
#'
#' @param x `character(1)` with the ID of the MetaboLights data set (usually
#'     starting with a *MTBLS* followed by a number).
#'
#' @param mustWork for `mtbls_ftp_path()`: `logical(1)` whether the validity of
#'     the path should be verified or not. By default (with `mustWork = TRUE`)
#'     the function throws an error if either the data set does not exist or
#'     if the folder can not be accessed (e.g. if no internet connection is
#'     available).
#'
#' @author Johannes Rainer, Philippine Louail
#'
#' @examples
#'
#' ## Get the FTP path to the data set MTBLS2
#' mtbls_ftp_path("MTBLS2")
#'
#' ## Read all assay data files for MTBLS2
#' afiles <- mtbls_assay_list("MTBLS2")
#' afiles
NULL

#' @rdname MetaboLights-utils
#'
#' @export
mtbls_ftp_path <- function(x = character(), mustWork = TRUE) {
    if (length(x) != 1L)
        stop("'x' has to be a single ID.")
    res <- paste0("ftp://ftp.ebi.ac.uk/pub/databases/metabolights/",
                  "studies/public/", x, "/")
    if (mustWork)
        .mtbls_list_files(x)
    res
}

#' @rdname MetaboLights-utils
#'
#' @export
mtbls_assay_list <- function(x = character()) {
    fpath <- mtbls_ftp_path(x)
    a_fls <- .mtbls_list_files(x, pattern = "a_")
    res <- lapply(a_fls, function(z) {
        read.table(paste0(fpath, z),
                   sep = "\t", header = TRUE,
                   check.names = FALSE)
    })
    names(res) <- a_fls
    res
}

#' List files (matching an optionally provided pattern) from a ftp directory
#'
#' @param x `character(1)` with the MetaboLights ID
#'
#' @param pattern `character` to filter the results.
#'
#'
#' @importFrom curl new_handle handle_setopt curl
#'
#' @return `character` with the file names matching the provided pattern.
#'
#' @noRd
.mtbls_list_files <- function(x = character(), pattern = NULL) {
    cu <- new_handle()
    handle_setopt(cu, ftp_use_epsv = TRUE, dirlistonly = TRUE)
    tryCatch({
        con <- curl(url = mtbls_ftp_path(x, mustWork = FALSE), "r", handle = cu)
    }, error = function(e) {
        stop("Failed to connect to MetaboLights. No internet connection? ",
             "Does the data set \"", x, "\" exist?\n - ", e$message,
             call. = FALSE)
    })
    fls <- readLines(con)
    close(con)
    if (length(pattern))
        fls[grepl(pattern, fls)]
    else fls
}

#' Extract the MS data files from MTBLS assay tables'
#' *Derived Spectral Data File* column(s). The function checks all present
#' columns in the provided `data.frame` and returns the content of the first of
#' these columns with files matching the provided `pattern`.
#'
#' @param x `data.frame` representing the content of an *assay* ISA file from
#'     MetaboLights.
#'
#' @param pattern `character(1)` with supported data types.
#'
#' @return `character` with the file names matching the provided pattern.
#'
#' @noRd
.mtbls_derived_data_file <- function(x, pattern = "mzML$|CDF$|mzXML$") {
    cls <- which(colnames(x) == "Derived Spectral Data File")
    res <- character()
    for (i in cls) {
        keep <- grepl(pattern, x[[i]])
        if (any(keep)) {
            res <- x[[i]][keep]
            break
        }
    }
    res
}
