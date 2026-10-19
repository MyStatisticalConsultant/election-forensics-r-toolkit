# Initial official-results validation: 2017/2022 Serbian elections

**Assessment date:** 18 October 2026. **Status:** 73 `PASS`, 1 `REVIEW`, 0 `FAIL` across the separate 74-check reference comparison produced from the three uploaded workbooks. This independent one-time comparison is not the same as execution of the new R validator, which has yet to be run in a local R session.

| Metric | Presidential 2017 | Presidential 2022 | Parliamentary 2022 |
|---|---:|---:|---:|
| Polling stations | 8,396 | 8,267 | 8,267 |
| Registered voters: RZS station sum | 6,723,177 | 6,502,307 | 6,502,307 |
| Registered voters: published RIK register | 6,724,949 | 6,502,307 | 6,502,307 |
| Voters recorded as attending (`A`) | 3,655,365 | 3,811,585 | 3,810,559 |
| Ballots cast / in boxes (`C`) | 3,654,014 | 3,797,612 | 3,806,050 |
| Invalid ballots (`I`) | 60,378 | 89,933 | 112,722 |
| Valid ballots (`B`) | 3,593,636 | 3,707,679 | 3,693,328 |
| Vote options individually matched with RIK | 11 / 11 | 8 / 8 | 19 / 19 |
| Eligible `Main` polling stations | 8,023 | 7,787 | 7,787 |

The 2017 RZS station-level sum of registered voters differs from RIK's published national register by **−1,772**. This discrepancy remains **REVIEW**, and no causal explanation is established. It cannot be classified as an error in the preparation code based on these materials alone. The difference concerns the registered-voter denominator, which can affect calculated turnout percentages; it does not affect the exact reconciliation of candidate totals with RIK.

For every election, `Master = Main + Excluded` by row count, national candidate/list vote totals reconcile exactly to valid ballots, and the available QC summaries report zero duplicate station keys, zero ballot identity failures, and zero vote-sum failures. These QC checks are *derived from the preparation output* and not independent precinct-minute authentication. A separate validation against original RZS files, station-level official protocols, and subnational aggregate tables would strengthen the evidence.

**Official references:** [RIK presidential 2017 final candidate vote report](https://arhiva.rik.parlament.gov.rs/english/arhiva-sednice-2017.php), [2017 RIK electoral register archive](https://arhiva.rik.parlament.gov.rs/latinica/izbori-za-predsednika-republike-2017-broj-biraca.php), [RIK presidential 2022](https://www.rik.parlament.gov.rs/vest/sr/317359/70-sednica-republicke-izborne-komisije.php), and [RIK parliamentary 2022](https://www.rik.parlament.gov.rs/vest/sr/324925/79-sednica-republicke-izborne-komisije.php). [Election Archive](https://arhivaizbora.rs/teritorija/RS/srbija/izbori) separately lists 6,723,177 for 2017, supporting that the two published registration figures reflect an unresolved reporting/definition difference rather than proof that the preparation code altered votes.

**Publication status:** reasonable as a transparently labelled development/research release with qualified validation; not an unconditional claim of production-grade or precinct-audited accuracy.
