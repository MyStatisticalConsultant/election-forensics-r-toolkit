# Numerical and graphical output guide

[Srpski (latinica)](OUTPUT_GUIDE_SER.md) · [README](README.md) · [Methodology](METHODOLOGY.md)

All outputs are written to `approximate_normality_outputs/` on the local machine and are intentionally Git-ignored.

| Path | Content |
|---|---|
| `run_configuration.csv` | Recorded run settings and method choices. |
| `cross_election_manifest.csv` | Matched-area comparison status, number of elections and cross-election figures. |
| `run_manifest.csv` | One row per attempted election × area: PASS/SKIP and reason, counts of primary/under-100 stations and figures. |
| `normality_statistics.csv` | Group-level n, mean z, SD z, skewness, ordinary kurtosis, excess kurtosis, Jarque–Bera statistic and asymptotic p-value. |
| `<election>/station_qc.csv` | Every Master row, base counts and ν, eligibility flags, selected winner field and explicit exclusion reason. |
| `<election>/source_qc_summary.csv` | Election-wide counts of eligible, under-100 and excluded rows, with winner field. |
| `<election>/<level>/<area>/standardization_parameters.csv` | Mean and sample SD of ν over all primary E≥100 stations in this area. |
| `<election>/<level>/<area>/station_level_log_rates.csv` | All Master rows in that geographic area, ν, z, group label and eligibility/QC. |
| `<election>/<level>/<area>/within_election_histogram_bins.csv` | Primary All/Small/Large groups, bin index, centre, left/right edges, count, n, empirical probability and expected normal probability. |
| `<election>/<level>/<area>/under100_sensitivity_histogram_bins.csv` | Identically defined bins, primary All vs under-100 sensitivity subset (when eligible). |
| `cross_election/<level>/<area>/cross_election_histogram_bins.csv` | Common bin grid and per-election empirical frequencies for matched geographic areas. |
| `<election>/<level>/<area>/Figure2_style_within_EN.png` and `_SR.png` | Within-election group comparison. |
| `<election>/<level>/<area>/Figure2_style_under100_EN.png` and `_SR.png` | Separate under-100 sensitivity comparison, if n sufficient. |
| `cross_election/<level>/<area>/Figure2_style_cross_elections_EN.png` and `_SR.png` | Cross-election comparison if at least two elections share selected area. |

`<election>` is an internal ID such as `presidential_2017`, unchanged in filenames for reproducibility; human-facing figure legends replace underscores with spaces (SR labels translated). `<level>` is `national`, `district`, or `municipality`; `<area>` is the geographic code, or `national`.

All bilingual figures include an explicit **Standard normal reference, N(0,1)** legend entry for the black line. This curve shows expected probability **per bin** rather than the continuous normal density. Legend keys match the empirical curve colours; the reference key is black.

### Key numeric fields

`nu` = `log(W/(E-W))`; `z` = `(nu-mean_nu)/sd_nu` where the reference moments use all primary E≥100 stations in the same election × selected area. `bin_index` = `floor(z/BIN_WIDTH + 0.5)`; `x` = standardized bin centre; `left`/`right` = edges; `count` = integer frequency; `n` = number of stations in that **group**; `probability` = `count/n`; `normal_probability` = `pnorm(right)-pnorm(left)` for N(0,1). Histogram tables retain out-of-figure-range tails. The normal-bin probability is a probability **mass**, not `dnorm()` density.

`kurtosis` is Pearson kurtosis, with normal benchmark 3. `jb_p_value` assumes the asymptotic chi-square(2) reference; it is **not a fraud p-value**. Zero-count bins are exported explicitly, avoiding invisible gaps in the plots.

### Checking results

Review `run_manifest.csv` first, then the election `source_qc_summary.csv` and area `standardization_parameters.csv`. Confirm `sum(count)` equals the group n for each histogram and `sum(probability)=1` (subject to numerical precision). Review all exclusions and verify that national winner is correctly mapped in `Options`. Re-run the appropriate analysis whenever a prepared workbook changes.

Note: results from earlier runs can remain in the output directory if a later configuration skips them. Treat the current run manifests as authoritative; archive or clear a previous output folder before a materially different run. The module does not delete files automatically.
