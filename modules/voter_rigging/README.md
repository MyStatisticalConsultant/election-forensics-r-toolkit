# Voter rigging in small polling stations

[Srpski (latinica)](README_SER.md) · [Methodology](METHODOLOGY.md) · [Metodologija](METHODOLOGY_SER.md)

**Module:** `voter_rigging` · **Script:** `Voter_rigging.R` · **Version:** 0.1.1

This module implements the **small–large polling-station discrepancy measure** described by Jimenez, Hidalgo and Klimek (2017), including the source-defined local standardisation, 95% ellipse trimming, median-based distance `D(p)` at size thresholds `p = 0.5%, 1%, …, 90%`, and the cumulative winner-vote-share curve. It generates CSV numerical outputs and English/Serbian-Latin Figure 4-style graphs for configured national, district and municipality units.

## Critical limitation — stage B versus the original published test

**This release calculates `D(p)`, not the original internationally standardised test statistic `δ(p)`. It cannot reproduce Figure 4A's grey acceptance region or classify an election as statistically significant according to the paper.** In the source paper, `δ(p)` requires a **comparable multi-election reference distribution**: `D(p)` is first calculated for 21 elections from ten countries, the authors identify an internal reference set using an iterative modified Thompson tau outlier procedure, and the reported statistic standardises each election's distance by the **reference-set mean and SD at each p**.

The three available prepared Serbian election workbooks (2017/2022 presidential, 2022 parliamentary) do **not** constitute this independent international reference. The Supplementary Materials supply counts and electorate-size summaries for the original 21 cases, but **not their full `D(p)` series**, so one cannot recover the original acceptance envelope from those tables. Replacing the international distribution with three Serbian elections, assuming a standard normal null, or setting unavailable `δ(p)` to zero would fabricate unsupported significance results. **All `δ` fields are exported as `NA`, with `reference_status=NOT_AVAILABLE`.** A later stage A extension can compute it when audited, methodologically comparable international reference data exist. See [Methodology](METHODOLOGY.md).

This release optionally calculates **exploratory electorate-label permutation diagnostics** at selected `p` values. Their empirical tail probabilities are explicitly *not* substitutes for the authors' modified Thompson tau cross-election test or for `δ(p)`. The permutation null depends on how sizes are shuffled, while turnout itself contains the size denominator; treat these results as sensitivity checks only.

## Data and sample

Input: prepared RZS Excel workbooks from the independent `rzs_data_preparation` module, worksheet **`Master`**. `Main` is **not** the default because its E≥100 eligibility restriction would remove very small polling stations central to this question.

Required columns: `Station_key`, `District_code`, `Municipality_code`, `E` (registered voters), `B` (valid votes), `C` (ballots cast), and `Winner_votes` (the selected national winner). A documented explicit per-election fallback to `Option_06_votes` (presidential 2017/2022) or `Option_01_votes` (parliamentary 2022) is configured for datasets lacking `Winner_votes`; **confirm the national option from the `Options` sheet if fallback is used**. If source names change, adjust the editable settings rather than silently guessing.

Data QC requires a valid unique station ID, geography, positive valid votes and electorate, nonnegative integer vote counts, `B≤C≤E`, and `0≤W≤B`. Polling stations with **E<100 are intentionally kept** when these requirements are met. `Eligible_primary` or `Eligible_contour` flags are not reused because they may impose other modules' E≥100 cutoffs. All exclusions are documented in `station_level_qc.csv`.

## Numerical methods

- **A:** turnout = `B/E`, winner share = `W/B` (article-oriented definition).
- **B:** turnout = `C/E`, winner share = `W/B` (Toolkit sensitivity specification).
- Each station is compared with the **other eligible stations in its municipality** (leave-one-out). A neighborhood must contain at least **10 eligible stations**, thus each target has at least nine neighbors. This stricter rule differs from the `contours` module's five-peer default.
- Standardised coordinates are screened against the **95% sample-covariance ellipse of the election-wide standardised data**. This exclusion is part of the source's statistical procedure and **is not evidence that excluded polling stations are fraudulent**.
- For threshold `p`, small stations have `E < quantile(E,p/100)` among the analysis area's post-ellipse stations. The complementary group is large. Each needs at least **10** stations. `D(p)` is the Euclidean distance between the **two pairs of coordinate-wise medians**; it is not the KDE-mode arrow shown in `contours`.
- Figure 4B-style cumulative share sorts **all arithmetically valid stations** by electorate descending and computes cumulative winner votes / cumulative valid votes. Its denominator and sample intentionally differ from the ellipse-trimmed D curve.
- A and B are calculated independently for each selected geographic area; for district and municipality plots the percentile split is recomputed **within that displayed area** but the z-score neighborhoods and 95% ellipse are calculated at the whole-election level. These subnational curves are **exploratory**, not the international reference-tested statistic.

## Install and run (RStudio)

1. Copy folder `voter_rigging` to `election-forensics-r-toolkit/modules/`. Keep the existing RZS prepared Excel workbooks locally.
2. In RStudio, set your working directory to `modules/voter_rigging/`.
3. Install missing dependencies: `install.packages(c("readxl", "ggplot2"))`.
4. Review **EDITABLE SECTION** at the beginning of `Voter_rigging.R` — especially file paths, elections, `GEOGRAPHIC_LEVELS`, and winner field mapping.
5. Run:

```r
source("tests/run_tests.R")
source("tests/test_graphics.R")
source("tests/integration_real_data.R")  # optional; requires the local prepared XLSX
source("Voter_rigging.R")
source("tests/check_exports.R")
```

The default is **national** outputs for all three elections. To request district and municipality plots, set `GEOGRAPHIC_LEVELS <- c("national", "district", "municipality")`; optionally restrict to known `DISTRICT_CODES` and `MUNICIPALITY_CODES`. Start with one election and national only if you want a quick validation run. `RUN_EXPLORATORY_PERMUTATIONS <- FALSE` disables supplementary randomisation.

## Files produced

Under `voter_rigging_outputs/` (ignored by Git):

| File | Content |
|---|---|
| `run_configuration.csv` | Exact configured method and reference availability |
| `export_manifest.csv` | Each requested area/definition and success/skip counts |
| `<election>/definition_<A/B>/station_level_qc.csv` | Every Master row, reason/eligibility, raw rates, municipal reference mean/SD, z scores, Mahalanobis distance and ellipse inclusion |
| `quality_summary.csv`, `ellipse_parameters.csv` | Sample counts and 95% ellipse covariance, centre and threshold |
| `<level>/<area>/D_by_size_threshold.csv` | All p values, cutoff, group counts, four medians, signed axis differences, `D(p)`, `δ=NA` and status |
| `<level>/<area>/cumulative_vote_share.csv` | Electorate rank and cumulative sums of registered, valid and winner votes, plus cumulative share |
| `permutation_summary.csv`, `permutation_draws.csv` | Optional exploratory label-permutation diagnostics, explicitly nonconfirmatory |
| `Figure4A_D_EN/SR.png`, `Figure4B_cumulative_EN/SR.png` | Separate bilingual panels; 4A is **D**, not original **δ** |
| `Figure4_style_EN/SR.png` | Two-panel figure for each area/election/definition |
| `Figure4_style_comparison_<A/B>_EN/SR.png` | National multi-election two-panel comparisons if national enabled |

The module never modifies RZS prepared workbooks or other toolkit modules, and does not store personal voter records.

## Interpretation

A shift in the centres of small and large polling stations is **a statistical pattern requiring contextual scrutiny, not proof of voter coercion or election fraud**. Non-fraud mechanisms such as demographic differences, geography, station assignment and genuine differential mobilisation may also affect results. Conversely, voter intimidation distributed across both large and small stations might escape this method. Relevant polling-station records, observer evidence and legal procedures remain essential.

## Source

Jimenez, R., Hidalgo, M., & Klimek, P. (2017). *Testing for voter rigging in small polling stations*. **Science Advances, 3**(6), e1602363. https://doi.org/10.1126/sciadv.1602363. Specifically main text pp. 3–6 and its Supplementary Materials, pp. 2–4 (eligibility, ellipse, median D, Thompson tau and size thresholds).

### Interpretation of Figure 4-style A/B comparison files

`Figure4_style_comparison_A_EN.png` uses **turnout definition A**, `B/E` (valid votes / registered voters), in its **D(p)** panel. `Figure4_style_comparison_B_EN.png` uses **turnout definition B**, `C/E` (ballots cast / registered voters), in its **D(p)** panel. Each panel A subtitle identifies the definition. When invalid-ballot shares are small, the two `D(p)` profiles may look similar. **The Figure 4B panel is exactly the same** in the two combined files: it uses the cumulative winner votes divided by cumulative valid votes and does not use the turnout definition. The vertical axis of Figure 4A reads *Effect size, D(p)*, **not** the source paper’s inferential `δ(p)`. Figure 4B contains a dashed 50% reference line. Legends display readable election names and wrap after at most three entries per row.
