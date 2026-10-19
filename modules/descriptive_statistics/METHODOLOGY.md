# Methodology and interpretation — v0.3.1

[Srpski](METHODOLOGY_SER.md)

## Measurement levels

The input observation is a polling station. Tables are computed independently for Republic of Serbia, RZS district code and **district code + municipality code**. Source codes/labels and special categories are preserved; these are not necessarily equivalent to ordinary geographical municipality boundaries. Do not silently pool different election types even if they share a year.

## QC and classification

`Main` is the default QC-eligible E ≥ 100 sample. Supplementary `Less than 100` is assembled from `Master` **only after independent eligibility screening**, and `All = Main + accepted under-100`. The three `Size` groups and two `Size_JHK` groups are separate partitions of `Main` using nationally defined sizes. Their thresholds do **not** change by area. [MAIN_SAMPLE_GUIDE.md](MAIN_SAMPLE_GUIDE.md).

## Aggregated rates versus polling-station moments

For group `G`, with registered electorate `E_i`, cast ballots `C_i`, valid ballots `B_i`, invalid ballots `I_i` and option votes `V_ki`:

- Aggregate turnout = `100 × Σ C_i / Σ E_i`; attendance = `100 × Σ A_i / Σ E_i`.
- Invalid share of cast ballots = `100 × Σ I_i / Σ C_i`.
- Candidate/list share of valid ballots = `100 × Σ V_ki / Σ B_i`.
- Candidate/list share of registered electorate = `100 × Σ V_ki / Σ E_i`.
- Unweighted mean polling-station turnout = `mean(100 × C_i / E_i)` over stations with defined values.

The aggregate rate is **electorate-weighted**, whereas a mean or SD of station-level rates gives each station equal weight. **Example:** one station of 100 voters with turnout 80% and another of 900 with 40% have simple mean turnout 60%, but aggregated turnout `(80+360)/(100+900) × 100 = 44%`. Report which concept is used.

National first and second options are taken from the prepared `Options`/canonical totals and kept constant in every district/municipality. Local leader and local second are computed separately by local vote totals. The *effective number of options* is `1 / Σ p_k²`, with `p_k = votes_k / valid ballots`. For shares 0.5/0.3/0.2, the value is `1/(.25+.09+.04)=2.63`. It measures concentration, not electoral integrity.

## Robust station distributions

For the electorate, station turnout, national leader's station share and invalid share the module computes N, mean, median, sample SD, Q1/Q3, IQR, P10/P90 and Tukey fences `[Q1−1.5 IQR, Q3+1.5 IQR]`. Outlier counts are observations outside those fences, **not verified irregularities**. Small or homogeneous groups may produce zero IQR or undefined sample SD.

## Bivariate distributions and inferential tests

The 10-pp joint turnout×leading-share table counts stations, not ballots, in each available cell; 100% values are placed in the terminal 90–100 bin. Polling-station Pearson and Spearman correlations are reported with pair N and p; the `Joint_*` fields refer to **individual stations** within the indicated area and group.

Actual **Kruskal–Wallis** tests compare `Small`, `Middle`, `Large` for turnout and national leader's station share; actual **Wilcoxon rank-sum** tests compare `JHK Small` versus the **whole complementary** `JHK Large`. Tests run at the national level and within each area if at least two groups with sufficient variation are present. Differences are exploratory and may reflect composition, not manipulation. BH q-values are corrected **within each reporting level × outcome × test family across areas**, not globally across all statistical outputs. For causal claims one would need stronger designs, covariates, observer material and institutional evidence.

## Aggregate correlation matrices

These are correlations of **area aggregates**, separately by size group and geographical level, not within-area station correlations. Pearson p-values are two-sided and nominal `p<0.05` produces an asterisk in the workbook; BH q-values are computed **within each matrix**. Count/percentage mechanical correlations, spatial dependence and multiple comparisons limit interpretation. [CORRELATIONS.md](CORRELATIONS.md).

## Audits and inferential limits

The engine checks that all option vote totals reconcile to valid ballots, source/Main/under-100 populations are consistent, and the two size partitions reconstruct Main at national and subnational levels. Its tests do not verify RZS source provenance or establish fraud. Strong outliers/significance should lead to **targeted** investigation of signed polling-station protocols, recounts, observer reports, legal challenges, geographical context, and independent sources. The preparation module's 2017 registered-voter REVIEW item remains reported separately.
