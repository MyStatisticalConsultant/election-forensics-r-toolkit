# Methodology — Small-station voter-rigging discrepancy analysis

**Research basis:** R. Jimenez, M. Hidalgo and P. Klimek (2017), *Testing for voter rigging in small polling stations*, Science Advances, 3, e1602363 (main article pp. 3–6; Supplementary Materials pp. 2–4).

## 1. The idea without equations

The test asks whether small polling stations display a *systematic difference* in turnout and support for the nationally selected winning option relative to larger polling stations, **after allowing for local electoral geography**. A small rural community might naturally vote differently from a city. The method therefore does not directly compare its raw voting percentage with the national average; it compares each station with other eligible stations **inside its own municipality**, then asks whether smaller stations tend to be displaced from larger ones in the resulting two-dimensional representation.

For each station we consider turnout and the fraction of valid votes cast for the nationally selected winner. Each is transformed into a z-score: how far above or below that municipality's other stations does the station lie, in local standard-deviation units? A station at (+1,+1), for example, has both turnout and winner support about one local standard deviation above its municipality's *other stations*. Large and small stations create two clouds of points. The paper measures the distance between their centres by using **medians** on each axis, not a fitted-density mode or the visual contour arrow from the separate `contours` module.

The entire procedure is repeated under many definitions of what counts as 'small' (the lowest 0.5%, 1.0%, ... 90.0% of electorate sizes). If the size-related difference persists across a range of cutoffs, it is a descriptively notable pattern. However, **the raw size of the difference does not tell us whether it is unusual in a statistical comparison across elections**. The source authors required a reference set of multiple other elections to evaluate that claim. This release has no such independent reference set, so the output remains `D(p)`, not their international reference-standardised test `δ(p)`.

The second visual (Figure 4B-style) answers a simpler question: when polling stations are accumulated from largest to smallest, does the overall winner vote share change as the smallest stations enter the count? This is a vote-weighted descriptive curve, not a significance test.

## 2. Data contract and scope

For each station `i` let:

- `E_i`: registered electorate, `E_i>=1`;
- `B_i`: valid votes, `0<B_i<=C_i`;
- `C_i`: ballots cast/ballots in box, `C_i<=E_i`;
- `W_i`: votes for the *same nationally selected winner* across all regions, `0<=W_i<=B_i`.

The default source is `RZS_prepared/<election>_RZS_prepared.xlsx`, worksheet `Master`. This matters because `Main` often applies E≥100, whereas the original small-station hypothesis concerns especially small units. For purposes of this module, independently check the basic arithmetic and identifiers and **do not automatically inherit an exclusion solely because E<100**. `station_level_qc.csv` gives the complete record and reason code for each input row.

Two definitions are calculated as a robustness check:

`A: t_i = B_i/E_i; v_i = W_i/B_i`

`B: t_i = C_i/E_i; v_i = W_i/B_i`

The original study describes turnout and winner share as percentages; multiplying either input rate by 100 does not change its neighbourhood z-score. Definition B is an explicit Toolkit sensitivity analysis, not a claim that both variants appear in the original paper.

## 3. Neighbourhood (municipal) standardisation

Let `N(i)` be all **other**, arithmetically eligible stations in the **same municipality** (identified by district and municipality codes). The reference statistics are computed before size stratification or geographic output filtering:

`Z_t(i) = [t_i - mean(t_j : j in N(i))] / sd(t_j : j in N(i))`

`Z_v(i) = [v_i - mean(v_j : j in N(i))] / sd(v_j : j in N(i))`.

A municipality must have at least **10 eligible stations in total**, leaving at least nine reference stations for any target station. This follows the supplement's minimum of ten units per electoral neighbourhood, interpreted with the figure-5 instruction to exclude station `i` from its own reference group. This rule differs from `contours`' less restrictive five-neighbour default. A missing or zero reference SD causes the station's standardised pair to be omitted, with the reason saved to CSV.

The implementation computes the *leave-one-out* mean and sample SD algebraically from group sums, giving exactly the same result as repeatedly excluding the target and calling `mean` and `sd`. The peer mean and SD for each coordinate and both standardised scores are retained in CSV.

## 4. Elliptical outlier removal

Following Supplementary Materials' *Outliers removal*: collect all finite pairs `(Z_t,Z_v)` for one election and rate definition. Estimate the sample mean vector `m` and covariance matrix `S` and calculate each point's squared Mahalanobis distance:

`Q_i = (Z_i-m)' S^{-1} (Z_i-m)`.

Keep points with `Q_i <= qchisq(.95, df=2)`. The threshold is approximately 5.99146. The ellipse is fitted at the **election-wide level**, not refitted separately for each district or municipality. Its centre, covariance components, cutoff and each station's inclusion flag are exported.

The supplement states that the filter removed around 5% of atypical units in its datasets; **the actual removed proportion in Serbia is calculated and may differ**. Being outside the ellipse is a statistical sample-exclusion rule, **not proof of irregularity**. If the covariance is singular, the module does not invent a substitute ellipse; it reports the failure.

## 5. Original raw discrepancy D(p)

For each geographic output area and threshold `p` in `{0.5,1,1.5,...,90}`:

1. Take the area's stations retained by the election-wide ellipse.
2. Let `q_p` be the p-th percentile of electorate size `E` *within that area*, using R's documented quantile type 7.
3. Define `S(p)={i:E_i<q_p}` and `L(p)={i:E_i>=q_p}`. **Tied sizes at the threshold remain in L.** This strict split follows the supplement's wording; resulting counts need not equal exactly p%.
4. Do not calculate the distance unless each group has at least 10 observations.
5. Calculate the coordinate medians, `m_t^S`, `m_v^S`, `m_t^L`, `m_v^L`, then:

`D(p) = sqrt( (m_t^S - m_t^L)^2 + (m_v^S - m_v^L)^2 )`.

The signed differences `dx=m_t^S-m_t^L` and `dy=m_v^S-m_v^L` are also saved. **D is unsigned**: a large value may reflect an upper-right, lower-left or other displacement. To distinguish mechanisms inspect `dx`, `dy`, the two group medians, observer reports and the wider political context.

Under the paper's hypothesised mechanism of coercive mobilization benefiting the winner in small stations, both coordinates tend to increase (upper right). An upper-left shift may correspond to suppressed turnout alongside elevated winner share. Non-fraud mechanisms can also generate size-related shifts. A zero or small D does not rule out manipulations that do not vary by station size.

## 6. Why delta(p) and the grey accepted region are unavailable in stage B

The original authors constructed `D_k(p)` for 21 elections from ten countries. At each p they applied the **modified Thompson tau** outlier procedure; they then identified an election-wide reference set `R` using the fraction of thresholds at which each election was not flagged, and calculated:

`delta_k(p) = [D_k(p)-mean(D_l(p): l in R)] / sd(D_l(p): l in R)`.

Only with this independently established reference set is Figure 4A's reference-standardised vertical axis and acceptance region meaningful. The supplement does **not** report the individual `D_k(p)` for all 21 cases. Its table S1 contains station counts and electorate mean/SD only. We therefore do **not** compute a surrogate delta, do **not** plot a grey acceptance region and do **not** declare the Serbian observations significant or nonsignificant by the published test.

`vr_thompson_tau()` is included as a **tested, uncalled helper** for a future stage A implementation. The full stage A extension must first obtain underlying or validated comparable election data, reproduce the same filtering, turnout definition, neighbourhood rules and p-grid, audit independence of the reference and target elections, then recompute reference inclusion and any appropriate rejection thresholds. This is more than adding an arbitrary mean and SD to a graph.

**Do not equate the descriptive y-axis `D(p)` with the article's `delta(p)` or use the descriptive Figure 4-style PNG as a replica of the original inference.**

## 7. Cumulative winner vote share — Figure 4B-style

For all **arithmetically valid** stations in the chosen area, order by `E` descending (break ties by `Station_key` for reproducibility). For rank `r` calculate:

`cumi(r) = [sum_{i<=r} W_i] / [sum_{i<=r} B_i]`.

This **weights** stations by valid votes and uses the raw vote data, not the 95%-ellipse subset needed for D. The x-axis uses a logarithmic rank scale as in the article. A sharp movement when small stations enter the cumulative total suggests a station-size-related change in winner support, not proof of coercion.

The combined **Figure 4-style** panels have bilingual labels, but panel A shows raw `D(p)` and explicitly warns that it is not the article's delta(p) graph. Multi-election national overlays are generated only if the national level is selected. District and municipality curves are a separately labeled **exploratory extension**, not a claim to reproduce the article's national cross-election test.

## 8. Optional exploratory randomisation

For selected `p`, use only ellipse-retained `(Z_t,Z_v)` and permute `E` labels (within municipality by default, or globally if explicitly selected), while keeping the observed standardised coordinates fixed. Recalculate the small–large median distance and record all randomised distances plus:

`p_exploratory = [1 + #{D_random >= D_observed}]/[1 + number of valid randomisations]`.

This is a **conditional randomisation diagnostic**, *not* the modified Thompson tau cross-election reference test. A station's turnout has `E` in the denominator, so randomising electorate size while fixing z-scores is not a fully generative election null. Municipality-constrained permutations impose another null from global permutations. Results are therefore exploratory even if the empirical tail probability is small, and should not be interpreted as confirmation of voter rigging. Disable with `RUN_EXPLORATORY_PERMUTATIONS <- FALSE`.

## 9. Reproducibility, limitations and further investigation

The module records the full Master-to-QC-to-standardisation-to-ellipse-to-p-to-D chain in CSV. It has deterministic threshold ties, optional fixed-seed randomisation, a manifest for every requested area, and independent synthetic tests that verify the formula against hand-computed values. No input workbook is modified.

Eligibility in the original comparison involved >1,000 units per national election, >100 geographic neighbourhoods and at least ten units per neighbourhood. This module records national QC sample counts; small district/municipality analyses are not treated as if those whole-election comparison criteria were automatically met. At every level, lack of minimum group sizes yields an explicit missing D, not an invented result. Differences in local political support, assignment of stations to settlements, genuine mobilisation and other contextual factors can generate or obscure such patterns. Verify statistical signals with scanned protocols, observer reports, administrative data and, where warranted, lawful investigative procedures.

### Figure labelling and turnout-definition robustness

In combined Figure 4-style comparisons, only the displacement panel changes between definition A (`B/E`) and B (`C/E`). The cumulative winner-vote-share panel is algebraically independent of the turnout denominator and is identical in A and B comparison PNGs. The dashed horizontal line in this panel indicates 50% of valid votes. In the displacement panel, the axis text *Effect size, D(p)* describes the **raw median-centre distance**; it must not be confused with the cross-election standardized statistic `δ(p)` of Jimenez et al. (2017).
