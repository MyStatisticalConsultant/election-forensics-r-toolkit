# Changelog

## v0.1.3 — Readable two-line figure captions

- Split the excess-votes figure footnote into exactly two concise lines in both English and Serbian-Latin and increased the caption margin to prevent clipping.
- Expanded graphics tests to check the number, non-emptiness, and length of caption lines.
- Conditional excess shading still follows the observed/reference curves, and the statistic remains the sum of positive CSV bin residuals. Core algorithms, parameters, data contracts and CSV schemas are unchanged.

## v0.1.2 — Curve-following excess-vote shading

- Replaced grey bin rectangles with piecewise-linear polygons bounded by the red observed and blue reference curves. At sign changes, interpolated intersections prevent shading beyond either curve.
- Shading is limited to the positive high-turnout region; empty/negative residuals do not create grey polygons. The graph's visual area is **not** integrated to estimate votes: the numerical estimate continues to use the unchanged sum of positive CSV bin residuals.
- Expanded graphics tests to check polygon vertices and interpolated crossings. Updated bilingual methodology and output descriptions.
- Core calculations, station eligibility, simulation parameters and CSV schemas have not changed. The graphics test verifies the interpolated polygon geometry.

## v0.1.1 — Public graphics clarification

- The conditional excess-votes plots now shade positive observed-minus-baseline differences **only above the upper reference-core limit**, matching `positive_residual_votes` in `excess_summary.csv`.
- An EN/SR subtitle reports the conditional positive excess in votes and as a percentage of the observed winner votes; grey shading is explained in the figure caption.
- Corrected the excess-plot baseline legend: it uses the reference-core winner/other-valid-vote ratio, **not a Monte Carlo mean**. The separate integer-anomaly Monte Carlo figures remain unchanged.
- Extended the bilingual graphics tests to check shading against calculated positive bin residuals and to ensure no shading when the positive tail is zero.
- Corrected Serbian thousands/decimal separators in excess-vote annotations; graphics tests now fail on formatting warnings.
- No changes to the numerical estimator, station eligibility, data inputs, simulations, or exported CSV schemas.


## v0.1.0 — Initial public release

Introduced bilingual source-aligned descriptive percentage histograms; original Kobak et al. (2016) integer-percentage Monte Carlo null with registered-electorate weighting, separate 0.1 pp and 0.05 pp controls, and exported simulation envelopes; and a separately labelled, assumption-dependent nonparametric excess-votes scenario with core sensitivity. RZS `Master` inputs, QC logs, geographic selections, independent tests, and CSV exports. Validation: synthetic unit tests, bilingual graphics, real-data Master integration and export checks passed for three prepared elections; independent national-total reconciliation and full 10,000-replicate reference run are not established.
