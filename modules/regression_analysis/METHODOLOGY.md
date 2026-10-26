# Methodology: station-level regression diagnostics

## 1. Intuitive interpretation

A scatterplot displays one polling station per point. The horizontal position represents a characteristic of the station (such as turnout or the number of invalid ballots); the vertical position represents the fraction of votes associated with a candidate or list. A fitted straight line summarises the average association in the observed data. A steep line, or one sloping down rather than up, can be a useful *diagnostic signal* worth comparing across territories, years and station types. Neither the direction nor significance of such a line identifies who might have manipulated ballots — or whether manipulation happened at all.

In the first method, Lukinova and co-authors studied the percentage of **all registered voters** who voted for a given candidate, not the candidate's share among those casting valid votes. Comparing the winner's and another candidate's lines across districts helped the authors investigate the Russian elections of 2004 and 2008. In the second method, the intuition is that some mechanisms of irregular vote reporting might combine unusually high winner support with unusually few invalid ballots. Yet invalid ballots also depend on station size, vote complexity and administration. This is why the module reports both their count and rate and follows up with sensitivity regressions.

## 2. Data, definitions and eligibility

For polling station *i*, let `E_i` be registered electors, `B_i` valid ballots, `C_i` ballots cast (valid plus invalid), `W_i` votes for the nationally determined winning option, and `R_i` votes for the national runner-up. The main turnout definition is `T_i = C_i/E_i`; the secondary sensitivity definition is `T_i^B = B_i/E_i`. The number of invalid ballots is `I_i=C_i-B_i`, while the invalid-ballot rate is `Q_i=I_i/C_i`. The winner's valid-vote percentage is `S_i=W_i/B_i`. Ratios are plotted multiplied by 100, so both axes use percentage-point units where applicable.

The `Master` worksheet retains all stations, including those with fewer than 100 registered voters. Records must have unique station keys, available district and municipality identifiers and logically consistent nonnegative integer values with `1 <= B <= C <= E`, `0 <= W`, `0 <= R`, and `W+R <= B`. A failed record is exported to `station_qc.csv` with a reason. The primary sample requires `E >= 100`; `E < 100` is a separate sensitivity group. Local subgroup thresholds are **not** recalculated.

The two national options are ranked by their aggregated valid votes across eligible stations; they are checked against the prepared `Winner_votes` / fallback column. User-selected overrides must pass the same winner check. Candidate/list labels are read from the `Options` worksheet using the ballot `Option_number`, with an optional verified `OPTION_LABELS` override; ambiguous or absent mappings are rejected rather than inferred from `Option_NN` numbers. The national winner and runner-up remain fixed in district/municipal plots. Partial overrides are supported: an unspecified selected option is resolved from the same verified dictionary.

## 3. Part A: Lukinova, Myagkov and Ordeshook (2011)

The station-level original-form ordinary least squares (OLS) models are:

\[
100\frac{W_i}{E_i}=\alpha_W+\beta_W\left(100\frac{C_i}{E_i}\right)+\epsilon_{Wi},
\qquad
100\frac{R_i}{E_i}=\alpha_R+\beta_R\left(100\frac{C_i}{E_i}\right)+\epsilon_{Ri}.
\]

Replacing `C/E` with `B/E` produces a separately labelled sensitivity run. These are two distinct univariate OLS regressions, estimated using one record per station with **equal station weights**. OLS minimises the sum of squared residuals and produces an intercept and slope for each option. Figures plot individual observations and the actual recorded OLS lines, rather than a smoothed curve.

The source paper, *Metastasised Fraud in Russia's 2008 Presidential Election*, reports analogous `V/E = βT + α` regressions at territorial level (see pp. 613–620, notably Figures 12–29). Its discussion of winner coefficients near or above 1 concerns specific patterns and comparisons from that election. It is **not a general proof criterion**. The paper is reproduced at the level of the variable definition and straight-line fitting procedure; the source's Russian geographic samples, option choices and historical counterfactuals are not reproduced.

**Mathematical coupling matters:** since `W_i <= C_i`, the quantity `W_i/E_i` is part of turnout. A strong positive association is therefore possible even if vote shares remain perfectly stable across stations. For example, if the winner has a constant fraction `s` of cast ballots, then `W_i/E_i \approx s(C_i/E_i)`. The estimated slope can also reflect demographic, geographic or mobilisation differences. The fact that a slope exceeds 1 for some sample does not by itself establish that votes were added.

## 4. Part B: invalid-ballot regressions inspired by Mebane

The original graphical check supplied by the user plots the winner's share of **valid ballots** against the **absolute number of invalid ballots**, not against votes per registered elector. We reproduce that scatterplot and add a station-size-normalised counterpart:

\[
\begin{aligned}
\text{B1:}\quad 100\frac{W_i}{B_i}&=a_1+b_1 I_i+u_i,\\
\text{B2:}\quad 100\frac{W_i}{B_i}&=a_2+b_2\left(100\frac{I_i}{C_i}\right)+v_i.
\end{aligned}
\]

A negative slope is **compatible with some hypotheses** about irregularities but is not required by a universal election-integrity null model. Likewise, a positive slope does not rule out irregularities. Because `I_i=C_i-B_i`, the invalid rate and winner share are both functions of ballot totals; ratios may exhibit artefacts from compositional structure and measurement definitions.

Separate sensitivity regressions estimate:

\[
100\frac{W_i}{B_i}=a+bX_i+\gamma T_i^{(\%)}+\lambda\log E_i+u_i,
\]

where `X_i` is either the invalid count or invalid percentage; optional municipality fixed effects add `+ γ_m 1(municipality_i=m)` when multiple municipalities exist and the number of levels is manageable. These additional models are **not** attributed to a fully specified estimator from Mebane's writings; they are Toolkit extensions for checking whether a bivariate association persists after readily available controls. They are not causal identification strategies.

The only substantive premise claimed from Mebane is the *motivation* for examining a low-invalid/high-winner configuration. The documentation makes no claim that a particular negative OLS slope, p-value, or numeric threshold was prescribed in the attached Lukinova paper.

## 5. Statistical estimation and exported diagnostics

For each OLS fit, the module records the fitted equation, coefficients, classical OLS standard errors, t tests, 95% confidence intervals, adjusted `R²`, F statistic, overall F-test p value, residual standard deviation and sample size. HC3 heteroskedasticity-consistent standard errors are computed from the sandwich covariance estimator:

\[
\widehat V_{HC3}=(X'X)^{-1}X'\,\operatorname{diag}\!\left[\frac{e_i^2}{(1-h_{ii})^2}\right]X(X'X)^{-1},
\]

where `e_i` are residuals and `h_ii` diagonal hat-matrix elements. The reported robust p-values use a residual-degrees-of-freedom t approximation (not clustered inference). Rank-deficient or data-insufficient fits receive explicit status indicators. The Breusch–Pagan-style auxiliary regression of squared residuals on fitted values is a simple heteroskedasticity diagnostic; its reported p-value is descriptive and does not certify the model.

Station-level fitted values, residuals, leverage and Cook's distance are written to CSV for independent scrutiny. Since more than one model and subgroup is estimated, the resulting many p-values should not be interpreted without multiple-testing and dependence considerations. We do not perform geographic clustering of standard errors automatically; polling stations may share geographic shocks.

## 6. Groups and geography

For each requested national/district/municipality area, analyses cover:

- All eligible stations with `E >= 100`;
- `Size == Small` and `Size == Large` using the established national classification;
- `Size_JHK == Small` and `Size_JHK == Large` using the nationally defined JHK classification;
- `E < 100` separately, as a sensitivity analysis.

The first four categories overlap and are **not statistically independent subsamples**. JHK Small/Large are not recomputed for districts or municipalities, preventing local selection artefacts. For an exact boundary `E = 100`, the station belongs to the primary sample, not the under-100 subset.

## 7. Limitations and interpretation

Observed turnout, ballot counts and candidate votes are administrative measurements that may contain errors, legitimate heterogeneity or irregularities. Both model families are ecological station-level correlations. OLS assumptions (linear conditional mean, independent errors, constant variance for classical inference) may fail; HC3 only addresses heteroskedasticity of a particular kind. Small-area and small-station regressions may be unstable, with influential observations. Screening by model diagnostics or multiple comparisons can create false positives. Results should be triangulated with documentary evidence, observation reports, station-level protocols and complementary tools. Neither positive/negative slope nor statistical significance warrants a declaration of fraud.

## References

Lukinova, E., Myagkov, M., & Ordeshook, P. C. (2011). *Metastasised Fraud in Russia's 2008 Presidential Election*. *Europe-Asia Studies, 63*(4), 603–621. https://doi.org/10.1080/09668136.2011.566426

Mebane, W. R. Jr. *A Guide to Election Forensics*. Consult the original source for the broader qualitative argument concerning invalid ballots. The two explicit OLS specifications and their controlled variants here are **Toolkit-defined diagnostics**, not claimed as equations quoted from that guide.
