# Contributing and reporting issues

Contributions are welcome for verified RZS schema updates, clear bilingual documentation, test fixtures, reconciliation checks, new forensic modules and public-friendly reporting. Before suggesting a changed eligibility rule or statistical conclusion, provide a methodological rationale, source/provenance, unit tests and examples of affected results. Keep political interpretation distinct from measured diagnostics.

Report bugs through GitHub Issues once the repository is published or email `Zlatko@MyStatisticalConsultant.com`. Include OS, R version, `sessionInfo()`, source year/schema, exact error text and minimal reproduction. Do **not** upload sensitive personal information or unofficially obtained protected electoral data. Pull requests should preserve raw-source integrity and add/update both English and Serbian-Latin documentation where relevant. There is no commitment here to a specific response time.


## Election-type coverage and v1.2 data contract

This module processes Serbian **presidential** candidates and **parliamentary** electoral lists as neutral vote **options**. Set `election_type` to `presidential` or `parliamentary`; combined input rows may share a year, but must not share the same type/year pair. The 2022 parliamentary source is [`G202219002.xlsx`](https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx); save it as `raw_data/Parliament 2022 ~ G202219002.xlsx`. The other configured inputs are the 2017 and 2022 presidential results.

**Validation limitation:** the structure of the 2022 parliamentary XLSX could not be directly inspected in this preparation environment. It is provisionally assigned the `2022` column template; **validate its headers, row totals, option columns and QC results** against the official workbook before analytical use. The script does not support local-election source files without a separately validated schema and (where applicable) constituency-specific winner/list logic.

For both supported types, `Main` remains the default analysis worksheet and `Master` the complete audit-preserving dataset. `Option_01_votes`, `Option_01_pct`, etc., have type-neutral meanings; `Options` maps each option to its source heading. `Winner_*` / `Second_*` are the top two **national vote totals** in the input, not automatically the winner of every constituency or an allocation of seats. No parliamentary seat allocation is performed. Election identifiers now include `Election_type`, protecting against same-year collisions. Outputs are `presidential_2017_RZS_prepared.xlsx`, `presidential_2022_RZS_prepared.xlsx` and `parliamentary_2022_RZS_prepared.xlsx`.

Existing downstream scripts that expected `Candidate_*`, `Candidates`, a year-only station key, or `P2022_RZS_prepared.xlsx` must be adapted to the v1.2 contract.
