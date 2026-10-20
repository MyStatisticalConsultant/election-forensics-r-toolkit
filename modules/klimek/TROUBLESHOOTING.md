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
