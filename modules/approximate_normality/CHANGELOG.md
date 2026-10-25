# Changelog — approximate_normality

## v0.1.2

- Fixed the colour-legend regression introduced in v0.1.1: empirical legend keys now match their plotted curves, and the N(0,1) reference is black.
- Replaced separate colour and linetype guides with a single explicit colour scale; the legend wraps at three entries per row.
- Expanded bilingual graphics tests to validate actual layer colours for four-election, three-group, and under-100 comparisons.
- No changes to log-rate, standardisation, histogram calculations, normality statistics, or CSV schemas.

## v0.1.1

- Identified the black standard-normal N(0,1) bin-probability reference directly in the legend of every English and Serbian-Latin figure, while preserving empirical group colours and multi-row legends.
- Expanded the graphics regression test to check the translated reference labels. No statistical calculations or CSV field definitions changed.

## v0.1.0

- Implemented the Klimek et al. (2012) electorate-based logarithmic vote rate and election/area-wide standardisation.
- Added fixed-width empirical histogram probability curves with theoretical N(0,1) bin masses; primary Figure 2-style charts use no KDE smoothing.
- Added cross-election, within-election Small/Large and separately labelled under-100 sensitivity comparisons, in English and Serbian-Latin.
- Added station-level, histogram-level, QC, skewness/kurtosis/Jarque–Bera and configuration CSV outputs, bilingual scientific documentation and regression tests.
