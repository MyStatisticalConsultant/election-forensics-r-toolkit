# Output guide — regression_analysis v0.1.8

Run from `modules/regression_analysis/`. All results are written to `regression_analysis_outputs/` (excluded by Git), using this structure:

```
regression_analysis_outputs/
  run_configuration.csv
  export_manifest.csv
  presidential_2017/
    selected_options.csv
    turnout_C_over_E/
      station_qc.csv
      national/national/
        group_sample_counts.csv
        lukinova_station_values.csv
        invalid_station_values.csv
        model_summary.csv
        model_coefficients.csv
        model_station_residuals.csv
        Regression_A_Size_EN.png (and _SR.png)
        Regression_A_Size_JHK_EN.png (and _SR.png)
        Regression_B1_Size_EN.png (and _SR.png)
        Regression_B1_Size_JHK_EN.png (and _SR.png)
        Regression_B2_Size_EN.png (and _SR.png)
        Regression_B2_Size_JHK_EN.png (and _SR.png)
    turnout_B_over_E/ ...
  presidential_2022/ ...
  parliamentary_2022/ ...
```

District and municipality outputs use `district/<code>/` and `municipality/<code>/` in place of `national/national/`. Area identifiers are retained in the CSV file, including for cases skipped due to insufficient sample size.

## Numerical files

**`run_configuration.csv`** records version, definitions, geographic levels, Size/JHK settings and diagnostics. **`export_manifest.csv`** lists each election, turnout definition, area, number of primary and under-100 stations, number of model attempts and PNG files.

**`selected_options.csv`** records the two selected `Option_NN_votes` fields, winner/runner-up roles, national aggregate counts, selection mode, and verified public-facing labels plus their `label_source` (`Options:<column>` or `OPTION_LABELS_OVERRIDE`). Selection happens nationally and remains unchanged in lower-area plots.

**`station_qc.csv`** records every original `Master` row with `E`, `B`, `C`, `W`, runner-up votes, classification fields, all derived percentages, invalid ballots and explicit eligibility status. `valid_counts = FALSE` rows must not enter regressions.

**`group_sample_counts.csv`** lists counts for `All_100plus`, `Under100`, `Size_Small`, `Size_Large`, `JHK_Small`, and `JHK_Large`. `Size` and JHK are separate, overlapping classification frameworks.

**`lukinova_station_values.csv`** exports turnout and winner/runner-up votes per registered elector, including rows later excluded from models. **`invalid_station_values.csv`** exports winner's valid-vote percentage, invalid count, invalid rate, turnout, and log electorate.

**`model_summary.csv`** has one row for every attempted fit, with columns: `model` (A, B1, B2, B1_Controlled, B2_Controlled, optional municipality FE), `role`, `group`, `status`, `n`, `r2`, `adj_r2`, `f_stat`, `f_df1`, `f_df2`, `f_p`, `sigma`, `bp_lm`, `bp_p`, `n_cook_gt_4_over_n`. Skips have transparent status; no fictitious estimates are inserted.

**`model_coefficients.csv`** has one row per estimable coefficient, with `estimate`, conventional `se_ols`, `t_ols`, `p_ols`, `ci95_low`, `ci95_high`, HC3 `se_hc3`, `t_hc3`, `p_hc3`, and HC3 confidence limits. Controlled regressions have rows for control variables and any municipality fixed effects. Model IDs link this file to `model_summary.csv` and residual outputs.

**`model_station_residuals.csv`** records each included station and model with `observed`, `fitted`, `residual`, `leverage`, and `cooks_distance`. These allow independent checks of influence, outliers and residual patterns. Group overlap can lead to repeated stations across models; this is expected.

## Figure families

**`Regression_A_...`** shows two different vote-to-electorate outcomes (winner and runner-up) against turnout with ordinary OLS fitted lines. **`Regression_B1_...`** uses the number of invalid ballots as x; **`Regression_B2_...`** uses invalid ballots as a percentage of ballots cast. Their y-axis is always the winner's percentage **of valid votes**. The `Size` family uses four facets (All, Small, Large, and E < 100 sensitivity). The `Size_JHK` family uses exactly three: All and JHK Small across the top, JHK Large centred beneath. Under-100 sensitivity remains available in the Size figures and CSV exports. Each figure is exported in English (`EN`) and Serbian Latin (`SR`).

The fitted lines correspond to the recorded **uncontrolled OLS model**. Controlled models are supplied in CSV only to avoid misrepresenting the multiple-regressor conditional relationship as a simple bivariate line. No figure is evidence of wrongdoing.

## Validation and interpretation

Execute tests in this order: `run_tests.R`, `test_graphics.R`, `integration_real_data.R`, main script, `check_exports.R`. The real-data test verifies field/row contracts; it does **not** independently reconcile aggregate official totals or establish any fraud conclusion. Inspect warnings/status for small geographic units and sensitivity to alternative turnout definitions and classification schemes.

JHK layouts (v0.1.8) use a 17.5 × 13-inch canvas, share the horizontal and vertical axis titles, and keep the footer note on a single line. Model A formulas are spaced using a common 0–100% vertical scale to prevent collisions in restricted-range size groups.
