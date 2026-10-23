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

### B-graph titles, split overlays and panel layout (v0.1.1)

The previous version put the full candidate/list name into the B graph's main title, which could be cropped. The new **main title** contains only the election and area; the **subtitle** always contains `Electoral option: <full label>`. `OPTION_LABELS_EN/SR` remains the place to supply translated full names; `CUSTOM_SUBTITLE_EN/SR`, if non-empty, is appended after that name. `TITLE_WRAP_CHARS` and `SUBTITLE_WRAP_CHARS` control line wrapping; the original labels and vote data are unchanged.

B **combined** charts are split into two files when `B_SPLIT_COMBINED <- TRUE` (the default): `B_Option_XX_votes_combined_standard.png` for `ALL, GE100, LT100, SMALL, MIDDLE, LARGE` (only those selected in `PLOT_GROUPS`), and `B_Option_XX_votes_combined_jhk.png` for `JHK_SMALL, JHK_LARGE`. The previous eight-line `B_Option_XX_votes_combined.png` is deleted on rerun to avoid confusion. With `WRITE_FACETED <- TRUE` and `B_TWO_PANEL_FACET <- TRUE` (both defaults), `B_Option_XX_votes_faceted.png` is **one figure with two vertically stacked panels**, comparing standard and JHK curves using the same axes. `B_PANEL_COLUMNS=1L` and `B_PANEL_HEIGHT_MULTIPLIER=1.45` provide extra vertical room. To produce *only* the two-panel version, set `B_SPLIT_COMBINED <- FALSE` while keeping `WRITE_FACETED <- TRUE`. Set `B_TWO_PANEL_FACET <- FALSE` to omit it. PNG and PDF follow the same filename convention.

For A graphs with **three or more** candidate/list curves, `A_LEGEND_ROWS_3PLUS=2L` explicitly puts the legend on **two rows**. One or two curves use one row. Complete long names wrap automatically after roughly `LEGEND_WRAP_CHARS=31L` characters; `LEGEND_FONT_SIZE=9.5` controls legend typography. For B graphs with more than two visible groups, `B_LEGEND_ROWS_3PLUS=2L` also applies. Choose a Unicode-capable font and, if necessary, increase `PLOT_WIDTH_IN`, `PLOT_HEIGHT_IN`, or shorten the *display translation* without changing the underlying `Votes_field`.

This is a **presentation-only patch**: it does not change cumulative sums, turnout definitions, polling-station group membership, both normalisations, T90/T95 or numerical CSV/XLSX values. You only need to rerun `Klimek.R`, not upstream modules. After updating, execute `source("tests/test_graphics_layout.R")` and visually inspect a Serbian parliamentary B graph and an A graph with three options.

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


### Graph-title and axis refinements in v0.1.2-dev

A-family figures place the full polling-station group name on the second title line. Both A and B families use 10-percentage-point spacing on the vertical axis, and B-family figures now display all expected percentage labels.


### Title localization refinements in v0.1.3-dev

Main chart titles now show reader-friendly election and area labels (for example, "parliamentary 2022 Serbia"). In A-family figures, the polling-station group appears on a separate subtitle-like line in a smaller, non-bold style. The same logic applies to selected district and municipality figures.



### Special RZS reporting categories (v0.1.3.2-dev)

District titles are **code-aware**. When creating selected district plots (`GEOGRAPHIC_PLOTS = "selected"`), use official `SELECT_DISTRICT_CODES` values. Code `33` is shown as **Overseas** (SR: **Inostranstvo**); code `55` is **Prisons** (SR: **Zavodi za izvršenje krivičnih sankcija**). Neither gets a fictitious `district`/`okrug` suffix. The source category remains unchanged in all numerical tables. For codes `25`–`29` (Kosovo-associated in the preparation module), graphs preserve the official RZS reporting label and only translate an **existing** district suffix. Those categories must not be interpreted as evidence that a polling station is physically inside the named territory. Ordinary districts continue to use localized `district`/`okrug` labels. The same names appear in A and B graphs and in either graph language.


### Single-station groups (v0.1.3.3-dev)

For selected district/municipality plots, a polling-station size group can contain exactly one eligible station. An example is the `Large` group for Overseas (district code 33) in the 2022 elections. Such an observation is shown as an isolated point (controlled by `SINGLE_POINT_SIZE`) because a cumulative line requires at least two observations. It remains part of all numeric summaries. This is not evidence of fraud or a script failure. One informational line per affected area replaces the repeated `geom_line()` warnings.


### Zero, one, and multiple polling stations (v0.1.4)

**0 stations:** The group is included in district/municipality summaries with `Stations=0`, count totals equal to zero, and undefined percentages marked `NA`. No A figure is drawn for it; B figures omit that group, and an area with no drawable data produces no new figures. An area-scoped cleanup removes earlier Klimek A/B PNG/PDF before redrawing so stale figures cannot remain. The console gives a single consolidated `zero-station group(s)` message per area. **1 station:** point only. **2+ stations:** cumulative line. For a release check, run `source("tests/test_zero_station_groups.R")` from `modules/klimek/`, followed by the existing tests and export verification. This does not require reprocessing the RZS workbooks.
