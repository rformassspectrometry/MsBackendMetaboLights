#' @title MsBackend representing MS data from MetaboLights
#'
#' @name MsBackendMetaboLights
#'
#' @aliases MsBackendMetaboLights-class
#'
#' @description
#'
#' The `MsBackendMetaboLights` retrieves and represents mass spectrometry (MS)
#' data from metabolomics experiments stored in the
#' [MetaboLights](https://www.ebi.ac.uk/metabolights/) repository. The backend
#' directly extends the [MsBackendMzR] backend from the *Spectra* package and
#' hence supports MS data in mzML, netCDF and mzXML format. Upon initialization
#' with the `backendInitialize()` method, the `MsBackendMetaboLights` backend
#' downloads and caches the MS data files of an experiment locally avoiding
#' hence repeated download of the data.
#'
#' @section Initialization and loading of data:
#'
#' New instances of the class can be created with the `MsBackendMetaboLights()`
#' function. Data is loaded and initialized using the `backendInitialize()`
#' function with parameters `mtblsId`, `assayId` and `filePattern`. `mtblsId`
#' must be the ID of a **single** (existing) MetaboLights data set. Parameter
#' `assayId` allows to define specific *assays* of the MetaboLights data set
#' from which the data files should be loaded. If provided, it should be the
#' file names of the respective assays in MetaboLights (use e.g.
#' `mtbls_list_files(<MetaboLights ID>, pattern = "^a_")` to list all available
#' assay files for a given MetaboLights ID `<MetaboLights ID>`. By default,
#' with `assayId = character()` MS data files from all assays of a data set
#' are loaded. Optional parameter `filePattern` defines the pattern that should
#' be used to filter the file names. It defaults to data files with file
#' endings of supported MS data files. `backendInitialize()` requires by
#' default an active internet connection as the function first compares the
#' remote file content to eventually synchronize changes/updates. This can be
#' skipped with `offline = TRUE` in which case only locally cached content
#' is considered.
#'
#' @param object an instance of `MsBackendMetaboLights`.
#'
#' @param mtblsId `character(1)` with the ID of the MetaboLights data
#'     set/experiment.
#'
#' @param assayId `character` with the file names of assay files of the data
#'     set. If not provided (`assayId = character()`, the default), MS data
#'     files of all data set's assays is loaded. Use
#'     `mtbls_list_files(<MetaboLights ID>, pattern = "^a_")` to list all
#'     available assay files of a data set `<MetaboLights ID>`.
#'
#' @param filePattern `character` with the pattern defining the supported (or
#'     requested) file types. Defaults to
#'     `filePattern = "mzML$|CDF$|cdf$|mzXML$"` hence restricting to mzML,
#'     CDF and mzXML files supported by *Spectra*'s `MsBackendMzR` backend.
#'
#' @param offline `logical(1)` whether only locally cached content should be
#'     evaluated/loaded.
#'
#' @param ... additional parameters; currently ignored.
#'
#' @details
#'
#' Data files are by default extracted from the column `"Derived Spectral
#' Data File"` of the MetaboLights data set's *assay* table. If this column
#' does not contain any supported file names, the assay's column
#' `"Raw Spectral Data File"` is evaluated.
#'
#' The backend uses the
#' [BiocFileCache](https://bioconductor.org/packages/BiocFileCache) package for
#' caching of the data files. These are stored in the default local
#' *BiocFileCache* cache along with additional metadata that includes the
#' MetaboLights ID, the assay file name with which the data file is associated
#' with. Note that at present only MS data files in *mzML*, *CDF* and *mzXML*
#' format are supported.
#'
#' The `MsBackendMetaboLights` backend defines and provides additional spectra
#' variables `"mtbls_id"`, `"mtbls_assay_name"` and
#' `"derived_spectral_data_file"` that list the MetaboLights ID, the name of
#' the assay file and the original data file name on the MetaboLights ftp
#' server for each individual spectrum. The `"derived_spectral_data_file"` can
#' be used for the mapping between the experiment/data sets samples and the
#' individual data files, respective their spectra. This mapping is provided
#' in the respective MetaboLights assay file.
#'
#' The `MsBackendMetaboLights()` is considered *read-only* and does thus not
#' support changing *m/z* and intensity values directly.
#'
#' Also, merging of MS data of `MsBackendMetaboLights` is not supported and
#' thus `c()` of several `Spectra` with MS data represented by
#' `MsBackendMetaboLights` will throw an error.
#'
#' @importClassesFrom Spectra MsBackendMzR
#'
#' @exportClass MsBackendMetaboLights
#'
#' @author Philippine Louail, Johannes Rainer
#'
NULL

setClass("MsBackendMetaboLights",
         contains = "MsBackendMzR",
         slots = c(mtblsId = "character",
                   assays = "character"),
         prototype = prototype(
             mtblsId = character(),
             assays = character()
         ))

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
#' @importMethodsFrom ProtGenerics dataOrigin
#'
#' @importFrom methods callNextMethod
#'
#' @exportMethod backendInitialize
setMethod(
    "backendInitialize", "MsBackendMetaboLights",
    function(object, mtblsId = character(), assayId = character(),
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
            mdata <- .mtbls_data_files_offline(mtblsId, assayId, filePattern)
        else mdata <- .mtbls_data_files(mtblsId, assayId, filePattern)
        object <- callNextMethod(object, files = mdata$rpath)
        object@mtblsId <- mtblsId
        object@assays <- unique(mdata$mtbls_assay_name)
        idx <- match(dataOrigin(object),
                     normalizePath(mdata$rpath, mustWork = FALSE))
        object@spectraData$mtbls_id <- mdata$mtbls_id[idx]
        object@spectraData$mtbls_assay_name <- mdata$mtbls_assay_name[idx]
        object@spectraData$derived_spectral_data_file <-
            mdata$derived_spectral_data_file[idx]
        object
    })

#' @rdname MsBackendMetaboLights
#'
#' @importFrom ProtGenerics backendMerge
#'
#' @exportMethod backendMerge
setMethod(
    "backendMerge", "MsBackendMetaboLights",
    function(object, ...) {
        stop("Merging of backends of type 'MsBackendMetaboLights' is not ",
             "supported. Use 'setBackend()' to change to a backend that ",
             "supports merging, such as the 'MsBackendMemory'.")
    })


################################################################################
##
## File caching utils
##
################################################################################

#' Get information on data files for a given MTBLS ID/assay eventually
#' downloading and caching them. This function needs an active internet
#' connection as it queries the MTBLS ftp server for available data files
#' that are then cached. The function returns the **local** file names
#' **from the cache**.
#'
#' The function:
#' - retrieves all "Derived Data Files" for all assays (or for specified assays)
#'   for one MetaboLights ID.
#' - uses BiocFileCache to cache these files, i.e. downloading them if they
#'   are not yet cached.
#' - returns a `data.frame` with all information.
#'
#' This `data.frame` has one row per data file with columns:
#' - `"rid"`: the BiocFileCache ID of each file.
#' - `"mtbls_id"`: the MTBLS ID
#' - `"mtbls_assay_name"`: the name of the assay file for each data file
#' - `"derived_spectral_data_file"`: the name of the data file in the assay
#'   file/table
#' - `"rpath"`: the name of the cached data file (full local path)
#'
#' @importFrom BiocFileCache BiocFileCache
#'
#' @importMethodsFrom BiocFileCache bfcrpath bfcmeta<-
#'
#' @noRd
.mtbls_data_files <- function(mtblsId = character(), assayId = character(),
                              pattern = "mzML$|CDF$|mzXML$") {
    assays <- .mtbls_assay_list(mtblsId)
    anames <- names(assays)
    if (length(assayId)) {
        if (!all(assayId %in% anames))
            stop("Not all assay names defined with 'assayId' are available ",
                 "for ", mtblsId, ". Available assay names are: \n",
                 paste0(" - \"", anames, "\"", collapse = "\n"), call. = FALSE)
        assays <- assays[anames %in% assayId]
    }
    fpath <- mtbls_ftp_path(mtblsId, mustWork = FALSE)
    dfiles <- lapply(assays, .mtbls_data_file_from_assay, pattern = pattern)
    ffiles <- unlist(dfiles, use.names = FALSE)
    if (!length(ffiles)) {
        ## Failsafe; use evaluate also raw data file
        dfiles <- lapply(assays, .mtbls_data_file_from_assay, pattern = pattern,
                         colname = "Raw Spectral Data File")
        ffiles <- unlist(dfiles, use.names = FALSE)
        if (!length(ffiles))
            stop("No files matching the provided file pattern found for ",
                 "MetaboLights data set ", mtblsId, ".", call. = FALSE)
        else
            message("Used data files from the assay's column \"Raw Spectral ",
                    "Data File\" since none were available in column ",
                    "\"Derived Spectral Data File\".")
    }
    ## Cache files
    bfc <- BiocFileCache()
    lfiles <- bfcrpath(bfc, paste0(fpath, ffiles), fname = "exact")
    ## Add and store metadata to the cached files
    mdata <- data.frame(
        rid = names(lfiles),
        mtbls_id = mtblsId,
        mtbls_assay_name = rep(names(dfiles), lengths(dfiles)),
        derived_spectral_data_file = unlist(dfiles, use.names = FALSE))
    bfcmeta(bfc, name = "MTBLS", overwrite = TRUE) <- mdata
    mdata$rpath <- lfiles
    mdata
}

#' Check for a given MTBLS ID and assay IDs/file names if we have cached data
#' files. This function is supposed to work also offline using only previously
#' cached content. In contrast to `.mtbls_data_files()`, this function just
#' queries the BiocFileCache for content and returns a `data.frame` with
#' all cached data files for a given MTBLS ID, assay name and pattern. The
#' returned `data.frame` has the same format as the one returned by
#' `.mtbls_data_files()`.
#'
#' @importMethodsFrom BiocFileCache bfcmetalist bfcquery
#'
#' @noRd
.mtbls_data_files_offline <- function(mtblsId = character(),
                                      assayId = character(),
                                      pattern = "mzML$|CDF$|mzXML$") {
    bfc <- BiocFileCache()
    if (!any(bfcmetalist(bfc) == "MTBLS"))
        stop("No local MetaboLights cache available. Please re-run with ",
             "'offline = FALSE' first.", call. = FALSE)
    res <- as.data.frame(bfcquery(bfc, mtblsId, field = "mtbls_id"))
    if (length(assayId)) {
        res <- res[res$mtbls_assay_name %in% assayId, ]
    }
    res <- res[grepl(pattern, res$derived_spectral_data_file), ]
    if (!nrow(res))
        stop("No locally cached data files found for the specified ",
             "parameters.", call. = FALSE)
    res[, c("rid", "mtbls_id", "mtbls_assay_name",
            "derived_spectral_data_file", "rpath")]
}
