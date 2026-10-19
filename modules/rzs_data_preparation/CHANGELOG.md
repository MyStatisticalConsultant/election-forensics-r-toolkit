# Changelog

## 1.3.1 — 2026-10-18

- Fixed an R `if`/`else` parsing error at the end of `tests/validate_official_totals.R` (previously reported at line 194).
- The lightweight `tests/run_tests.R` now also parses the validation script, catching syntax regressions before data-dependent validation starts.
- No changes to the election-data preparation logic, official reference values or validation calculations.


## 1.1 — 2026-10-18

- Clearly separated user-editable configuration from protected analysis code, with bilingual English/Serbian-Latin guidance and input checks.
- Added bilingual comments introducing major processing blocks.
- Made local official-input paths explicit (`raw_data/`); reinforced `Main` as downstream default and `Master` as audit data.
- Added English/Serbian-Latin project documentation, documented overrides template, repository architecture and lightweight tests.
- Preserved the original 1.0 computational definitions and output sheet design; no source XLSX values are changed by the script.

## 1.0 — source script supplied by author

- Initial 2017/2022 RZS Excel import, harmonization, grouping, QC, provenance and output generation.

## 1.2.0 — 2026-10-18
Generalised to presidential and parliamentary elections, with type/year identifiers, type-neutral option columns and separate output names. Added official parliamentary 2022 URL and documented unverified schema assumption. BREAKING: field and output naming changes.

### 1.2.1 — Structural-test alignment

Clarified the `Main`/`Master` analysis-input comments in `RZS_data_preparation.R` and aligned the static test assertion. No data-preparation calculations were changed.


## 1.3 — 2026-10-18
- Added independent RIK final-result verification for all three elections and all 38 candidate/list totals.
- Added documented `REVIEW` handling for the 2017 registered-voter discrepancy (RZS station sum 6,723,177; RIK published register 6,724,949).
- Added bilingual validation instructions, reference datasets and a machine-readable validation report. Data-preparation calculations remain unchanged.
