# Workflow — run modules independently

[Srpski (latinica)](WORKFLOW_SER.md) · [Installation](INSTALLATION.md) · [Module registry](MODULE_REGISTRY.md)

## 1. Prepare election data once

`modules/rzs_data_preparation/RZS_data_preparation.R` transforms official RZS workbooks into validated local files in `modules/rzs_data_preparation/RZS_prepared/`:

```text
presidential_2017_RZS_prepared.xlsx
presidential_2022_RZS_prepared.xlsx
parliamentary_2022_RZS_prepared.xlsx
```

The `Main` sheet contains QC-eligible polling stations with registered electorate `E >= 100`; `Master` retains additional prepared records and status flags; `Options` identifies candidates and lists. These workbooks **are not included in the public repository**. Compatible existing files can be reused; adding an independent downstream module does not require running preparation again.

## 2. Run the required analysis only

Set the RStudio working directory to the listed module directory and source its entry-point file.

| Analysis | Directory | Command | Local output |
|---|---|---|---|
| Descriptive statistics | `modules/descriptive_statistics/` | `source("Descriptive_statistics.R")` | `descriptive_outputs/` |
| Klimek cumulative curves | `modules/klimek/` | `source("Klimek.R")` | `klimek_outputs/` |
| Election fingerprints | `modules/election_fingerprints/` | `source("Election_fingerprints.R")` | `fingerprint_outputs/` |
| **Contour diagrams** | `modules/contours/` | `source("Contours.R")` | `contours_outputs/` |

For the first run, install any module-specific R packages and execute the tests listed in that module's README. For Contours specifically:

```r
install.packages(c("readxl", "ggplot2", "MASS"))  # If missing
source("tests/run_tests.R")
source("tests/test_graphics.R")
Sys.unsetenv("EF_CONTOUR_TEST_MODE")
source("Contours.R")
```

Contours supports turnout A (`B/E`) and B (`C/E`), `Size` and `Size_JHK`, EN/SR-Latin PNGs, and national/district/municipality selections. The municipality-level leave-one-out reference is computed **before** selecting the plotted group or reporting area. A two-group KDE is skipped where either group is too small (default threshold: 15); details appear in `contour_export_manifest.csv`. Refer to the [module README](modules/contours/README.md) for the complete interpretation and options. For Fingerprints, including strict invalid-area handling, refer to its [user guide](modules/election_fingerprints/USER_GUIDE.md).

## 3. When to recompute

| Change | Rerun RZS preparation? | Downstream action |
|---|---|---|
| Add a module or modify only its plot language/style | No | Test/run the changed module only |
| Change the numerical method for one module | No, if prepared fields and QC are unchanged | Retest/rerun the affected module |
| Change official RZS inputs, QC eligibility, fields or `Size`/`Size_JHK` definitions | Yes; revalidate | Rerun all analyses affected by those changes |
| Add a new election or input workbook | Prepare and validate compatible data | Configure/test each downstream analysis used |

Scripts do not automatically detect stale local input workbooks. Keep checksums, configuration, code version and `sessionInfo()` for each publication snapshot.

## 4. GitHub source versus local data

Version-control code, tests and documentation; keep official raw XLSX, prepared XLSX and generated graphs/tables locally. The root [`.gitignore`](.gitignore) excludes `raw_data/`, `RZS_prepared/`, `descriptive_outputs/`, `klimek_outputs/`, `fingerprint_outputs/` and `contours_outputs/`. Git ignore rules do not prevent accidental manual deletion or overwriting. Preserve these directories during updates.
