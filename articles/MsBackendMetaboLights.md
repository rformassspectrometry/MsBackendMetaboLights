# Retrieve and Use Mass Spectrometry Data from MetaboLights

**Package**:
*[MsBackendMetaboLights](https://bioconductor.org/packages/3.24/MsBackendMetaboLights)*\
**Authors**: Johannes Rainer \[aut, cre\] (ORCID:
<https://orcid.org/0000-0002-6977-7147>), Philippine Louail \[aut\]
(ORCID: <https://orcid.org/0009-0007-5429-6846>), Gabriele Tomè \[aut\]
(ORCID: <https://orcid.org/0000-0002-3976-6068>, fnd:
MetaRbolomics4Galaxy project (CUP: D53C25001030003) co-funded by the
Autonomous Province of Bolzano under the Joint Projects South
Tyrol–Germany 2025 program.)\
**Last modified:** 2026-05-22 12:29:38.968994\
**Compiled**: Fri May 22 12:49:47 2026

## Introduction

The *[Spectra](https://bioconductor.org/packages/3.24/Spectra)* package
provides a central infrastructure for the handling of Mass Spectrometry
(MS) data in Bioconductor. The package supports interchangeable use of
different *backends* to import and represent MS data from a variety of
sources and data formats. The *MsBackendMetaboLights* package allows to
retrieve MS data files directly from the
[MetaboLights](https://www.ebi.ac.uk/metabolights/) repository.
MetaboLights is one of the main public repositories for deposition of
metabolomics experiments including (raw) MS and/or NMR data files and
the related experimental and analytical results. The
*MsBackendMetaboLights* package downloads and locally caches MS data
files for a MetaboLights data set and enables further analyses of this
data directly in R.

## Installation

The package can be installed from within R with the commands below:

``` r

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("RforMassSpectrometry/MsBackendMetaboLights")
```

## Importing MS Data from MetaboLights

[MetaboLights](https://www.ebi.ac.uk/metabolights/) is one of the main
public repositories for deposition of metabolomics experiments including
(raw) mass spectrometry (MS) and NMR data files and
experimental/analysis results. The experimental metadata and results are
stored as plain text files in ISA-tab format. Each MetaboLights
experiment must provide a file describing the samples analyzed and at
least one *assay* file that links between the experimental samples and
the (raw and processed) data files with quantification of
metabolites/features in these samples.

In this vignette we explore and load MS data files from a small
MetaboLights experiment. MetaboLights provides information on a data
set/experiment as a set of plain text files in *ISA-tab* format. These
can be accessed and read from the data set’s ftp folder. The set of
files consist generally of a file with information on the
experiment/investigation (in a file with the file name starting with
*i\_*) the samples of the data set (file name starting with *s\_*), the
*assay* (measurements/analysis) of the experiment and a file with
quantified metabolite abundances (file name starting with *m\_*). Note
that a data set can have more than one assay file.

Below we list all files from the MetaboLights data set with the ID
*MTBLS39*.

``` r

library(MsBackendMetaboLights)

#' List files of a MetaboLights data set
all_files <- mtbls_list_files("MTBLS39")
```

All these files are directly accessible in the ftp folder associated
with the MetaboLights data set. Below we use the
[`mtbls_ftp_path()`](https://rformassspectrometry.github.io/MsBackendMetaboLights/reference/MetaboLights-utils.md)
function to return the ftp path for our test data set.

``` r

mtbls_ftp_path("MTBLS39")
```

    ## [1] "ftp://ftp.ebi.ac.uk/pub/databases/metabolights/studies/public/MTBLS39/"

We could inspect the content of this folder also using a browser
supporting the ftp file transfer protocol and download individual files
manually. We can however access the files also directly from within R.
Below we read the *assay* data file directly using the base R
[`read.table()`](https://rdrr.io/r/utils/read.table.html) function. Note
that connections to the MetaboLights FTP server are rate-limited and
might thus fail. We use below the `retry()` function from the
*[MsCoreUtils](https://bioconductor.org/packages/3.24/MsCoreUtils)*
package to retry reading from the FTP server if the connection fails or
gets closed before the data is fully read.

``` r

#' Get the assay files of the data set
grep("^a_", all_files, value = TRUE)
```

    ## [1] "a_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry.txt"

``` r

#' Read the assay file
a <- MsCoreUtils::retry(
    read.table(paste0(mtbls_ftp_path("MTBLS39"),
                      grep("^a_", all_files, value = TRUE)),
               sep = "\t", header = TRUE, check.names = FALSE),
    ntimes = 5, sleep_mult = 7)
```

Each row in this assay table refers to one measurement (data file) of
the data set, with columns providing information on that measurement.
The number and content of columns can vary between data sets and depends
on the information the original researcher (manually) provided. Below we
list the columns available in the assay file of our test data set.

``` r

colnames(a)
```

    ##  [1] "Sample Name"                               
    ##  [2] "Protocol REF"                              
    ##  [3] "Parameter Value[Post Extraction]"          
    ##  [4] "Parameter Value[Derivatization]"           
    ##  [5] "Extract Name"                              
    ##  [6] "Protocol REF"                              
    ##  [7] "Parameter Value[Chromatography Instrument]"
    ##  [8] "Term Source REF"                           
    ##  [9] "Term Accession Number"                     
    ## [10] "Parameter Value[Autosampler model]"        
    ## [11] "Term Source REF"                           
    ## [12] "Term Accession Number"                     
    ## [13] "Parameter Value[Column model]"             
    ## [14] "Parameter Value[Column type]"              
    ## [15] "Parameter Value[Guard column]"             
    ## [16] "Term Source REF"                           
    ## [17] "Term Accession Number"                     
    ## [18] "Labeled Extract Name"                      
    ## [19] "Label"                                     
    ## [20] "Term Source REF"                           
    ## [21] "Term Accession Number"                     
    ## [22] "Protocol REF"                              
    ## [23] "Parameter Value[Scan polarity]"            
    ## [24] "Parameter Value[Scan m/z range]"           
    ## [25] "Parameter Value[Instrument]"               
    ## [26] "Term Source REF"                           
    ## [27] "Term Accession Number"                     
    ## [28] "Parameter Value[Ion source]"               
    ## [29] "Term Source REF"                           
    ## [30] "Term Accession Number"                     
    ## [31] "Parameter Value[Mass analyzer]"            
    ## [32] "Term Source REF"                           
    ## [33] "Term Accession Number"                     
    ## [34] "MS Assay Name"                             
    ## [35] "Raw Spectral Data File"                    
    ## [36] "Protocol REF"                              
    ## [37] "Normalization Name"                        
    ## [38] "Derived Spectral Data File"                
    ## [39] "Protocol REF"                              
    ## [40] "Data Transformation Name"                  
    ## [41] "Metabolite Assignment File"

MS data files are generally provided in a column named
`"Derived Spectral Data File"` but sometimes they are also listed in a
column named `"Raw Spectral Data File"`. Note that providing MS data
files is not absolutely mandatory, thus, for some data sets no MS data
files might be available. Below we list the content of these data
columns.

``` r

a[, c("Raw Spectral Data File", "Derived Spectral Data File")]
```

    ##    Raw Spectral Data File Derived Spectral Data File
    ## 1        FILES/MN063A.cdf                         NA
    ## 2        FILES/MN063B.cdf                         NA
    ## 3        FILES/MN063C.cdf                         NA
    ## 4        FILES/CS063A.cdf                         NA
    ## 5        FILES/CS063B.cdf                         NA
    ## 6        FILES/CS063C.cdf                         NA
    ## 7        FILES/AM063A.cdf                         NA
    ## 8        FILES/AM063B.cdf                         NA
    ## 9        FILES/AM063C.cdf                         NA
    ## 10       FILES/MN073A.cdf                         NA
    ## 11       FILES/MN073B.cdf                         NA
    ## 12       FILES/MN073C.cdf                         NA
    ## 13       FILES/CS073A.cdf                         NA
    ## 14       FILES/CS073B.cdf                         NA
    ## 15       FILES/CS073C.cdf                         NA
    ## 16       FILES/AM073A.cdf                         NA
    ## 17       FILES/AM073B.cdf                         NA
    ## 18       FILES/AM073C.cdf                         NA
    ## 19       FILES/MN083A.cdf                         NA
    ## 20       FILES/MN083B.cdf                         NA
    ## 21       FILES/MN083C.cdf                         NA
    ## 22       FILES/CS083A.cdf                         NA
    ## 23       FILES/CS083B.cdf                         NA
    ## 24       FILES/CS083C.cdf                         NA
    ## 25       FILES/AM083A.cdf                         NA
    ## 26       FILES/AM083B.cdf                         NA
    ## 27       FILES/AM083C.cdf                         NA

For this particular data set the MS data files are provided in the
`"Raw Spectral Data File"` column. These files are in CDF format and can
hence be loaded using the `MsBackendMetaboLights` backend into R as a
`Spectra` object (`MsBackendMetaboLights` directly extends *Spectra*’s
`MsBackendMzR` backend and therefore supports import of MS data files in
*mzML*, *CDF* or *mzXML* formats). By default, all MS data files of all
assays would be retrieved, but in our example below we restrict to few
data files to reduce the amount of data that needs to be downloaded. To
this end we define a pattern matching the file name of only some data
files using the `filePattern` parameter. Alternatively, for data sets
with more than one assay, it would also be possible to select MS data
files from one particular assay only using the `assayName` parameter. In
our case we load all MS data files that end with *63A.cdf*.

``` r

library(Spectra)

#' Load MS data files of one data set
s <- Spectra("MTBLS39", filePattern = "63A.cdf",
             source = MsBackendMetaboLights())
```

    ## Used data files from the assay's column "Raw Spectral Data File" since none were available in column "Derived Spectral Data File".

``` r

s
```

    ## MSn data (Spectra) with 1664 spectra in a MsBackendMetaboLights backend:
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1  0.296384         1
    ## 2            1  6.206912         2
    ## 3            1 12.093056         3
    ## 4            1 17.942912         4
    ## 5            1 23.835072         5
    ## ...        ...       ...       ...
    ## 1660         1   2678.27       549
    ## 1661         1   2683.01       550
    ## 1662         1   2687.81       551
    ## 1663         1   2692.62       552
    ## 1664         1   2697.40       553
    ##  ... 37 more variables/columns.
    ## 
    ## file(s):
    ## MN063A.cdf
    ## CS063A.cdf
    ## AM063A.cdf

This call now downloaded the files to the local cache and loaded these
files as a `Spectra` object. The downloading and caching of the data is
handled by Bioconductor’s
*[BiocFileCache](https://bioconductor.org/packages/3.24/BiocFileCache)*.
The local cache can thus be managed directly using functionality from
that package. Any subsequent loading of the same data files will load
the locally cached versions avoiding thus repetitive download of the
same data.

The message that is shown by the call above indicates that the MS data
files were not provided in the expected column
(`"Derived Spectral Data File"`) but in the column for raw data files.

The `Spectra` object with the MS data files of the MetaboLights data set
enables now any subsequent analysis of the data in R. On top of the
spectra variables and mass peak data values that are provided by the MS
data files also additional information related to the MetaboLights data
set are available as specific *spectra variables*. We list all available
spectra variables of the data set below.

``` r

spectraVariables(s)
```

    ##  [1] "msLevel"                    "rtime"                     
    ##  [3] "acquisitionNum"             "scanIndex"                 
    ##  [5] "dataStorage"                "dataOrigin"                
    ##  [7] "centroided"                 "smoothed"                  
    ##  [9] "polarity"                   "precScanNum"               
    ## [11] "precursorMz"                "precursorIntensity"        
    ## [13] "precursorCharge"            "collisionEnergy"           
    ## [15] "isolationWindowLowerMz"     "isolationWindowTargetMz"   
    ## [17] "isolationWindowUpperMz"     "peaksCount"                
    ## [19] "totIonCurrent"              "basePeakMZ"                
    ## [21] "basePeakIntensity"          "electronBeamEnergy"        
    ## [23] "ionisationEnergy"           "lowMZ"                     
    ## [25] "highMZ"                     "mergedScan"                
    ## [27] "mergedResultScanNum"        "mergedResultStartScanNum"  
    ## [29] "mergedResultEndScanNum"     "injectionTime"             
    ## [31] "filterString"               "spectrumId"                
    ## [33] "ionMobilityDriftTime"       "scanWindowLowerLimit"      
    ## [35] "scanWindowUpperLimit"       "mtbls_id"                  
    ## [37] "mtbls_assay_name"           "derived_spectral_data_file"

The MetaboLights-specific variables are `"mtbls_id"`,
`"mtbls_assay_name"` and `"derived_spectral_data_file"` providing the
MetaboLights ID of the data set, the assay/method with which the data
files were generated and the original file path/name of the data files
on the MetaboLights ftp server.

``` r

spectraData(s, c("mtbls_id", "mtbls_assay_name",
                 "derived_spectral_data_file"))
```

    ## DataFrame with 1664 rows and 3 columns
    ##         mtbls_id       mtbls_assay_name derived_spectral_data_file
    ##      <character>            <character>                <character>
    ## 1        MTBLS39 a_MTBLS39_the_plasti..           FILES/MN063A.cdf
    ## 2        MTBLS39 a_MTBLS39_the_plasti..           FILES/MN063A.cdf
    ## 3        MTBLS39 a_MTBLS39_the_plasti..           FILES/MN063A.cdf
    ## 4        MTBLS39 a_MTBLS39_the_plasti..           FILES/MN063A.cdf
    ## 5        MTBLS39 a_MTBLS39_the_plasti..           FILES/MN063A.cdf
    ## ...          ...                    ...                        ...
    ## 1660     MTBLS39 a_MTBLS39_the_plasti..           FILES/AM063A.cdf
    ## 1661     MTBLS39 a_MTBLS39_the_plasti..           FILES/AM063A.cdf
    ## 1662     MTBLS39 a_MTBLS39_the_plasti..           FILES/AM063A.cdf
    ## 1663     MTBLS39 a_MTBLS39_the_plasti..           FILES/AM063A.cdf
    ## 1664     MTBLS39 a_MTBLS39_the_plasti..           FILES/AM063A.cdf

These variables can be used to link the individual spectra back to the
original sample (e.g. through the *assay* and *sample* tables of the
MetaboLights data set.

The
[`mtbls_sync()`](https://rformassspectrometry.github.io/MsBackendMetaboLights/reference/MsBackendMetaboLights.md)
function can be used to *synchronize* the local content of a
`MsBackendMetaboLights`. This function checks if all data files of the
backend are available locally and eventually downloads and caches
missing files.

``` r

mtbls_sync(s@backend)
```

    ## Used data files from the assay's column "Raw Spectral Data File" since none were available in column "Derived Spectral Data File".

    ## MsBackendMetaboLights with 1664 spectra
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1  0.296384         1
    ## 2            1  6.206912         2
    ## 3            1 12.093056         3
    ## 4            1 17.942912         4
    ## 5            1 23.835072         5
    ## ...        ...       ...       ...
    ## 1660         1   2678.27       549
    ## 1661         1   2683.01       550
    ## 1662         1   2687.81       551
    ## 1663         1   2692.62       552
    ## 1664         1   2697.40       553
    ##  ... 37 more variables/columns.
    ## 
    ## file(s):
    ## MN063A.cdf
    ## CS063A.cdf
    ## AM063A.cdf

Also, it is possible to *manually* cache and download data files from
MetaboLights using the
[`mtbls_sync_data_files()`](https://rformassspectrometry.github.io/MsBackendMetaboLights/reference/MetaboLights-utils.md)
function. This function evaluates if the respective data files are
already cached and, if so, does not download them again. Below we use
this retrieve the local storage information on one of the data files of
the MetaboLights data set *MTBLS39*:

``` r

res <- mtbls_sync_data_files("MTBLS39", fileName = "AM063A.cdf")
```

    ## Used data files from the assay's column "Raw Spectral Data File" since none were available in column "Derived Spectral Data File".

``` r

res
```

    ##     rid mtbls_id
    ## 1 BFC36  MTBLS39
    ##                                                                                           mtbls_assay_name
    ## 1 a_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry.txt
    ##   derived_spectral_data_file                                          rpath
    ## 1           FILES/AM063A.cdf /github/home/.cache/R/BiocFileCache/AM063A.cdf

The
[`mtbls_cached_data_files()`](https://rformassspectrometry.github.io/MsBackendMetaboLights/reference/MetaboLights-utils.md)
function can be used to inspect and list locally cached MetaboLights
data files. This function does not require an active internet connection
since only local content is queried. With the default settings, a
`data.frame` with all available data files is returned.

``` r

mtbls_cached_data_files()
```

    ##      rid mtbls_id
    ## 28 BFC36  MTBLS39
    ##                                                                                            mtbls_assay_name
    ## 28 a_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry.txt
    ##    derived_spectral_data_file                                          rpath
    ## 28           FILES/AM063A.cdf /github/home/.cache/R/BiocFileCache/AM063A.cdf

Locally cached files for a MetaboLights data set can be removed using
the
[`mtbls_delete_cache()`](https://rformassspectrometry.github.io/MsBackendMetaboLights/reference/MetaboLights-utils.md)
function providing the ID of the MetaboLights data set for which local
data files should be removed.

## General information for a MetaboLights data set

Next to the code to cache and download MS data files,
*MsBackendMetaboLights* provides also utility functions to retrieve
general data and information for a data set from the MetaboLights
repository. These functions are listed on the `?Metabolites-utils` help
page. The
[`mtbls_list_files()`](https://rformassspectrometry.github.io/MsBackendMetaboLights/reference/MetaboLights-utils.md)
for example allows to list all available files in the data set’s base
FTP folder.

``` r

mtbls_list_files("MTBLS39")
```

    ## [1] "FILES"                                                                                                          
    ## [2] "HASHES"                                                                                                         
    ## [3] "METADATA_REVISIONS"                                                                                             
    ## [4] "a_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry.txt"       
    ## [5] "i_Investigation.txt"                                                                                            
    ## [6] "m_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry_v2_maf.tsv"
    ## [7] "s_MTBLS39.txt"

The
[`mtbls_assay_data()`](https://rformassspectrometry.github.io/MsBackendMetaboLights/reference/MetaboLights-utils.md)
retrieves information on the, or one of the possibly multiple, used
assay(s).

``` r

adat <- mtbls_assay_data("MTBLS39")
head(adat)
```

    ##   Sample Name Protocol REF Parameter Value[Post Extraction]
    ## 1      MN063A   Extraction             methanol/formic acid
    ## 2      MN063B   Extraction             methanol/formic acid
    ## 3      MN063C   Extraction             methanol/formic acid
    ## 4      CS063A   Extraction             methanol/formic acid
    ## 5      CS063B   Extraction             methanol/formic acid
    ## 6      CS063C   Extraction             methanol/formic acid
    ##   Parameter Value[Derivatization] Extract Name   Protocol REF
    ## 1                              NA       MN063A Chromatography
    ## 2                              NA       MN063B Chromatography
    ## 3                              NA       MN063C Chromatography
    ## 4                              NA       CS063A Chromatography
    ## 5                              NA       CS063B Chromatography
    ## 6                              NA       CS063C Chromatography
    ##   Parameter Value[Chromatography Instrument] Term Source REF
    ## 1  Beckman Coulter System Gold HPLC 127 pump              NA
    ## 2  Beckman Coulter System Gold HPLC 127 pump              NA
    ## 3  Beckman Coulter System Gold HPLC 127 pump              NA
    ## 4  Beckman Coulter System Gold HPLC 127 pump              NA
    ## 5  Beckman Coulter System Gold HPLC 127 pump              NA
    ## 6  Beckman Coulter System Gold HPLC 127 pump              NA
    ##   Term Accession Number Parameter Value[Autosampler model] Term Source REF
    ## 1                    NA   System Gold HPLC 508 autosampler              NA
    ## 2                    NA   System Gold HPLC 508 autosampler              NA
    ## 3                    NA   System Gold HPLC 508 autosampler              NA
    ## 4                    NA   System Gold HPLC 508 autosampler              NA
    ## 5                    NA   System Gold HPLC 508 autosampler              NA
    ## 6                    NA   System Gold HPLC 508 autosampler              NA
    ##   Term Accession Number                   Parameter Value[Column model]
    ## 1                    NA Alltima HP C18 (3 μm, 2.1 mm x 150 mm; Alltech)
    ## 2                    NA Alltima HP C18 (3 μm, 2.1 mm x 150 mm; Alltech)
    ## 3                    NA Alltima HP C18 (3 μm, 2.1 mm x 150 mm; Alltech)
    ## 4                    NA Alltima HP C18 (3 μm, 2.1 mm x 150 mm; Alltech)
    ## 5                    NA Alltima HP C18 (3 μm, 2.1 mm x 150 mm; Alltech)
    ## 6                    NA Alltima HP C18 (3 μm, 2.1 mm x 150 mm; Alltech)
    ##   Parameter Value[Column type]                Parameter Value[Guard column]
    ## 1                reverse phase Alltima HP-Guard C18 (2.1 x 7.5 mm; Alltech)
    ## 2                reverse phase Alltima HP-Guard C18 (2.1 x 7.5 mm; Alltech)
    ## 3                reverse phase Alltima HP-Guard C18 (2.1 x 7.5 mm; Alltech)
    ## 4                reverse phase Alltima HP-Guard C18 (2.1 x 7.5 mm; Alltech)
    ## 5                reverse phase Alltima HP-Guard C18 (2.1 x 7.5 mm; Alltech)
    ## 6                reverse phase Alltima HP-Guard C18 (2.1 x 7.5 mm; Alltech)
    ##   Term Source REF Term Accession Number Labeled Extract Name Label
    ## 1              NA                    NA                   NA    NA
    ## 2              NA                    NA                   NA    NA
    ## 3              NA                    NA                   NA    NA
    ## 4              NA                    NA                   NA    NA
    ## 5              NA                    NA                   NA    NA
    ## 6              NA                    NA                   NA    NA
    ##   Term Source REF Term Accession Number      Protocol REF
    ## 1              NA                    NA Mass spectrometry
    ## 2              NA                    NA Mass spectrometry
    ## 3              NA                    NA Mass spectrometry
    ## 4              NA                    NA Mass spectrometry
    ## 5              NA                    NA Mass spectrometry
    ## 6              NA                    NA Mass spectrometry
    ##   Parameter Value[Scan polarity] Parameter Value[Scan m/z range]
    ## 1                    alternating                         50–1500
    ## 2                    alternating                         50–1500
    ## 3                    alternating                         50–1500
    ## 4                    alternating                         50–1500
    ## 5                    alternating                         50–1500
    ## 6                    alternating                         50–1500
    ##   Parameter Value[Instrument] Term Source REF Term Accession Number
    ## 1         Bruker Esquire 6000              NA                    NA
    ## 2         Bruker Esquire 6000              NA                    NA
    ## 3         Bruker Esquire 6000              NA                    NA
    ## 4         Bruker Esquire 6000              NA                    NA
    ## 5         Bruker Esquire 6000              NA                    NA
    ## 6         Bruker Esquire 6000              NA                    NA
    ##   Parameter Value[Ion source] Term Source REF Term Accession Number
    ## 1     electrospray ionization              MS                    NA
    ## 2     electrospray ionization              MS                    NA
    ## 3     electrospray ionization              MS                    NA
    ## 4     electrospray ionization              MS                    NA
    ## 5     electrospray ionization              MS                    NA
    ## 6     electrospray ionization              MS                    NA
    ##   Parameter Value[Mass analyzer] Term Source REF
    ## 1            quadrupole ion trap              MS
    ## 2            quadrupole ion trap              MS
    ## 3            quadrupole ion trap              MS
    ## 4            quadrupole ion trap              MS
    ## 5            quadrupole ion trap              MS
    ## 6            quadrupole ion trap              MS
    ##                       Term Accession Number MS Assay Name
    ## 1 http://purl.obolibrary.org/obo/MS_1000082        MN063A
    ## 2 http://purl.obolibrary.org/obo/MS_1000082        MN063B
    ## 3 http://purl.obolibrary.org/obo/MS_1000082        MN063C
    ## 4 http://purl.obolibrary.org/obo/MS_1000082        CS063A
    ## 5 http://purl.obolibrary.org/obo/MS_1000082        CS063B
    ## 6 http://purl.obolibrary.org/obo/MS_1000082        CS063C
    ##   Raw Spectral Data File        Protocol REF Normalization Name
    ## 1       FILES/MN063A.cdf Data transformation             MN063A
    ## 2       FILES/MN063B.cdf Data transformation             MN063B
    ## 3       FILES/MN063C.cdf Data transformation             MN063C
    ## 4       FILES/CS063A.cdf Data transformation             CS063A
    ## 5       FILES/CS063B.cdf Data transformation             CS063B
    ## 6       FILES/CS063C.cdf Data transformation             CS063C
    ##   Derived Spectral Data File              Protocol REF Data Transformation Name
    ## 1                         NA Metabolite identification                   MN063A
    ## 2                         NA Metabolite identification                   MN063B
    ## 3                         NA Metabolite identification                   MN063C
    ## 4                         NA Metabolite identification                   CS063A
    ## 5                         NA Metabolite identification                   CS063B
    ## 6                         NA Metabolite identification                   CS063C
    ##                                                                                        Metabolite Assignment File
    ## 1 m_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry_v2_maf.tsv
    ## 2 m_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry_v2_maf.tsv
    ## 3 m_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry_v2_maf.tsv
    ## 4 m_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry_v2_maf.tsv
    ## 5 m_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry_v2_maf.tsv
    ## 6 m_MTBLS39_the_plasticity_of_the_grapevine_berry_transcriptome_metabolite_profiling_mass_spectrometry_v2_maf.tsv

The
[`mtbls_sample_data()`](https://rformassspectrometry.github.io/MsBackendMetaboLights/reference/MetaboLights-utils.md)
retrieves the sample information for a data set.

``` r

sdat <- mtbls_sample_data("MTBLS39")
head(sdat)
```

    ##                            Source Name Characteristics[Organism]
    ## 1 Vineyard MN,Year 2006,Stage 3,Rep. A            Vitis vinifera
    ## 2 Vineyard MN,Year 2006,Stage 3,Rep. B            Vitis vinifera
    ## 3 Vineyard MN,Year 2006,Stage 3,Rep. C            Vitis vinifera
    ## 4 Vineyard CS,Year 2006,Stage 3,Rep. A            Vitis vinifera
    ## 5 Vineyard CS,Year 2006,Stage 3,Rep. B            Vitis vinifera
    ## 6 Vineyard CS,Year 2006,Stage 3,Rep. C            Vitis vinifera
    ##   Term Source REF                                Term Accession Number
    ## 1       NCBITAXON http://purl.bioontology.org/ontology/NCBITAXON/29760
    ## 2       NCBITAXON http://purl.bioontology.org/ontology/NCBITAXON/29760
    ## 3       NCBITAXON http://purl.bioontology.org/ontology/NCBITAXON/29760
    ## 4       NCBITAXON http://purl.bioontology.org/ontology/NCBITAXON/29760
    ## 5       NCBITAXON http://purl.bioontology.org/ontology/NCBITAXON/29760
    ## 6       NCBITAXON http://purl.bioontology.org/ontology/NCBITAXON/29760
    ##   Characteristics[Organism part] Term Source REF
    ## 1                          berry             BTO
    ## 2                          berry             BTO
    ## 3                          berry             BTO
    ## 4                          berry             BTO
    ## 5                          berry             BTO
    ## 6                          berry             BTO
    ##                        Term Accession Number Characteristics[Variant]
    ## 1 http://purl.obolibrary.org/obo/BTO_0000119                       NA
    ## 2 http://purl.obolibrary.org/obo/BTO_0000119                       NA
    ## 3 http://purl.obolibrary.org/obo/BTO_0000119                       NA
    ## 4 http://purl.obolibrary.org/obo/BTO_0000119                       NA
    ## 5 http://purl.obolibrary.org/obo/BTO_0000119                       NA
    ## 6 http://purl.obolibrary.org/obo/BTO_0000119                       NA
    ##   Term Source REF Term Accession Number Characteristics[Sample type]
    ## 1              NA                    NA                           NA
    ## 2              NA                    NA                           NA
    ## 3              NA                    NA                           NA
    ## 4              NA                    NA                           NA
    ## 5              NA                    NA                           NA
    ## 6              NA                    NA                           NA
    ##   Term Source REF Term Accession Number      Protocol REF Sample Name
    ## 1              NA                    NA Sample collection      MN063A
    ## 2              NA                    NA Sample collection      MN063B
    ## 3              NA                    NA Sample collection      MN063C
    ## 4              NA                    NA Sample collection      CS063A
    ## 5              NA                    NA Sample collection      CS063B
    ## 6              NA                    NA Sample collection      CS063C
    ##   Factor Value[Year of Harvesting] Term Source REF Term Accession Number
    ## 1                             2006              NA                    NA
    ## 2                             2006              NA                    NA
    ## 3                             2006              NA                    NA
    ## 4                             2006              NA                    NA
    ## 5                             2006              NA                    NA
    ## 6                             2006              NA                    NA
    ##   Factor Value[Vineyard] Term Source REF Term Accession Number
    ## 1            Vineyard MN              NA                    NA
    ## 2            Vineyard MN              NA                    NA
    ## 3            Vineyard MN              NA                    NA
    ## 4            Vineyard CS              NA                    NA
    ## 5            Vineyard CS              NA                    NA
    ## 6            Vineyard CS              NA                    NA
    ##   Factor Value[Replicate] Term Source REF Term Accession Number
    ## 1                       A              NA                    NA
    ## 2                       B              NA                    NA
    ## 3                       C              NA                    NA
    ## 4                       A              NA                    NA
    ## 5                       B              NA                    NA
    ## 6                       C              NA                    NA

And the
[`mtbls_metadata()`](https://rformassspectrometry.github.io/MsBackendMetaboLights/reference/MetaboLights-utils.md)
combines the sample and assay information into a single `data.frame`
from which individual sample information for the respective MS data
files could be extracted.

``` r

mdat <- mtbls_metadata("MTBLS39")
dim(mdat)
```

    ## [1] 27 65

## Session information

``` r

sessionInfo()
```

    ## R version 4.6.0 (2026-04-24)
    ## Platform: x86_64-pc-linux-gnu
    ## Running under: Ubuntu 24.04.4 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
    ##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
    ##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## time zone: UTC
    ## tzcode source: system (glibc)
    ## 
    ## attached base packages:
    ## [1] stats4    stats     graphics  grDevices utils     datasets  methods  
    ## [8] base     
    ## 
    ## other attached packages:
    ## [1] MsBackendMetaboLights_1.5.4 Spectra_1.23.0             
    ## [3] BiocParallel_1.47.0         S4Vectors_0.51.2           
    ## [5] BiocGenerics_0.59.2         generics_0.1.4             
    ## [7] BiocStyle_2.41.0           
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] xfun_0.57              bslib_0.11.0           httr2_1.2.2           
    ##  [4] htmlwidgets_1.6.4      Biobase_2.73.1         vctrs_0.7.3           
    ##  [7] tools_4.6.0            curl_7.1.0             parallel_4.6.0        
    ## [10] tibble_3.3.1           RSQLite_3.52.0         cluster_2.1.8.2       
    ## [13] blob_1.3.0             pkgconfig_2.0.3        data.table_1.18.4     
    ## [16] dbplyr_2.5.2           desc_1.4.3             lifecycle_1.0.5       
    ## [19] compiler_4.6.0         textshaping_1.0.5      progress_1.2.3        
    ## [22] codetools_0.2-20       ncdf4_1.24             clue_0.3-68           
    ## [25] htmltools_0.5.9        sass_0.4.10            yaml_2.3.12           
    ## [28] pkgdown_2.2.0.9000     pillar_1.11.1          crayon_1.5.3          
    ## [31] jquerylib_0.1.4        MASS_7.3-65            cachem_1.1.0          
    ## [34] MetaboCoreUtils_1.21.1 tidyselect_1.2.1       digest_0.6.39         
    ## [37] dplyr_1.2.1            purrr_1.2.2            bookdown_0.46         
    ## [40] fastmap_1.2.0          cli_3.6.6              magrittr_2.0.5        
    ## [43] withr_3.0.2            prettyunits_1.2.0      filelock_1.0.3        
    ## [46] rappdirs_0.3.4         bit64_4.8.2            rmarkdown_2.31        
    ## [49] bit_4.6.0              otel_0.2.0             ragg_1.5.2            
    ## [52] hms_1.1.4              memoise_2.0.1          evaluate_1.0.5        
    ## [55] knitr_1.51             IRanges_2.47.1         BiocFileCache_3.3.0   
    ## [58] rlang_1.2.0            Rcpp_1.1.1-1.1         glue_1.8.1            
    ## [61] DBI_1.3.0              mzR_2.47.0             BiocManager_1.30.27   
    ## [64] jsonlite_2.0.0         R6_2.6.1               systemfonts_1.3.2     
    ## [67] fs_2.1.0               ProtGenerics_1.45.0    MsCoreUtils_1.25.4
