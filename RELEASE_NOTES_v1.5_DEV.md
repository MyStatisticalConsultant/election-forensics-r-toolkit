# Election Forensics R Toolkit v1.5.1-dev

The first module (`rzs_data_preparation`) is unchanged at the calculation/code level from the previously validated release. The new `descriptive_statistics` module is **v0.2.1 development** and extends the previously locally tested v0.1.0 engine.

What's new: Unicode-friendly CSV export (UTF-8 BOM), national tables, QC-approved `<100` stations, two report tables for national/district/municipality levels, 14 district/municipality ecological correlation matrices per election (Pearson r, nominal 5% *, p/N/BH q), optional Word document generation and export-validation tests. See `modules/descriptive_statistics/README.md` and Serbian version.

**Test status:** earlier v0.1.0 R tests passed in user RStudio. v0.2.1 R execution tests, Word layout and new output reconciliation must be run in user RStudio before production publication. No actual original data were modified. The 2017 presidential registered-electorate discrepancy documented upstream remains.

**GitHub publishing:** only scripts/docs/fixtures/reference totals are in this ZIP. `raw_data`, `RZS_prepared`, generated descriptive outputs and auto-generated validation directories remain excluded by `.gitignore`.

**Source format limitations:** future RZS-added administrative columns currently cannot be safely handled by the positional import scheme. See `modules/rzs_data_preparation/SCHEMA_EVOLUTION.md`.


## v1.5.1-dev correlation regression fix

Fixed empty-group correlation details and added extended synthetic regression checks. No source workbook or RZS data-preparation changes. Run the extended synthetic/integration/export tests locally before publishing as validated.
