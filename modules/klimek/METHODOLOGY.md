# Methodology and statistical interpretation

[Srpski (latinica)](METHODOLOGY_SER.md)

## Data and ordering

Inputs are canonical rows from `RZS_data_preparation.R`. `E` is registered electorate, `C` ballots cast, `B` valid ballots and `Option_XX_votes` the integer votes for a candidate or parliamentary list. Station turnout is `100*C/E`. Sorting is ascending turnout with `Station_key` as deterministic tie-break. No source values are modified and no turnout is capped. The curve is a **stepwise cumulative vote sum over polling stations ordered by turnout**, not a time-series or an empirical cumulative distribution over turnout.

## Two normalisations

For stations `i=1,...,n` in a given group (ordered), with valid votes `B_i` and option votes `v_ij`, define `S_j(k)=Σ(i≤k) v_ij`.

- **Valid-ballot normalisation:** `Y_j^valid(k)=100*S_j(k)/Σ_i B_i`. At the final station this equals `100*Σ_i v_ij/Σ_i B_i`, the vote share of option `j` in that group. For example, 400 votes from 1,000 valid ballots end at 40%.
- **Own-option normalisation:** `Y_j^option(k)=100*S_j(k)/Σ_i v_ij`. If the option obtained votes, the endpoint equals 100% by construction. The same example ends at 100%. For zero option votes it is undefined, not evidence of zero turnout or fraud.

The second curve removes level differences and highlights *where along the turnout ordering* an option accumulates its own votes. Comparisons between curves using the second normalisation describe shapes, not vote shares. For two groups or two options, station populations and denominators differ; differences are not automatically statistically significant. Zero-valid stations make no contribution to vote totals, but remain counted in the eligible group where applicable.

## Groups and sample universes

`GE100` is exactly the upstream `Main` worksheet (registered electorate ≥100 and other QC rules passed). `LT100` is the `Master` subset with `Under_100=TRUE` that passes every other upstream QC condition. `ALL=GE100∪LT100` is disjoint. `SMALL/MIDDLE/LARGE` are the upstream `Size` three-part partition of `Main`, using cumulative registered-electorate thresholds with boundary ties. `JHK_SMALL/JHK_LARGE` are the separate upstream `Size_JHK` two-part partition based on the 20th percentile of station size, with Large as the complement. The JHK grouping alone does **not** apply the complete JHK significance test or geographic standardisation. All eight reporting rows are overlapping representations, not eight disjoint samples.

## Geographical measures

Numeric aggregates at national, district and municipality levels are sums of source integer counts before percentages. District keys are `District_code`; municipality keys combine `District_code|Municipality_code` to prevent collisions. National classification thresholds remain fixed inside every geographical subset; this supports comparability. Geographical comparison may still suffer compositional confounding and ecological fallacy.

## Optional T90/T95 descriptive contrasts

Define two **nonoverlapping sets** of option vote fields a priori. Within a group, find the sample turnout quantile `q_p` at p=0.90 or 0.95 (R quantile type 7). Keep all stations with turnout ≥ `q_p`, including ties, and `B>0`. Let `A_i` and `D_i` be the sums for the two specified blocs. Report `Mean_station_margin_pp=mean_i[100*(A_i−D_i)/B_i]` and `Pooled_margin_pp=100*(Σ A_i−Σ D_i)/(Σ B_i)`. Also report number of selected stations and turnout cutoff. The two margins estimate different averages due to station-size weighting. The top 5% notion is based on a percentile and may include more than 5% when there are ties. No permutation p-value is computed because shuffling the bloc shares separately, as in the historical scripts, violates their compositional dependence and lacks a justified exchangeability null.

## Interpretation and limitations

High-turnout concentrations may result from demographic sorting, specific areas, campaigning, turnout mobilisation, unequal station sizes, legitimate special categories or transcription problems. Curves are exploratory visual evidence only. A research claim should investigate matched within-district or within-municipality baselines, station-level covariates, observation and complaint reports, polling-station protocols, and, where legally appropriate, recount or audit material. Statistical irregularity **is not proof of electoral fraud**. This script deliberately contains no Benford, FMM, formal JHK likelihood/significance test, prediction, causal adjustment or legal classification.

**Provenance:** original figure families and the descriptive tail concept are adapted from the three user-provided historical Klimek scripts; canonical variable mapping, eight eligibility-based groups, both explicit denominators, multilingual graphics and removal of the unsupported permutation inference are the revised module's specifications. The source files themselves should be retained separately in the research archive, not confused with the GitHub module.
