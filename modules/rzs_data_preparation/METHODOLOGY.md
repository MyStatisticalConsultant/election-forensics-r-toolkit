# Methodology — RZS Presidential and Parliamentary Data Preparation

## Research purpose and limits

This module makes election-station records suitable for reproducible exploratory forensic work. It does **not** test the null hypothesis of any electoral-integrity model, label fraud, or alter official votes. Inferential validity must be evaluated separately for every subsequent module.

## Source, schema and traceability

The code recognizes only `2017` and `2022` input schemas via positional columns. It reads the first Excel sheet as **text**, with header row 5 for 2017 and row 1 for 2022, and skips observations lacking complete district, municipality and polling-station identifiers. Raw imported columns are retained as `V1...Vn`; `Source_row` points to the Excel row. `Station_key` concatenates year, district code, municipality code and polling-station number. Those keys identify records within the covered RZS layouts, not a universal longitudinal station identifier.

## Canonical variables

`E`: registered electorate; `A`: reported attendance; `C`: cast ballots (ballots in boxes); `I`: invalid ballots; `B`: valid ballots. `Ballots_received` and `Unused_ballots` exist in the 2017 input schema, but are undefined for 2022-style input. Candidate counts are mapped by ordinal candidate column and a candidate dictionary. National winner and second place are based on sums of supplied candidate columns.

Percentages are `Turnout=100*C/E`, `Attendance_pct=100*A/E`, `Valid_participation_pct=100*B/E`, `Winner_pct=100*Winner_votes/B`, `Invalid_pct_cast=100*I/C`, `Winner_per_registered_pct=100*Winner_votes/E`; positive ratio logarithms use `log(Winner_votes/E)`. Invalid or zero denominators generate `NA`, never automatic zeros.

## Checks, flags and analytic eligibility

Checks include missing core fields, negative or fractional counts, duplicated station keys, violations of `C = I + B` and `sum(candidate votes) = B`, `C>E`, `A>E`, and (when supplied) `C>Ballots_received`. An `A−C` discrepancy is retained and summarized, but *not itself* a blanket eligibility exclusion. Records remain in `Master`. `Under_100` marks `E<MIN_ELECTORATE`; `Admin_no_ballots` distinguishes documented non-receipt from mere zero cast votes where receipt information is missing. `Eligible_primary` excludes threshold failures, administrative invalidity, no-ballot-receipt decisions and numeric/identity failures; `Main` filters by this flag. `Exclusion_reason` lists every applicable reason.

Optional administrative statuses from the overrides CSV are evidence-based, manually curated decisions. `verified_complete` can counter an automatic no-ballots-received flag without modifying count values. The override loader uses character columns to preserve leading zeroes; source and override key formatting must still be matched exactly.

## Size groups: two different definitions

`Size` uses **bottom and top shares of total registered electorate**. Unique polling-station electorate sizes are ordered from small and large, cumulatively weighted by `E`, and a nearest boundary to 20% of electorate is chosen for each tail. **All tied boundary-size stations are included**, and ties between equally close candidate boundaries prefer the lower cumulative electorate. Other eligible stations are `Middle`. This is a design stratification, not a statistical hypothesis test.

`Size_JHK` instead uses the 20th percentile of station electorate size (`stats::quantile(..., type=7)`). Eligible stations with `E<q` are `Small`, **all others** are the complementary `Large` group. This grouping supports, but does not itself implement, a JHK-style comparison. No geographic standardization, bootstrap/significance test or effect-size inference is performed.

## Additional analytical eligibility flags

The master table carries `Eligible_turnout`, `Eligible_cumulative`, `Eligible_fingerprint`, `Eligible_contour`, `Eligible_regression`, `Eligible_normality`, and `Eligible_invalid_share`, derived from available denominators and relevant variables. A downstream method must re-check all relevant assumptions, including needed geography, support, spatial dependence, model scope and missingness.

## Exception handling and preservation

A zero-valid-ballot station may remain in `Main` if otherwise eligible: winner shares are `NA`, not zero. Special district codes are classified as Overseas (`33`), Prison (`55`), Kosovo-associated (`25`–`29`) and Ordinary; these are RZS administrative classifications, not claims about a physical polling-place location. The workbook contains source, master, main, excluded, QC, size grouping, candidate map, metadata, and dictionaries. The original RZS XLSX is never written to.

## Interpretation

An anomaly is a cue for further examination, not proof of wrongdoing. Administrative context, documentation, laws, alternative measurement conventions, multiplicity, selection and geographic variation all matter. Publication-ready conclusions must use model-specific validation, transparent uncertainty and independent checks where feasible.

## Further reading

The source code contains the cited JHK paper DOI `10.1126/sciadv.1602363`. The link documents an analytic inspiration, not execution of its full test. See the RZS original publications and source metadata for election-specific information.


## Election-type coverage and v1.2 data contract

This module processes Serbian **presidential** candidates and **parliamentary** electoral lists as neutral vote **options**. Set `election_type` to `presidential` or `parliamentary`; combined input rows may share a year, but must not share the same type/year pair. The 2022 parliamentary source is [`G202219002.xlsx`](https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx); save it as `raw_data/Parliament 2022 ~ G202219002.xlsx`. The other configured inputs are the 2017 and 2022 presidential results.

**Validation limitation:** the structure of the 2022 parliamentary XLSX could not be directly inspected in this preparation environment. It is provisionally assigned the `2022` column template; **validate its headers, row totals, option columns and QC results** against the official workbook before analytical use. The script does not support local-election source files without a separately validated schema and (where applicable) constituency-specific winner/list logic.

For both supported types, `Main` remains the default analysis worksheet and `Master` the complete audit-preserving dataset. `Option_01_votes`, `Option_01_pct`, etc., have type-neutral meanings; `Options` maps each option to its source heading. `Winner_*` / `Second_*` are the top two **national vote totals** in the input, not automatically the winner of every constituency or an allocation of seats. No parliamentary seat allocation is performed. Election identifiers now include `Election_type`, protecting against same-year collisions. Outputs are `presidential_2017_RZS_prepared.xlsx`, `presidential_2022_RZS_prepared.xlsx` and `parliamentary_2022_RZS_prepared.xlsx`.

Existing downstream scripts that expected `Candidate_*`, `Candidates`, a year-only station key, or `P2022_RZS_prepared.xlsx` must be adapted to the v1.2 contract.
