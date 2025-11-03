# Retrieve Mass Spectrometry Data from MetaboLights

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check-bioc](https://github.com/RforMassSpectrometry/MsBackendMetaboLights/workflows/R-CMD-check-bioc/badge.svg)](https://github.com/RforMassSpectrometry/MsBackendMetaboLights/actions?query=workflow%3AR-CMD-check-bioc)
[![codecov](https://codecov.io/gh/rformassspectrometry/MsBackendMetaboLights/graph/badge.svg?token=jpxt7OlA2k)](https://codecov.io/gh/rformassspectrometry/MsBackendMetaboLights)
[![:name status
badge](https://rformassspectrometry.r-universe.dev/badges/:name)](https://rformassspectrometry.r-universe.dev/)
[![license](https://img.shields.io/badge/license-Artistic--2.0-brightgreen.svg)](https://opensource.org/licenses/Artistic-2.0)

This repository provides a *backend* for
[Spectra](https://github.com/RforMassSpectrometry/Spectra) objects that
represents and retrieves mass spectrometry (MS) data directly from
metabolomics experiments deposited at the public
[MetaboLights](https://www.ebi.ac.uk/metabolights/) repository. Mass
spectrometry data files of an experiment are downloaded and cached
locally using the
[BiocFileCache](https://bioconductor.org/packages/BiocFileCache)
package.

# Installation

The package can be installed with

``` r

install.packages("BiocManager")
BiocManager::install("RforMassSpectrometry/MsBackendMetaboLights")
```

# Contributions

Contributions are highly welcome and should follow the [contribution
guidelines](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html#contributions).
Also, please check the coding style guidelines in the
[RforMassSpectrometry
vignette](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html).
