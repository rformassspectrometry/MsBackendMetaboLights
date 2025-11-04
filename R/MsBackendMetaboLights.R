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
#' The functions listed here allow to query and retrieve information of a
#' data set/experiment from MetaboLights.
#'
#' - `mtbls_ftp_path()`: returns the FTP path for a provided MetaboLights ID.
#'   With `mustWork = TRUE` (the default) the function throws an error if
#'   the path is not accessible (either because the data set does not exist or
#'   no internet connection is available). The function returns a
#'   `character(1)` with the FTP path to the data set folder.
#'
#' - `mtbls_cached_data_files()`: lists locally cached data files from
#'   MetaboLights. Since this function evaluates only local content it does not
#'   require an internet connection. With the default parameters all available
#'   data files are listed. The parameters can be used to restrict the lookup.
#'
#' - `mtbls_list_files()`: returns the available files (and directories) for the
#'   specified MetaboLights data set (i.e., the FTP directory content of the
#'   data set). The function returns a `character` vector with the relative
#'   file names to the absolute FTP path (`mtbls_ftp_path()`) of the data set.
#'   Parameter `pattern` allows to filter the file names and define which
#'   file names should be returned.
#'
#' - `mtbls_sync_data_files()`: synchronize data files of a specifies
#'   MetaboLights data set eventually downloading and locally caching them.
#'   Parameter `fileName` allows to specify names of selected data files to
#'   sync.
#'
#' - `mtbls_delete_cache()`: removes all local content for the MetaboLights
#'   data set with ID `mtblsId`. This will delete eventually present
#'   locally cached data files for the specified data set. This does not
#'   change any other data eventually present in the local `BiocFileCache`.
#'
#' @param x `character(1)` with the ID of the MetaboLights data set (usually
#'     starting with a *MTBLS* followed by a number).
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
#' @param mustWork for `mtbls_ftp_path()`: `logical(1)` whether the validity of
#'     the path should be verified or not. By default (with `mustWork = TRUE`)
#'     the function throws an error if either the data set does not exist or
#'     if the folder can not be accessed (e.g. if no internet connection is
#'     available).
#'
#' @param pattern for `mtbls_list_files()`, `mtbls_sync_data_files()` and
#'     `mtbls_cached_data_files()`: `character(1)` defining a pattern
#'     to filter the file names, such as `pattern = "^a_"` to retrieve the
#'     file names of all assay files of the data set (i.e., files with a name
#'     starting with `"a_"`). This parameter is passed to the [grepl()]
#'     function.
#'
#' @param fileName for `mtbls_sync_data_files()` and
#'     `mtbls_cached_data_files()`: optional `character`
#'     defining the names of specific data files of a data set that should be
#'     downloaded and cached.
#'
#' @return
#'
#' - For `mtbls_ftp_path()`: `character(1)` with the ftp path to the specified
#'   data set on the MetaboLights ftp server.
#' - For `mtbls_list_files()`: `character` with the names of the files in the
#'   data set's base ftp directory.
#' - For `mtbls_sync_data_files()` and `mtbls_cached_data_files()`: a
#'   `data.frame` with the MetaboLights ID, the assay name(s) and remote and
#'   local file names of the synchronized data files.
#'
#' @author Johannes Rainer, Philippine Louail
#'
#' @examples
#'
#' ## Get the FTP path to the data set MTBLS2
#' mtbls_ftp_path("MTBLS2")
#'
#' ## Retrieve available files (and directories) for the data set MTBLS2
#' mtbls_list_files("MTBLS2")
#'
#' ## Retrieve the available assay files (file names starting with "a_").
#' afiles <- mtbls_list_files("MTBLS2", pattern = "^a_")
#' afiles
#'
#' ## Read the content of one file. Connections to the MetaboLights ftp server
#' ## are limited and might fail, thus we use the `retry()` function to
#' ## retry on failure for 5 times (waiting `i * sleep_mult` seconds in between)
#' a <- retry(
#'     read.table(paste0(mtbls_ftp_path("MTBLS2"), afiles[1L]),
#'     header = TRUE, sep = "\t", check.names = FALSE),
#'     ntimes = 5, sleep_mult = 4)
#' head(a)
#'
#' ## List all available files
#' mtbls_cached_data_files()
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
        mtbls_list_files(x)
    res
}

#' @importFrom curl new_handle handle_setopt curl
#'
#' @rdname MetaboLights-utils
#'
#' @export
mtbls_list_files <- function(x = character(), pattern = NULL) {
    cu <- new_handle()
    handle_setopt(cu, ftp_use_epsv = TRUE, dirlistonly = TRUE)
    tryCatch({
        con <- retry(
            curl(url = mtbls_ftp_path(x, mustWork = FALSE), "r", handle = cu),
            sleep_mult = .sleep_mult())
    }, error = function(e) {
        stop("Failed to connect to MetaboLights. No internet connection? ",
             "Does the data set \"", x, "\" exist?\n - ", e$message,
             call. = FALSE)
    })
    fls <- retry(readLines(con), sleep_mult = .sleep_mult())
    close(con)
    if (length(pattern))
        fls[grepl(pattern, fls)]
    else fls
}

#' retrieves and reads the/all assay data file(s) for a given MetaboLights
#' data set and returns it/them as a `list` of `data.frame`s. The file
#' names of the respective assay data file(s) are reported as `names()` of
#' the returned `list`.
#'
#' @param x `character(1)` with the MetaboLights ID of the data set.
#'
#' @importFrom utils read.table
#'
#' @noRd
.mtbls_assay_list <- function(x = character()) {
    fpath <- mtbls_ftp_path(x, mustWork = FALSE)
    a_fls <- mtbls_list_files(x, pattern = "^a_")
    res <- lapply(a_fls, function(z) {
        retry(read.table(paste0(fpath, z),
                          sep = "\t", header = TRUE,
                          check.names = FALSE),
               sleep_mult = .sleep_mult())
    })
    names(res) <- a_fls
    res
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
.mtbls_data_file_from_assay <-
    function(x, pattern = "mzML$|CDF$|cdf$|mzXML$",
             colname = "Derived Spectral Data File") {
        cls <- which(colnames(x) == colname)
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

################################################################################
##
## File caching utils
##
################################################################################

#' @rdname MetaboLights-utils
#'
#' @export
mtbls_sync_data_files <- function(mtblsId = character(),
                                  assayName = character(),
                                  pattern = "mzML$|CDF$|cdf$|mzXML$",
                                  fileName = character()) {
    if (!length(mtblsId))
        stop("No MetaboLights data set ID provided with parameter 'mtblsId'")
    .mtbls_data_files(mtblsId, assayName, pattern, fileName)
}

#' @rdname MetaboLights-utils
#'
#' @export
mtbls_cached_data_files <- function(mtblsId = character(),
                                    assayName = character(),
                                    pattern = "*", fileName = character()) {
    res <- .mtbls_data_files_offline(mtblsId = mtblsId, assayName = assayName,
                                     pattern = pattern)
    if (length(fileName))
        res <- res[basename(res$derived_spectral_data_file) %in% fileName, ]
    else res
}

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
#' @note
#'
#' Download from MsBackendMetaboLights is tried 3 times with an increasing time
#' delay between tries that can be configured using the
#' `"metabolights.sleep_mult"` option.
#'
#' @importFrom BiocFileCache BiocFileCache
#'
#' @importFrom progress progress_bar
#'
#' @importMethodsFrom BiocFileCache bfcrpath bfcmeta<-
#'
#' @importFrom utils capture.output
#'
#' @noRd
.mtbls_data_files <- function(mtblsId = character(), assayName = character(),
                              pattern = "mzML$|CDF$|mzXML$",
                              fileName = character()) {
    assays <- .mtbls_assay_list(mtblsId)
    anames <- names(assays)
    if (length(assayName)) {
        if (!all(assayName %in% anames))
            stop("Not all assay names defined with 'assayName' are available ",
                 "for ", mtblsId, ". Available assay names are: \n",
                 paste0(" - \"", anames, "\"", collapse = "\n"), call. = FALSE)
        assays <- assays[anames %in% assayName]
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
    if (length(fileName)) {
        keep <- basename(ffiles) %in% fileName
        if (!any(keep))
            stop("None of the 'fileName' found in data set \"", mtblsId, "\"")
        ffiles <- ffiles[keep]
        dfiles <- lapply(dfiles, function(z) z[basename(z) %in% fileName])
    }
    ## Cache files
    bfc <- BiocFileCache()
    pb <- progress_bar$new(format = paste0("[:bar] :current/:",
                                           "total (:percent) in ",
                                           ":elapsed"),
                           total = length(ffiles), clear = FALSE)
    lfiles <- unlist(lapply(ffiles, function(z) {
        pb$tick()
        invisible(capture.output(suppressMessages(
            f <- retry(bfcrpath(bfc, paste0(fpath, z), fname = "exact"),
                        sleep_mult = .sleep_mult()))))
        f
    }))

    ## lfiles <- bfcrpath(bfc, paste0(fpath, ffiles), fname = "exact")
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
#' @importMethodsFrom BiocFileCache bfcquery
#'
#' @noRd
.mtbls_data_files_offline <- function(mtblsId = character(),
                                      assayName = character(),
                                      pattern = "mzML$|CDF$|mzXML$") {
    bfc <- BiocFileCache()
    if (!.mtbls_has_mtbls_table())
        stop("No local MetaboLights cache available. Please re-run with ",
             "'offline = FALSE' first.", call. = FALSE)
    res <- as.data.frame(bfcquery(bfc, mtblsId, field = "mtbls_id"))
    if (length(assayName)) {
        res <- res[res$mtbls_assay_name %in% assayName, ]
    }
    res <- res[grepl(pattern, res$derived_spectral_data_file), ]
    if (!nrow(res))
        stop("No locally cached data files found for the specified ",
             "parameters.", call. = FALSE)
    res[, c("rid", "mtbls_id", "mtbls_assay_name",
            "derived_spectral_data_file", "rpath")]
}

#' @importMethodsFrom BiocFileCache bfcmetalist
#'
#' @noRd
.mtbls_has_mtbls_table <- function() {
    bfc <- BiocFileCache()
    any(bfcmetalist(bfc) == "MTBLS")
}

#' @rdname MetaboLights-utils
#'
#' @importFrom BiocFileCache bfcremove bfcinfo
#'
#' @export
mtbls_delete_cache <- function(mtblsId = character()) {
    bfc <- BiocFileCache()
    b <- as.data.frame(bfcinfo(bfc))
    if (nrow(b) && any(colnames(b) == "mtbls_id")) {
        if (length(mtblsId)) {
            rem <- b[b$mtbls_id %in% mtblsId, ]
            bfcremove(bfc, rids = rem$rid)
        }
    }
}
