# Election Forensics R Toolkit — v1.11.0

Release date: 26 October 2026.

## Added

- **Approximate normality v0.1.2** as an independent module in `modules/approximate_normality/`, based on Klimek, Yegorov, Hanel and Thurner (2012), *Statistical detection of systematic election irregularities*, PNAS, https://doi.org/10.1073/pnas.1210722109.
- Original rescaled logarithmic winner-vote rate, `log(W/(E-W))`, for units where `0 < W < E`; election/area standardisation to zero mean and unit sample SD.
- Figure 2-style **empirical, fixed-width histogram bin probabilities connected by straight segments** rather than kernel-density estimates. Default standardised bin width is 0.2; bin width and visible x-range are configurable.
- English and Serbian-Latin cross-election and within-election figures; within-election comparisons of all eligible stations and nationally prepared Small/Large groups use the same reference standardisation. A separate sensitivity analysis shows stations with fewer than 100 registered voters; primary figures follow the source paper's `E >= 100` inclusion rule.
- Explicitly labelled black standard normal `N(0,1)` reference with correct matching legend colours, multi-row legends, and bilingual plot descriptions.
- Numerical CSV outputs for station-level exclusions, transformed observations, reference means/SDs, empirical bin counts and probabilities, expected normal-bin probabilities, skewness, ordinary kurtosis, Jarque–Bera statistics/p-values, and export diagnostics.
- Synthetic numerical tests, graphical tests, real-data integration tests and export checks; documented module methodology and output guides in both languages.
- Root registry, installation, workflow, citation metadata, Git ignore rules and checksum manifest updated for the new module. Previous analytical-module code remains unchanged.

## Scope and interpretation

The module describes approximate normality and deviations from a normal reference. **Neither a non-normal distribution nor a statistically significant normality test establishes electoral fraud.** Geographic heterogeneity, aggregation and legitimate voting mechanisms can affect these distributions. The module does **not** implement the separate parametric fraud model or estimate its parameters `f_i` and `f_e`.

See [approximate-normality README](modules/approximate_normality/README.md), its [methodology](modules/approximate_normality/METHODOLOGY.md), and [previous release notes](RELEASE_NOTES_v1.10.0.md).
