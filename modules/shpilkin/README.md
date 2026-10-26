# Shpilkin: election-distribution diagnostics and conditional excess-votes scenarios

[Srpski (latinica)](README_SER.md) · [Methodology](METHODOLOGY.md) · [Output guide](OUTPUT_GUIDE.md)

**Module:** `shpilkin` | **Version:** 0.1.3 | **Main entry:** `Shpilkin.R`

This independent Election Forensics R Toolkit module provides **three related but distinct** analyses:

1. **Descriptive histograms** of turnout and national winner share, with publication-style centered bins and configurable 0.5 percentage-point width (optional 0.25), station-normalized area and reproducible numerator-only jitter for figures.
2. **Kobak–Shpilkin–Pshenichnikov (2016) integer-percentage Monte Carlo test:** original 0.1 pp electorate-weighted histograms, ±0.05 pp near-integer events, independent binomial draws, simulated null reference bands and negative-control half-integer statistics.
3. **Conditional Shpilkin-style excess-votes scenario:** turnout-binned winner and other valid vote curves, scaling within a specified or automatically proposed core, explicit positive residuals and core-width sensitivity. This third component is a documented adaptation, **not an exact uniquely identified algorithm from the supplied PDF**.

**Excess-vote display:** The grey high-turnout fill is a piecewise-linear polygon following the actual gap between observed winner votes and the core-scaled baseline, with interpolated crossing points. It is not rectangle-based. The displayed vote total is still the **sum of positive bin residuals** (CSV), not the plotted geometric area.

This module is **not** a classifier of fraudulent elections or polling stations. Neither departures in plots nor the scenario estimate establishes illegal activity. The Monte Carlo test addresses a narrower stochastic null about near-integer frequencies, not the total extent of possible fraud.

## Requirements and data

- R 4.2+ recommended; `readxl`, `ggplot2`; no Python and no EFToolkit required.
- Work locally within `modules/shpilkin/`.
- Prepared spreadsheets: `../rzs_data_preparation/RZS_prepared/*_RZS_prepared.xlsx`, **Master** sheet. They stay on your PC, not in this GitHub module.
- Primary fields: `Station_key`, `District_code`, `Municipality_code`, `E`, `B`, `C`, `Winner_votes`; configured candidate/list fallback only when `Winner_votes` is absent. Confirm the national winner against the prepared `Options` worksheet.
- Primary turnout `C/E`, sensitivity `B/E`; winner vote share always `W/B`. The Russian source uses different administrative denominators; see methodology.
- E < 100 stations are excluded from primary analyses, with detailed exclusion records. Descriptive histograms omit 100% boundaries; integer tests omit stations reporting above 99% turnout or winner percentage.

## Run in RStudio

Set working directory to `modules/shpilkin`, then:

```r
install.packages(c('readxl','ggplot2'))  # once, if necessary
source('tests/run_tests.R')
source('tests/test_graphics.R')
source('tests/integration_real_data.R')
Sys.unsetenv('EF_SHPILKIN_TEST_MODE')
source('Shpilkin.R')
source('tests/check_exports.R')
```

Output directory: `shpilkin_outputs/`. A full run of three elections with `B/E` sensitivity and Monte Carlo can be computationally demanding; tests use deliberately tiny synthetic examples. Data production only runs when sourcing `Shpilkin.R`, not when sourcing its core functions.

## Editable options

The editable section at the top of `Shpilkin.R` controls elections and paths, geographic levels (national default; district/municipality optional), languages (`EN`, `SR`), histogram widths, Monte Carlo iterations and seeds, and the excess-votes reference range.

**Important bin distinction:** `DESCRIPTIVE_BIN_WIDTH <- 0.5` improves plot readability with Serbian station counts. It does **not** affect the source-aligned test, for which `INTEGER_BIN_WIDTH <- 0.1` and `INTEGER_WINDOW_HALF_WIDTH <- 0.05` remain separate. The original *Significance* illustration used 0.25 pp; users can set 0.25 as a sensitivity check.

`MONTE_CARLO_REPS <- 999L` is the default exploratory setting. To match the number of simulations in the original paper, set `MONTE_CARLO_REPS <- 10000L`. Monte Carlo tail probability can never be smaller than `1/(reps+1)` under the implemented finite-simulation correction.

To avoid interpreting a data-selected “honest core” as established fact, prefer `EXCESS_CORE_RANGE <- c(lower,upper)` specified **before** examining the target outcome. If NULL, the runner selects a descriptive modal-turnout window and labels the outcome accordingly. Sensitivity CSVs show changes with three core widths.

## What gets exported?

At every requested election/turnout-definition/geography: station-level QC, descriptive station rates and binned counts, Monte Carlo replicate metrics, aggregate integer-test results, observed-vs-simulated E-weighted histograms, binned winner/other votes, conditional excess scenarios and sensitivity tables. Figures are written in English and Serbian-Latin. The root output folder has a configuration CSV, full area manifest and cross-election histogram table/figures. See [OUTPUT_GUIDE.md](OUTPUT_GUIDE.md) for paths and units.

## Sources and caveats

- Kobak, D., Shpilkin, S. & Pshenichnikov, M. S. (2016). *Integer percentages as electoral falsification fingerprints*. **Annals of Applied Statistics**, 10(1), 54–73. https://doi.org/10.1214/16-AOAS904
- Kobak, D., Shpilkin, S. & Pshenichnikov, M. S. (2016). *Statistical fingerprints of electoral fraud?* **Significance**, 13(4), 20–23. https://doi.org/10.1111/j.1740-9713.2016.00936.x
- For nonparametric scaling context: https://cedarus.io/research/evolution-of-russian-elections ; original EFToolkit's documented `NonparamElectionForensics()` provides an alternative implementation that is **not** used or copied in this module.

### Validation scope

The bundled synthetic unit tests and bilingual graphics tests passed, as did real-data integration and export checks for the prepared presidential 2017, presidential 2022 and parliamentary 2022 workbooks. Eligible stations for descriptive histograms: **7,988**, **7,772** and **7,787**, respectively; integer-test eligibility: **7,983**, **7,768** and **7,786**. Outputs were generated for all three elections. These integration checks confirm input compatibility and station-level QC; they are **not** an independent reconciliation against official national totals, independent replication of the published results, or a finding of electoral fraud. The default 999-replicate exploratory run is not equivalent to the paper's 10,000-replicate benchmark. For substantive use, validate provenance, denominators, reference-core assumptions and simulation sensitivity. Local source data and generated results are not included in this repository release.

**Graphics verification:** Run `source("tests/test_graphics.R")` to check curve-following excess-vote shading, interpolated crossings, two-line English/Serbian figure captions and PNG exports.
