# MsBackend representing MS data from MetaboLights

`MsBackendMetaboLights` retrieves and represents mass spectrometry (MS)
data from metabolomics experiments stored in the
[MetaboLights](https://www.ebi.ac.uk/metabolights/) repository. The
backend directly extends the
[Spectra::MsBackendMzR](https://rdrr.io/pkg/Spectra/man/MsBackend.html)
backend from the *Spectra* package and hence supports MS data in mzML,
netCDF and mzXML format. Data in other formats can not be loaded with
`MsBackendMetaboLights`. Upon initialization with the
`backendInitialize()` method, the `MsBackendMetaboLights` backend
downloads and caches the MS data files of an experiment locally avoiding
hence repeated download of the data. The local data cache is managed by
Bioconductor's *BiocFileCache* package. See the help and vignettes from
that package for details on cached data resources. Additional utility
function for management of cached files are also provided by
*MsBackendMetaboLights*. See help for
[`mtbls_cached_data_files()`](https://rformassspectrometry.github.io/MsBackendMetaboLights/reference/MetaboLights-utils.md)
for more information.

## Usage

``` r
MsBackendMetaboLights()

# S4 method for class 'MsBackendMetaboLights'
backendInitialize(
  object,
  mtblsId = character(),
  assayName = character(),
  filePattern = "mzML$|CDF$|cdf$|mzXML$",
  offline = FALSE,
  ...
)

# S4 method for class 'MsBackendMetaboLights'
backendRequiredSpectraVariables(object, ...)

mtbls_sync(x, offline = FALSE)
```

## Arguments

- object:

  an instance of `MsBackendMetaboLights`.

- mtblsId:

  `character(1)` with the ID of a single MetaboLights data
  set/experiment.

- assayName:

  `character` with the file names of assay files of the data set. If not
  provided (`assayName = character()`, the default), MS data files of
  all data set's assays are loaded. Use
  `mtbls_list_files(<MetaboLights ID>, pattern = "^a_")` to list all
  available assay files of a data set `<MetaboLights ID>`.

- filePattern:

  `character` with the pattern defining the supported (or requested)
  file types. Defaults to `filePattern = "mzML$|CDF$|cdf$|mzXML$"` hence
  restricting to mzML, CDF and mzXML files which are supported by
  *Spectra*'s `MsBackendMzR` backend.

- offline:

  `logical(1)` whether only locally cached content should be
  evaluated/loaded.

- ...:

  additional parameters; currently ignored.

- x:

  an instance of `MsBackendMetaboLights`.

## Value

- For `MsBackendMetaboLights()`: an instance of `MsBackendMetaboLights`.

- For
  [`backendInitialize()`](https://rdrr.io/pkg/ProtGenerics/man/backendInitialize.html):
  an instance of `MsBackendMetaboLights` with the MS data of the
  specified MetaboLights data set.

- For
  [`backendRequiredSpectraVariables()`](https://rdrr.io/pkg/Spectra/man/MsBackend.html):
  `character` with spectra variables that are needed for the backend to
  provide the MS data.

- For `mtbls_sync()`: the input `MsBackendMetaboLights` with the paths
  to the locally cached data files being eventually updated.

## Details

File names for data files are by default extracted from the column
`"Derived Spectral Data File"` of the MetaboLights data set's *assay*
table. If this column does not contain any supported file names, the
assay's column `"Raw Spectral Data File"` is evaluated instead.

The backend uses the
[BiocFileCache](https://bioconductor.org/packages/BiocFileCache) package
for caching of the data files. These are stored in the default local
*BiocFileCache* cache along with additional metadata that includes the
MetaboLights ID and the assay file name with which the data file is
associated with. Note that at present only MS data files in *mzML*,
*CDF* and *mzXML* format are supported.

The `MsBackendMetaboLights` backend defines and provides additional
spectra variables `"mtbls_id"`, `"mtbls_assay_name"` and
`"derived_spectral_data_file"` that list the MetaboLights ID, the name
of the assay file and the original data file name on the MetaboLights
ftp server for each individual spectrum. The
`"derived_spectral_data_file"` can be used for the mapping between the
experiment's samples and the individual data files, respective their
spectra. This mapping is provided in the MetaboLights assay file.

The `MsBackendMetaboLights` backend is considered *read-only* and does
thus not support changing *m/z* and intensity values directly.

## Note

To account for high server load and eventually failing or rejected
downloads from the MetaboLights ftp server, the download functions
repeatedly retry to download a file. An error is thrown if download
fails for 3 consecutive attempts. Between each attemp, the function
waits for an increasing time period (5 seconds between the first and
second and 10 seconds between the 2nd and 3rd attempt). This time period
can also be configured with the `"metabolights.sleep_mult"` option,
which defines the *sleep time multiplicator* (defaults to 5).

## Initialization and loading of data

New instances of the class can be created with the
`MsBackendMetaboLights()` function. Data is loaded and initialized using
the
[`backendInitialize()`](https://rdrr.io/pkg/ProtGenerics/man/backendInitialize.html)
function which can be configured with parameters `mtblsId`, `assayName`
and `filePattern`. `mtblsId` must be the ID of a **single** (existing)
MetaboLights data set. Parameter `assayName` allows to define specific
*assays* of the MetaboLights data set from which the data files should
be loaded. If provided, it should be the file name(s) of the respective
assay(s) in MetaboLights (use e.g.
`mtbls_list_files(<MetaboLights ID>, pattern = "^a_")` to list all
available assay files for a given MetaboLights ID `<MetaboLights ID>`).
By default, with `assayName = character()` MS data files from **all**
assays of a data set are loaded. Optional parameter `filePattern`
defines the pattern that should be used to filter the file names of the
MS data files. It defaults to data files with file endings of supported
MS data files.
[`backendInitialize()`](https://rdrr.io/pkg/ProtGenerics/man/backendInitialize.html)
requires an active internet connection as the function first compares
the remote file content to the locally cached files and eventually
synchronizes changes/updates. This can be skipped with `offline = TRUE`
in which case only locally cached content is queried.

The
[`backendRequiredSpectraVariables()`](https://rdrr.io/pkg/Spectra/man/MsBackend.html)
function returns the names of the spectra variables required for the
backend to provide the MS data.

The `mtbls_sync()` function can be used to *synchronize* the local data
cache and ensure that all data files are locally available. The function
will check the local cache and eventually download missing data files
from the MetaboLights repository.

## Author

Philippine Louail, Johannes Rainer

## Examples

``` r

library(MsBackendMetaboLights)

## List files of a MetaboLights data set
mtbls_list_files("MTBLS39")
#> [1] "FILES"                                                                                                          
#> [2] "HASHES"                                                                                                         
#> [3] "METADATA_REVISIONS"                                                                                             
#> [4] "a_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry.txt"       
#> [5] "i_Investigation.txt"                                                                                            
#> [6] "m_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry_v2_maf.tsv"
#> [7] "s_MTBLS39.txt"                                                                                                  

## Initialize a MsBackendMetaboLights representing all MS data files of
## the data set with the ID "MTBLS39". This will download and cache all
## files and subsequently load and represent them in R.

be <- backendInitialize(MsBackendMetaboLights(), "MTBLS39")
#> Used data files from the assay's column "Raw Spectral Data File" since none were available in column "Derived Spectral Data File".
be
#> MsBackendMetaboLights with 15141 spectra
#>         msLevel     rtime scanIndex
#>       <integer> <numeric> <integer>
#> 1             1  0.296384         1
#> 2             1  6.206912         2
#> 3             1 12.093056         3
#> 4             1 17.942912         4
#> 5             1 23.835072         5
#> ...         ...       ...       ...
#> 15137         1   2682.81       596
#> 15138         1   2687.29       597
#> 15139         1   2691.77       598
#> 15140         1   2696.27       599
#> 15141         1   2700.81       600
#>  ... 37 more variables/columns.
#> 
#> file(s):
#> MN063A.cdf
#> MN063B.cdf
#> MN063C.cdf
#>  ... 24 more files

## The `mtbls_sync()` function can be used to ensure that all data files are
## available locally. This function will eventually download missing data
## files or update their paths.
be <- mtbls_sync(be)
#> Used data files from the assay's column "Raw Spectral Data File" since none were available in column "Derived Spectral Data File".
```
