# Output guide — v0.3.1

[Srpski](OUTPUT_GUIDE_SER.md) · [Table methodology](JOURNAL_REPORTS.md)

## Per-election files

In the `descriptive_outputs/` folder each election produces `<election_type>_<year>_descriptive.xlsx`, optional `<election_type>_<year>_descriptive_journal_tables.docx`, and a same-stem CSV subdirectory. The runner produces these from `Main`, `Master`, and `Options` without modifying them. All tables identify reporting groups; the eight labels are overlapping partitions, not additive rows.

## Workbook worksheets

| Sheet(s) | Meaning |
|---|---|
| `README` | Run metadata and population definitions |
| `Nat_counts`, `Dist_counts`, `Mun_counts` | Counts, station numbers, electorate, attendance, cast/valid/invalid ballots and station-size moments |
| `Nat_rates`, `Dist_rates`, `Mun_rates` | Turnout, shares, leading/runner-up option rates, dispersion, effective number of options |
| `Nat_options`, `Dist_options`, `Mun_options` | Long-format **all candidate/list** votes and shares of valid votes/registered voters |
| `Nat_robust`, `Dis_robust`, `Mun_robust` | Full area/group summaries with robust and joint turnout–vote-share indicators |
| `Nat_joint_bins`, `Dis_joint_bins`, `Mun_joint_bins` | Two-dimensional 10-percentage-point station-count bins |
| `Group_tests` | Executed Kruskal–Wallis and Wilcoxon rank-sum comparisons, group Ns, p and BH q |
| `Options_dictionary` | Canonical option numbers, names and vote columns |
| `Correlation_overview` | Inventory of 16 district/municipality correlation matrices |
| `Corr_D_01` … `Corr_D_08` | District-level Pearson matrices, annotated with nominal p-value asterisks |
| `Corr_M_01` … `Corr_M_08` | Municipality-level Pearson matrices, same convention |

`D` = District; `M` = Municipality. Matrix IDs `01–07` represent `All`, `Less than 100`, `Small`, `Middle`, `Large`, `JHK Small`, `JHK Large`; **`08` represents `100 or more`**. Display sheets are **not** substitutes for detailed `r,p,q,N` CSV output.

## CSV files

Each `<stem>/` directory includes `national_table1_counts.csv`, `national_table2_rates.csv`, equivalents with `district_` and `municipality_` prefixes, `national_options.csv`, `district_options.csv`, `municipality_options.csv`, `national_robust_distributions.csv`, `district_robust_distributions.csv`, `municipality_robust_distributions.csv`, `national_joint_turnout_winner_bins.csv`, and geographic equivalents, plus `group_significance_tests.csv`, `correlation_overview.csv`, `correlation_pairs_p_q_n.csv`.

CSV is written **UTF-8 BOM** for Excel Windows compatibility; do not use legacy ANSI to import. `.xlsx` and `.docx` are Unicode. CSV contains numerical values at computational precision, while rendered tables display two decimals for rates/measures, whole integers for counts and generally three decimals for p/q values.

## Word publication document

One election-specific DOCX begins with national Tables 1–4, followed by district/municipality Appendices A (votes/rates), B (dispersion and association) and C (applied tests). These appendices are intentionally long; use selected tables in a journal's main text. The four bilingual explanatory files in `docs/publication/` explain the variables and interpretation. Avoid treating unadjusted correlation markers as verdicts.

## Missing and undefined results

`NA` and empty cells indicate missing, zero-denominator or statistically non-estimable measures, rather than zero. For zero valid ballots, candidate share is undefined. Empty groups may yield no area summary while the corresponding correlation sheet remains present and shows undefined results. P-values are not computed with fewer than three complete nonconstant observations in the correlation code. See [DATA_DICTIONARY.md](DATA_DICTIONARY.md) and [CORRELATIONS.md](CORRELATIONS.md).
