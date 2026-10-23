# Troubleshooting

[Srpski (latinica)](TROUBLESHOOTING_SER.md)

**Workbook not found.** Open RStudio in the `modules/klimek` directory (or use `setwd` to that directory), verify `INPUTS$prepared_file` and run the RZS preparation module first. Do not copy system-specific personal paths into the source code below EDITABLE.

**Required column missing / bad `Options`.** The input workbook is not the canonical RZS-prepared format or has been edited. Recreate it using a supported source schema; future RZS columns require a versioned schema update to the *preparation* module, not a guessed `_pct` import here.

**Serbian Š Đ Ž Č Ć are wrong.** Open generated CSV as UTF-8 with BOM; open XLSX natively; use a Unicode-capable `BASE_FONT_FAMILY` (on Windows, for example `Arial`) and inspect PNG and PDF separately. On systems without Cairo, PDF font support may differ.

**Graph has fewer than three options.** The selected group may be empty, have zero valid ballots, or an option may have zero votes under `option` normalisation. Inspect `tables/coverage.csv` and `tables/curve_endpoints.csv`. Check selected option fields exist in `Options.Votes_field`.

**X-axis values above 100.** Check source QC records. The script does not silently cap turnout; use `LIMIT_X_TO_100=TRUE` *only for visual zoom*, and disclose this decision.

**Too many graph files / slow run.** Set `GRAPH_LANGUAGES="EN"`, `CURVE_NORMALISATIONS="valid"`, `WRITE_FACETED=FALSE`, `SAVE_PDF=FALSE`, `SAVE_CURVE_POINTS=FALSE` and `OPTION_SELECTION_MODE="top_n"`. Numeric national/district/municipality aggregates for all options are still generated.

**T90/T95 error.** Define both non-overlapping blocs separately for each election, or set `ENABLE_BLOC_TAIL_METRICS=FALSE`. No inferential p-value is supplied.

When filing an issue, attach the precise R error, relevant EDITABLE values without private paths, `sessionInfo()`, source MD5, affected election/group and steps to reproduce.


### `subscript out of bounds` in `tests/test_graphics_layout.R`

The v0.1.3 script introduced a six-argument title function while the old test still called its earlier four-argument interface. This issue is fixed in the complete v0.1.4 module. If it reappears, ensure `Klimek.R` and all `tests/` files are from the same release, then rerun the tests. Do not change input workbooks.


### `geom_line(): Each group consists of only one observation`

Versions before v0.1.3.3 could repeat this warning for geographically selected, single-station size groups. This is not an execution failure. Version v0.1.3.3 shows the observation as a point and retains the numeric result. Run `source("tests/test_single_station_plots.R")` after upgrading.


### Why is an A figure missing for a selected district? (v0.1.3.4)

If that district has zero eligible stations for the requested group, this is expected: the console reports `zero-station group(s)` once for the area, and no line or dot is invented. The same area/group/option appears in district/municipality exports with `Stations=0` and percentages `NA`. Earlier A/B images for this area are removed before rendering; other districts are unaffected.
