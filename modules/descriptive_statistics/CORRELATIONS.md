# Correlation analysis: the 16 matrices and their summary — v0.3.1

[Srpski](CORRELATIONS_SER.md)

## What is correlated?

Each matrix is a separate **ecological Pearson correlation matrix**. The data points are **aggregate districts** (`D`) or **aggregate district–municipality areas** (`M`), after selecting one reporting group of stations. A matrix based on 32 districts contains at most 32 observations per coefficient, **not thousands of polling stations**. The included variables cover counts (registered, attendance, ballots and votes of every option), percentages, local winning margin, effective number of options and selected dispersion measures. A correlation between registered voters and number of ballots can be high largely because bigger districts generate bigger counts.

The station-level `Joint_Pearson_r` and `Joint_Spearman_rho` in the robust outputs instead correlate **polling-station turnout and nationally leading-option share within an area/group**. Do not mix these estimands.

## Matrix IDs

`D_01`/`M_01` = `All`; `_02` = `Less than 100`; `_03` = `Small`; `_04` = `Middle`; `_05` = `Large`; `_06` = `JHK Small`; `_07` = `JHK Large`; `_08` = **`100 or more` (`Main`)**. Earlier IDs were deliberately preserved when `_08` was introduced.

## Coefficients, p-values and q-values

For each pair of numerical columns, Pearson r is estimated on pairwise-complete area observations. `N_pairs` is the actual count of areas contributing to **that pair**, possibly smaller than `Areas`. Correlations are undefined with fewer than 3 complete observations or zero variance. The code computes a two-sided t-test p-value for r (subject to standard test assumptions) and applies Benjamini–Hochberg false-discovery-rate adjustment **within each matrix**, producing `BH_q_value`. `*` shown next to r in `Corr_*` means **nominal** p<0.05, not BH significance. Detailed results are in `correlation_pairs_p_q_n.csv` (`R`, `P_value`, `N_pairs`, `BH_q_value`).

## Understanding `correlation_overview.csv` — every field

| Column | What the number represents |
|---|---|
| `Matrix` | Matrix ID, e.g. `D_08` |
| `Level` | Observational unit, district or district–municipality |
| `Size_group` | Which stations were selected before aggregating |
| `Areas` | Number of available area rows; **not polling stations** |
| `Variables` | Number of numeric indicators being compared |
| `N_tested` | Count of non-diagonal **unique variable pairs** with calculable p-values |
| `Significant_nominal` | Number of those pairs with two-sided p<0.05 |
| `Significant_BH` | Number of pairs with within-matrix BH q<0.05 |

Example (invented): `D_08, District, 100 or more, Areas=32, Variables=50, N_tested=1100, Significant_nominal=85, Significant_BH=43`. Out of a possible 50×49/2 = 1,225 unique pairs, only 1,100 have calculable tests. **The numbers 85 and 43 count associations between variables, not districts or suspicious polling stations.** The actual values and data provenance are in the generated CSV; do not quote these dummy values as findings.

## Statistical and forensic cautions

A coefficient r=0.70 means a relatively strong **linear association across areas**, not a 70% change, 70% probability of fraud or proof of causation. High correlations can arise from common denominators, area size, compositional vote shares (they sum to 100%), geographic sorting, socioeconomic differences, outlying areas, spatial dependence and correlated reporting errors. Multiple comparisons increase the expected number of nominal significant results; BH controls one aspect but does not fix all dependence or model-assumption problems.

For suspicious-looking patterns, specify a hypothesis before testing, inspect scatterplots and leverage points, compare like areas and station groups, consider spatial/area controls, and corroborate with signed polling-station protocols, observer reports and recounts. For polling-station-level inference, use dedicated models rather than treating ecological matrices as direct evidence. [METHODOLOGY.md](METHODOLOGY.md).
