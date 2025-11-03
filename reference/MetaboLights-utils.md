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

- `mtbls_cached_data_files()`: lists locally cached data files from
  MetaboLights. Since this function evaluates only local content it does
  not require an internet connection. With the default parameters all
  available data files are listed. The parameters can be used to
  restrict the lookup.

- `mtbls_list_files()`: returns the available files (and directories)
  for the specified MetaboLights data set (i.e., the FTP directory
  content of the data set). The function returns a `character` vector
  with the relative file names to the absolute FTP path
  (`mtbls_ftp_path()`) of the data set. Parameter `pattern` allows to
  filter the file names and define which file names should be returned.

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

## Read the content of one file
a <- read.table(paste0(mtbls_ftp_path("MTBLS2"), afiles[1L]),
    header = TRUE, sep = "\t", check.names = FALSE)
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

## List all available files
mtbls_cached_data_files()
#>      rid mtbls_id
#> 26 BFC43  MTBLS39
#> 27 BFC44  MTBLS39
#> 28 BFC47  MTBLS39
#>                                                                                            mtbls_assay_name
#> 26 a_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry.txt
#> 27 a_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry.txt
#> 28 a_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry.txt
#>    derived_spectral_data_file                                          rpath
#> 26           FILES/MN063A.cdf /github/home/.cache/R/BiocFileCache/MN063A.cdf
#> 27           FILES/CS063A.cdf /github/home/.cache/R/BiocFileCache/CS063A.cdf
#> 28           FILES/AM063A.cdf /github/home/.cache/R/BiocFileCache/AM063A.cdf
```
