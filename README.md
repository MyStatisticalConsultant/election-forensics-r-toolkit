# Election Forensics R Toolkit — v1.9.0

[Srpski (latinica)](README_SER.md) · [Installation](INSTALLATION.md) · [Module registry](MODULE_REGISTRY.md) · [Workflow](WORKFLOW.md) · [Release notes](RELEASE_NOTES_v1.9.0.md)

An open-source R toolkit for reproducible analysis of official Serbian election returns at polling-station level. It comprises **one upstream data-preparation module and four independent analytical modules**. Outputs are descriptive or diagnostic: **a statistical anomaly alone is not proof of electoral fraud**.

## Modules

| Module | Version / status | Purpose | Documentation |
|---|---|---|---|
| RZS data preparation | Established, previously validated | Harmonise official workbooks, apply data-quality checks, prepare the `Main`, `Master` and `Options` sheets | [RZS preparation](modules/rzs_data_preparation/README.md) |
| Descriptive statistics | v0.3.1 | National, district and municipality statistics, robust measures and reporting tables | [Descriptive statistics](modules/descriptive_statistics/README.md) |
| Klimek cumulative curves | v0.1.4 | Cumulative turnout–vote curves, including pre-defined Size and JHK groups | [Klimek](modules/klimek/README.md) |
| Election fingerprints | v0.1.4 | Observed two-dimensional turnout–vote-share count histograms and supplementary KDE diagnostics | [Election fingerprints](modules/election_fingerprints/README.md) |
| **Contour diagrams** | **v0.1.4** | Standardised, bilingual two-dimensional KDE contours comparing Small/Large and JHK groups at national, district and municipality levels | [Contours](modules/contours/README.md) |

Detailed methodological definitions, numerical and graphical parameters, module-specific tests and limitations are documented **in each module**, rather than reproduced in this root overview. Downstream modules read the prepared RZS data independently; they do not alter the source workbooks or require another analytical module to be executed first.

## Getting started

1. Install [R](https://cran.r-project.org/) and optionally [RStudio](https://posit.co/download/rstudio-desktop/); clone or download this repository. See [installation](INSTALLATION.md).
2. Obtain the official RZS input workbooks and prepare them once, **or reuse compatible, previously validated local workbooks** in `modules/rzs_data_preparation/RZS_prepared/`. The source and prepared Excel data are not distributed with the repository.
3. Choose an analytical module, set the RStudio working directory to that module's folder and run its script. For example, to generate contour diagrams:

```r
setwd("modules/contours")  # Adjust the path to your working directory
install.packages(c("readxl", "ggplot2", "MASS"))  # First time only
source("tests/run_tests.R")
source("tests/test_graphics.R")
Sys.unsetenv("EF_CONTOUR_TEST_MODE")  # Ensures a normal run
source("Contours.R")
```

`Contours.R` provides an **EDITABLE SECTION** for election selection, turnout definitions A (`B/E`) and B (`C/E`), station-size comparisons, languages and geographic scope. See [Contours README](modules/contours/README.md) and the [workflow guide](WORKFLOW.md). Other modules have their own documented entry points.

## Data, reproducibility and limitations

The default prepared `Main` data used by these methods contain 8,023 polling stations for presidential 2017 and 7,787 for each supported 2022 election after upstream QC and sample restrictions. Analyses for other elections require compatible prepared workbooks and validation.

- The root [`.gitignore`](.gitignore) excludes official raw data, prepared workbooks and locally generated outputs, including `contours_outputs/`.
- Keep source checksums, code versions, configuration and `sessionInfo()` alongside published analyses. A missing or too-small group is logged as `SKIP`; an algorithm should not manufacture a density plot for it.
- Contour diagrams visualise geographically standardised distributions. Their arrows show KDE-mode displacement **descriptively**, not the separate *voter-rigging test*. No module's output alone proves intentional manipulation.
- The root [checksum manifest](MANIFEST.sha256) lists source-file hashes. To audit a complete checkout, validate the manifest against the complete published file set, not only a ZIP of root documents.

## License and citation

MIT License: [LICENSE](LICENSE). Citation metadata: [CITATION.cff](CITATION.cff). © 2026 Zlatko J. Kovačić.
