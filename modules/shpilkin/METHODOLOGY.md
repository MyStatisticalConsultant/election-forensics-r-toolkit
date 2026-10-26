# Methodology — Shpilkin and Kobak–Shpilkin–Pshenichnikov analyses

## 1. Intuitive explanation

This module contains **three different tools**, not one all-purpose fraud test. The first shows how turnout and winner vote share are distributed across polling stations. A regular-looking distribution is neither a guarantee of an honest election nor a mathematical requirement. Peaks and long tails can arise from political geography, institutions and turnout mobilization.

The second examines whether turnout or winner vote share accumulates **unusually often near whole-number percentages** such as 65%, 70%, 75%, or 91%. Because ratios of integer vote counts naturally form spikes, merely seeing peaks is inadequate. Kobak, Shpilkin and Pshenichnikov (2016) proposed simulating how often these values would arise if, at each station, independent binomial voting produced results fluctuating around the *observed* local rates. Their method preserves actual station denominators and compares the observed number of near-integer stations against simulations.

The third is an **assumption-dependent excess-votes scenario**. If the winner-to-other-votes ratio is broadly stable in a low/intermediate-turnout reference range, one may scale the curve of votes for all other valid choices to predict the winner's curve at higher turnout. Positive deviations can be accumulated as *model-dependent anomalous votes*. This is not an identified tally of fraudulent ballots; demographic and geographical variation, tactical voting and selective mobilisation can violate the required invariance.

## 2. Sources and scope

- **Descriptive histograms:** Kobak, Shpilkin & Pshenichnikov (2016), *Statistical fingerprints of electoral fraud?*, Significance 13(4), 20–23, DOI:10.1111/j.1740-9713.2016.00936.x. Figure 3: 0.25 percentage-point centred bins, unit area, numerator jitter U(-0.5,0.5). We allow 0.5 pp as an explicit Serbian data-resolution adaptation.
- **Integer-percentages inference:** Kobak, Shpilkin & Pshenichnikov (2016), *Integer percentages as electoral falsification fingerprints*, Annals of Applied Statistics 10(1), 54–73, DOI:10.1214/16-AOAS904, §§2–3, Figures 1 and 4. Original 0.1 pp bins, **registered-voter-weighted** histograms and 10,000 binomial simulations.
- **Excess-votes extension:** Shpilkin-style nonparametric turnout-conditioned scaling as described in the methodology discussions of *Statistical fingerprints of electoral fraud?*, and the public documentation of the `NonparamElectionForensics()` approach in EFToolkit; complementary implementation descriptions: Cedar-Russia, `https://cedarus.io/research/evolution-of-russian-elections`. **Unlike the first two components, the supplied PDF does not specify this third estimator as an executable, uniquely defined algorithm.** This module deliberately labels the implemented baseline ratio, binning, core selection and positive-part rule as a documented **scenario implementation**, not an exact replication of a unique published estimator.

## 3. Data contracts and sample rules

Prepared workbook `Master` supplies registered voters E, valid votes B, ballots cast C, national winner votes W, station and geographic IDs. The national winner must be verified from `Options`; if `Winner_votes` is absent, explicitly configured fallback columns are used. Only arithmetically sound integer counts 0 ≤ W ≤ B ≤ C ≤ E, E > 0, B > 0, nonmissing station IDs are accepted. Do not silently interpolate or fix invalid election counts.

Primary turnout: **T = 100 C/E**. Optional sensitivity definition: **T_A = 100 B/E**. Winner share in both: **R = 100 W/B**. These are the agreed Serbian definitions. The Russian study's turnout numerator was ballots *issued to voters* G, while the ratio for its winning result used *cast ballots* B_Russian. Because the prepared Serbian fields differ, exact equivalence should not be claimed; the chosen mappings and denominators are exported.

E < 100 is excluded by all three primary methods. It remains visible in `station_level_qc.csv`. Descriptive and excess analyses exclude 100% turnout and 100% winner share. The integer Monte Carlo test additionally excludes **observed** turnout or result greater than 99%, following the source paper (exactly 99.00% is retained). QC decisions are listed in CSV and never used as evidence that an individual station is fraudulent.

District and municipality analyses are optional. They require enough stations to estimate meaningful distributions, and their small samples can be highly unstable. The integer Monte Carlo runner is national-only by default to avoid unreasonable execution costs and fragile local inference.

## 4. Descriptive distributions

Let X_i be T_i or R_i in percentage points. In the figure-only jitter option, replace its numerator by numerator + ε_i, ε_i ~ U(-0.5,0.5), while retaining the original denominator. A fixed seed is recorded, and **all inferential analyses use unchanged integer counts**, not jittered values. Define centred bins around b_k = k h, with width h in percentage points. For accepted N stations, n_k counts stations inside bin k. The plotted empirical **density** is

    f_hat(b_k) = n_k / (N * h).

Thus sum_k f_hat(b_k) h = 1 (up to boundary handling). The published illustration used h=0.25; the default is h=0.5 for a smaller Serbian station sample, and can be changed to h=0.25 or h=1 for sensitivity analysis. **This width has no effect on the inferential 0.1 pp integer-histogram test.**

## 5. Original integer-percentage Monte Carlo test

Define the observed near-integer event at one station by

    I_i = 1{ min(|T_i − round(T_i)|, |R_i − round(R_i)|) <= omega },

with omega = 0.05 percentage points and the near-integer rule applied to either turnout or leader result. The statistic q = sum_i I_i. Separate counts for turnout, leader, and half-integer negative controls are also exported.

For each eligible i and simulation replicate r, generate *independently*:

    G_i^(r) ~ Binomial(E_i, G_i/E_i),
    W_i^(r) ~ Binomial(B_i, W_i/B_i).

Then compute T_i^(r)=100 G_i^(r)/E_i and R_i^(r)=100 W_i^(r)/B_i and repeat the same near-integer counting rule. The observed denominator B_i stays fixed for leader simulation, matching the source's two independent binomial distributions. The observed station cohort is fixed; simulated values exceeding 99% are not counted as in the original exclusion rule. Simulated percentages need not satisfy joint physical ballot constraints: this is the article's **marginal null** construction, not a generator of complete hypothetical protocols.

For each statistic, report q_obs, MC mean, MC standard deviation, q_obs minus MC mean, z-score, 0.5% and 99.5% empirical quantiles, and conservative one-sided MC tail probability (1+#MC >= observed)/(R+1). With R=999 the smallest possible reported p-value is 0.001; with R=10,000 it is approximately 0.0001. This finite-resolution p-value is not an independently calibrated causal fraud probability.

For Figure 4-style histograms, original 0.1 pp centred bins sum **E_i** over stations in each bin, not one unit per station. Bands are computed bin-by-bin from 0.5% and 99.5% Monte Carlo quantiles. Such pointwise bands do **not** constitute a simultaneous 99% confidence band across all bin positions.

The source paper used 10,000 MC replicates. The exploratory default is R=999 for manageable runtime; set `MONTE_CARLO_REPS <- 10000L` for a source-resolution publication run.

## 6. Conditional excess-votes scenario (explicit Toolkit implementation)

For turnout-bin k, compute valid winner votes W_k = sum_i W_i and other valid votes O_k = sum_i (B_i−W_i), using stations in that bin. For user-declared core C=[a,b], or an **automatically selected modal-turnout ±w** core, estimate

    alpha = (sum_{k in C} W_k) / (sum_{k in C} O_k).

Expected winner votes by bin under constant vote composition are alpha*O_k. The signed difference is d_k = W_k − alpha O_k. This implementation reports the positive excess **only for turnout bins above the upper core boundary**:

    A_+ = sum_{k: t_k > b} max(d_k,0).

The signed residual sum over the same bins is also exported.

**Figure and estimator alignment.** Grey **curve-following polygons** are drawn only to the right of the upper reference-core boundary where the observed winner curve is higher than the blue baseline. Between adjacent turnout-bin centres, both curves are linearly interpolated, and any crossing points are inserted before shading. This eliminates rectangle overhangs or gaps. The sum `positive_residual_votes` in the summary CSV is calculated from the **original discrete turnout-bin residuals**; it is **not the geometric integral** of the shaded polygons. The plot converts the y-axis to thousands of votes and displays the rounded total in its subtitle. The blue baseline is **not** a Monte Carlo expectation: it is the other-valid-vote curve multiplied by `alpha` fitted in the reference core. By contrast, grey envelopes on separate integer-percentage Monte Carlo charts represent simulated pointwise quantiles. This graphical display does not resolve causal identification or prove a number of stolen ballots. This does not establish that A_+ votes were illegally added; it is the counterfactual difference **conditional on an invariance hypothesis**. Natural increases in winner support at high turnout, regional mixtures, differences in parties' turnout mobilisation and shifts in invalid votes can all change A_+ in the absence of manipulation.

Automatic core selection maximises the **number of polling stations** in a 1 pp turnout bin between 20% and 80%, then takes a configured symmetric window. Its purpose is usability, not to identify an inherently “honest” reference region. Its output is labelled `AUTO_MODAL_DESCRIPTIVE`. The `excess_sensitivity.csv` reports 5, 7.5 and 10 percentage-point half-widths; users should declare and test substantively justified reference ranges before interpreting any estimate. If core station or nonwinner counts are insufficient, the module returns no numeric estimate. A coefficient of variation of core bin ratios greater than 0.35 is a **diagnostic warning**, not a validated significance cutoff.

No causal claim, fraud ranking, count of stolen votes, adjusted official result or winner counterfactual is produced.

## 7. Reproducibility, limitations and comparison across elections

All intermediate tables are exported to CSV: station QC and plot-only perturbed rates; unweighted station histogram densities; weighted E histograms and pointwise MC bands; per-replicate integer statistics and final MC summaries; turnout-binned vote totals and alternative core scenarios; configuration and export manifest.

Each election has its own national winner, as selected from that election's actual results. Therefore, overlaid winner curves from different elections compare the **distribution of winners' percentages**, not necessarily the same party's support. The three Serbian prepared workbooks contain no 2023 election until it is separately added and validated.

Interpretation must be triangulated with source-data validation, candidate/list definition, polling-station characteristics, official protocols, observer reports and alternative explanations. Statistical indicators are screening evidence, not proof of manipulation, intent, or an estimate of legal invalidity.
