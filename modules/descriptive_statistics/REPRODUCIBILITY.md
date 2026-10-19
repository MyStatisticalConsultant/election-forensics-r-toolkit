# Reproducibility protocol — v0.3.1

[Srpski](REPRODUCIBILITY_SER.md)

Reproducibility requires **the precise R source files, identical official raw input workbooks (or verified prepared workbook files), configuration, software environment and sample-definition rules**. A matching final table without retained provenance is not enough for an academic audit.

## Recommended record for each run

1. Official source URL, download date, original filename and source MD5 (recorded upstream); election type/year/template and administrative overrides if any.
2. Upstream preparation module code version/commit and `Main`, `Master`, `Options`, `Metadata`, `QC_summary`/`QC_records` sheets; document the 2017 registered-voter REVIEW item.
3. Descriptive module v0.3.1 code/commit; values of `INPUTS`, `OUTPUT_DIR`, `DISPLAY_DECIMALS`, `WRITE_CSV`, `WRITE_WORD`.
4. `sessionInfo()` for R version, operating system and package versions; optional `renv` lockfile may be added in a later release but is **not included or implemented here**.
5. Test console transcript from the seven commands in [VALIDATION.md](VALIDATION.md), with selected R-versus-independent numerical comparisons.
6. SHA-256 of each distributed output file, if publishing snapshots, and a description of rounding (CSV full precision; presentation rounding only).

## Input/output treatment

The module reads three prepared Excel sheets; **never edit generated worksheets manually and then describe them as unchanged source output**. Raw files, prepared workbooks and `descriptive_outputs/` are intentionally excluded from Git via `.gitignore`; readers regenerate them. If sharing large already-produced data, use a clearly versioned *release asset* after reviewing source terms and documenting checksums; do not commit it as ordinary code.

The descriptive module's area counts are computed on national classification thresholds; do not substitute local thresholds when reproducing. `All` is QC-accepted, not unfiltered Master. Word shows rounded values; use CSV or R objects for exact comparisons. Re-run all tests when R/packages, input file schemas or sorting rules change.

## Future sources

The preparation module's positional templates may interpret an added RZS administrative field as an extra electoral option. Before using new years or local-election data, implement and test a heading/role-based, versioned source schema; see [SCHEMA_EVOLUTION.md](../rzs_data_preparation/SCHEMA_EVOLUTION.md).
