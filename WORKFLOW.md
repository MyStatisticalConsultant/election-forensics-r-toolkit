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
| **Voter-rigging diagnostics** | `modules/voter_rigging/` | `source("Voter_rigging.R")` | `voter_rigging_outputs/` |
| **Approximate normality** | `modules/approximate_normality/` | `source("Approximate_normality.R")` | `approximate_normality_outputs/` |
| **Shpilkin/Kobak diagnostics** | `modules/shpilkin/` | `source("Shpilkin.R")` | `shpilkin_outputs/` |
| **Regression analysis** | `modules/regression_analysis/` | `source("Regression_analysis.R")` | `regression_analysis_outputs/` |

For the first run, install any module-specific R packages and execute the tests listed in that module's README. For Contours specifically:

```r
install.packages(c("readxl", "ggplot2", "MASS"))  # If missing
source("tests/run_tests.R")
source("tests/test_graphics.R")
Sys.unsetenv("EF_CONTOUR_TEST_MODE")
source("Contours.R")
```

Contours supports turnout A (`B/E`) and B (`C/E`), `Size` and `Size_JHK`, EN/SR-Latin PNGs, and national/district/municipality selections. The municipality-level leave-one-out reference is computed **before** selecting the plotted group or reporting area. A two-group KDE is skipped where either group is too small (default threshold: 15); details appear in `contour_export_manifest.csv`. Refer to the [module README](modules/contours/README.md) for the complete interpretation and options. For Fingerprints, including strict invalid-area handling, refer to its [user guide](modules/election_fingerprints/USER_GUIDE.md).

For `voter_rigging`, use the `Master` worksheet to retain small polling stations; set the working directory to `modules/voter_rigging/` and run the four validation/export checks listed in its [README](modules/voter_rigging/README.md). It calculates descriptive median-distance `D(p)` (turnout A/B) and cumulative share curves, not the international reference-standardised `δ(p)`. No prior downstream analysis needs to be rerun.

For `approximate_normality`, use the `Master` worksheet, retaining QC-eligible stations with `E >= 100` for primary figures and reporting under-100 stations separately as a sensitivity analysis. From `modules/approximate_normality/`, run `source("tests/run_tests.R")`, `source("tests/test_graphics.R")`, `source("tests/integration_real_data.R")`, `Sys.unsetenv("EF_APPROX_NORMALITY_TEST_MODE")`, `source("Approximate_normality.R")` and `source("tests/check_exports.R")`. The figures reproduce the *binned empirical* approach to approximate normality, with one standard `N(0,1)` reference per standardized-election comparison, and export detailed CSVs; see its [README](modules/approximate_normality/README.md). It does not implement a parametric fraud model.

The `shpilkin` module includes three separate procedures: descriptive turnout/winner histograms; an integer-percentage Monte Carlo test (default 999 repetitions, optional 10,000 for source-comparable precision); and a conditional turnout-reference excess-votes estimate. From `modules/shpilkin/` run the four tests described in its [README](modules/shpilkin/README.md) as needed. **A zero conditional excess estimate cannot be interpreted as no fraud**, and a positive value is not a verified fraud tally. No other analytical module needs to be rerun.

For `regression_analysis`, use compatible `Master` and `Options` sheets from the same prepared election workbook. From `modules/regression_analysis/` run the numerical, graphics and real-data tests, the main script and the export check in the sequence given in its [README](modules/regression_analysis/README.md). The primary turnout definition is `C/E`, with `B/E` as sensitivity. All eligible `E >= 100` stations are analysed alongside `Size` and `Size_JHK` Small/Large groups, and `E < 100` stations are a separate sensitivity group. Candidate/list names are resolved from `Options`; the national winner and runner-up candidates/lists are compared. The A model regresses candidate votes per registered voter on turnout; B1 and B2 regress winner's valid-vote share on invalid-ballot counts and rates. Controlled models, OLS/HC3 coefficients, diagnostics, PNGs and station-level CSVs are saved under `regression_analysis_outputs/`. Apparent associations must not be interpreted as evidence that fraud occurred.

## 3. When to recompute

| Change | Rerun RZS preparation? | Downstream action |
|---|---|---|
| Add a module or modify only its plot language/style | No | Test/run the changed module only |
| Change the numerical method for one module | No, if prepared fields and QC are unchanged | Retest/rerun the affected module |
| Change official RZS inputs, QC eligibility, fields or `Size`/`Size_JHK` definitions | Yes; revalidate | Rerun all analyses affected by those changes |
| Add a new election or input workbook | Prepare and validate compatible data | Configure/test each downstream analysis used |

Scripts do not automatically detect stale local input workbooks. Keep checksums, configuration, code version and `sessionInfo()` for each publication snapshot.

## 4. GitHub source versus local data

Version-control code, tests and documentation; keep official raw XLSX, prepared XLSX and generated graphs/tables locally. The root [`.gitignore`](.gitignore) excludes `raw_data/`, `RZS_prepared/`, `descriptive_outputs/`, `klimek_outputs/`, `fingerprint_outputs/`, `contours_outputs/`, `voter_rigging_outputs/` and `approximate_normality_outputs/`, `shpilkin_outputs/` and `regression_analysis_outputs/`. Git ignore rules do not prevent accidental manual deletion or overwriting. Preserve these directories during updates.
