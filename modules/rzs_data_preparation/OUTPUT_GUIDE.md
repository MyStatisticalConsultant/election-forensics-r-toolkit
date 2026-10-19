# Output guide: what to use and when

## First-choice analysis input: `Main`

Run the preparation script locally. Open `RZS_prepared/presidential_2017_RZS_prepared.xlsx` or `RZS_prepared/presidential_2022_RZS_prepared.xlsx`. **For the next forensic module, import the `Main` worksheet**. It contains all rows where `Eligible_primary` is true, with harmonized fields and station-level method flags. For instance:

```r
x <- readxl::read_excel("RZS_prepared/presidential_2022_RZS_prepared.xlsx", sheet="Main")
fingerprints <- x[!is.na(x$Eligible_fingerprint) & x$Eligible_fingerprint, ]
```

This is illustrative selection logic, **not** an implemented forensic test. The supplied `Main` is not necessarily an appropriate sample for all models.

## Audit: `Master`, `Excluded`, QC sheets

`Master` is the **complete prepared dataset** and must be retained for transparent reporting. It includes both eligible and excluded stations, exclusion reasons and QC flags. Consult `Excluded`, `QC_records`, `QC_summary` and `Zero_cases` before drawing conclusions. `Raw_RZS` preserves imported source text. `Source_row`, dictionaries and `Metadata` enable cross-checks against RZS data.

## Other worksheets

`Gap_distribution`, `Gap_direction`, `Size_summary`, `Size_thresholds`, `Options`, `Source_dictionary`, `Derived_dictionary` and `Metadata` document reconciliation, grouping, identities and source provenance. The two station-size definitions must **not** be interchanged.

## Files per run

One `P<YEAR>_RZS_prepared.xlsx` workbook per input election and one `cross_election_QC_summary.csv`. The CSV combines QC counts **only**, not polling-station records. Output files are regenerated/overwritten at the same paths on subsequent runs.

## Intended downstream reporting standard

Every future forensic method should identify source year/version, `Main` or alternative audit-derived sample, exclusions, method parameters, observed statistic, assumptions, uncertainty, sensitivity analysis and the limitation that a diagnostic signal is not proof of wrongdoing. Present understandable captions for the general public and supply reproducible tabular results for researchers.


## Election-type coverage and v1.2 data contract

This module processes Serbian **presidential** candidates and **parliamentary** electoral lists as neutral vote **options**. Set `election_type` to `presidential` or `parliamentary`; combined input rows may share a year, but must not share the same type/year pair. The 2022 parliamentary source is [`G202219002.xlsx`](https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx); save it as `raw_data/Parliament 2022 ~ G202219002.xlsx`. The other configured inputs are the 2017 and 2022 presidential results.

**Validation limitation:** the structure of the 2022 parliamentary XLSX could not be directly inspected in this preparation environment. It is provisionally assigned the `2022` column template; **validate its headers, row totals, option columns and QC results** against the official workbook before analytical use. The script does not support local-election source files without a separately validated schema and (where applicable) constituency-specific winner/list logic.

For both supported types, `Main` remains the default analysis worksheet and `Master` the complete audit-preserving dataset. `Option_01_votes`, `Option_01_pct`, etc., have type-neutral meanings; `Options` maps each option to its source heading. `Winner_*` / `Second_*` are the top two **national vote totals** in the input, not automatically the winner of every constituency or an allocation of seats. No parliamentary seat allocation is performed. Election identifiers now include `Election_type`, protecting against same-year collisions. Outputs are `presidential_2017_RZS_prepared.xlsx`, `presidential_2022_RZS_prepared.xlsx` and `parliamentary_2022_RZS_prepared.xlsx`.

Existing downstream scripts that expected `Candidate_*`, `Candidates`, a year-only station key, or `P2022_RZS_prepared.xlsx` must be adapted to the v1.2 contract.
