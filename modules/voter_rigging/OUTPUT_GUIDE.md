# Numerical outputs and interpretation — voter_rigging

[Serbian](OUTPUT_GUIDE_SER.md) · [README](README.md) · [Methodology](METHODOLOGY.md)

All numeric calculations are exported as ordinary UTF-8 CSV files under the local (Git-ignored) directory `voter_rigging_outputs/`. Nothing is appended to or changed in the source RZS Excel files.

- **run_configuration.csv:** selected worksheet and methodological constants. The reference field is intentionally `UNAVAILABLE` for the international cross-election test.
- **export_manifest.csv:** election, definition, geography, input row count, standardised/ellipse sample sizes, number of usable p thresholds, and number of exported figures; `SKIP_D` means no eligible D thresholds.
- **station_level_qc.csv:** `E,B,C,W`, elected winner field, turnout, winner share, `base_ok`, neighbourhood peer means (`peer_mean_t`,`peer_mean_v`), peer standard deviations (`peer_sd_t`,`peer_sd_v`), `z_t`,`z_v`, number of peers, neighbourhood size, `mahalanobis2`, 95% ellipse inclusion, and `qc_reason`. **Reasons are sampling/QC diagnostics, not allegations.**
- **quality_summary.csv:** raw and eligible counts, number of E<100 stations included, number standardized/retained after ellipse, number of geographic neighbourhoods, and whether the basic national sample-size conditions in the supplement are met. These checks alone never confer inferential validity.
- **ellipse_parameters.csv:** sample mean of Z coordinates, variance/covariance components and `chi_square_cutoff`.
- **D_by_size_threshold.csv:** rows for all `p=0.5,...,90`, cutoff E value, small/large sample sizes, medians (`med_small_t`, `med_small_v`, `med_large_t`, `med_large_v`), axis shifts `dx`,`dy`, raw `D`, and status. `delta_reference=NA` and `reference_status=NOT_AVAILABLE` expressly indicate that no international calibration was performed.
- **cumulative_vote_share.csv:** decreasing-electorate `rank`, original `station_key`, electorate and cumulative sums of registered, valid and winner votes, with vote-weighted `cumulative_winner_share`.
- **permutation_summary.csv / permutation_draws.csv:** optional supplementary null distances and empirical tail probabilities. Always interpret as exploratory conditional diagnostics, **not** the source paper's modified Thompson-tau / international calibration.

**Plots:** `Figure4A_D` shows descriptive distance **D(p)** and no accepted/rejected region. `Figure4B_cumulative` shows winner vote share accumulated across decreasing station sizes. `Figure4_style` combines those two descriptions; the suffix `EN`/`SR` selects the language. National cross-election figures provide side-by-side descriptive overlays, not the 21-election statistical reference analysis in the article.

If a unit has too few valid stations or fewer than ten in either size group, the corresponding D remains missing with `INSUFFICIENT_GROUP`. Never interpret missing distance as zero. Geographic standardisation occurs at election-wide municipal level, and the ellipse is fitted election-wide before district/municipality subsets are selected.

**Figure labels and A/B interpretation (v0.1.1):** Figure 4A displays `Effect size, D(p)` with an italic `p`; `δ(p)` cannot be shown without a validated international reference. The Figure 4B horizontal dashed line denotes 50%. Its curves depend on cumulative vote counts only and are identical under A (`B/E`) and B (`C/E`). In `Figure4_style_comparison_<A/B>_<language>.png`, **only Figure 4A is sensitive to the A/B turnout definition**. The labels of elections have spaces instead of underscores and wrap to additional legend rows after three entries. File naming remains unchanged for compatibility.
