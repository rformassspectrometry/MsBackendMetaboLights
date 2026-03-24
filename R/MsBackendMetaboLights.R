#' @title MsBackend representing MS data from MetaboLights
#'
#' @name MsBackendMetaboLights
#'
#' @aliases MsBackendMetaboLights-class
#'
#' @description
#'
#' `MsBackendMetaboLights` retrieves and represents mass spectrometry (MS)
#' data from metabolomics experiments stored in the
#' [MetaboLights](https://www.ebi.ac.uk/metabolights/) repository. The backend
#' directly extends the [Spectra::MsBackendMzR] backend from the *Spectra*
#' package and hence supports MS data in mzML, netCDF and mzXML format. Data
#' in other formats can not be loaded with `MsBackendMetaboLights`.
#' Upon initialization with the `backendInitialize()` method, the
#' `MsBackendMetaboLights` backend downloads and caches the MS data files of
#' an experiment locally avoiding hence repeated download of the data.
#' The local data cache is managed by Bioconductor's *BiocFileCache* package.
#' See the help and vignettes from that package for details on cached data
#' resources. Additional utility function for management of cached files are
#' also provided by *MsBackendMetaboLights*. See help for
#' [mtbls_cached_data_files()] for more information.
#'
#' @section Initialization and loading of data:
#'
#' New instances of the class can be created with the `MsBackendMetaboLights()`
#' function. Data is loaded and initialized using the `backendInitialize()`
#' function which can be configured with parameters `mtblsId`, `assayName` and
#' `filePattern`. `mtblsId` must be the ID of a **single** (existing)
#' MetaboLights data set. Parameter `assayName` allows to define specific
#' *assays* of the MetaboLights data set from which the data files should be
#' loaded. If provided, it should be the file name(s) of the respective
#' assay(s) in MetaboLights (use e.g.
#' `mtbls_list_files(<MetaboLights ID>, pattern = "^a_")` to list all available
#' assay files for a given MetaboLights ID `<MetaboLights ID>`). By default,
#' with `assayName = character()` MS data files from **all** assays of a data
#' set are loaded. Optional parameter `filePattern` defines the pattern that
#' should be used to filter the file names of the MS data files. It defaults
#' to data files with file endings of supported MS data files.
#' `backendInitialize()` requires an active internet connection as the
#' function first compares the remote file content to the locally cached files
#' and eventually synchronizes changes/updates. This can be skipped with
#' `offline = TRUE` in which case only locally cached content is queried.
#'
#' The `backendRequiredSpectraVariables()` function returns the names of the
#' spectra variables required for the backend to provide the MS data.
#'
#' The `mtbls_sync()` function can be used to *synchronize* the local data
#' cache and ensure that all data files are locally available. The function
#' will check the local cache and eventually download missing data files from
#' the MetaboLights repository.
#'
#' @note
#'
#' To account for high server load and eventually failing or rejected
#' downloads from the MetaboLights ftp server, the download functions
#' repeatedly retry to download a file. An error is thrown if download fails
#' for 3 consecutive attempts. Between each attemp, the function waits
#' for an increasing time period (5 seconds between the first and second
#' and 10 seconds between the 2nd and 3rd attempt). This time period can
#' also be configured with the `"metabolights.sleep_mult"` option, which
#' defines the *sleep time multiplicator* (defaults to 5).
#'
#' @param object an instance of `MsBackendMetaboLights`.
#'
#' @param mtblsId `character(1)` with the ID of a single MetaboLights data
#'     set/experiment.
#'
#' @param assayName `character` with the file names of assay files of the data
#'     set. If not provided (`assayName = character()`, the default), MS data
#'     files of all data set's assays are loaded. Use
#'     `mtbls_list_files(<MetaboLights ID>, pattern = "^a_")` to list all
#'     available assay files of a data set `<MetaboLights ID>`.
#'
#' @param filePattern `character` with the pattern defining the supported (or
#'     requested) file types. Defaults to
#'     `filePattern = "mzML$|CDF$|cdf$|mzXML$"` hence restricting to mzML,
#'     CDF and mzXML files which are supported by *Spectra*'s
#'     `MsBackendMzR` backend.
#'
#' @param offline `logical(1)` whether only locally cached content should be
#'     evaluated/loaded.
#'
#' @param x an instance of `MsBackendMetaboLights`.
#'
#' @param ... additional parameters; currently ignored.
#'
#' @return
#'
#' - For `MsBackendMetaboLights()`: an instance of `MsBackendMetaboLights`.
#' - For `backendInitialize()`: an instance of `MsBackendMetaboLights` with
#'   the MS data of the specified MetaboLights data set.
#' - For `backendRequiredSpectraVariables()`: `character` with spectra
#'   variables that are needed for the backend to provide the MS data.
#' - For `mtbls_sync()`: the input `MsBackendMetaboLights` with the paths to
#'   the locally cached data files being eventually updated.
#'
#' @details
#'
#' File names for data files are by default extracted from the column
#' `"Derived Spectral Data File"` of the MetaboLights data set's *assay*
#' table. If this column does not contain any supported file names, the
#' assay's column `"Raw Spectral Data File"` is evaluated instead.
#'
#' The backend uses the
#' [BiocFileCache](https://bioconductor.org/packages/BiocFileCache) package for
#' caching of the data files. These are stored in the default local
#' *BiocFileCache* cache along with additional metadata that includes the
#' MetaboLights ID and the assay file name with which the data file is
#' associated with. Note that at present only MS data files in *mzML*, *CDF*
#' and *mzXML* format are supported.
#'
#' The `MsBackendMetaboLights` backend defines and provides additional spectra
#' variables `"mtbls_id"`, `"mtbls_assay_name"` and
#' `"derived_spectral_data_file"` that list the MetaboLights ID, the name of
#' the assay file and the original data file name on the MetaboLights ftp
#' server for each individual spectrum. The `"derived_spectral_data_file"` can
#' be used for the mapping between the experiment's samples and the
#' individual data files, respective their spectra. This mapping is provided
#' in the MetaboLights assay file.
#'
#' The `MsBackendMetaboLights` backend is considered *read-only* and does
#' thus not support changing *m/z* and intensity values directly.
#'
#' @importClassesFrom Spectra MsBackendMzR
#'
#' @importClassesFrom Spectra MsBackendDataFrame
#'
#' @importFrom S4Vectors DataFrame
#'
#' @exportClass MsBackendMetaboLights
#'
#' @author Philippine Louail, Johannes Rainer
#'
#' @examples
#'
#' library(MsBackendMetaboLights)
#'
#' ## List files of a MetaboLights data set
#' mtbls_list_files("MTBLS39")
#'
#' ## Initialize a MsBackendMetaboLights representing all MS data files of
#' ## the data set with the ID "MTBLS39". This will download and cache all
#' ## files and subsequently load and represent them in R.
#'
#' be <- backendInitialize(MsBackendMetaboLights(), "MTBLS39")
#' be
#'
#' ## The `mtbls_sync()` function can be used to ensure that all data files are
#' ## available locally. This function will eventually download missing data
#' ## files or update their paths.
#' be <- mtbls_sync(be)
NULL

setClass("MsBackendMetaboLights",
         contains = "MsBackendMzR")

#' @rdname MsBackendMetaboLights
#'
#' @importFrom methods new
#'
#' @export
MsBackendMetaboLights <- function() {
    new("MsBackendMetaboLights")
}

#' @rdname MsBackendMetaboLights
#'
#' @importMethodsFrom ProtGenerics backendInitialize
#'
#' @importMethodsFrom Spectra backendInitialize
#'
#' @importMethodsFrom Spectra [
#'
#' @importMethodsFrom ProtGenerics dataOrigin
#'
#' @importFrom methods callNextMethod
#'
#' @importFrom methods as
#'
#' @importFrom Spectra MsBackendMzR
#'
#' @exportMethod backendInitialize
setMethod(
    "backendInitialize", "MsBackendMetaboLights",
    function(object, mtblsId = character(), assayName = character(),
             filePattern = "mzML$|CDF$|cdf$|mzXML$", offline = FALSE, ...) {
        dots <- list(...)
        if (any(names(dots) == "data"))
            stop("Parameter 'data' is not supported for ",
                 "'MsBackendMetaboLights'. A 'MsBackendMetaboLights' object ",
                 "can only be instantiated using 'backendInitialize()'.")
        if (length(mtblsId) != 1)
            stop("Parameter 'mtblsId' is required and can only be a single ID ",
                 "of a MetaboLights data set.")
        if (offline)
            mdata <- .mtbls_data_files_offline(mtblsId, assayName, filePattern)
        else mdata <- .mtbls_data_files(mtblsId, assayName, filePattern)
        object <- backendInitialize(MsBackendMzR(), files = mdata$rpath)
        idx <- match(dataOrigin(object),
                     normalizePath(mdata$rpath, mustWork = FALSE))
        object@spectraData$mtbls_id <- mdata$mtbls_id[idx]
        object@spectraData$mtbls_assay_name <- mdata$mtbls_assay_name[idx]
        object@spectraData$derived_spectral_data_file <-
            mdata$derived_spectral_data_file[idx]
        object <- as(object, "MsBackendMetaboLights")
    })

#' @rdname MsBackendMetaboLights
#'
#' @importMethodsFrom Spectra backendRequiredSpectraVariables
#'
#' @exportMethod backendRequiredSpectraVariables
setMethod(
    "backendRequiredSpectraVariables", "MsBackendMetaboLights",
    function(object, ...) {
        c(callNextMethod(), "mtbls_id", "mtbls_assay_name",
          "derived_spectral_data_file")
    })

.valid_mtbls_required_columns <- function(object) {
    if (nrow(object@spectraData)) {
        if (!all(c("mtbls_id", "mtbls_assay_name",
                   "derived_spectral_data_file") %in%
                 colnames(object@spectraData)))
            return(paste0("One or more of required spectra variable(s) ",
                          "\"mtbls_id\", \"mtbls_assay_name\", \"derived_",
                          "spectral_data_file\" is (are) missing"))
    }
    character()
}

.valid_files_local <- function(object) {
    if (nrow(object@spectraData)) {
        if (!all(file.exists(object@spectraData$dataStorage)))
            return(paste0("One or more of the data files are not found in ",
                          "the local cache. Please run `mtbls_sync()` on ",
                          "the data object."))
    }
    character()
}

setValidity("MsBackendMetaboLights", function(object) {
    msg <- .valid_mtbls_required_columns(object)
    msg <- c(msg, .valid_files_local(object))
    if (length(msg)) return(msg)
    else TRUE
})

#' @importFrom methods validObject
#'
#' @rdname MsBackendMetaboLights
#'
#' @export
mtbls_sync <- function(x, offline = FALSE) {
    if (!inherits(x, "MsBackendMetaboLights"))
        stop("'x' is expected to be an instance of 'MsBackendMetaboLights'")
    sdata <- unique(
        as.data.frame(x@spectraData[, c("mtbls_id", "mtbls_assay_name",
                                        "derived_spectral_data_file")]))
    cn <- c("derived_spectral_data_file", "rpath")
    res <- lapply(split(sdata, sdata$mtbls_id), function(z, offline) {
        if (offline)
            mtbls_cached_data_files(
                sdata$mtbls_id[1L], pattern = "*",
                fileName = basename(sdata$derived_spectral_data_file))[, cn]
        else
            mtbls_sync_data_files(
                 sdata$mtbls_id[1L], pattern = "*",
                 fileName = basename(sdata$derived_spectral_data_file))[, cn]
    }, offline = offline)
    res <- do.call(rbind, res)
    if (!all(sdata$derived_spectral_data_file %in%
        res$derived_spectral_data_file))
        stop("Some of the data files are not available. Please run with ",
             "'offline = FALSE' to ensure data missing data files get ",
             "downloaded.")
    x@spectraData$dataStorage <- res[match(
        x@spectraData$derived_spectral_data_file,
        res$derived_spectral_data_file), "rpath"]
    validObject(x)
    x
}
