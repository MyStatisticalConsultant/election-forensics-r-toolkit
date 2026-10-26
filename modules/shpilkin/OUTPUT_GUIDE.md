# Output guide — shpilkin

The runner writes only under `shpilkin_outputs/` (excluded from Git). All numeric products use UTF-8 CSV with header row; `NA` values are empty fields, not zeros.

At output root:
- `run_configuration.csv`: method settings, random seed, bin sizes, definitions and assumptions.
- `export_manifest.csv`: requested election/definition/area, eligible station counts, whether MC ran, and number of figures.
- `national_comparison_histograms.csv`: exact binned frequencies/densities for the all-election comparison. The first configured turnout definition is used.
- `National_comparison_EN.png` / `_SR.png`: cross-election descriptive comparison; legend wraps after three elections per row.

Per election, definition and area (`<election>/turnout_C_over_E|turnout_B_over_E/national|district|municipality/<area>/`):
- `station_level_qc.csv` at election/definition level: original counts E,B,C, configured winner W, turnout/winner percentages, reasons for exclusions and separate `base_ok`, `hist_ok`, `test_ok` flags. **Includes E<100** for auditability.
- `quality_summary.csv`: counts eligible for each method; totals are not independent validation against official RZS totals.
- `descriptive_station_rates.csv`: observed and plot-jittered rates (if enabled) for included stations. Jitter is never used for significance tests.
- `descriptive_turnout_bins.csv`, `descriptive_winner_bins.csv`: midpoint, boundaries, unweighted station frequency, probability mass and density per percentage point. Normalized unit area.
- `Descriptive_turnout_EN/SR.png` and `Descriptive_winner_EN/SR.png`: source-style centered-bin station histograms, with `DESCRIPTIVE_BIN_WIDTH` settable to 0.5 or 0.25.
- `integer_mc_summary.csv`: observed number of integer stations, Monte Carlo mean/SD/quantiles, excess, z, finite-simulation upper p, and half-integer control statistics. Only when MC is enabled for the area and sample adequate.
- `integer_mc_replicates.csv`: per-replicate integer event counts (full reproducibility of summary distribution).
- `integer_turnout_mc_histogram.csv`, `integer_winner_mc_histogram.csv`: **registered-voter weighted** per-0.1-pp observed totals and Monte Carlo mean/0.5%/99.5% pointwise envelopes, in individual voters (divide by 1e6 for plotted million voters).
- `Integer_MC_turnout_EN/SR.png`, `Integer_MC_winner_EN/SR.png`: red empirical, black null mean, grey MC pointwise reference envelope.
- `excess_turnout_bins.csv`: per turnout bin, N stations, registered, B, winner W, other valid B-W, fitted `alpha*(B-W)`, residual and positive residual, plus core/integration masks.
- `excess_summary.csv`: reference core selection, size, ratio alpha, core variation diagnostic, signed and positive conditional excess. **Not a verified fraud count.**
- `excess_sensitivity.csv`: conditional scenarios with 5, 7.5, 10 pp half-widths about modal turnout.
- `Excess_scenario_EN/SR.png`: red observed winner curve, blue reference-core-scaled other-valid-votes baseline (not Monte Carlo mean), dotted core boundaries and **grey polygons following the positive gap between the two curves beyond the upper reference limit, with crossings interpolated**. The subtitle displays rounded `positive_residual_votes` and its fraction of observed winner votes; detailed unrounded values remain in the CSV; the numerical result is a sum of bin residuals, not an integral of the plotted shaded area. Grey MC bands in the separate integer-percentage figures represent simulation envelopes, not excess votes. The figure footnote has exactly two lines to remain fully visible in exported PNGs.

Missing MC files for districts or municipalities are by default intentional (`MONTE_CARLO_LEVELS <- c('national')`). Missing plots in small areas are indicated by the manifest status, not silently replaced by national figures. Existing outputs can be overwritten on rerun; preserve published snapshots separately.
