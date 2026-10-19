# Data dictionary and statistical measures — v0.3.1

[Srpski](DATA_DICTIONARY_SER.md) · [Detailed Word explanation](docs/publication/VARIABLES_EN.docx)

**Scope:** columns of the descriptive outputs; the full canonical input dictionary is maintained in the [RZS preparation module](../rzs_data_preparation/DATA_DICTIONARY.md). Integer counts are displayed without decimal places. Numeric ratios are expressed as **percent, 0–100**, not proportions, unless explicitly stated.

## Identity and counts

| Variable | Definition |
|---|---|
| `Election_type`, `Year`, `Level` | Presidential/parliamentary, election year; `National`, `District` or `Municipality` |
| `Area_key` | National `RS`, RZS district code, or `district_code|municipality_code`; this avoids collisions |
| `Area_name` | Corresponding source area name, including special administrative categories when present |
| `Classification`, `Size_group` | Sample-definition method and one of the eight reporting labels; groups overlap across methods |
| `Polling_stations` | Number of QC-accepted stations contributing to that area/group |
| `Registered` | Sum of E (registered voters) |
| `Attendance` | Sum of A (official attendance/election participation measure) |
| `Ballots_cast` | Sum of C (ballots cast/inside boxes) |
| `Valid` / `Invalid` | Sums of B/I, satisfying C = B + I |
| `Winner_votes`, `Runnerup_votes` | Votes for the **nationally** highest- and second-highest-ranked options (fixed across all areas) |
| `Local_leader`, `Local_leader_votes`, `Local_second_votes` | Highest/second-highest option in the specified area and group; may differ from national ordering |

## Rates and concentration

| Variable | Computation |
|---|---|
| `Turnout_pct` | `100 × Ballots_cast / Registered` |
| `Attendance_pct` | `100 × Attendance / Registered` |
| `Valid_per_registered_pct` | `100 × Valid / Registered` |
| `Invalid_per_cast_pct` | `100 × Invalid / Ballots_cast` |
| `Invalid_per_registered_pct` | `100 × Invalid / Registered` |
| `Winner_per_valid_pct`, `Runnerup_per_valid_pct` | `100 × nationally first/second option votes / Valid` |
| `Winner_per_registered_pct` | `100 × nationally first option votes / Registered` |
| `Local_margin_pct` | `100 × (local top option votes − local second option votes) / Valid` |
| `Effective_number_options` | `1 / Σ (option_votes/Valid)^2`; undefined if Valid=0 |
| `Share_valid_pct`, `Share_registered_pct` | For each row of `*_options.csv`, `100 × Votes/Valid` and `100 × Votes/Registered` |

Division by zero returns missing/undefined, never an invented zero share. For dummy option shares 50%, 30%, 20%, the effective number of options is 2.63: concentration equivalent to roughly 2.63 equal-share options, **not** a probability or fraud score.

## Polling-station distribution statistics

The older core summary retains `Mean_E`, `Median_E`, `SD_E`, `Min_E`, `Max_E`, `N_turnout`, `Mean_turnout_pct`, `Median_turnout_pct`, `SD_turnout_pct`, `P20_turnout_pct`, `P80_turnout_pct`, `N_winner_share`, `Mean_winner_share_pct`, `Median_winner_share_pct`, `SD_winner_share_pct`, and analogous invalid-share fields. The extended version also includes these **prefix families**:

- `Electorate_*`: distribution of registered voters `E` across stations.
- `Turnout_*`: distribution of station `100×C/E`.
- `Winner_share_*`: distribution of nationally leading option `100×Winner_votes/B`, excluding undefined B=0.
- `Invalid_share_*`: distribution of station `100×I/C`, excluding undefined C=0.

Each family expands to `_N`, `_Mean`, `_Median`, `_SD`, `_Q1`, `_Q3`, `_IQR`, `_P10`, `_P90`, `_Outlier_count`, `_Outlier_pct`. `_SD` is sample standard deviation; `_IQR = Q3−Q1`; `_Outlier_count` counts observations outside Tukey `[Q1−1.5 IQR, Q3+1.5 IQR]`; `_Outlier_pct = 100 × outliers/N`. **Example:** `Turnout_Median=57.20`, `Turnout_IQR=12.40` means 50% of station turnout values fall within a middle range 12.40 percentage points wide; it does not say 50% are between 57.20±6.20.

`Mean_ballots_cast`, `SD_ballots_cast`, `Mean_valid`, `SD_valid`, `Mean_invalid`, `SD_invalid` are unweighted station-level moments of ballot counts.

## Within-area turnout–vote-share association

`Joint_N` = count of stations having **both** turnout and winner share; `Joint_Pearson_r`, `Joint_Pearson_p`, `Joint_Spearman_rho`, `Joint_Spearman_p` are two-sided correlation coefficients and nominal p-values **across stations within that area/group**. `Joint_Pearson_BH_q`, `Joint_Spearman_BH_q` (where present) report adjusted q-values. These must not be confused with the district/municipality **aggregate** correlation matrices.

For `*_joint_turnout_winner_bins.csv`: `Level`, `Area_key`, `Size_group` describe the subset; `Turnout_bin`, `Winner_share_bin` give 10-percentage-point intervals; `Stations` counts observations within the bin; `N_complete` counts stations with both rates; `Share_in_area_group_pct = 100×Stations/N_complete`. A bin with 4 stations means **4 stations**, not 4 votes.

## Inferential outputs and correlation inventory

`group_significance_tests.csv`: `Outcome`, `Test` (`Size_Kruskal_Wallis` or `JHK_Wilcoxon`), `Level`, `Area_key`, `N_used`, `N_Small`, `N_Middle`, `N_Large`, group medians, test `Statistic`, two-sided `P_value`, `BH_q_value`, `Significant_nominal`, `Significant_BH`. `NA` means the test was not estimable; do not present it as p=0.

`correlation_overview.csv`: `Matrix` (`D_01`–`D_08`, `M_01`–`M_08`), `Level`, `Size_group`, `Areas` (number of aggregated area observations), `Variables` (number of numerical columns), `N_tested` (number of **variable pairs** with calculable p), `Significant_nominal` (pairs at p<0.05), `Significant_BH` (pairs at within-matrix q<0.05). **None of these counts is a count of anomalous or fraudulent polling stations.** Each pair's `R`, `P_value`, `N_pairs`, `BH_q_value` and `Significant_5pct` is in `correlation_pairs_p_q_n.csv`. See [CORRELATIONS.md](CORRELATIONS.md) and [JOURNAL_REPORTS.md](JOURNAL_REPORTS.md).

Further explanations and dummy interpretation examples are in the included four EN/SR `.docx` guides in `docs/publication/`.
