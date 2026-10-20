# User guide — Klimek cumulative curves

[Srpski (latinica)](USER_GUIDE_SER.md)

## 1. What you need

Use R and optionally RStudio, with `readxl`, `openxlsx`, `ggplot2` and `readr`. Run `RZS_data_preparation.R` **only if the prepared workbooks do not yet exist or need regeneration**; otherwise reuse them without rerunning previous modules. The script expects canonical `Main`, `Master`, `Options` sheets and does **not** read unprepared RZS originals. Run from `modules/klimek` so that relative paths work. The `RZS_prepared` directory must exist in its sibling preparation module.

## 2. Editing boundaries and election choices

Edit values **above** `DO NOT CHANGE THE CODE BELOW THIS LINE`. Each `INPUTS` row contains `election_type`, `year`, and the workbook path. Keep the year/type combination unique (two 2022 elections are deliberately separate). You can analyse only one election by keeping only its row in all three vectors; add future rows only for a validated matching schema. `OUTPUT_DIR` determines where new files go. Old output filenames can be overwritten; original prepared input workbooks are not modified.

## 3. Language and full option names

Set `GRAPH_LANGUAGES <- "EN"`, `"SR"`, or `c("EN","SR")` for both in one run. `OPTION_LABELS_EN` and `OPTION_LABELS_SR` are named lists keyed by `election_type_year` and **exact** `Votes_field` codes from the `Options` worksheet. For example:

```r
OPTION_LABELS_EN <- list(
  presidential_2022 = c(Option_01_votes = "Full candidate name in English")
)
OPTION_LABELS_SR <- list(
  presidential_2022 = c(Option_01_votes = "Puno ime kandidata na srpskom")
)
```

Replace illustrative names with your actual candidates and lists after checking their `Options` dictionary; **Option_01 is source-order, not necessarily the winner**. Non-overridden names default to their RZS Serbian-Latin names (not auto-translated). `CUSTOM_MAIN_TITLE_EN/SR`, `CUSTOM_SUBTITLE_EN/SR`, `CUSTOM_X_LABEL_EN/SR`, and `CUSTOM_Y_VALID/OPTION_EN/SR` independently customise visible text. Serbian characters require a Unicode-capable system font; `BASE_FONT_FAMILY` can be set to a font available on your PC, for example `Arial` on Windows.

## 4. Selecting curves for graphs

`OPTION_SELECTION_MODE="top_n"` and `DISPLAY_TOP_N=3L` plots three highest **nationally ranked** options from `Options.Total_votes`. `"all"` plots all; `"selected"` plots `SELECT_OPTION_FIELDS`, e.g. `c("Option_01_votes","Option_04_votes")`. `OPTION_FIELDS_BY_ELECTION` can override the global option selection for individual workbooks. Every candidate/list still receives national curve calculations and numerical aggregate output. Plot selection is a readability setting, not filtering the election result.

Eight possible groups: `ALL`, `GE100`, `LT100`, `SMALL`, `MIDDLE`, `LARGE`, `JHK_SMALL`, `JHK_LARGE`. Their established classifications are supplied by RZS preparation. `ALL` is `Main` plus QC-accepted under-100 stations. `GE100` is exactly `Main`. `SMALL/MIDDLE/LARGE` partitions `GE100`; `JHK_SMALL/JHK_LARGE` is another partition of `GE100`. Do not treat the eight overlapping curves as independent evidence.

## 5. Understanding the two normalisations

In both types, polling stations are sorted by turnout `100*C/E` (with ties resolved by `Station_key`). The horizontal axis is **turnout**, not a percentage of stations or cumulative registered voters.

For option `j` at the kth ordered station, let `v_ij` denote option votes and `B_i` valid ballots. Set `V_j(k) = sum_{i<=k} v_ij`. `valid`: `y=100*V_j(k)/sum_i B_i`. Example: with 2,000 valid group ballots and 800 votes for an option, its curve ends at **40%**, indicating final valid-vote share. `option`: `y=100*V_j(k)/sum_i v_ij`; the same curve ends at **100%**, showing the *distribution of the option's own votes* across the turnout ordering. For zero total option votes the `option` ratio is undefined (`NA`), never set to zero.

Use `CURVE_NORMALISATIONS <- "both"` to generate both. Do not compare height across options in the `option` normalisation as though it represented electoral support; the denominators differ. Both modes use official **vote counts**, not rounded percentages.

## 6. Choose image families, colours and size

- `PLOT_FAMILY_A=TRUE`: one group, several chosen options. `PLOT_FAMILY_B=TRUE`: one option, several groups.
- `WRITE_COMBINED=TRUE`: one overlaid chart. `WRITE_FACETED=TRUE`: multipanel chart.
- `FACET_FREE_Y=FALSE`: comparable facet scales; change to `TRUE` for visibility with tiny lists, with the explicit caveat that panels then have different axes.
- `COLOR_SCHEME`: `"OkabeIto"`, `"Dark2"`, `"Viridis"` or `"Custom"`.
- `OPTION_COLORS <- c(Option_01_votes="#0072B2", Option_02_votes="#D55E00")` and `GROUP_COLORS <- c(ALL="#333333",GE100="#009E73")` override particular keys. HEX values must be six-digit `#RRGGBB`.
- `PLOT_WIDTH_IN`, `PLOT_HEIGHT_IN`, `PNG_DPI`, `BASE_FONT_SIZE`, `BASE_FONT_FAMILY`, `LINE_WIDTH`, `ADD_POINTS`, `POINT_SIZE`, `POINT_ALPHA`, `LEGEND_POSITION`, `FACET_COLUMNS`, `PLOT_THEME`, `SHOW_MAJOR_GRID`, `X_TICK_STEP`, `Y_TICK_STEP`, `X_LABEL_ANGLE` control presentation. `SAVE_PNG` and `SAVE_PDF` select formats.
- `LIMIT_X_TO_100=FALSE` preserves visibility of exceptional turnout readings above 100. Setting it TRUE only zooms the display; it never removes or repairs source counts.

For 19 parliamentary lists, prefer `top_n` and perhaps `WRITE_FACETED=TRUE`. Avoid printing all options in one overlaid plot unless the result is legible.

## 7. Geographical selection

Regardless of graph settings, `district.csv` and `municipality.csv` provide *all* areas, all groups and all options. Graphs default to `GEOGRAPHIC_PLOTS="national"`. For selected areas set `"selected"`, `SELECT_DISTRICT_CODES <- c("01")`, or `SELECT_MUNICIPALITY_KEYS <- c("01|001")` with actual codes copied from `tables/areas.csv`. Municipality keys always combine district and municipality, avoiding ambiguous names. No station-size thresholds are re-estimated locally.

## 8. Optional T90 and T95 comparison

Set `ENABLE_BLOC_TAIL_METRICS=TRUE` only when both blocs are substantively defined for **each** selected election. Example:

```r
BLOC_A_BY_ELECTION <- list(parliamentary_2022=c("Option_01_votes"))
BLOC_B_BY_ELECTION <- list(parliamentary_2022=c("Option_02_votes","Option_03_votes"))
TAIL_PERCENTILES <- c(0.90,0.95)
```

Those names are illustrative and do **not** classify actual parties. The lists must be disjoint. The turnout threshold is the 90th/95th percentile of stations in the currently analysed group; all ties at that threshold are included. `Mean_station_margin_pp` is the mean of station option-share differences (percentage points) among selected high-turnout stations. `Pooled_margin_pp` uses total bloc votes divided by total valid ballots in that tail. These differ because polling stations have different sizes. No p-value is assigned by the module; a statistically meaningful null requires a separate, defensible design.

## 9. Outputs and checks

`klimek_outputs/<election>/tables/` stores BOM-encoded CSV tables; summary XLSX files are next to that folder. `curves/national/` contains per-option/per-group cumulative points when `SAVE_CURVE_POINTS=TRUE`; selected extra-area curves appear under `curves/`. `figures/<language>/<normalisation>/<area>/` contains PNG/PDF plots. `tables/coverage.csv` must satisfy `ALL = GE100 + LT100`, `GE100 = SMALL + MIDDLE + LARGE`, and `GE100 = JHK_SMALL + JHK_LARGE` for station counts and registered voters. `tables/curve_endpoints.csv` gives final curve percentages for **all options**.

Run `source("tests/run_tests.R")`, `source("tests/integration_real_data.R")`, `source("Klimek.R")`, then `source("tests/check_exports.R")`. Review at least one bilingual overlay/facet and compare national option endpoints to the prepared `Options` totals restricted to the appropriate sample. See [VALIDATION.md](VALIDATION.md).

## 10. Interpretation

A curve rising steeply near very high turnout indicates that the option accumulated a relatively large share of its counted votes in those stations, under the chosen denominator; it is **not a direct estimate of fraud**. Plausible alternatives include stronghold geography, different electorate sizes, special voting categories, mobilisation, and composition. Follow up with spatial controls, observer reports, signed protocols and legally available audit material, not accusation from a curve alone.
