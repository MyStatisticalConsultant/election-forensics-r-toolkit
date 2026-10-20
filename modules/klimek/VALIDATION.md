# Testing and validation boundary

[Srpski (latinica)](VALIDATION_SER.md)

**Status v0.1.0-dev: NOT YET validated through a live local R run.** This module is new; the validation of `RZS_data_preparation.R` and `Descriptive_statistics.R` does not automatically validate these cumulative-curve implementations. The source script's syntax and the ZIP archive can be reviewed outside R, but a true R parser/execution plus real-data tests and figure inspection are necessary.

Run **from the module directory**:

```r
source("tests/run_tests.R")
source("tests/integration_real_data.R")
source("Klimek.R")
source("tests/check_exports.R")
```

The first suite checks syntax and synthetic edge cases, stable turnout ties, both normalisations, group partitions, empty inputs, Unicode and optional tail summaries. The second reads all three local prepared workbooks and verifies the `Main` group counts (8,023 / 7,787 / 7,787), group/electorate partition identities, valid-ballot conservation and final curve endpoints for **all electoral options**. The runner generates outputs. The final script checks existence of the output contract, group counts, per-option endpoints and graph formats. None proves the accuracy of an unvalidated future RZS schema.

Beyond these automated checks, inspect an English and a Serbian combined/faceted chart at both normalisations; verify candidate/list translations; confirm national curve endpoints numerically against sample-filtered vote and valid-ballot sums; check special administrative stations and the `LT100` subset; record `sessionInfo()` and the input workbook MD5. If enabled, review each bloc assignment before any interpretation of T90/T95. Plot shapes and descriptive margins do not have inferential significance assigned by this module.

For academic publication, preserve the Git commit, configuration, input MD5 and independent checks; document any changes to source-format maps, inclusion rules or official records.
