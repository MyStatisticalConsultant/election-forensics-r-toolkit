# Election Fingerprints — v0.1.4 (stable)

[Srpski (latinica)](README_SER.md) · [User guide](USER_GUIDE.md) · [Methodology](METHODOLOGY.md) · [Output guide](OUTPUT_GUIDE.md) · [Validation](VALIDATION.md) · [Changelog](CHANGELOG.md)

An independent Election Forensics R Toolkit module for **observed two-dimensional election fingerprints** inspired by Figure 1 of Klimek et al. (2012). The primary figure is a histogram of **polling-station counts**, not a fitted density and not proof of election manipulation. KDE density surfaces and ballots-cast turnout are separately labelled supplementary analyses. The module does **not** estimate the article's fraud parameters `f_i`/`f_e`.

## Definition

From the prepared RZS `Main` worksheet, with eligible registered electorate `E ≥ 100`:

- Primary turnout (`x`): `100 × B/E`, where `B` is valid ballots; winning option share (`y`): `100 × W/B`.
- Sensitivity turnout (`x`): `100 × C/E`, where `C` is ballots cast; `y` still uses `B`.
- Each eligible polling station with defined rates contributes one count to its 2D histogram cell, irrespective of electorate size. With `HIST_BINS <- 50`, the grid has 50×50 equally sized 2-percentage-point cells.
- The winning option is selected from `Options.Total_votes` nationally and remains fixed for all subnational figures; an explicit manual choice is available.
- Supplementary KDE is provided by `MASS::kde2d` on a 200×200 raster with relative peak normalization, *not* by the original histogram. KDE can show boundary bias and is omitted for insufficient station counts or variation.

## Quick start

Working directory: `modules/election_fingerprints/`. Prepared Excel files must exist in sibling `../rzs_data_preparation/RZS_prepared/`. Install once:

```r
install.packages(c("readxl", "ggplot2", "MASS", "ggExtra", "cowplot", "readr"))
```

Test, generate and verify:

```r
source("tests/run_tests.R")
source("tests/test_graphics.R")
source("tests/test_geography_validation.R")
source("tests/integration_real_data.R")
Sys.unsetenv("EF_FINGERPRINT_TEST_MODE")
source("Election_fingerprints.R")
source("tests/check_exports.R")
```

Use the entry-point **EDITABLE INPUTS** block for `AREA_MODE` (`national`, `selected`, `all`), `GENERATE_DISTRICTS`, `GENERATE_MUNICIPALITIES`, IDs, `GRAPH_LANGUAGES`, national/manual winner selection, plot and turnout variants. **`INVALID_AREA_POLICY <- "error"` is explicitly included and enabled by default:** unknown selected district/municipality keys stop execution. The optional `"warn"` setting continues after reporting the rejected keys and possible corrections.

The five optional-by-setting but **enabled-by-default** polling-station strata are `SMALL`, `MIDDLE`, `LARGE` from `Size` and `JHK_SMALL`, `JHK_LARGE` from `Size_JHK`. Their membership is inherited from the validated national preparation, never recomputed inside an area. The two classification schemes overlap: do not add all five group counts together.

Outputs are written to `fingerprint_outputs/<election>/<area>/`, and size-group files to `<area>/groups/<GROUP>/`. PNG/PDF plots are separately produced in English and Serbian-Latin; CSV exports include full histograms, audits, group status, and supplementary KDE grids where estimable. Empty groups are recorded without figures; single-station groups retain a histogram but not KDE. The script never edits prepared workbooks.

**Validation:** Researcher-reported PASS for unit, graphics (200×200 KDE and 14-pt subtitle), geographic-key QA, real-data integration, and comprehensive geographic export checks across the three supported elections. Tested operational scope: one national area, four districts and two municipalities per election, six size/baseline outputs per area; no unexpected R warnings. See [VALIDATION.md](VALIDATION.md) for exact scope and limitations.

Source: Klimek, P., Yegorov, Y., Hanel, R., & Thurner, S. (2012), *Statistical detection of systematic election irregularities*, PNAS 109(41), 16469–16473. https://doi.org/10.1073/pnas.1210722109
