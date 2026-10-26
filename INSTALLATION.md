# Installation and first run — Toolkit v1.12.0

[Srpski (latinica)](INSTALLATION_SER.md) · [README](README.md) · [Module registry](MODULE_REGISTRY.md)

## 1. Obtain the software

Install [R](https://cran.r-project.org/) and optionally [RStudio Desktop](https://posit.co/download/rstudio-desktop/). Clone the public repository using GitHub Desktop or choose **Code > Download ZIP** on GitHub. The repository contains code and documentation, **not** official RZS workbooks or generated election analyses.

```text
election-forensics-r-toolkit/
  README.md  INSTALLATION.md  MODULE_REGISTRY.md  WORKFLOW.md
  modules/
    rzs_data_preparation/      # RZS_data_preparation.R
    descriptive_statistics/    # Descriptive_statistics.R
    klimek/                    # Klimek.R
    election_fingerprints/     # Election_fingerprints.R
    contours/                  # Contours.R
    voter_rigging/             # Voter_rigging.R
    approximate_normality/     # Approximate_normality.R
    shpilkin/                  # Shpilkin.R
```

## 2. Prepare or reuse election inputs

The supported analytical modules expect compatible RZS workbooks in the local `modules/rzs_data_preparation/RZS_prepared/` directory:

```text
presidential_2017_RZS_prepared.xlsx
presidential_2022_RZS_prepared.xlsx
parliamentary_2022_RZS_prepared.xlsx
```

If these workbooks are already locally validated and unchanged, **reuse them**. Otherwise obtain the official Excel sources and follow the [RZS preparation documentation](modules/rzs_data_preparation/README.md) to build and validate the inputs. Do not upload raw/prepared data to GitHub. A change to source data or preparation rules requires revalidation.

## 3. Choose an analysis

In RStudio select **Session > Set Working Directory > Choose Directory…**, select the relevant module directory and check `getwd()`. Install only the packages needed by that module and run its tests as described in the corresponding README:

| Module | Entry point | Instructions |
|---|---|---|
| Descriptive statistics | `Descriptive_statistics.R` | [README](modules/descriptive_statistics/README.md) |
| Klimek cumulative curves | `Klimek.R` | [README](modules/klimek/README.md) |
| Election fingerprints | `Election_fingerprints.R` | [User guide](modules/election_fingerprints/USER_GUIDE.md) |
| Contour diagrams | `Contours.R` | [README](modules/contours/README.md) |
| Voter-rigging diagnostics | `Voter_rigging.R` | [README](modules/voter_rigging/README.md) |
| Approximate normality | `Approximate_normality.R` | [README](modules/approximate_normality/README.md) |
| Shpilkin/Kobak diagnostics | `Shpilkin.R` | [README](modules/shpilkin/README.md) |

For example, from `modules/contours/`:

```r
install.packages(c("readxl", "ggplot2", "MASS"))  # Once, if absent
source("tests/run_tests.R")
source("tests/test_graphics.R")
Sys.unsetenv("EF_CONTOUR_TEST_MODE")
source("Contours.R")
```

Default settings process the three supported elections; modify the **EDITABLE SECTION** in `Contours.R` to select elections, A/B turnout definitions, classifications, language(s), areas and figure options. Use a national-only run first if you want a smaller output set.

## 4. Find and interpret outputs

Each module writes its outputs to its own local `*_outputs/` folder, not to the prepared input files. Contours produces PNG diagrams and CSV files describing standardised observations, QC counts and PASS/SKIP conditions in `modules/contours/contours_outputs/`. The complete layout and interpretation are described in the [Contours module README](modules/contours/README.md).

For `voter_rigging`, use the `Master` worksheet (including QC-eligible E<100 units); output is stored locally in `modules/voter_rigging/voter_rigging_outputs/`. The analysis reports descriptive `D(p)` and does not calculate `δ(p)` without an appropriate international reference set.

The `approximate_normality` module reads `Master`, uses QC-eligible `E >= 100` units for primary comparisons and keeps stations below that size threshold in a separate sensitivity analysis. From `modules/approximate_normality/`, install `readxl`, `ggplot2` and `scales` if needed; run `source("tests/run_tests.R")`, `source("tests/test_graphics.R")`, `source("tests/integration_real_data.R")`, then `Sys.unsetenv("EF_APPROX_NORMALITY_TEST_MODE")`, `source("Approximate_normality.R")` and `source("tests/check_exports.R")`. Results (EN/SR-Latin PNG figures and numeric CSVs) are saved to `approximate_normality_outputs/`. Its fixed-bin distributions are descriptive normality diagnostics, not a fraud classification.

The `shpilkin` module runs from `modules/shpilkin/` with `source("tests/run_tests.R")`, `source("tests/test_graphics.R")`, `source("tests/integration_real_data.R")`, `Sys.unsetenv("EF_SHPILKIN_TEST_MODE")`, `source("Shpilkin.R")`, and `source("tests/check_exports.R")`. It reads `Master` and writes only `shpilkin_outputs/`; its default Monte Carlo count (999) is exploratory, while the original study used 10,000. The excess-votes calculation requires sensitivity to its reference turnout range and does **not** certify fraud or its absence.

Statistical diagnostics are not legal determinations of electoral misconduct. Consult the respective module's limitations and retain provenance, parameters, code version and `sessionInfo()` with substantive analyses.
