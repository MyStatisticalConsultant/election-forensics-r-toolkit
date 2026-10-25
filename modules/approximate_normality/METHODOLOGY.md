# Methodology — approximate normality of logarithmic vote rates

[Srpski (latinica)](METHODOLOGY_SER.md) · [Module README](README.md)

**Source basis:** Klimek, P., Yegorov, Y., Hanel, R., & Thurner, S. (2012), *Statistical detection of systematic election irregularities*, *Proceedings of the National Academy of Sciences*, 109(41), 16469–16473; Supplementary Information; https://doi.org/10.1073/pnas.1210722109. In particular, see *Data Collapse* and Figure 2 (article p. 2), *Approximate Normality* and Figure 3 (p. 3), *Discussion* (p. 5), and Tables S2–S3 (Supplementary Information pp. 4–5).

## A. Intuitive explanation

### Why examine the shape of an election distribution?

Polling stations vary in their support for a nationally selected winning party or candidate. The fraction of registered electors who voted for that winner is bounded between zero and one. It may be more informative to transform it into an *unbounded logarithmic odds*, and then put the transformed values for each election on a common scale. A station with an unusually high or low winner-vote rate ends up in one of the tails. Different elections can then be compared without mixing differences in their overall winner support and variability.

If many election units are subject to similar mixing processes, the rescaled distributions may look roughly bell-shaped. Klimek et al. report this as **approximate normality**, not as a physical law obeyed by every legitimate election. Very long tails, asymmetry, or multiple peaks may motivate further investigation. Yet a large deviation can also arise from ordinary geographic sorting, different population groups, differential mobilisation, special electorates, or aggregation effects. Conversely, some manipulations need not change the shape appreciably. Therefore: **neither a visual difference nor a Jarque–Bera p-value identifies fraud or quantifies fraudulent votes**.

### Why do the paper's lines look angular?

The supplied legacy `Approx_normal.r` uses `geom_density()`, which calculates a smoothed kernel-density estimate. In the original paper's Figure 2, empirical histogram measurements are shown at discrete locations and connected. A small-sample or narrow-bin histogram is consequently jagged. The new module calculates the bin counts, divides each by that group's sample size and connects the observed bin-centre values directly. No smoothing kernel is applied.

The original publication does not provide a precise reproducible histogram bin width. The **default 0.2 standardized units is an explicitly configurable Toolkit choice**, not a verified recovered parameter from the authors' code. To compare graphs fairly, hold the width fixed and inspect the numerical bin tables.

### Why separate the under-100 subgroup?

The paper excludes units with electorate smaller than 100 to reduce extreme rates arising from very small numbers. The Toolkit preserves the same primary exclusion but displays otherwise valid under-100 stations in a separately labelled *sensitivity* figure. Such plots are exploratory and may be noisy. They are never pooled into the baseline mean and SD used by the primary analysis.

## B. Formal algorithm

### 1. Definitions, QC, eligibility

For station i let E_i (N_i in Klimek et al.) be registered electors, B_i valid ballots, C_i ballots cast and W_i votes for the **nationally selected winner**. Basic arithmetic requires finite nonnegative integer counts, E_i ≥ 1, 0 ≤ W_i ≤ B_i ≤ C_i ≤ E_i, and a unique station identifier. The logarithmic transform additionally requires 0 < W_i < E_i. Where W_i is zero or equals E_i, the log odds is undefined and the station is excluded rather than corrected, clipped or assigned an arbitrary pseudocount. The module exports the reason.

**Primary sample:** stations satisfying these requirements with E_i ≥ 100. **Sensitivity sample:** stations satisfying the same arithmetic requirements with E_i < 100. The official prepared `Master` tab contains both groups; unlike `Main`, it is not restricted in advance to E_i ≥ 100.

### 2. Original logarithmic vote rate

The paper's equation is

\[
\nu_i = \log\left(\frac{W_i}{E_i-W_i}\right)
      = \operatorname{logit}\left(\frac{W_i}{E_i}\right).
\]

It is **not** `log((B_i-W_i)/W_i)`, `log((C_i-W_i)/W_i)` or their inverse. The denominator is the number of registered people not counted among winner votes, including nonvoters and other valid/invalid votes where applicable. The result is an electorate-based rate rather than a winner's share of valid ballots.

### 3. Standardisation / data collapse

In a given election k and geographic area g, calculate the ordinary (unweighted) mean and **sample standard deviation** of ν_i over **all** primary-eligible stations in that area:

\[
\bar\nu_{k,g}=\frac{1}{n_{k,g}}\sum_{i\in A_{k,g}}\nu_i,\qquad
s_{k,g}=\sqrt{\frac{1}{n_{k,g}-1}\sum_{i\in A_{k,g}}(\nu_i-\bar\nu_{k,g})^2}.
\]

For every usable station, including a member of a subgroup, calculate

\[
z_i=\frac{\nu_i-\bar\nu_{k,g}}{s_{k,g}}.
\]

This produces mean 0 and sample SD 1 within the *all-primary* distribution. Small, Large, and E<100 subsets **do not get independent mean/SD estimates** because that would remove their between-group displacement. At the national level this implements election-wide standardisation as in the cross-election comparison. At district or municipal levels it is a transparent area-specific extension, not a replication of an original election-wide result. Require n≥30 primary stations and a positive SD before producing charts.

### 4. Histogram, fixed bins, probability mass

Choose positive common standardized bin width h (default 0.2). For a finite value z_i, the index is

\[
k_i=\left\lfloor z_i/h+\frac{1}{2}\right\rfloor,
\]

with bin centre x_k=kh and half-open interval [kh−h/2,kh+h/2). For group G the observed bin probability is

\[
\widehat P_G(k)=\frac{\#\{i\in G:k_i=k\}}{|G|}.
\]

All bins from the minimum to maximum index occurring in the displayed comparison groups are included, so there are explicit zero-count bins. Lines join the empirical points (x_k, P_G(k)) without statistical smoothing. The theoretical normal comparison uses **the same probability-per-bin scale**:

\[
P_0(k)=\Phi(kh+h/2)-\Phi(kh-h/2),
\]

where Φ is the standard normal CDF. This is more directly comparable than plotting `dnorm(x)` (a density per unit x) against probability masses. This coherent bin-mass construction follows the published binned-plot concept; it is not a claim of exact pixel-level reconstruction of Figure 2.

The graph defaults to x from −5 to +5 for legibility. All observed bins, including tails outside this visible range, are saved in CSV. Do not confuse an x-axis crop with deletion from summary statistics.

### 5. Comparison designs

**Cross-election figure:** each election's national (or selected matched-area) full primary-eligible sample is standardized using that election's own primary mean and SD. Their bin probabilities, using the same bin width and 0-centred bin lattice, are overlaid. A plot requires at least two elections in that area. Colour legends have at most three elections per row.

**Within-election figure:** the all-primary distribution is shown alongside the prepared `Size`-labelled Small and Large stations, omitting other Size classes as separate curves but retaining them in the **All** group and in reference standardisation. An individual Small or Large curve requires at least ten valid stations; the **Size categories come from national preparation** and are never recomputed on the selected district or municipality.

**Under-100 sensitivity figure:** primary All is compared with the separately eligible E<100 group, which is transformed using the **primary E≥100 mean/SD**. Under-100 cases are never included in the reference estimate. A separate curve requires at least ten valid under-100 stations in the selected geographic area.

### 6. Skewness, ordinary kurtosis and Jarque–Bera

For group G of size n, define central moments m_j = n⁻¹Σ(z_i−z̄)^j, and compute

\[
\mathrm{skewness}=m_3/m_2^{3/2},\quad
\mathrm{kurtosis}=m_4/m_2^2,\quad
\mathrm{excess\ kurtosis}=\mathrm{kurtosis}-3.
\]

This is **ordinary Pearson kurtosis**, not excess kurtosis; its normal reference is **3**, matching the paper's discussion and Tables S2–S3. The descriptive Jarque–Bera statistic is

\[
JB=\frac{n}{6}\left(\mathrm{skewness}^2+\frac{(\mathrm{kurtosis}-3)^2}{4}\right),
\qquad p=P(\chi^2_2\ge JB).
\]

The chi-square p-value is an asymptotic iid-style reference. Polling-station outcomes are geographically dependent and differ in electorate sizes; with large n, tiny non-Gaussian effects are often statistically detectable. These p-values are **shape diagnostics only**, not operational fraud flags. Kurtosis and skewness can change with geographical aggregation, as the article expressly illustrates.

## C. Distinctions from the paper and reproducibility

The article reports multi-country electoral-unit distributions in Figure 2, not a four-subgroup breakdown inside an election. The Toolkit adds subgroup, geographic and under-100 analyses. The original figure's exact bin width and plotting software are not supplied in the attached paper or Supplementary Information; we preserve a clear code/configuration record rather than claim an exact graphical replica. The module does not estimate the separate incremental/extreme fraud parameters described elsewhere in the article. Histogram tables, group counts, per-station values, area-specific standardisation and raw test values are exported to CSV for independent auditing.

## D. Interpretive checklist

Check the winner choice against `Options`; reconcile station counts and official totals upstream; check exclusions (especially W=0, W=E, E<100); compare full data with local/geographic subsets; inspect the bin-width sensitivity, tail data and group sizes; seek independent observer or legal evidence before attributing irregularities to manipulation. Neither a normal-looking curve nor a rejection of normality resolves the integrity of an election.
