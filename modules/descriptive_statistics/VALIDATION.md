# Validation record and scope — descriptive module v0.3.1

[Srpski](VALIDATION_SER.md)

## What may be described as validated?

**Validated for the three tested election datasets, subject to local test completion and the reported independent comparisons.** The researcher reports that outputs from the current descriptive workflow match independently compiled reference results for **presidential 2017, presidential 2022, and parliamentary 2022**. This is meaningful evidence of correctness for these datasets and configurations, not universal software certification for future or altered RZS workbooks.

**Evidence presently stored in the repository:** synthetic structural tests, real-data integration tests, robust/extended tests, export verification, and `tests/reference_100_or_more_totals.csv`. The last file contains independently compiled fixed reference totals used to confirm that `100 or more` equals upstream `Main` and that `All` has the expected counts. These reference totals do **not** independently verify every p-value, every correlation, Word layout, or new data schema. The **complete console output of a single successful v0.3.1 run has not been attached to this documentation package**. Preserve it when finalising a release.

## Tested elections and Main reference figures

| Election | Main stations | Main registered voters |
|---|---:|---:|
| Presidential 2017 | 8,023 | 6,680,494 |
| Presidential 2022 | 7,787 | 6,467,903 |
| Parliamentary 2022 | 7,787 | 6,467,903 |

The under-100 and All totals are also in `tests/reference_100_or_more_totals.csv`. The upstream official-total validation identified one **REVIEW** discrepancy in the number of 2017 registered voters: national RZS station sum 6,723,177 versus reported RIK figure 6,724,949, while candidate and ballot sums matched. See [upstream findings](../rzs_data_preparation/VALIDATION_FINDINGS.md). The reason for the difference has not been established; **do not alter source values merely to force agreement**.

## How to reproduce validation

Run from `modules/descriptive_statistics` after preparing the original three XLSX workbooks:

```r
source("tests/run_tests.R", encoding="UTF-8")
source("tests/run_tests_extended.R", encoding="UTF-8")
source("tests/run_tests_robust.R", encoding="UTF-8")
source("tests/integration_real_data.R", encoding="UTF-8")
source("tests/integration_extended.R", encoding="UTF-8")
source("Descriptive_statistics.R", encoding="UTF-8")
source("tests/check_exports.R", encoding="UTF-8")
writeLines(capture.output(sessionInfo()), "sessionInfo.txt")
```

Retain the session information and exact console transcript in a **local release record**; remove usernames and paths before publication. The export checker expects the **three** default elections and checks worksheet structure, count references, 16 matrices, group tests and BOM text encoding. It is not a comprehensive numerical oracle for all statistical p/q-values. For a journal, compare selected R-generated p/q values with independent implementations, documenting tie handling, multiple-testing families and software versions.

## Required reconciliation and invariants

1. Main reproduces the upstream eligible sample (8,023 / 7,787 / 7,787 stations).
2. `All = 100 or more + Less than 100` for additive counts, nationally and per area.
3. `100 or more = Small + Middle + Large = JHK Small + JHK Large` independently.
4. District and municipality sums equal the national sample totals.
5. For each area/group, all option-vote totals equal valid ballots.
6. Unknown/empty groups do not silently create spurious significant correlations; p/q values must lie in [0,1] when finite.
7. Source XLSX files remain unchanged and Serbian diacritics survive Excel/CSV export.

A **future version** of the upstream positional importer must be validated separately when RZS inserts new administrative columns, changes worksheets, or changes election types. This release makes **no** claim of that compatibility.

## Suggested release phrasing

“Descriptive module v0.3.1 was validated against independently compiled results for the 2017 and 2022 presidential elections and the 2022 parliamentary election, with automated reconciliation and test scripts included. This validation applies only to the tested RZS formats and data. One upstream 2017 registered-voter discrepancy remains documented for review.”

This is validation of *processing and computation under tested conditions*, **not** evidence that unusual election results are fraudulent.
