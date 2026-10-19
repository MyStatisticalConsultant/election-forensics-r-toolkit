# Descriptive Statistics — Election Forensics R Toolkit

**R module v0.3.1** · Presidential/parliamentary elections in Serbia · [Srpski (latinica)](README_SER.md) · [Toolkit home](../../README.md)

## Purpose and limits

This locally run R module consumes the **unaltered `Master`, `Main` and `Options` worksheets** produced by [`RZS_data_preparation.R`](../rzs_data_preparation/README.md). It generates comparable descriptive statistics for the **national level, RZS districts and district–municipality units** in the **2017 presidential, 2022 presidential and 2022 parliamentary** datasets. It does not infer misconduct or calculate the full Jiménez–Hidalgo–Klimek test. It never rewrites source workbooks.

The module is appropriate for researchers, students, election observers and journalists who need auditable tables rather than an online interface. The outputs distinguish between (a) ratios computed from aggregated counts and (b) unweighted statistics describing the **distribution among polling stations**. They are not interchangeable.

## What is implemented

- **Eight reporting groups:** `All`, `100 or more`, `Less than 100`, `Small`, `Middle`, `Large`, `JHK Small`, `JHK Large`, for each election and available administrative area. Groups overlap; see [sample definitions](MAIN_SAMPLE_GUIDE.md).
- **Two compact summary tables** at national, district and municipality levels, with polling-station counts, electorate, attendance, ballots cast, valid/invalid ballots, turnout, candidate/list shares, dispersion and effective number of electoral options.
- **Every candidate/electoral list**, not only the first two. Nationally first/second-ranked options are kept fixed across areas; local leaders are separately labelled.
- **Robust distributions:** valid N, mean, median, sample SD, Q1/Q3, IQR, P10/P90, Tukey 1.5×IQR outlier count/share for electorate, turnout, leading-option share and invalid-ballot share.
- **Joint turnout–leading-option diagnostics:** station-level Pearson/Spearman coefficients, nominal p-values, BH q-values and 10-percentage-point joint frequency cells.
- **Actual group comparisons:** Kruskal–Wallis across the disjoint `Size` categories, and two-sided Wilcoxon rank-sum across `Size_JHK` Small/Large, nationally and within each administrative area where estimable. Includes p and BH-adjusted q values.
- **16 ecological Pearson matrices per election:** 8 size groups × 2 geographic aggregation levels (district and municipality), with exact pairwise N, r, p and BH q available in CSV. See [correlations](CORRELATIONS.md).
- Styled `.xlsx`, Excel-friendly **UTF-8 BOM CSV**, and an **optional separate Word report per election** with compact national tables and comprehensive district/municipality appendices.

## Data prerequisites and populations

Only these **tested prepared source configurations** are supplied by default:

| Election | Prepared input filename | Main stations (E ≥ 100 + QC) |
|---|---|---:|
| Presidential 2017 | `presidential_2017_RZS_prepared.xlsx` | 8,023 |
| Presidential 2022 | `presidential_2022_RZS_prepared.xlsx` | 7,787 |
| Parliamentary 2022 | `parliamentary_2022_RZS_prepared.xlsx` | 7,787 |

`Main` = the complete **QC-eligible** sample with at least 100 registered voters (`E`). `All` = `Main` plus **QC-accepted** sub-100 stations from `Master`, not every RZS station. **`100 or more` = exactly `Main`.** The `Size` classification partitions `Main` as Small/Middle/Large by roughly 20% of the *registered electorate at each tail*, including boundary ties. `Size_JHK` partitions `Main` at the 20th percentile of *station size* into JHK Small and its **entire complementary** JHK Large group. Thresholds are set **nationally**, not recalculated per district/municipality.

Do **not** add the eight rows together. For station counts and all additive totals, `All = (100 or more) + (Less than 100)`; independently, `(100 or more) = Small + Middle + Large = JHK Small + JHK Large`. See [MAIN_SAMPLE_GUIDE.md](MAIN_SAMPLE_GUIDE.md).

## Install and run

Install [R](https://cran.r-project.org/) and optionally [RStudio Desktop](https://posit.co/download/rstudio-desktop/). R packages:

```r
install.packages(c("readxl", "openxlsx", "readr"))
# For DOCX reports:
install.packages(c("officer", "flextable"))
```

Download/clone **the whole toolkit**. Generate the three prepared `.xlsx` workbooks with the upstream preparation module (official raw RZS Excel files are not in Git), then put them in `modules/rzs_data_preparation/RZS_prepared/`.

In RStudio set the working directory to **`modules/descriptive_statistics`**, or open R there. Edit **only the `EDITABLE USER CONFIGURATION`** at the top of `Descriptive_statistics.R` (`INPUTS`, `OUTPUT_DIR`, `DISPLAY_DECIMALS`, `WRITE_CSV`, `WRITE_WORD`). Do not add a machine-specific `setwd()` to the code.

```r
# From modules/descriptive_statistics
source("tests/run_tests.R", encoding="UTF-8")
source("tests/run_tests_extended.R", encoding="UTF-8")
source("tests/run_tests_robust.R", encoding="UTF-8")
source("tests/integration_real_data.R", encoding="UTF-8")
source("tests/integration_extended.R", encoding="UTF-8")
source("Descriptive_statistics.R", encoding="UTF-8")
source("tests/check_exports.R", encoding="UTF-8")
```

The test order matters: run the export checker **after** generating the workbooks. RStudio is optional; from a terminal run `Rscript Descriptive_statistics.R` with the module as the working directory. See [installation details](INSTALLATION.md) and [troubleshooting](TROUBLESHOOTING.md).

## Files produced

For **each** election, default outputs appear under `descriptive_outputs/`:

```text
presidential_2017_descriptive.xlsx
presidential_2017_descriptive_journal_tables.docx  [only when WRITE_WORD=TRUE]
presidential_2017_descriptive/
    national_table1_counts.csv / national_table2_rates.csv
    district_table1_counts.csv / district_table2_rates.csv
    municipality_table1_counts.csv / municipality_table2_rates.csv
    national_options.csv / district_options.csv / municipality_options.csv
    national_robust_distributions.csv  [district/municipality equivalents]
    national_joint_turnout_winner_bins.csv [district/municipality equivalents]
    group_significance_tests.csv
    correlation_overview.csv
    correlation_pairs_p_q_n.csv
```

Corresponding stems are `presidential_2022` and `parliamentary_2022`. The Excel workbook additionally contains `Nat_*`, `Dist_*`, `Mun_*` tables, `Options_dictionary`, `Group_tests`, `Correlation_overview`, and `Corr_D_01`–`Corr_D_08` / `Corr_M_01`–`Corr_M_08`. Codes `01–07` follow the earlier seven labels; **`08` is `100 or more`**. Details in [OUTPUT_GUIDE.md](OUTPUT_GUIDE.md) and [JOURNAL_REPORTS.md](JOURNAL_REPORTS.md). **CSV numerical values are not rounded**; formatting in Word/Excel typically displays two decimals for measures and whole-number counts (p/q values may show three decimals or `<0.001`).

## Interpretation and safeguards

Turnout means `100 × sum(C) / sum(E)` for aggregated totals; it is **not** the arithmetic mean of station turnouts. Correlation matrices use **district or municipality aggregates as observations**; the `Joint_*` correlation fields instead use **polling stations** within the specified area/group. `correlation_overview.csv` counts **variable pairs**, not suspicious areas or stations. Asterisks on Pearson coefficients denote **nominal** two-sided `p < 0.05`; inspect BH-adjusted q-values before discussing multiple comparisons. All tests are exploratory; size, geography, socioeconomic composition, turnout patterns, administrative rules and recording errors can produce differences without fraud. [Methodology](METHODOLOGY.md) · [Dictionary](DATA_DICTIONARY.md) · [Correlations](CORRELATIONS.md).

## Validation and release status

**v0.3.1 is assessed against the three listed datasets only.** The researcher reports agreement of the resulting tables with independently calculated references, including the explicit `100 or more` population. Existing R tests cover structural, synthetic, real-data, extended, robust and exported-output checks. A complete **v0.3.1 RStudio console log has not been included with this documentation package**; run the seven commands above and retain their outputs for the final release record. No future election/source-format compatibility is implied. The upstream preparation module retains one documented official-total **REVIEW** item for 2017 registered voters; this does not by itself invalidate downstream arithmetic. See [validation guidance](VALIDATION.md) and [reproducibility](REPRODUCIBILITY.md).

## Repository files, support, citation and licence

- `Descriptive_statistics.R`: editable configuration, output writing, run loop; `R/descriptive_core.R` and `R/descriptive_extended.R`: reusable logic.
- `tests/`: all named tests and fixed national reference values; `examples/`: demonstration guidance; `docs/publication/`: four EN/SR explanatory Word guides.
- Detailed bilingual documentation: [installation](INSTALLATION.md), [methodology](METHODOLOGY.md), [dictionary](DATA_DICTIONARY.md), [outputs](OUTPUT_GUIDE.md), [publication tables](JOURNAL_REPORTS.md), [validation](VALIDATION.md), [correlation interpretation](CORRELATIONS.md), [reproducibility](REPRODUCIBILITY.md) and [troubleshooting](TROUBLESHOOTING.md); each has a `_SER.md` counterpart.

Report errors with **R version, `sessionInfo()`, election, exact error, reproducible steps and non-sensitive sample input** via GitHub Issues or `Zlatko@MyStatisticalConsultant.com`. Contributions: [CONTRIBUTING.md](CONTRIBUTING.md). Cite: Kovačić, Z. J. (2026). *Election Forensics R Toolkit: Descriptive Statistics* (v0.3.1) [R software], GitHub repository, version/commit ID. [CITATION.cff](CITATION.cff). MIT licence applies through the [repository root](../../LICENSE). © 2026 Zlatko J. Kovačić.
