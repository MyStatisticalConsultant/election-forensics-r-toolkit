# Election Forensics R Toolkit — v1.13.0

Release date: 27 October 2026.

## New analytical module

- Added **`regression_analysis` v0.1.8** (`modules/regression_analysis/`) as the eighth independent analytical module, alongside the upstream RZS data-preparation module. Existing analytical modules and source workbooks are unchanged.
- **A — Turnout and votes per registered voter.** Polling-station-level ordinary least squares (OLS) comparisons of the national winner and runner-up against turnout, following the descriptive regression specification illustrated by Lukinova, Myagkov and Ordeshook (2011, pp. 613–620); not claiming that the authors invented OLS or that findings in Russia generalise to Serbia.
- **B1 — Invalid-ballot count.** Winner's percentage of valid votes regressed on the *number* of invalid ballots.
- **B2 — Invalid-ballot rate.** Winner's percentage of valid votes regressed on invalid ballots divided by ballots cast, with controlled sensitivity regressions (turnout, electorate size, optional municipality fixed effects) reported separately.
- Both `C/E` (primary) and `B/E` turnout definitions; two upstream classification systems (`Size`, `Size_JHK`) without local reclassification; under-100 stations as a labelled sensitivity sample. The JHK figure family has **All, JHK Small and JHK Large** panels.
- English and Serbian-Latin PNG plots with verified candidate/list names resolved using the prepared `Options` dictionary; CSV files for configuration, option choice, quality control, sample counts, fitted coefficients (conventional and HC3), model diagnostics, fitted values, residuals and influence measures.
- Updated root README, module registries, installation, workflow, `.gitignore`, citation metadata and source-file checksum manifest; historical release notes and licence unchanged.

## Validation and limitations

The module's synthetic numerical tests, bilingual graphics checks, integration tests on the three prepared Serbian elections, and national CSV export checks have been reported as passing in RStudio during development; the final v0.1.8 figures have been visually reviewed. These tests do **not** independently reconcile official results, establish causal relationships, or prove manipulation. Re-run the validation steps from [module README](modules/regression_analysis/README.md) after installation and retain the configurations and output CSVs for each analysis.

The turnout–vote regression contains a **mechanical component** because votes per registered voter are part of turnout. Invalid-ballot counts depend on station size; neither a negative association nor a statistically significant relationship establishes intent. Controlled B1/B2 models are sensitivity analyses, not a formal fraud classifier, and a null association does not certify the absence of fraud.

Refer to the [regression module methodology](modules/regression_analysis/METHODOLOGY.md), [output guide](modules/regression_analysis/OUTPUT_GUIDE.md) and [previous release notes](RELEASE_NOTES_v1.12.0.md).
