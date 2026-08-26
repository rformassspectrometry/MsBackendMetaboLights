# Retrieve Mass Spectrometry Data from MetaboLights

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check-bioc](https://github.com/RforMassSpectrometry/MsBackendMetaboLights/workflows/R-CMD-check-bioc/badge.svg)](https://github.com/RforMassSpectrometry/MsBackendMetaboLights/actions?query=workflow%3AR-CMD-check-bioc)
[![codecov](https://codecov.io/gh/rformassspectrometry/MsBackendMetaboLights/graph/badge.svg?token=jpxt7OlA2k)](https://codecov.io/gh/rformassspectrometry/MsBackendMetaboLights)
[![:name status
badge](https://rformassspectrometry.r-universe.dev/badges/:name)](https://rformassspectrometry.r-universe.dev/)
[![years in
bioc](http://bioconductor.org/shields/years-in-bioc/MsBackendMetaboLights.svg)](https://doi.org/doi:10.18129/B9.bioc.MsBackendMetaboLights)
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

## Installation

The package can be installed from
[Bioconductor](https://bioconductor.org) with

[`install.packages`](https://rdrr.io/r/utils/install.packages.html)`(``"BiocManager"``)`` ``BiocManager``::`[`install`](https://bioconductor.github.io/BiocManager/reference/install.html)`(``"MsBackendMetaboLights"``)`

------------------------------------------------------------------------

## 🤝 Contributing

We appreciate contributions of all kinds — from bug fixes and tests to
documentation and new format support.

If you’re planning to contribute:

1.  Read our [contribution
    guidelines](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html#contributions)
2.  Follow the [RforMassSpectrometry style
    guide](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html)
3.  Fork the repo, create a branch, implement your changes, and submit a
    pull request —

# Funding information

Part of this work was funded by the **European Union** under the
**HORIZON-MSCA-2021** project **101073062: HUMAN – Harmonising and
Unifying Blood Metabolic Analysis Networks**, by the **Autonomous
Province of Bolzano** under the **MetaRbolomics4Galaxy** project (CUP:
D53C25001030003) from the *Joint Projects South Tyrol–Germany 2025*
funding program and by the DFG grant no.
[564004112](https://gepris.dfg.de/gepris/projekt/564004112?language=en).

![EU
Logo](https://github.com/rformassspectrometry/Metabonaut/raw/main/vignettes/images/EULogo.jpg)

EU Logo

![funding](https://github.com/rformassspectrometry/MsBackendMassIVE/raw/main/man/figures/SuedDFG-60.png)

funding
