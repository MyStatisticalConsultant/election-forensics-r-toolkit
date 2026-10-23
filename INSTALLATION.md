# Installation and first run — Toolkit v1.8.4

[Srpski (latinica)](INSTALLATION_SER.md) · [README](README.md)

## A. Obtain the public code

Install [R](https://cran.r-project.org/) and optionally [RStudio Desktop](https://posit.co/download/rstudio-desktop/). Use **GitHub Desktop** to clone the published repository to your computer (Repository > Clone Repository), or use GitHub **Code > Download ZIP** and extract it. The downloaded code contains no official RZS election data.

Directory layout:

```text
election-forensics-r-toolkit/
  README.md  INSTALLATION.md  MODULE_REGISTRY.md  WORKFLOW.md
  modules/
    rzs_data_preparation/
      RZS_data_preparation.R
      RZS_prepared/                    # created locally, not in Git
    descriptive_statistics/
      Descriptive_statistics.R
    klimek/
      Klimek.R
    election_fingerprints/
      Election_fingerprints.R
      tests/
```

## B. Obtain the prepared election inputs

Election Fingerprints requires the prepared RZS workbooks to exist in `modules/rzs_data_preparation/RZS_prepared/` with the exact filenames:

```text
presidential_2017_RZS_prepared.xlsx
presidential_2022_RZS_prepared.xlsx
parliamentary_2022_RZS_prepared.xlsx
```

If you already have compatible validated files locally, **reuse them**. Otherwise obtain official source workbooks, configure `modules/rzs_data_preparation/RZS_data_preparation.R`, run it, and follow its validation documentation. Do not publish either raw data or prepared workbooks in the GitHub repository.

## C. Run Election Fingerprints

In RStudio select **Session > Set Working Directory > Choose Directory…**, select `modules/election_fingerprints/`, and confirm `getwd()` returns this directory. Install dependencies once:

```r
install.packages(c("readxl", "ggplot2", "MASS", "ggExtra", "cowplot", "readr"))
```

Open `Election_fingerprints.R`; in its **EDITABLE INPUTS** adjust election input paths, `AREA_MODE`, `GENERATE_DISTRICTS`, `GENERATE_MUNICIPALITIES`, geographic selection IDs, languages, plot options and `INVALID_AREA_POLICY` as needed. The default policy `"error"` stops on an unknown requested district/municipality; the alternative `"warn"` allows valid areas to continue.

For installation verification, run:

```r
source("tests/run_tests.R")
source("tests/test_graphics.R")
source("tests/test_geography_validation.R")
source("tests/integration_real_data.R")
Sys.unsetenv("EF_FINGERPRINT_TEST_MODE")
source("Election_fingerprints.R")
source("tests/check_exports.R")
```

For ordinary later figure adjustments, `source("Election_fingerprints.R")` is sufficient; check exports after changing geographic scope. `Sys.unsetenv` is useful if a test-only environment variable remains set. If the analysis returns with no `[Fingerprints]` messages, inspect the test-mode setting before assuming outputs were generated.

## D. Where results are saved

All results go to `modules/election_fingerprints/fingerprint_outputs/<election>/<area>/`, including bilingual PNG/PDF files, 2D count grids, audits and status summaries. Size/JHK outputs are in `groups/<CODE>/` under each area. The file `fingerprints_status.csv` lists empty groups and skipped KDE cases as well as generated figures. Inputs are never overwritten by this module.

See [complete fingerprint user guide](modules/election_fingerprints/USER_GUIDE.md), [output guide](modules/election_fingerprints/OUTPUT_GUIDE.md) and [validation](modules/election_fingerprints/VALIDATION.md).
