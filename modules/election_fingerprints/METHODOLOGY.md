# Methodology: observed election fingerprints

[Serbian](METHODOLOGY_SER.md) · [Module](README.md)

## What is replicated

Klimek et al. (2012), Figure 1, describes **two-dimensional histograms of the number of electoral units** for given voter turnout (horizontal axis) and winning party/candidate vote percentage (vertical axis). The paper excludes electoral units with fewer than 100 registered voters. We therefore use the Toolkit's already-validated `Main` and count **one polling station per two-dimensional cell**. No rounding/reconstruction of vote counts, no electorate weights, no smoothing of the primary histogram.

Let E = registered voters, B = valid ballots, C = ballots cast and W = votes for the selected election option. For the primary paper-consistent map use x = 100B/E and y = 100W/B. For the explicitly supplementary turnout sensitivity analysis use x = 100C/E and retain y = 100W/B. Only stations satisfying E>=100, B>0, B<=E and 0<=W<=B are included, plus 0<=C<=E for cast-turnout graphs. Invalid/missing rates are excluded and reported without capping to 100%.

The `Options` worksheet supplies official vote counts and national totals. The winner is the highest `Total_votes` nationally and stays the selected option for every district/municipality. Manual selection is possible and is identified as such on the figure.

For B histogram bins in 0–100%, index k = `findInterval(rate, seq(0,100,length.out=B+1), rightmost.closed=TRUE, all.inside=TRUE)`. A cell count is the sum of polling stations in its x/y combination. Exactly 100% is included in the final bin. Empty cells remain zero and are assigned the low-intensity palette colour. The count sum must equal the number of included stations. `HIST_BINS=50` is our documented bin-width choice, not an undocumented assertion about the exact pixel grid used in the 2012 figure.

## What is intentionally supplementary

- A **kernel-density estimate**, using `MASS::kde2d` with a fixed [0,100] × [0,100] evaluation domain. Legend values equal density divided by its maximum, ranging from 0 to 1; they are **not numbers of polling stations or posterior fraud probabilities**. Ordinary Gaussian KDE is boundary-biased: concentrations near 0% or 100% must be interpreted with that limitation. No KDE is produced below the configured minimum sample size or when one axis is constant.
- Top/right marginal density curves (or marginal histograms for tiny samples) are a design addition, not part of the original Figure 1.
- Ballots-cast turnout is a separately labelled sensitivity definition; it is not silently substituted for the valid-vote ratio.

## Not reproduced

The article's parametric simulation/estimation of `f_i` and `f_e`, Gaussian rescaling of logarithmic vote rates, counterfactual fair-election models and hypothesis tests are **out of scope**. The old R script's three-component `Mclust` labels are not used: cluster separation alone does not identify fraud mechanisms.

## Territorial interpretation

A district/municipality fingerprint is the histogram of its **polling stations**, not a district-aggregated row. Station counts and bin densities are naturally sensitive to local sample size. Similarity/difference of plot shape is not a formal fraud finding; geographic and political heterogeneity are plausible alternatives. Source paper discussion explicitly warns about heterogeneity in fingerprint shapes.

## Reproducibility and citation

Inputs are official RZS `Main` and `Options`; output includes `Source_workbook_MD5`, audit records, exact histogram/KDE grids and status counts. Publish study-specific filtering, bins, selected option and geographic scope. For the algorithmic inspiration cite: Klimek et al. (2012), PNAS 109(41), 16469–16473, https://doi.org/10.1073/pnas.1210722109. The histogram is an independently coded implementation, not the authors' original plotting source code.


## Pre-defined polling-station size strata

In addition to the unchanged national `Main` fingerprint, the new default output provides separate fingerprints for the `Size` groups Small/Middle/Large and the `Size_JHK` groups Small/Large. These assignments are produced and quality-checked in the upstream RZS preparation module; **the new fingerprint module does not infer percentile boundaries or regroup district/municipality stations**. The two alternative classifications each cover all eligible Main polling stations within the given territory but their overlapping group totals cannot be combined. This is stratified descriptive visualisation, not a new test or the parametric fraud model of Klimek et al. The paper-consistent electorate threshold of at least 100 remains unchanged.

### Supplementary KDE raster boundary convention

The 0–100% plotting domain is partitioned into `KDE_GRID` equal raster cells per axis. KDE values are evaluated at the **centres** of those cells (for a 200×200 grid: 0.25%, 0.75%, …, 99.75%). The original observations, Gaussian KDE estimator, bandwidth calculation and primary 2D histogram are unchanged. This avoids `geom_raster()` discarding 796 perimeter tiles whose former centres lay exactly at the plotting limits. Boundary bias of an ordinary Gaussian KDE remains a methodological limitation; this modification corrects rendering only and does **not** implement a boundary-corrected estimator.

### Display-only boundary correction

The 200×200 KDE remains computed by `MASS::kde2d` at half-cell centres. Its displayed 0–100% range is now enforced via `coord_equal(xlim=c(0,100), ylim=c(0,100), expand=FALSE)`, **not hard limits on `scale_x/y_continuous`**, to avoid ggplot discarding border raster rows. This changes neither the estimator nor its numeric grid values. A full-size 200×200 rendering regression is included to guard against raster-row omissions.
