# Reproducibility protocol

1. Download the official RZS original `.xlsx` files from the publication URLs in `README.md`. Do not commit raw or generated election files to Git. Preserve original filenames or update the editable paths.
2. Record source URLs, access date, source schema, downloaded-file hashes, R version and package versions. The output `Metadata` worksheet includes the original-file MD5 and UTC runtime timestamp; MD5 is an identity marker here, not a modern security guarantee.
3. Change configuration only in the labeled EDITABLE section. Record the entire configuration in the research protocol, including exact station override decisions and documentary provenance.
4. Run `source("RZS_data_preparation.R", encoding="UTF-8")` from the module directory. Check success messages and explicit analysis sheet guidance.
5. Inspect counts and station records in `QC_summary`, `QC_records`, `Excluded`, `Zero_cases`, `Size_thresholds` and `Options`; verify against official totals independently.
6. Record R/package environment: `writeLines(capture.output(sessionInfo()), "sessionInfo.txt")`; preserve alongside the experiment, not necessarily in the public repository.
7. Run `source("tests/run_tests.R", encoding="UTF-8")`. Tests supplied here mainly check structure and configuration; full integration exercises require verified local RZS inputs and their schema.
8. Cite the software release/commit, year(s), raw source edition, overrides and analysis-specific selection flags in subsequent outputs.

The pipeline is deterministic for fixed source, configuration, environment and overrides, except for export metadata such as the UTC execution timestamp. Exact workbook bytes are not promised to be identical across runs even when numerical contents are identical. The script does not download official data or maintain a lockfile; package-version pinning (e.g. `renv`) is recommended as the toolkit matures.

**Integrity/interpretation:** QC exceptions cannot be equated with malpractice, and cleaning choices require transparent preregistration or sensitivity analyses. Do not modify source votes to make arithmetic identities fit.


## Election-type coverage and v1.2 data contract

This module processes Serbian **presidential** candidates and **parliamentary** electoral lists as neutral vote **options**. Set `election_type` to `presidential` or `parliamentary`; combined input rows may share a year, but must not share the same type/year pair. The 2022 parliamentary source is [`G202219002.xlsx`](https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx); save it as `raw_data/Parliament 2022 ~ G202219002.xlsx`. The other configured inputs are the 2017 and 2022 presidential results.

**Validation limitation:** the structure of the 2022 parliamentary XLSX could not be directly inspected in this preparation environment. It is provisionally assigned the `2022` column template; **validate its headers, row totals, option columns and QC results** against the official workbook before analytical use. The script does not support local-election source files without a separately validated schema and (where applicable) constituency-specific winner/list logic.

For both supported types, `Main` remains the default analysis worksheet and `Master` the complete audit-preserving dataset. `Option_01_votes`, `Option_01_pct`, etc., have type-neutral meanings; `Options` maps each option to its source heading. `Winner_*` / `Second_*` are the top two **national vote totals** in the input, not automatically the winner of every constituency or an allocation of seats. No parliamentary seat allocation is performed. Election identifiers now include `Election_type`, protecting against same-year collisions. Outputs are `presidential_2017_RZS_prepared.xlsx`, `presidential_2022_RZS_prepared.xlsx` and `parliamentary_2022_RZS_prepared.xlsx`.

Existing downstream scripts that expected `Candidate_*`, `Candidates`, a year-only station key, or `P2022_RZS_prepared.xlsx` must be adapted to the v1.2 contract.


## Independent validation against RIK final totals

Run `source("tests/validate_official_totals.R")` after the data-preparation run. The validator verifies all 38 candidate/list results, published national totals, workbook partitions, source-column mappings and derived mathematical identities. The 2017 registered-voter comparison is recorded as `REVIEW`, not silently reconciled. See [`tests/VALIDATION_README.md`](tests/VALIDATION_README.md).
