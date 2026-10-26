# Regression analysis — Election Forensics R Toolkit

**Module:** `regression_analysis` · **Version:** v0.1.8 (development) · **Languages:** English and Serbian (Latin)

## Overview

This module provides two types of station-level regression diagnostics for prepared Serbian election data:

1. **Lukinova et al. (2011):** regress each candidate's votes as a percentage of registered voters on turnout. Compare the national winner and the runner-up. The specification reproduces the *form* of the OLS regressions in Figures 12–29 of the source paper (especially pp. 613–620). The paper's particular geographic and historical interpretation of Russia is **not** assumed to transfer to Serbia.
2. **Mebane-inspired invalid-ballot regressions:** investigate whether the winner's percentage of valid votes is associated with the **absolute count** of invalid ballots (B1) or with the **invalid-ballot rate** (B2). Separately report controls for turnout and electorate size, and optional municipality fixed effects. This is a documented diagnostic extension, **not** a claimed exact replication of a formally specified Mebane regression test.

These are **descriptive associations, not causal or forensic determinations of electoral fraud**. A statistically significant coefficient — positive or negative — is not sufficient evidence of manipulation. A null coefficient does not prove an election was free of manipulation.

## Files

- `Regression_analysis.R`: editable configuration and batch runner
- `R/regression_core.R`: data selection, eligibility, OLS, HC3 and diagnostics
- `R/regression_plots.R`: bilingual Size four-panel and JHK centred three-panel figures
- `tests/run_tests.R`, `tests/test_graphics.R`, `tests/integration_real_data.R`, `tests/check_exports.R`
- `METHODOLOGY.md` / `_SER.md`: intuitive and formal specification
- `OUTPUT_GUIDE.md` / `_SER.md`: CSV columns, figures and directory structure

## Installation and execution

From the module directory (`modules/regression_analysis/`):

```r
install.packages(c('readxl','ggplot2'))  # only if needed
source('tests/run_tests.R')
source('tests/test_graphics.R')
source('tests/integration_real_data.R')
Sys.unsetenv('EF_REGRESSION_TEST_MODE')
source('Regression_analysis.R')
source('tests/check_exports.R')
```

The default inputs are the `Master` worksheets of `presidential_2017`, `presidential_2022`, and `parliamentary_2022` in `../rzs_data_preparation/RZS_prepared/`. Raw spreadsheets and output files are not part of the public repository.

### Editable options

Change `INPUTS` to add elections. The module picks the two options with the highest national counts from `Option_NN_votes` columns; the winner is **cross-checked against `Winner_votes`** (or the configured fallback). Set `SELECTION` to override the two columns for a particular election; the first must agree with the prepared national winner. Names are automatically taken from the `Options` worksheet by `Option_number` and shown in both language figures. If a verified mapping is unavailable, the run stops with a clear instruction to supply `OPTION_LABELS`; the module does not guess identities from `Option_NN` numbers. `selected_options.csv` records the name and provenance. Partial named `OPTION_LABELS` overrides are permitted: unspecified candidate/list fields still use `Options` (for example `list(presidential_2022=c(Option_06_votes="Verified winner"))`).

`TURNOUT_DEFINITIONS = c('C/E','B/E')` generates both the turnout based on ballots cast and the turnout based on valid votes. **`C/E` is primary.** The invalid-ballot count is `C-B`; the invalid rate is `100(C-B)/C` (regardless of which turnout definition appears on the same page).

`SIZE_CLASSIFICATIONS = c('Size','Size_JHK')` generates **both** classification families. The `Size` figures show All eligible stations with `E >= 100`, Small, Large and the under-100 sensitivity group. The `Size_JHK` figures show All, JHK Small and JHK Large in a centred 2-over-1 arrangement; the under-100 sensitivity group remains available in the `Size` figures and CSV exports. These groups can overlap; the `Size_JHK` category thresholds were defined in upstream national data preparation and are **never recalculated per area**. The classification labels themselves are preserved.

Set `GEOGRAPHIC_LEVELS` to `c('national','district','municipality')` and optionally restrict geographic identifiers. The defaults use national analyses only. When a group has fewer than 30 usable stations, or no relevant predictor variation, it receives an explicit `status` in the CSV rather than a potentially unreliable fitted line.

The module **does not modify** RZS workbooks or other Toolkit modules. Results are written under `regression_analysis_outputs/`, which is Git-ignored.


### Plot presentation (v0.1.8)

All figure fonts are increased 1.5× relative to v0.1.3. Model A regression equations are inset at the upper-left, with consistent vertical separation. B1/B2 equations are inset at the lower-right, away from dense invalid-ballot points. Legends have one horizontal row; bottom captions use enlarged type. Method A figure titles describe the regression rather than attributing it to Lukinova. Size/JHK sample definitions and numerical OLS fitting are unchanged. JHK figures use a shared legend and a bottom-centred Large panel, avoiding an oversized two-facet layout.

## Interpretation and quality assurance

The main coefficient for Part A is the OLS slope of `100 votes/E` on `100 turnout`, in **percentage-point units**. The ratio `votes/E` has a mathematical relationship to turnout, so positive slopes can occur for entirely legitimate reasons. The original paper's emphasis on slopes near or above 1 is contextual, not a universal numerical fraud threshold.

For Part B, absolute invalid counts scale with station size. The invalid-rate and controlled specifications reduce some confounding but do not remove selection effects, compositional constraints, ecological aggregation or unobserved heterogeneity. HC3 standard errors are reported alongside classical OLS inference; neither addresses causal identification.

Tests check code behaviour on constructed examples and RZS file contracts. They do not independently reconcile official election subtotals, establish electoral wrongdoing, or establish that OLS assumptions hold in real election data.

**References:** Lukinova, E., Myagkov, M., & Ordeshook, P. C. (2011). *Metastasised Fraud in Russia’s 2008 Presidential Election*. Europe-Asia Studies, 63(4), 603–621. See the bibliography and detailed methodological limits in `METHODOLOGY.md`.
