#' MetaboLights ID: MTBLS8735
#' ftp://ftp.ebi.ac.uk/pub/databases/metabolights/studies/public/MTBLS8735

library(testthat)
library(MsBackendMetaboLights)

test_check("MsBackendMetaboLights")

## Run tests with the unit test suite defined in the Spectra package to ensure
## compliance with the definitions of the MsBackend interface/class.
be <- backendInitialize(MsBackendMetaboLights(), mtblsId = "MTBLS39",
                        filePattern = "63A.cdf", offline = TRUE)
library(Spectra)
test_suite <- system.file("test_backends", "test_MsBackend",
                          package = "Spectra")
res <- test_dir(test_suite, stop_on_failure = TRUE)
