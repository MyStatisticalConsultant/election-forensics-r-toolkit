# Testing and validation boundary

**v0.1.4 release evidence (23 October 2026):** The researcher reports that generated images for zero, singleton and multi-station groups meet expectations. The complete tests listed below have **not been independently executed in this packaging environment**; obtain and retain the six-check RStudio log (plus the generator command) before claiming a fully validated release. Earlier *-dev notes below are historical.


[Srpski (latinica)](VALIDATION_SER.md)

**Status v0.1.3.3-dev: plotting patch requires new RStudio tests and inspection.** The user reported generating graphics with the preceding version; the validation of `RZS_data_preparation.R` and `Descriptive_statistics.R` does not automatically validate these cumulative-curve implementations. The source script's syntax and the ZIP archive can be reviewed outside R, but a true R parser/execution plus real-data tests and figure inspection are necessary.

Run **from the module directory**:

```r
source("tests/run_tests.R")
source("tests/test_graphics_layout.R")
source("tests/test_single_station_plots.R")
source("tests/test_zero_station_groups.R")
source("tests/integration_real_data.R")
source("Klimek.R")
source("tests/check_exports.R")
```

The first suite checks syntax and synthetic edge cases, stable turnout ties, both normalisations, group partitions, empty inputs, Unicode and optional tail summaries. The second reads all three local prepared workbooks and verifies the `Main` group counts (8,023 / 7,787 / 7,787), group/electorate partition identities, valid-ballot conservation and final curve endpoints for **all electoral options**. The runner generates outputs. The final script checks existence of the output contract, group counts, per-option endpoints and graph formats. None proves the accuracy of an unvalidated future RZS schema.

Beyond these automated checks, inspect an English and a Serbian combined/faceted chart at both normalisations; verify candidate/list translations; confirm national curve endpoints numerically against sample-filtered vote and valid-ballot sums; check special administrative stations and the `LT100` subset; record `sessionInfo()` and the input workbook MD5. If enabled, review each bloc assignment before any interpretation of T90/T95. Plot shapes and descriptive margins do not have inferential significance assigned by this module.

For academic publication, preserve the Git commit, configuration, input MD5 and independent checks; document any changes to source-format maps, inclusion rules or official records.

**Visual regression review (v0.1.3.1):** check that (a) a B graph's main title has no option name, while its subtitle contains the **full** EN/SR option name, (b) `combined_standard` has no JHK curve, (c) `combined_jhk` has only JHK curves, (d) `faceted` has two panels (standard/JHK), and (e) A plots with three or more options have legends on two rows with no cropped names. Confirm no old `B_*_combined.png`/PDF survives in the inspected output folder. This patch changes **no numerical calculations**, but those visual checks must still be performed before release.


**v0.1.3.2-dev hotfix:** `tests/test_graphics_layout.R` now uses the current six-argument `b_titles()` signature; regression cases cover SR/EN national and district titles. Unknown election types produce an explicit error. A-facet subtitles remain separate from bold main titles. The cumulative calculations are unchanged.



**v0.1.3.2-dev special-category verification:** `tests/test_graphics_layout.R` also checks code-aware SR/EN titles for Overseas (`33`), Prisons (`55`), an ordinary district and Kosovo-associated codes (`25`–`29`). Run the full five-command sequence again and, if your inputs contain these reporting categories, inspect one selected-area A and B figure in each language. Do not claim RStudio runtime validation until these tests pass. No numerical computations were changed.


### v0.1.3.3 singleton regression test

Run `source("tests/test_single_station_plots.R")` to check that a one-station group is plotted as one point without a false line or repeated `geom_line()` warning. This plot-level test does not replace the existing numeric and integration tests. RStudio execution and visual review are required before marking this development release validated.


### v0.1.3.4 empty-group validation

`tests/test_zero_station_groups.R` uses synthetic data to check 0/1/2-station behaviour, inclusion of zero-station rows in full district/municipality grids, `Stations=0` and undefined percentage `NA`, identity of retained nonempty records, and area-scoped stale-image cleanup. `tests/check_exports.R` also checks that each territorial area has eight groups for each option and that empty-row percentages round-trip as missing. These tests must be run locally; release is not validated merely because the ZIP was built.
