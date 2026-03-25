# Utility functions for the MetaboLights repository

[MetaboLights](https://www.ebi.ac.uk/metabolights/) is one of the main
public repositories for deposition of metabolomics experiments including
(raw) mass spectrometry (MS) and NMR data files and
experimental/analysis results. The experimental metadata and results are
stored as plain text files in ISA-tab format. Each MetaboLights
experiment must provide a file describing the samples analyzed and at
least one *assay* file that links between the experimental samples and
the (raw and processed) data files with quantification of
metabolites/features in these samples.

Each experiment in MetaboLights is identified with its unique
identifier, starting with *MTBLS* followed by a number. The data
(metadata files and MS/NMR data files) of an experiment are available
through the repository's ftp server.

The functions listed here allow to query and retrieve information of a
data set/experiment from MetaboLights.

- `mtbls_ftp_path()`: returns the FTP path for a provided MetaboLights
  ID. With `mustWork = TRUE` (the default) the function throws an error
  if the path is not accessible (either because the data set does not
  exist or no internet connection is available). The function returns a
  `character(1)` with the FTP path to the data set folder.

- `mtbls_list_files()`: returns the available files (and directories)
  for the specified MetaboLights data set (i.e., the FTP directory
  content of the data set). The function returns a `character` vector
  with the relative file names to the absolute FTP path
  (`mtbls_ftp_path()`) of the data set. Parameter `pattern` allows to
  filter the file names and define which file names should be returned.

- `mtbls_assay_data()`: retrieves one of the *assay* files for a
  MetaboLights data set (parameter `mtblsId`) returning its content as a
  `data.frame`. Parameter `assayName` allows to specify which assay file
  to load (if multiple are available).

- `mtbls_sample_data()`: gets the *sample* file for a MetaboLights data
  set (parameter `mtblsId`) and returns its content as a `data.frame`.

- `mtbls_metadata()`: gets one *assay* file for the specified
  MetaboLights data set (parameter `mtblsId`) and merges it with the
  respective *sample* information returning the content as a
  `data.frame`. Optional parameters `keepOntology`, `keepProtocol` and
  `simplify` allow to restrict the returned content to fewer columns.

- `mtbls_cached_data_files()`: lists locally cached data files from
  MetaboLights. Since this function evaluates only local content it does
  not require an internet connection. With the default parameters all
  available data files are listed. The parameters can be used to
  restrict the lookup.

- `mtbls_sync_data_files()`: synchronize data files of a specifies
  MetaboLights data set eventually downloading and locally caching them.
  Parameter `fileName` allows to specify names of selected data files to
  sync.

- `mtbls_delete_cache()`: removes all local content for the MetaboLights
  data set with ID `mtblsId`. This will delete eventually present
  locally cached data files for the specified data set. This does not
  change any other data eventually present in the local `BiocFileCache`.

## Usage

``` r
mtbls_ftp_path(x = character(), mustWork = TRUE)

mtbls_list_files(x = character(), pattern = NULL)

mtbls_sync_data_files(
  mtblsId = character(),
  assayName = character(),
  pattern = "mzML$|CDF$|cdf$|mzXML$",
  fileName = character()
)

mtbls_cached_data_files(
  mtblsId = character(),
  assayName = character(),
  pattern = "*",
  fileName = character()
)

mtbls_delete_cache(mtblsId = character())

mtbls_assay_data(mtblsId = character(), assayName = character())

mtbls_sample_data(mtblsId = character())

mtbls_metadata(
  mtblsId = character(),
  assayName = character(),
  keepOntology = TRUE,
  keepProtocol = TRUE,
  simplify = FALSE
)
```

## Arguments

- x:

  `character(1)` with the ID of the MetaboLights data set (usually
  starting with a *MTBLS* followed by a number).

- mustWork:

  for `mtbls_ftp_path()`: `logical(1)` whether the validity of the path
  should be verified or not. By default (with `mustWork = TRUE`) the
  function throws an error if either the data set does not exist or if
  the folder can not be accessed (e.g. if no internet connection is
  available).

- pattern:

  for `mtbls_list_files()`, `mtbls_sync_data_files()` and
  `mtbls_cached_data_files()`: `character(1)` defining a pattern to
  filter the file names, such as `pattern = "^a_"` to retrieve the file
  names of all assay files of the data set (i.e., files with a name
  starting with `"a_"`). This parameter is passed to the
  [`grepl()`](https://rdrr.io/r/base/grep.html) function.

- mtblsId:

  `character(1)` with the ID of a single MetaboLights data
  set/experiment.

- assayName:

  `character` with the file names of assay files of the data set. If not
  provided (`assayName = character()`, the default), MS data files of
  all data set's assays are loaded. Use
  `mtbls_list_files(<MetaboLights ID>, pattern = "^a_")` to list all
  available assay files of a data set `<MetaboLights ID>`.

- fileName:

  for `mtbls_sync_data_files()` and `mtbls_cached_data_files()`:
  optional `character` defining the names of specific data files of a
  data set that should be downloaded and cached.

- keepOntology:

  for `mtbls_metadata()`: `logical(1)` whether to keep columns related
  to ontology. Default is `TRUE`.

- keepProtocol:

  for `mtbls_metadata()`: `logical(1)` whether to keep columns with
  information related to protocols. Default is `TRUE`.

- simplify:

  for `mtbls_metadata()`: `logical(1)` whether to simplify the result
  removing columns with only missing data or duplicated content. Default
  is `FALSE`.

## Value

- For `mtbls_ftp_path()`: `character(1)` with the ftp path to the
  specified data set on the MetaboLights ftp server.

- For `mtbls_list_files()`: `character` with the names of the files in
  the data set's base ftp directory.

- For `mtbls_sync_data_files()` and `mtbls_cached_data_files()`: a
  `data.frame` with the MetaboLights ID, the assay name(s) and remote
  and local file names of the synchronized data files.

## Author

Johannes Rainer, Philippine Louail

## Examples

``` r

## Get the FTP path to the data set MTBLS2
mtbls_ftp_path("MTBLS2")
#> [1] "ftp://ftp.ebi.ac.uk/pub/databases/metabolights/studies/public/MTBLS2/"

## Retrieve available files (and directories) for the data set MTBLS2
mtbls_list_files("MTBLS2")
#> [1] "FILES"                                                     
#> [2] "HASHES"                                                    
#> [3] "METADATA_REVISIONS"                                        
#> [4] "a_MTBLS2_metabolite_profiling_mass_spectrometry.txt"       
#> [5] "i_Investigation.txt"                                       
#> [6] "m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv"
#> [7] "s_MTBLS2.txt"                                              

## Retrieve the available assay files (file names starting with "a_").
afiles <- mtbls_list_files("MTBLS2", pattern = "^a_")
afiles
#> [1] "a_MTBLS2_metabolite_profiling_mass_spectrometry.txt"

## Read the content of one file. Connections to the MetaboLights ftp server
## are limited and might fail, thus we use the `retry()` function to
## retry on failure for 5 times (waiting `i * sleep_mult` seconds in between)
a <- retry(
    read.table(paste0(mtbls_ftp_path("MTBLS2"), afiles[1L]),
    header = TRUE, sep = "\t", check.names = FALSE),
    ntimes = 5, sleep_mult = 4)
head(a)
#>          Sample Name Protocol REF   Parameter Value[Post Extraction]
#> 1  Ex1-Col0-48h-Ag-1   Extraction 200 µL methanol:water (30:70, v/v)
#> 2  Ex1-Col0-48h-Ag-2   Extraction 200 µL methanol:water (30:70, v/v)
#> 3  Ex1-Col0-48h-Ag-3   Extraction 200 µL methanol:water (30:70, v/v)
#> 4  Ex1-Col0-48h-Ag-4   Extraction 200 µL methanol:water (30:70, v/v)
#> 5 Ex1-cyp79-48h-Ag-1   Extraction 200 µL methanol:water (30:70, v/v)
#> 6 Ex1-cyp79-48h-Ag-2   Extraction 200 µL methanol:water (30:70, v/v)
#>   Parameter Value[Derivatization]       Extract Name   Protocol REF
#> 1                              NA  Ex1-Col0-48h-Ag-1 Chromatography
#> 2                              NA  Ex1-Col0-48h-Ag-2 Chromatography
#> 3                              NA  Ex1-Col0-48h-Ag-3 Chromatography
#> 4                              NA  Ex1-Col0-48h-Ag-4 Chromatography
#> 5                              NA Ex1-cyp79-48h-Ag-1 Chromatography
#> 6                              NA Ex1-cyp79-48h-Ag-2 Chromatography
#>   Parameter Value[Chromatography Instrument] Term Source REF
#> 1                 Waters ACQUITY UPLC system           MTBLS
#> 2                 Waters ACQUITY UPLC system           MTBLS
#> 3                 Waters ACQUITY UPLC system           MTBLS
#> 4                 Waters ACQUITY UPLC system           MTBLS
#> 5                 Waters ACQUITY UPLC system           MTBLS
#> 6                 Waters ACQUITY UPLC system           MTBLS
#>                                     Term Accession Number
#> 1 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 2 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 3 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 4 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 5 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 6 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#>   Parameter Value[Autosampler model]
#> 1                                 NA
#> 2                                 NA
#> 3                                 NA
#> 4                                 NA
#> 5                                 NA
#> 6                                 NA
#>                         Parameter Value[Column model]
#> 1 ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 2 ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 3 ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 4 ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 5 ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 6 ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#>   Parameter Value[Column type] Parameter Value[Guard column]
#> 1                reverse phase                            NA
#> 2                reverse phase                            NA
#> 3                reverse phase                            NA
#> 4                reverse phase                            NA
#> 5                reverse phase                            NA
#> 6                reverse phase                            NA
#>   Labeled Extract Name Label Term Source REF Term Accession Number
#> 1                   NA    NA              NA                    NA
#> 2                   NA    NA              NA                    NA
#> 3                   NA    NA              NA                    NA
#> 4                   NA    NA              NA                    NA
#> 5                   NA    NA              NA                    NA
#> 6                   NA    NA              NA                    NA
#>        Protocol REF Parameter Value[Scan polarity]
#> 1 Mass spectrometry                       positive
#> 2 Mass spectrometry                       positive
#> 3 Mass spectrometry                       positive
#> 4 Mass spectrometry                       positive
#> 5 Mass spectrometry                       positive
#> 6 Mass spectrometry                       positive
#>   Parameter Value[Scan m/z range] Parameter Value[Instrument] Term Source REF
#> 1                        100-1000        Bruker micrOTOF-Q II           MTBLS
#> 2                        100-1000        Bruker micrOTOF-Q II           MTBLS
#> 3                        100-1000        Bruker micrOTOF-Q II           MTBLS
#> 4                        100-1000        Bruker micrOTOF-Q II           MTBLS
#> 5                        100-1000        Bruker micrOTOF-Q II           MTBLS
#> 6                        100-1000        Bruker micrOTOF-Q II           MTBLS
#>                                     Term Accession Number
#> 1 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 2 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 3 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 4 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 5 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 6 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#>   Parameter Value[Ion source] Term Source REF
#> 1     electrospray ionization              MS
#> 2     electrospray ionization              MS
#> 3     electrospray ionization              MS
#> 4     electrospray ionization              MS
#> 5     electrospray ionization              MS
#> 6     electrospray ionization              MS
#>                       Term Accession Number Parameter Value[Mass analyzer]
#> 1 http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 2 http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 3 http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 4 http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 5 http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 6 http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#>   Term Source REF                                   Term Accession Number
#> 1           MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 2           MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 3           MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 4           MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 5           MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 6           MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#>                      MS Assay Name
#> 1  Ex1-Col0-48h-Ag-1_1-A,1_01_9818
#> 2  Ex1-Col0-48h-Ag-2_1-A,1_01_9820
#> 3  Ex1-Col0-48h-Ag-3_1-A,1_01_9822
#> 4  Ex1-Col0-48h-Ag-4_1-A,1_01_9824
#> 5 Ex1-cyp79-48h-Ag-1_1-B,1_01_9819
#> 6 Ex1-cyp79-48h-Ag-2_1-B,2_01_9821
#>                           Raw Spectral Data File        Protocol REF
#> 1  FILES/MSpos-Ex1-Col0-48h-Ag-1_1-A,1_01_9818.d Data transformation
#> 2  FILES/MSpos-Ex1-Col0-48h-Ag-2_1-A,1_01_9820.d Data transformation
#> 3  FILES/MSpos-Ex1-Col0-48h-Ag-3_1-A,1_01_9822.d Data transformation
#> 4  FILES/MSpos-Ex1-Col0-48h-Ag-4_1-A,1_01_9824.d Data transformation
#> 5 FILES/MSpos-Ex1-cyp79-48h-Ag-1_1-B,1_01_9819.d Data transformation
#> 6 FILES/MSpos-Ex1-cyp79-48h-Ag-2_1-B,2_01_9821.d Data transformation
#>                 Normalization Name
#> 1  Ex1-Col0-48h-Ag-1_1-A,1_01_9818
#> 2  Ex1-Col0-48h-Ag-2_1-A,1_01_9820
#> 3  Ex1-Col0-48h-Ag-3_1-A,1_01_9822
#> 4  Ex1-Col0-48h-Ag-4_1-A,1_01_9824
#> 5 Ex1-cyp79-48h-Ag-1_1-B,1_01_9819
#> 6 Ex1-cyp79-48h-Ag-2_1-B,2_01_9821
#>                                Derived Spectral Data File
#> 1  FILES/mzML/MSpos-Ex1-Col0-48h-Ag-1_1-A__1_01_9818.mzML
#> 2  FILES/mzML/MSpos-Ex1-Col0-48h-Ag-2_1-A__1_01_9820.mzML
#> 3  FILES/mzML/MSpos-Ex1-Col0-48h-Ag-3_1-A__1_01_9822.mzML
#> 4  FILES/mzML/MSpos-Ex1-Col0-48h-Ag-4_1-A__1_01_9824.mzML
#> 5 FILES/mzML/MSpos-Ex1-cyp79-48h-Ag-1_1-B__1_01_9819.mzML
#> 6 FILES/mzML/MSpos-Ex1-cyp79-48h-Ag-2_1-B__2_01_9821.mzML
#>                                   Derived Spectral Data File
#> 1  FILES/mzData/MSpos-Ex1-Col0-48h-Ag-1_1-A,1_01_9818.mzData
#> 2  FILES/mzData/MSpos-Ex1-Col0-48h-Ag-2_1-A,1_01_9820.mzData
#> 3  FILES/mzData/MSpos-Ex1-Col0-48h-Ag-3_1-A,1_01_9822.mzData
#> 4  FILES/mzData/MSpos-Ex1-Col0-48h-Ag-4_1-A,1_01_9824.mzData
#> 5 FILES/mzData/MSpos-Ex1-cyp79-48h-Ag-1_1-B,1_01_9819.mzData
#> 6 FILES/mzData/MSpos-Ex1-cyp79-48h-Ag-2_1-B,2_01_9821.mzData
#>                Protocol REF         Data Transformation Name
#> 1 Metabolite identification  Ex1-Col0-48h-Ag-1_1-A,1_01_9818
#> 2 Metabolite identification  Ex1-Col0-48h-Ag-2_1-A,1_01_9820
#> 3 Metabolite identification  Ex1-Col0-48h-Ag-3_1-A,1_01_9822
#> 4 Metabolite identification  Ex1-Col0-48h-Ag-4_1-A,1_01_9824
#> 5 Metabolite identification Ex1-cyp79-48h-Ag-1_1-B,1_01_9819
#> 6 Metabolite identification Ex1-cyp79-48h-Ag-2_1-B,2_01_9821
#>                                   Metabolite Assignment File
#> 1 m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 2 m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 3 m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 4 m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 5 m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 6 m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#>   Factor Value[genotype] Term Source REF Term Accession Number
#> 1                  Col-0              NA                    NA
#> 2                  Col-0              NA                    NA
#> 3                  Col-0              NA                    NA
#> 4                  Col-0              NA                    NA
#> 5                  cyp79              NA                    NA
#> 6                  cyp79              NA                    NA
#>   Factor Value[replicate] Term Source REF Term Accession Number
#> 1                    Exp1              NA                    NA
#> 2                    Exp1              NA                    NA
#> 3                    Exp1              NA                    NA
#> 4                    Exp1              NA                    NA
#> 5                    Exp1              NA                    NA
#> 6                    Exp1              NA                    NA

## Get the assay information for one MTBLS data set
mtbls_assay_data("MTBLS2")
#>           Sample Name Protocol REF   Parameter Value[Post Extraction]
#> 1   Ex1-Col0-48h-Ag-1   Extraction 200 µL methanol:water (30:70, v/v)
#> 2   Ex1-Col0-48h-Ag-2   Extraction 200 µL methanol:water (30:70, v/v)
#> 3   Ex1-Col0-48h-Ag-3   Extraction 200 µL methanol:water (30:70, v/v)
#> 4   Ex1-Col0-48h-Ag-4   Extraction 200 µL methanol:water (30:70, v/v)
#> 5  Ex1-cyp79-48h-Ag-1   Extraction 200 µL methanol:water (30:70, v/v)
#> 6  Ex1-cyp79-48h-Ag-2   Extraction 200 µL methanol:water (30:70, v/v)
#> 7  Ex1-cyp79-48h-Ag-3   Extraction 200 µL methanol:water (30:70, v/v)
#> 8  Ex1-cyp79-48h-Ag-4   Extraction 200 µL methanol:water (30:70, v/v)
#> 9   Ex2-Col0-48h-Ag-1   Extraction 200 µL methanol:water (30:70, v/v)
#> 10  Ex2-Col0-48h-Ag-2   Extraction 200 µL methanol:water (30:70, v/v)
#> 11  Ex2-Col0-48h-Ag-3   Extraction 200 µL methanol:water (30:70, v/v)
#> 12  Ex2-Col0-48h-Ag-4   Extraction 200 µL methanol:water (30:70, v/v)
#> 13 Ex2-cyp79-48h-Ag-1   Extraction 200 µL methanol:water (30:70, v/v)
#> 14 Ex2-cyp79-48h-Ag-2   Extraction 200 µL methanol:water (30:70, v/v)
#> 15 Ex2-cyp79-48h-Ag-3   Extraction 200 µL methanol:water (30:70, v/v)
#> 16 Ex2-cyp79-48h-Ag-4   Extraction 200 µL methanol:water (30:70, v/v)
#>    Parameter Value[Derivatization]       Extract Name   Protocol REF
#> 1                               NA  Ex1-Col0-48h-Ag-1 Chromatography
#> 2                               NA  Ex1-Col0-48h-Ag-2 Chromatography
#> 3                               NA  Ex1-Col0-48h-Ag-3 Chromatography
#> 4                               NA  Ex1-Col0-48h-Ag-4 Chromatography
#> 5                               NA Ex1-cyp79-48h-Ag-1 Chromatography
#> 6                               NA Ex1-cyp79-48h-Ag-2 Chromatography
#> 7                               NA Ex1-cyp79-48h-Ag-3 Chromatography
#> 8                               NA Ex1-cyp79-48h-Ag-4 Chromatography
#> 9                               NA  Ex2-Col0-48h-Ag-1 Chromatography
#> 10                              NA  Ex2-Col0-48h-Ag-2 Chromatography
#> 11                              NA  Ex2-Col0-48h-Ag-3 Chromatography
#> 12                              NA  Ex2-Col0-48h-Ag-4 Chromatography
#> 13                              NA Ex2-cyp79-48h-Ag-1 Chromatography
#> 14                              NA Ex2-cyp79-48h-Ag-2 Chromatography
#> 15                              NA Ex2-cyp79-48h-Ag-3 Chromatography
#> 16                              NA Ex2-cyp79-48h-Ag-4 Chromatography
#>    Parameter Value[Chromatography Instrument] Term Source REF
#> 1                  Waters ACQUITY UPLC system           MTBLS
#> 2                  Waters ACQUITY UPLC system           MTBLS
#> 3                  Waters ACQUITY UPLC system           MTBLS
#> 4                  Waters ACQUITY UPLC system           MTBLS
#> 5                  Waters ACQUITY UPLC system           MTBLS
#> 6                  Waters ACQUITY UPLC system           MTBLS
#> 7                  Waters ACQUITY UPLC system           MTBLS
#> 8                  Waters ACQUITY UPLC system           MTBLS
#> 9                  Waters ACQUITY UPLC system           MTBLS
#> 10                 Waters ACQUITY UPLC system           MTBLS
#> 11                 Waters ACQUITY UPLC system           MTBLS
#> 12                 Waters ACQUITY UPLC system           MTBLS
#> 13                 Waters ACQUITY UPLC system           MTBLS
#> 14                 Waters ACQUITY UPLC system           MTBLS
#> 15                 Waters ACQUITY UPLC system           MTBLS
#> 16                 Waters ACQUITY UPLC system           MTBLS
#>                                      Term Accession Number
#> 1  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 2  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 3  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 4  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 5  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 6  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 7  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 8  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 9  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 10 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 11 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 12 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 13 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 14 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 15 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#> 16 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000877
#>    Parameter Value[Autosampler model]
#> 1                                  NA
#> 2                                  NA
#> 3                                  NA
#> 4                                  NA
#> 5                                  NA
#> 6                                  NA
#> 7                                  NA
#> 8                                  NA
#> 9                                  NA
#> 10                                 NA
#> 11                                 NA
#> 12                                 NA
#> 13                                 NA
#> 14                                 NA
#> 15                                 NA
#> 16                                 NA
#>                          Parameter Value[Column model]
#> 1  ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 2  ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 3  ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 4  ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 5  ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 6  ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 7  ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 8  ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 9  ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 10 ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 11 ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 12 ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 13 ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 14 ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 15 ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#> 16 ACQUITY UPLC HSS T3 (1.8 µm, 1 mm x 100 mm; Waters)
#>    Parameter Value[Column type] Parameter Value[Guard column]
#> 1                 reverse phase                            NA
#> 2                 reverse phase                            NA
#> 3                 reverse phase                            NA
#> 4                 reverse phase                            NA
#> 5                 reverse phase                            NA
#> 6                 reverse phase                            NA
#> 7                 reverse phase                            NA
#> 8                 reverse phase                            NA
#> 9                 reverse phase                            NA
#> 10                reverse phase                            NA
#> 11                reverse phase                            NA
#> 12                reverse phase                            NA
#> 13                reverse phase                            NA
#> 14                reverse phase                            NA
#> 15                reverse phase                            NA
#> 16                reverse phase                            NA
#>    Labeled Extract Name Label Term Source REF Term Accession Number
#> 1                    NA    NA              NA                    NA
#> 2                    NA    NA              NA                    NA
#> 3                    NA    NA              NA                    NA
#> 4                    NA    NA              NA                    NA
#> 5                    NA    NA              NA                    NA
#> 6                    NA    NA              NA                    NA
#> 7                    NA    NA              NA                    NA
#> 8                    NA    NA              NA                    NA
#> 9                    NA    NA              NA                    NA
#> 10                   NA    NA              NA                    NA
#> 11                   NA    NA              NA                    NA
#> 12                   NA    NA              NA                    NA
#> 13                   NA    NA              NA                    NA
#> 14                   NA    NA              NA                    NA
#> 15                   NA    NA              NA                    NA
#> 16                   NA    NA              NA                    NA
#>         Protocol REF Parameter Value[Scan polarity]
#> 1  Mass spectrometry                       positive
#> 2  Mass spectrometry                       positive
#> 3  Mass spectrometry                       positive
#> 4  Mass spectrometry                       positive
#> 5  Mass spectrometry                       positive
#> 6  Mass spectrometry                       positive
#> 7  Mass spectrometry                       positive
#> 8  Mass spectrometry                       positive
#> 9  Mass spectrometry                       positive
#> 10 Mass spectrometry                       positive
#> 11 Mass spectrometry                       positive
#> 12 Mass spectrometry                       positive
#> 13 Mass spectrometry                       positive
#> 14 Mass spectrometry                       positive
#> 15 Mass spectrometry                       positive
#> 16 Mass spectrometry                       positive
#>    Parameter Value[Scan m/z range] Parameter Value[Instrument] Term Source REF
#> 1                         100-1000        Bruker micrOTOF-Q II           MTBLS
#> 2                         100-1000        Bruker micrOTOF-Q II           MTBLS
#> 3                         100-1000        Bruker micrOTOF-Q II           MTBLS
#> 4                         100-1000        Bruker micrOTOF-Q II           MTBLS
#> 5                         100-1000        Bruker micrOTOF-Q II           MTBLS
#> 6                         100-1000        Bruker micrOTOF-Q II           MTBLS
#> 7                         100-1000        Bruker micrOTOF-Q II           MTBLS
#> 8                         100-1000        Bruker micrOTOF-Q II           MTBLS
#> 9                         100-1000        Bruker micrOTOF-Q II           MTBLS
#> 10                        100-1000        Bruker micrOTOF-Q II           MTBLS
#> 11                        100-1000        Bruker micrOTOF-Q II           MTBLS
#> 12                        100-1000        Bruker micrOTOF-Q II           MTBLS
#> 13                        100-1000        Bruker micrOTOF-Q II           MTBLS
#> 14                        100-1000        Bruker micrOTOF-Q II           MTBLS
#> 15                        100-1000        Bruker micrOTOF-Q II           MTBLS
#> 16                        100-1000        Bruker micrOTOF-Q II           MTBLS
#>                                      Term Accession Number
#> 1  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 2  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 3  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 4  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 5  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 6  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 7  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 8  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 9  http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 10 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 11 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 12 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 13 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 14 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 15 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#> 16 http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000633
#>    Parameter Value[Ion source] Term Source REF
#> 1      electrospray ionization              MS
#> 2      electrospray ionization              MS
#> 3      electrospray ionization              MS
#> 4      electrospray ionization              MS
#> 5      electrospray ionization              MS
#> 6      electrospray ionization              MS
#> 7      electrospray ionization              MS
#> 8      electrospray ionization              MS
#> 9      electrospray ionization              MS
#> 10     electrospray ionization              MS
#> 11     electrospray ionization              MS
#> 12     electrospray ionization              MS
#> 13     electrospray ionization              MS
#> 14     electrospray ionization              MS
#> 15     electrospray ionization              MS
#> 16     electrospray ionization              MS
#>                        Term Accession Number Parameter Value[Mass analyzer]
#> 1  http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 2  http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 3  http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 4  http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 5  http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 6  http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 7  http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 8  http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 9  http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 10 http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 11 http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 12 http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 13 http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 14 http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 15 http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#> 16 http://purl.obolibrary.org/obo/MS_1000073      quadrupole time-of-flight
#>    Term Source REF                                   Term Accession Number
#> 1            MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 2            MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 3            MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 4            MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 5            MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 6            MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 7            MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 8            MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 9            MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 10           MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 11           MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 12           MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 13           MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 14           MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 15           MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#> 16           MTBLS http://www.ebi.ac.uk/metabolights/ontology/MTBLS_000699
#>                       MS Assay Name
#> 1   Ex1-Col0-48h-Ag-1_1-A,1_01_9818
#> 2   Ex1-Col0-48h-Ag-2_1-A,1_01_9820
#> 3   Ex1-Col0-48h-Ag-3_1-A,1_01_9822
#> 4   Ex1-Col0-48h-Ag-4_1-A,1_01_9824
#> 5  Ex1-cyp79-48h-Ag-1_1-B,1_01_9819
#> 6  Ex1-cyp79-48h-Ag-2_1-B,2_01_9821
#> 7  Ex1-cyp79-48h-Ag-3_1-B,1_01_9823
#> 8  Ex1-cyp79-48h-Ag-4_1-B,2_01_9825
#> 9   Ex2-Col0-48h-Ag-1_1-A,2_01_9827
#> 10  Ex2-Col0-48h-Ag-2_1-A,3_01_9829
#> 11  Ex2-Col0-48h-Ag-3_1-A,4_01_9831
#> 12  Ex2-Col0-48h-Ag-4_1-A,2_01_9833
#> 13 Ex2-cyp79-48h-Ag-1_1-B,3_01_9828
#> 14 Ex2-cyp79-48h-Ag-2_1-B,4_01_9830
#> 15 Ex2-cyp79-48h-Ag-3_1-B,3_01_9832
#> 16 Ex2-cyp79-48h-Ag-4_1-B,4_01_9834
#>                            Raw Spectral Data File        Protocol REF
#> 1   FILES/MSpos-Ex1-Col0-48h-Ag-1_1-A,1_01_9818.d Data transformation
#> 2   FILES/MSpos-Ex1-Col0-48h-Ag-2_1-A,1_01_9820.d Data transformation
#> 3   FILES/MSpos-Ex1-Col0-48h-Ag-3_1-A,1_01_9822.d Data transformation
#> 4   FILES/MSpos-Ex1-Col0-48h-Ag-4_1-A,1_01_9824.d Data transformation
#> 5  FILES/MSpos-Ex1-cyp79-48h-Ag-1_1-B,1_01_9819.d Data transformation
#> 6  FILES/MSpos-Ex1-cyp79-48h-Ag-2_1-B,2_01_9821.d Data transformation
#> 7  FILES/MSpos-Ex1-cyp79-48h-Ag-3_1-B,1_01_9823.d Data transformation
#> 8  FILES/MSpos-Ex1-cyp79-48h-Ag-4_1-B,2_01_9825.d Data transformation
#> 9   FILES/MSpos-Ex2-Col0-48h-Ag-1_1-A,2_01_9827.d Data transformation
#> 10  FILES/MSpos-Ex2-Col0-48h-Ag-2_1-A,3_01_9829.d Data transformation
#> 11  FILES/MSpos-Ex2-Col0-48h-Ag-3_1-A,4_01_9831.d Data transformation
#> 12  FILES/MSpos-Ex2-Col0-48h-Ag-4_1-A,2_01_9833.d Data transformation
#> 13 FILES/MSpos-Ex2-cyp79-48h-Ag-1_1-B,3_01_9828.d Data transformation
#> 14 FILES/MSpos-Ex2-cyp79-48h-Ag-2_1-B,4_01_9830.d Data transformation
#> 15 FILES/MSpos-Ex2-cyp79-48h-Ag-3_1-B,3_01_9832.d Data transformation
#> 16 FILES/MSpos-Ex2-cyp79-48h-Ag-4_1-B,4_01_9834.d Data transformation
#>                  Normalization Name
#> 1   Ex1-Col0-48h-Ag-1_1-A,1_01_9818
#> 2   Ex1-Col0-48h-Ag-2_1-A,1_01_9820
#> 3   Ex1-Col0-48h-Ag-3_1-A,1_01_9822
#> 4   Ex1-Col0-48h-Ag-4_1-A,1_01_9824
#> 5  Ex1-cyp79-48h-Ag-1_1-B,1_01_9819
#> 6  Ex1-cyp79-48h-Ag-2_1-B,2_01_9821
#> 7  Ex1-cyp79-48h-Ag-3_1-B,1_01_9823
#> 8  Ex1-cyp79-48h-Ag-4_1-B,2_01_9825
#> 9   Ex2-Col0-48h-Ag-1_1-A,2_01_9827
#> 10  Ex2-Col0-48h-Ag-2_1-A,3_01_9829
#> 11  Ex2-Col0-48h-Ag-3_1-A,4_01_9831
#> 12  Ex2-Col0-48h-Ag-4_1-A,2_01_9833
#> 13 Ex2-cyp79-48h-Ag-1_1-B,3_01_9828
#> 14 Ex2-cyp79-48h-Ag-2_1-B,4_01_9830
#> 15 Ex2-cyp79-48h-Ag-3_1-B,3_01_9832
#> 16 Ex2-cyp79-48h-Ag-4_1-B,4_01_9834
#>                                 Derived Spectral Data File
#> 1   FILES/mzML/MSpos-Ex1-Col0-48h-Ag-1_1-A__1_01_9818.mzML
#> 2   FILES/mzML/MSpos-Ex1-Col0-48h-Ag-2_1-A__1_01_9820.mzML
#> 3   FILES/mzML/MSpos-Ex1-Col0-48h-Ag-3_1-A__1_01_9822.mzML
#> 4   FILES/mzML/MSpos-Ex1-Col0-48h-Ag-4_1-A__1_01_9824.mzML
#> 5  FILES/mzML/MSpos-Ex1-cyp79-48h-Ag-1_1-B__1_01_9819.mzML
#> 6  FILES/mzML/MSpos-Ex1-cyp79-48h-Ag-2_1-B__2_01_9821.mzML
#> 7  FILES/mzML/MSpos-Ex1-cyp79-48h-Ag-3_1-B__1_01_9823.mzML
#> 8  FILES/mzML/MSpos-Ex1-cyp79-48h-Ag-4_1-B__2_01_9825.mzML
#> 9   FILES/mzML/MSpos-Ex2-Col0-48h-Ag-1_1-A__2_01_9827.mzML
#> 10  FILES/mzML/MSpos-Ex2-Col0-48h-Ag-2_1-A__3_01_9829.mzML
#> 11  FILES/mzML/MSpos-Ex2-Col0-48h-Ag-3_1-A__4_01_9831.mzML
#> 12  FILES/mzML/MSpos-Ex2-Col0-48h-Ag-4_1-A__2_01_9833.mzML
#> 13 FILES/mzML/MSpos-Ex2-cyp79-48h-Ag-1_1-B__3_01_9828.mzML
#> 14 FILES/mzML/MSpos-Ex2-cyp79-48h-Ag-2_1-B__4_01_9830.mzML
#> 15 FILES/mzML/MSpos-Ex2-cyp79-48h-Ag-3_1-B__3_01_9832.mzML
#> 16 FILES/mzML/MSpos-Ex2-cyp79-48h-Ag-4_1-B__4_01_9834.mzML
#>                                    Derived Spectral Data File
#> 1   FILES/mzData/MSpos-Ex1-Col0-48h-Ag-1_1-A,1_01_9818.mzData
#> 2   FILES/mzData/MSpos-Ex1-Col0-48h-Ag-2_1-A,1_01_9820.mzData
#> 3   FILES/mzData/MSpos-Ex1-Col0-48h-Ag-3_1-A,1_01_9822.mzData
#> 4   FILES/mzData/MSpos-Ex1-Col0-48h-Ag-4_1-A,1_01_9824.mzData
#> 5  FILES/mzData/MSpos-Ex1-cyp79-48h-Ag-1_1-B,1_01_9819.mzData
#> 6  FILES/mzData/MSpos-Ex1-cyp79-48h-Ag-2_1-B,2_01_9821.mzData
#> 7  FILES/mzData/MSpos-Ex1-cyp79-48h-Ag-3_1-B,1_01_9823.mzData
#> 8  FILES/mzData/MSpos-Ex1-cyp79-48h-Ag-4_1-B,2_01_9825.mzData
#> 9   FILES/mzData/MSpos-Ex2-Col0-48h-Ag-1_1-A,2_01_9827.mzData
#> 10  FILES/mzData/MSpos-Ex2-Col0-48h-Ag-2_1-A,3_01_9829.mzData
#> 11  FILES/mzData/MSpos-Ex2-Col0-48h-Ag-3_1-A,4_01_9831.mzData
#> 12  FILES/mzData/MSpos-Ex2-Col0-48h-Ag-4_1-A,2_01_9833.mzData
#> 13 FILES/mzData/MSpos-Ex2-cyp79-48h-Ag-1_1-B,3_01_9828.mzData
#> 14 FILES/mzData/MSpos-Ex2-cyp79-48h-Ag-2_1-B,4_01_9830.mzData
#> 15 FILES/mzData/MSpos-Ex2-cyp79-48h-Ag-3_1-B,3_01_9832.mzData
#> 16 FILES/mzData/MSpos-Ex2-cyp79-48h-Ag-4_1-B,4_01_9834.mzData
#>                 Protocol REF         Data Transformation Name
#> 1  Metabolite identification  Ex1-Col0-48h-Ag-1_1-A,1_01_9818
#> 2  Metabolite identification  Ex1-Col0-48h-Ag-2_1-A,1_01_9820
#> 3  Metabolite identification  Ex1-Col0-48h-Ag-3_1-A,1_01_9822
#> 4  Metabolite identification  Ex1-Col0-48h-Ag-4_1-A,1_01_9824
#> 5  Metabolite identification Ex1-cyp79-48h-Ag-1_1-B,1_01_9819
#> 6  Metabolite identification Ex1-cyp79-48h-Ag-2_1-B,2_01_9821
#> 7  Metabolite identification Ex1-cyp79-48h-Ag-3_1-B,1_01_9823
#> 8  Metabolite identification Ex1-cyp79-48h-Ag-4_1-B,2_01_9825
#> 9  Metabolite identification  Ex2-Col0-48h-Ag-1_1-A,2_01_9827
#> 10 Metabolite identification  Ex2-Col0-48h-Ag-2_1-A,3_01_9829
#> 11 Metabolite identification  Ex2-Col0-48h-Ag-3_1-A,4_01_9831
#> 12 Metabolite identification  Ex2-Col0-48h-Ag-4_1-A,2_01_9833
#> 13 Metabolite identification Ex2-cyp79-48h-Ag-1_1-B,3_01_9828
#> 14 Metabolite identification Ex2-cyp79-48h-Ag-2_1-B,4_01_9830
#> 15 Metabolite identification Ex2-cyp79-48h-Ag-3_1-B,3_01_9832
#> 16 Metabolite identification Ex2-cyp79-48h-Ag-4_1-B,4_01_9834
#>                                    Metabolite Assignment File
#> 1  m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 2  m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 3  m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 4  m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 5  m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 6  m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 7  m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 8  m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 9  m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 10 m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 11 m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 12 m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 13 m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 14 m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 15 m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#> 16 m_MTBLS2_metabolite_profiling_mass_spectrometry_v2_maf.tsv
#>    Factor Value[genotype] Term Source REF Term Accession Number
#> 1                   Col-0              NA                    NA
#> 2                   Col-0              NA                    NA
#> 3                   Col-0              NA                    NA
#> 4                   Col-0              NA                    NA
#> 5                   cyp79              NA                    NA
#> 6                   cyp79              NA                    NA
#> 7                   cyp79              NA                    NA
#> 8                   cyp79              NA                    NA
#> 9                   Col-0              NA                    NA
#> 10                  Col-0              NA                    NA
#> 11                  Col-0              NA                    NA
#> 12                  Col-0              NA                    NA
#> 13                  cyp79              NA                    NA
#> 14                  cyp79              NA                    NA
#> 15                  cyp79              NA                    NA
#> 16                  cyp79              NA                    NA
#>    Factor Value[replicate] Term Source REF Term Accession Number
#> 1                     Exp1              NA                    NA
#> 2                     Exp1              NA                    NA
#> 3                     Exp1              NA                    NA
#> 4                     Exp1              NA                    NA
#> 5                     Exp1              NA                    NA
#> 6                     Exp1              NA                    NA
#> 7                     Exp1              NA                    NA
#> 8                     Exp1              NA                    NA
#> 9                     Exp2              NA                    NA
#> 10                    Exp2              NA                    NA
#> 11                    Exp2              NA                    NA
#> 12                    Exp2              NA                    NA
#> 13                    Exp2              NA                    NA
#> 14                    Exp2              NA                    NA
#> 15                    Exp2              NA                    NA
#> 16                    Exp2              NA                    NA

## Get the sample information for one data set
mtbls_sample_data("MTBLS2")
#>                    Source Name Characteristics[Organism] Term Source REF
#> 1  IPB Halle.Group-1.Subject-1      Arabidopsis thaliana       NCBITaxon
#> 2  IPB Halle.Group-1.Subject-2      Arabidopsis thaliana       NCBITaxon
#> 3  IPB Halle.Group-1.Subject-3      Arabidopsis thaliana       NCBITaxon
#> 4  IPB Halle.Group-1.Subject-4      Arabidopsis thaliana       NCBITaxon
#> 5  IPB Halle.Group-2.Subject-1      Arabidopsis thaliana       NCBITaxon
#> 6  IPB Halle.Group-2.Subject-2      Arabidopsis thaliana       NCBITaxon
#> 7  IPB Halle.Group-2.Subject-3      Arabidopsis thaliana       NCBITaxon
#> 8  IPB Halle.Group-2.Subject-4      Arabidopsis thaliana       NCBITaxon
#> 9  IPB Halle.Group-3.Subject-1      Arabidopsis thaliana       NCBITaxon
#> 10 IPB Halle.Group-3.Subject-2      Arabidopsis thaliana       NCBITaxon
#> 11 IPB Halle.Group-3.Subject-3      Arabidopsis thaliana       NCBITaxon
#> 12 IPB Halle.Group-3.Subject-4      Arabidopsis thaliana       NCBITaxon
#> 13 IPB Halle.Group-4.Subject-1      Arabidopsis thaliana       NCBITaxon
#> 14 IPB Halle.Group-4.Subject-2      Arabidopsis thaliana       NCBITaxon
#> 15 IPB Halle.Group-4.Subject-3      Arabidopsis thaliana       NCBITaxon
#> 16 IPB Halle.Group-4.Subject-4      Arabidopsis thaliana       NCBITaxon
#>                            Term Accession Number Characteristics[Organism part]
#> 1  http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#> 2  http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#> 3  http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#> 4  http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#> 5  http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#> 6  http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#> 7  http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#> 8  http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#> 9  http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#> 10 http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#> 11 http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#> 12 http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#> 13 http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#> 14 http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#> 15 http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#> 16 http://purl.obolibrary.org/obo/NCBITaxon_3702                   rosette leaf
#>    Term Source REF                      Term Accession Number
#> 1              BTO http://purl.obolibrary.org/obo/BTO_0003086
#> 2              BTO http://purl.obolibrary.org/obo/BTO_0003086
#> 3              BTO http://purl.obolibrary.org/obo/BTO_0003086
#> 4              BTO http://purl.obolibrary.org/obo/BTO_0003086
#> 5              BTO http://purl.obolibrary.org/obo/BTO_0003086
#> 6              BTO http://purl.obolibrary.org/obo/BTO_0003086
#> 7              BTO http://purl.obolibrary.org/obo/BTO_0003086
#> 8              BTO http://purl.obolibrary.org/obo/BTO_0003086
#> 9              BTO http://purl.obolibrary.org/obo/BTO_0003086
#> 10             BTO http://purl.obolibrary.org/obo/BTO_0003086
#> 11             BTO http://purl.obolibrary.org/obo/BTO_0003086
#> 12             BTO http://purl.obolibrary.org/obo/BTO_0003086
#> 13             BTO http://purl.obolibrary.org/obo/BTO_0003086
#> 14             BTO http://purl.obolibrary.org/obo/BTO_0003086
#> 15             BTO http://purl.obolibrary.org/obo/BTO_0003086
#> 16             BTO http://purl.obolibrary.org/obo/BTO_0003086
#>    Characteristics[Variant] Term Source REF Term Accession Number
#> 1                        NA              NA                    NA
#> 2                        NA              NA                    NA
#> 3                        NA              NA                    NA
#> 4                        NA              NA                    NA
#> 5                        NA              NA                    NA
#> 6                        NA              NA                    NA
#> 7                        NA              NA                    NA
#> 8                        NA              NA                    NA
#> 9                        NA              NA                    NA
#> 10                       NA              NA                    NA
#> 11                       NA              NA                    NA
#> 12                       NA              NA                    NA
#> 13                       NA              NA                    NA
#> 14                       NA              NA                    NA
#> 15                       NA              NA                    NA
#> 16                       NA              NA                    NA
#>    Characteristics[Sample type] Term Source REF
#> 1           experimental sample            CHMO
#> 2           experimental sample            CHMO
#> 3           experimental sample            CHMO
#> 4           experimental sample            CHMO
#> 5           experimental sample            CHMO
#> 6           experimental sample            CHMO
#> 7           experimental sample            CHMO
#> 8           experimental sample            CHMO
#> 9           experimental sample            CHMO
#> 10          experimental sample            CHMO
#> 11          experimental sample            CHMO
#> 12          experimental sample            CHMO
#> 13          experimental sample            CHMO
#> 14          experimental sample            CHMO
#> 15          experimental sample            CHMO
#> 16          experimental sample            CHMO
#>                          Term Accession Number      Protocol REF
#> 1  http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#> 2  http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#> 3  http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#> 4  http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#> 5  http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#> 6  http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#> 7  http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#> 8  http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#> 9  http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#> 10 http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#> 11 http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#> 12 http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#> 13 http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#> 14 http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#> 15 http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#> 16 http://purl.obolibrary.org/obo/CHMO_0002746 Sample collection
#>           Sample Name Factor Value[Genotype] Term Source REF
#> 1   Ex1-Col0-48h-Ag-1                  Col-0              NA
#> 2   Ex1-Col0-48h-Ag-2                  Col-0              NA
#> 3   Ex1-Col0-48h-Ag-3                  Col-0              NA
#> 4   Ex1-Col0-48h-Ag-4                  Col-0              NA
#> 5  Ex1-cyp79-48h-Ag-1                  cyp79              NA
#> 6  Ex1-cyp79-48h-Ag-2                  cyp79              NA
#> 7  Ex1-cyp79-48h-Ag-3                  cyp79              NA
#> 8  Ex1-cyp79-48h-Ag-4                  cyp79              NA
#> 9   Ex2-Col0-48h-Ag-1                  Col-0              NA
#> 10  Ex2-Col0-48h-Ag-2                  Col-0              NA
#> 11  Ex2-Col0-48h-Ag-3                  Col-0              NA
#> 12  Ex2-Col0-48h-Ag-4                  Col-0              NA
#> 13 Ex2-cyp79-48h-Ag-1                  cyp79              NA
#> 14 Ex2-cyp79-48h-Ag-2                  cyp79              NA
#> 15 Ex2-cyp79-48h-Ag-3                  cyp79              NA
#> 16 Ex2-cyp79-48h-Ag-4                  cyp79              NA
#>    Term Accession Number Factor Value[Replicate] Term Source REF
#> 1                     NA                    Exp1              NA
#> 2                     NA                    Exp1              NA
#> 3                     NA                    Exp1              NA
#> 4                     NA                    Exp1              NA
#> 5                     NA                    Exp1              NA
#> 6                     NA                    Exp1              NA
#> 7                     NA                    Exp1              NA
#> 8                     NA                    Exp1              NA
#> 9                     NA                    Exp2              NA
#> 10                    NA                    Exp2              NA
#> 11                    NA                    Exp2              NA
#> 12                    NA                    Exp2              NA
#> 13                    NA                    Exp2              NA
#> 14                    NA                    Exp2              NA
#> 15                    NA                    Exp2              NA
#> 16                    NA                    Exp2              NA
#>    Term Accession Number
#> 1                     NA
#> 2                     NA
#> 3                     NA
#> 4                     NA
#> 5                     NA
#> 6                     NA
#> 7                     NA
#> 8                     NA
#> 9                     NA
#> 10                    NA
#> 11                    NA
#> 12                    NA
#> 13                    NA
#> 14                    NA
#> 15                    NA
#> 16                    NA

## List all available files
mtbls_cached_data_files()
#>      rid mtbls_id
#> 26 BFC33  MTBLS39
#> 27 BFC34  MTBLS39
#> 28 BFC36  MTBLS39
#>                                                                                            mtbls_assay_name
#> 26 a_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry.txt
#> 27 a_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry.txt
#> 28 a_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry.txt
#>    derived_spectral_data_file                                          rpath
#> 26           FILES/MN063A.cdf /github/home/.cache/R/BiocFileCache/MN063A.cdf
#> 27           FILES/CS063A.cdf /github/home/.cache/R/BiocFileCache/CS063A.cdf
#> 28           FILES/AM063A.cdf /github/home/.cache/R/BiocFileCache/AM063A.cdf
```
