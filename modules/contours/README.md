# Contour diagrams — v0.1.4

**Status:** v0.1.4 is ready for repository distribution. The author reported passing local synthetic tests and generated PNG outputs for selected national and district settings. A full independent end-to-end test of every geographic selection has not been reported.

This module makes **descriptive standardized two-dimensional isodensity contour diagrams**. The algorithm reproduces the **within-local-area leave-one-out geographic standardization** described by Klimek, Jiménez, Hidalgo, Hinteregger & Thurner (2018), *Forensic analysis of Turkish elections in 2017–2018*, PLOS ONE 13(10), e0204975, section “Voter rigging test”, equations (3) and (4), and Fig. 2(C–F). **It does not implement** the voter-rigging hypothesis test, displacement delta(p), accepted regions, significance levels or fraud inference. Those belong to a separate future module.

## Two reproducible turnout definitions

All candidate/list shares use the national winner, fixed in the RZS preparation dataset.

- **A (paper-consistent):** x = `B/E` = valid votes / registered voters; y = `Winner_votes/B`.
- **B (Toolkit-consistent):** x = `C/E` = ballots in box / registered voters; y = `Winner_votes/B`.

Both raw rates are converted to **municipality-level leave-one-out z-scores**. Each polling station is compared with **all other eligible stations in its own municipality**, regardless of their Size/Size_JHK groups. If the reference group contains fewer than `MIN_REFERENCE_NEIGHBORS` stations or has zero standard deviation in either variable, the station does not receive a usable pair of z-scores and is documented as excluded. Standardization is computed **before** plotting any national/district/municipality subset, and never recalculated using only Small/Large stations.

**Do not confuse the descriptive lines with the statistical voter-rigging test.** The figure alone does not establish the cause, significance or existence of electoral misconduct.

## Classification and reference universe

- `Size`: **Small** versus **Large**, excluding Middle **only from the drawing**, not from the municipal standardization reference. Prepared size thresholds remain nationally defined.
- `Size_JHK`: **Small** is the nationally defined lowest ~20% of polling-station electorates (prepared classification), and **Large** is its complement. Thresholds are not recomputed per district or municipality.
- Prepared sheet `Main` retains the QC-eligible records **with at least 100 registered voters**. This aligns with the principal sample restriction in the Turkish paper. It therefore cannot display stations below 100 registered voters without a separately documented change to the upstream analysis sample/classification.
- Each comparison plots **one smooth 2D KDE per group**, on a common coordinate system with a pooled bandwidth. Levels are **common relative fractions of each group's own KDE peak** (normalised density), rather than common absolute densities. The effective smoothing width is corrected for `MASS::kde2d`'s internal `h/4` convention, as in v0.1.3. This is a visualisation choice, not part of the inferential displacement test in the paper.
- Groups with fewer than `MIN_GROUP_STATIONS` valid standardized observations are skipped and recorded in the manifest. No automatic geographic fallback and no inventing contours.

## Installation and run (in the existing toolkit)

1. Copy this complete `contours` folder into `election-forensics-r-toolkit/modules/` without changing the existing `rzs_data_preparation`, `descriptive_statistics`, `klimek` or `election_fingerprints` modules.
2. In RStudio, choose **Session → Set Working Directory → Choose Directory** and select `election-forensics-r-toolkit/modules/contours`.
3. Install dependencies once if needed: `install.packages(c("readxl", "ggplot2", "MASS"))`.
4. Check the `INPUTS` table and confirm that the already prepared workbooks are in sibling folder `../rzs_data_preparation/RZS_prepared/`.
5. Initially test a single election and `GEOGRAPHIC_LEVELS <- "national"` for rapid inspection. For tests run `source("tests/run_tests.R")` and `source("tests/test_graphics.R")`.
6. Generate figures using `source("Contours.R")`. Tests restore `EF_CONTOUR_TEST_MODE` automatically (including v0.1.4).
7. Visually inspect the EN and SR plots, then enable additional geographic levels and elections. To restrict areas edit `DISTRICT_CODES` or `MUNICIPALITY_CODES` using official string identifiers.
8. Look in `contours_outputs/` for PNGs, each definition’s `standardized_rows.csv` and `standardization_qc.csv`, and the global `contour_export_manifest.csv`. The original RZS files are **never overwritten**.

## Visual annotations (v0.1.4)

- `CONTOUR_ALPHA_RANGE <- c(0.18, 0.95)` fades low-density outer contours while retaining crisp central lines; the contour *geometry* is unchanged from v0.1.3.
- With `SHOW_MODE_ARROW <- TRUE`, an arrow runs from the **KDE mode (density peak) of Large polling stations to the KDE mode of Small polling stations**. Small white markers at both modes are enabled by `SHOW_MODE_MARKERS <- TRUE`. Modes are computed from the same pooled bandwidth and pooled evaluation grid as the displayed group KDEs. The central tendency used is the *mode*, not the group mean.
- For coincident/nearly coincident modes (distance below `MODE_ARROW_MIN_DISTANCE`) or when a mode lies outside the visible plotting limits, the arrow and markers are **omitted**, rather than fabricating an apparent displacement. Set `SHOW_MODE_ARROW <- FALSE` to turn off the visual annotation altogether.
- **Important:** this arrow is descriptive only. It is **not** the published displacement statistic `delta(p)`, a hypothesis test, a significance assessment, or evidence of fraud. Those remain out of scope for this module.

## Plot text, language and names

English (`EN`) and Serbian Latin (`SR`) are available in a single run, with election + main descriptive title and subtitle containing geography, comparison, turnout definition and nationally determined winner. Output subfolders include definition `A_valid` or `B_cast`, geographic level and a location code. Each comparison has separate files for both languages.

## Metadata and reproducibility

`standardized_rows.csv` includes the numerator/denominators and raw rates, QC eligibility, municipality reference size and standardised values. The manifest records each plot request as `PASS` or `SKIP` with the reasons for skips. The supplied test files include synthetic checks of exact leave-one-out calculations and graphical export. The author reported both synthetic test scripts passing on 24 October 2026 in RStudio. The documented selected-area run returned 22 PASS figuresets (44 EN/SR PNG files) and 14 SKIP figuresets. Skips are recorded and are not software failures. The distribution was statically checked for packaging; R execution was not available in the release-building environment. Users should run both tests on their own installation.

## Dependencies and source

R: `readxl`, `ggplot2`, `MASS`. No `reshape2`, `ggExtra`, `tidyverse` bundle or external absolute paths required.

Klimek P, Jiménez R, Hidalgo M, Hinteregger A, Thurner S. (2018). *Forensic analysis of Turkish elections in 2017–2018.* PLOS ONE 13(10): e0204975. https://doi.org/10.1371/journal.pone.0204975

## Troubleshooting: tests PASS but no output folder (fixed in v0.1.1)

The v0.1.0 test scripts set `EF_CONTOUR_TEST_MODE=1` and did not unset it.
If you ran the old tests in the current RStudio session, run:

```r
Sys.unsetenv("EF_CONTOUR_TEST_MODE")
source("Contours.R")
```

With the v0.1.1 tests, this manual step is no longer needed. Both tests use a
private scope and automatically restore the previous environment value, including
when an error occurs. The scripts do not alter the RZS data files.

## Expected skips and selection-specific validation

If `DISTRICT_CODES <- c("00", "26")`, district `26` (Pećki district) may have only three available polling stations in the prepared sample, which is insufficient to draw a two-group KDE. For the tested 2017 district `00`, JHK Small had 12 standardized polling stations, below the configured minimum of 15. Both cases must be recorded as `SKIP`, not treated as an error or corrected by lowering thresholds or substituting a district-wide standardization.

**Local validation evidence (reported):** `source("tests/run_tests.R")` PASS, `source("tests/test_graphics.R")` PASS, `source("Contours.R")` produced 22 PASS and 14 SKIP figuresets for the selected areas and all three configured elections. This confirms that the run completed under those inputs, not every possible input/configuration.
