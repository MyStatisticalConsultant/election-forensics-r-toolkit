# Sampling and the eight reporting groups — v0.3.1

[Srpski](MAIN_SAMPLE_GUIDE_SER.md)

The upstream RZS module retains original stations and QC information in `Master` and creates `Main` for stations with `E >= 100` that pass the upstream eligibility conditions. **The descriptive label `100 or more` equals `Main`, exactly;** do not equate it with all raw stations with `E >= 100` regardless of quality.

`Less than 100` contains **only** stations in `Master` with `0 < E < 100` that have no numeric/identity violation, no verified invalid administrative status and no applicable zero-received-ballots exclusion. `All` means `Main` plus this accepted group; it may be smaller than the unfiltered source `Master`.

| Label | Construction | Use |
|---|---|---|
| `All` | QC-accepted `Main` + accepted under-100 | Expanded descriptive population |
| `100 or more` | Exactly `Main` | Primary forensic population |
| `Less than 100` | Accepted under-100 from `Master` | Supplementary sensitivity/context |
| `Small` / `Middle` / `Large` | `Size` column from `Main` | Disjoint cumulative-electorate groups |
| `JHK Small` / `JHK Large` | `Size_JHK` column from `Main` | Disjoint size-percentile groups; “Large” is entire complement |

Size thresholds are **election-wide**, so an area's Small group is a subset of the election's nationally defined Small group. This design enables comparable boundaries across areas, at the price of potentially very small or empty strata for some municipalities.

For every additive measure (polling stations, electorate, votes, ballots):

```text
All = (100 or more) + (Less than 100)
(100 or more) = Small + Middle + Large
(100 or more) = JHK Small + JHK Large
```

These are separate identities: **never sum all eight labels**. Recalculate percentages using the grouped sums; percentages themselves are not additive. In inferential tests, compare only **disjoint** Size groups with each other or disjoint JHK groups with each other. Never treat `All` and `100 or more` as independent samples.

The station counts in `Main` for the tested elections are 8,023 (2017 presidential), 7,787 (2022 presidential), 7,787 (2022 parliamentary). The national fixed references are recorded in `tests/reference_100_or_more_totals.csv`. See [VALIDATION.md](VALIDATION.md) and [METHODOLOGY.md](METHODOLOGY.md).
