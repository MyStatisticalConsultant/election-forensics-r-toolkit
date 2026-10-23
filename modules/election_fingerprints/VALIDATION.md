# Election Fingerprints v0.1.4 — validation record

[Srpski](VALIDATION_SER.md) · [README](README.md) · [Tests](tests/)

**Evidence:** The module author supplied successful RStudio console results on 24 October 2026 for the complete v0.1.3.1 development implementation. The v0.1.4 stable source changes only the release header and the initial setting `INVALID_AREA_POLICY <- "error"` (previously `"warn"`); the statistical, graphics, geographic-validation and export-test functions are unchanged. This document records the **user-reported execution results**; it is not a claim that R was executed during ZIP preparation.

## Tests passed on the three supported datasets

| Test or run | Researcher-confirmed result |
|---|---|
| `tests/run_tests.R` | PASS: canonical rates, count-based 2D bins and boundaries, national winner, bilingual geography |
| `tests/test_graphics.R` | PASS: EN/SR layout, default 200×200 KDE raster rendered without removed-border-row warnings, 14-pt subtitles, singleton case |
| `tests/test_geography_validation.R` | PASS: invalid-key warning and suggestions, strict error behaviour, complete geographic export coverage; negative incomplete-export test |
| `tests/integration_real_data.R` | PASS: presidential 2017 (8,023 Main stations), presidential 2022 (7,787), parliamentary 2022 (7,787), correct selected winner fields |
| `source("Election_fingerprints.R")` | Completed: each election had 1 National + 4 District + 2 Municipality areas, six ALL/size groups per area, EN/SR and both turnover definitions, without reported R warnings |
| `tests/check_exports.R` | PASS: National=1, District=4, Municipality=2 for each election; groups, turnout definitions, station counts and output files reconcile |

The selected operational districts were codes `25`, `26`, `33` and `55`; the municipalities were composite keys `18|71021` and `26|90239`. Cases with no stations were recorded without charts; cases with too few observations or constant axes retained the histogram and omitted KDE. These are documented safeguards, not run-time failures.

## Sample and algorithmic checks

The validated `Main` sample is restricted to eligible stations with E ≥ 100. Independent inspection of the provided prepared workbooks found these baseline numbers:

| Election | Main stations | Usable for primary histogram | B=0 excluded from histogram |
|---|---:|---:|---:|
| Presidential 2017 | 8,023 | 8,009 | 14 |
| Presidential 2022 | 7,787 | 7,782 | 5 |
| Parliamentary 2022 | 7,787 | 7,787 | 0 |

B=0 records remain in the source and audit; their share `W/B` is undefined, so **sum of histogram cells equals eligible included station count**, not necessarily `Main` count. The five optional size groups are two *overlapping classification systems*, each independently partitioning the relevant area. The tests verify counts per classification rather than summing all five groups.

## How to reproduce

Working directory: `modules/election_fingerprints/`, with the three prepared input workbooks present. Run:

```r
source("tests/run_tests.R")
source("tests/test_graphics.R")
source("tests/test_geography_validation.R")
source("tests/integration_real_data.R")
Sys.unsetenv("EF_FINGERPRINT_TEST_MODE")
source("Election_fingerprints.R")
source("tests/check_exports.R")
sessionInfo()
```

For a selected-area run, set the valid geographic codes and `INVALID_AREA_POLICY <- "error"` in **EDITABLE INPUTS**, save the script and rerun. Keep input hashes, settings and `sessionInfo()` for research reproducibility. Real-world data quality and interpretation require separate validation; these results do not establish a fraud finding or prove correctness for untested election datasets.

## Methodological limitations

The source article does not document the exact graphical pixel resolution of its Figure 1; `HIST_BINS=50` is an explicit reproducible implementation choice. The KDE supplement is an ordinary Gaussian KDE (boundary-biased), not the primary count histogram or a posterior probability. Special geographic groups may be too small for meaningful KDE. The module does not estimate fraud parameters `f_i`, `f_e` or conduct a formal electoral-fraud hypothesis test.
