# Independent validation against official election results

Run `source("tests/validate_official_totals.R")` from `modules/rzs_data_preparation/` after generating all three Excel workbooks in `RZS_prepared/`. This requires R and the `readxl` package. Reference CSVs and tests are included in Git, whereas raw and generated Excel datasets are **not** distributed. The validator does not download data or modify election records.

The test compares the complete `Master` worksheet with independently documented final Republic Electoral Commission (RIK) totals. It checks all 38 presidential-candidate and parliamentary-list totals by **ballot order**, all main ballot counts, original RZS columns, source-to-canonical mappings, derived percentages, unique station identifiers, the `Main`/`Excluded` partition, and some QC summaries. The original main `tests/run_tests.R` is only a syntax/structure check; run both scripts.

## Reference policy and 2017 registered-voter discrepancy

The 2017 polling-station `Master` contains **6,723,177** registered voters, while the published RIK final national register count is **6,724,949** (difference **−1,772**). The 2017 ballot counts, candidate votes and recorded attendance match the published final results. The independently maintained `arhivaizbora.rs` archive also reports 6,723,177 for election-level registration. The cause of the register discrepancy has **not** been established: it must not be silently attributed to repeat voting, errors, or ballot manipulation. It is recorded as **REVIEW**, not as a data-preparation failure and not as a clean PASS. Separate station-level register reconciliation is needed to close it.

For 2017, the official pre-election register figure and final voting figures come from RIK's 2017 archive and the 2017 election report. For 2022, references are the final RIK reports dated 9 May (presidential) and 5 July (parliamentary), **not preliminary election-night figures**. The reported ballot counts are exact integers. No numerical tolerance is applied to official counts; decimal values derived by ratios use tolerance `1e-8`.

### Output statuses

`PASS` means exact concordance (or equality within the documented formula tolerance). `FAIL` means an unexpected discrepancy or integrity failure. `REVIEW` means a known, unresolved reference/definition issue; the script still completes, but the validation is **qualified**. Output: `validation_results/official_validation_results.csv`. This directory is Git-ignored.

### Reference sources

- [RIK 2017 archive, final results and candidate totals](https://arhiva.rik.parlament.gov.rs/english/arhiva-sednice-2017.php)
- [RIK 2017 register information](https://arhiva.rik.parlament.gov.rs/latinica/izbori-za-predsednika-republike-2017-broj-biraca.php).
- [RIK 2022 presidential election final report](https://www.rik.parlament.gov.rs/vest/sr/317359/70-sednica-republicke-izborne-komisije.php)
- [RIK 2022 parliamentary election final report](https://www.rik.parlament.gov.rs/vest/sr/324925/79-sednica-republicke-izborne-komisije.php)
- [Election Archive, 2017 post-election tabulated registered-voter total](https://arhivaizbora.rs/teritorija/RS/srbija/izbori)

**Limitations.** This is an integration/aggregation test of the generated workbooks against published reference totals; it does not reconstruct RZS inputs independently from precinct minutes, verify all municipality/district subtotals, or prove the absence of statistical or administrative errors. References for additional election years must be sourced and reviewed before use.

Results summary: [`../VALIDATION_FINDINGS.md`](../VALIDATION_FINDINGS.md).
