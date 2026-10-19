# Data dictionary — canonical fields

This document lists core standardized fields. **The generated `Source_dictionary` and `Derived_dictionary` Excel sheets are the run-specific mapping/reference; they may include fields not enumerated here.** Original RZS columns are retained as `V1`, `V2`, ... and original Cyrillic headings are mapped by `Source_dictionary`.

| Field | Meaning / calculation | Notes |
|---|---|---|
| `Year` | Election year | Integer |
| `Source_row` | Original Excel row | Traceability |
| `District_code`, `Municipality_code`, `PS_number` | Station identifiers | Keep textual codes / leading zeros |
| `Station_key` | `Year|District_code|Municipality_code|PS_number` | Within-source composite identifier |
| `District`, `Municipality`, `Station_name`, `Station_address` | Label fields | Transliterated for convenience; optional by template |
| `E` | Registered voters | Denominator |
| `A` | Reported attendees | Not primary turnout numerator |
| `C` | Cast ballots | Primary turnout numerator |
| `I` | Invalid ballots | Typically `C−B` if reconciled |
| `B` | Valid ballots | Candidate shares denominator |
| `Ballots_received`, `Unused_ballots` | Source ballot supplies | Not present in 2022-style schema |
| `Option_XX_votes` | Votes for candidate number XX | Candidate names in `Options` sheet |
| `Option_XX_pct` | `100 * Option_XX_votes / B` | Missing if `B=0` |
| `Options_sum` | Sum of all candidate votes | Missing if any candidate result missing |
| `Winner_name`, `Second_name` | Top-two candidates by total reported votes | Election-specific |
| `Winner_votes`, `Second_votes` | Counts for top-two | From mapped candidate columns |
| `Turnout` | `100*C/E` | Percent, not proportion |
| `Attendance_pct` | `100*A/E` | Percent |
| `Valid_participation_pct` | `100*B/E` | Percent |
| `Invalid_pct_cast` | `100*I/C` | Percent |
| `Invalid_pct_registered` | `100*I/E` | Percent |
| `Winner_pct`, `Second_pct` | `100*votes/B` | Missing if `B=0` |
| `Winner_per_registered_pct`, `Second_per_registered_pct` | `100*votes/E` | Percent |
| `Log_winner_per_registered` | `log(Winner_votes/E)` | Requires numerator >0 |
| `Size` | Small/Middle/Large | Cumulative electorate tails |
| `Size_JHK` | Small/Large | 20th percentile of station-size threshold |
| `Special_category` | Administrative subgroup | Overseas, Prison, Kosovo-associated, Ordinary |
| `Administrative_status`, `Administrative_comment` | Curated decision and explanation | Overrides optional |
| `No_ballots_received`, `Zero_cast`, `Zero_valid` | Special zero conditions | Distinct concepts |
| `Missing_core`, `Negative_count`, `Noninteger_count` | Numeric QC | Logical |
| `Ballot_identity_violation`, `Option_identity_violation` | Count reconciliation failures | Logical |
| `Duplicate_station_id` | Duplicate composite keys | Logical |
| `Attendance_cast_difference` | `A−C` signed | Not automatic exclusion |
| `Eligible_primary` | Default inclusion | `Main` subset |
| `Eligible_*` | Method-oriented availability flags | Confirm each model's assumptions |
| `Exclusion_reason`, `Audit_action` | Transparent record disposition | Text |

`NA` represents undefined/missing values, **not zero**. `Source_dictionary` contains original source-column heading mappings; `Options` maps `Option_XX_votes` to Serbian-Latin names and election-wide totals. Exported percentages are numeric values on a **0–100** scale.


## Election-type coverage and v1.2 data contract

This module processes Serbian **presidential** candidates and **parliamentary** electoral lists as neutral vote **options**. Set `election_type` to `presidential` or `parliamentary`; combined input rows may share a year, but must not share the same type/year pair. The 2022 parliamentary source is [`G202219002.xlsx`](https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx); save it as `raw_data/Parliament 2022 ~ G202219002.xlsx`. The other configured inputs are the 2017 and 2022 presidential results.

**Validation limitation:** the structure of the 2022 parliamentary XLSX could not be directly inspected in this preparation environment. It is provisionally assigned the `2022` column template; **validate its headers, row totals, option columns and QC results** against the official workbook before analytical use. The script does not support local-election source files without a separately validated schema and (where applicable) constituency-specific winner/list logic.

For both supported types, `Main` remains the default analysis worksheet and `Master` the complete audit-preserving dataset. `Option_01_votes`, `Option_01_pct`, etc., have type-neutral meanings; `Options` maps each option to its source heading. `Winner_*` / `Second_*` are the top two **national vote totals** in the input, not automatically the winner of every constituency or an allocation of seats. No parliamentary seat allocation is performed. Election identifiers now include `Election_type`, protecting against same-year collisions. Outputs are `presidential_2017_RZS_prepared.xlsx`, `presidential_2022_RZS_prepared.xlsx` and `parliamentary_2022_RZS_prepared.xlsx`.

Existing downstream scripts that expected `Candidate_*`, `Candidates`, a year-only station key, or `P2022_RZS_prepared.xlsx` must be adapted to the v1.2 contract.
