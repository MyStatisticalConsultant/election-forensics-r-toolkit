# Contour diagrams

**Version:** 0.1.4 · [Srpski (latinica)](README_SER.md)

The `contours` module generates **descriptive, two-dimensional kernel-density contour diagrams** comparing polling-station turnout and the vote share of the nationally selected winning candidate or list. It follows the within-geographic-unit standardisation approach discussed by Klimek et al. (2018). Figures are available in English and Serbian (Latin script) at national, district and municipality levels.

This module **does not implement the voter-rigging test** or assess statistical significance or electoral fraud. The displacement statistic and related inferential procedures are reserved for a separate module.

## Variables and geographical standardisation

The prepared RZS data use the following variables: `E` (registered voters), `B` (valid votes), `C` (ballots cast/in the ballot box), and `Winner_votes` (votes for the nationally selected winner). Two turnout definitions permit a robustness comparison:

| Specification | Turnout (x) | Winner vote share (y) |
| --- | --- | --- |
| **A — article-oriented** | `B/E` | `Winner_votes/B` |
| **B — Toolkit-oriented** | `C/E` | `Winner_votes/B` |

For each definition, turnout and winner vote share are standardised separately against **all other eligible polling stations in the same municipality** (*leave-one-out* z-scores). The reference set is formed before filtering by station size or geographic reporting level. Neither the reference mean nor its standard deviation is recomputed separately for Small and Large stations. A reference set with fewer than `MIN_REFERENCE_NEIGHBORS` peers, or zero variance in either variable, produces no usable pair of standardised coordinates.

The same nationally defined station-size classifications from data preparation are applied throughout:

- **`Size`** — Small versus Large; Middle is not plotted, but remains in the municipal standardisation reference set.
- **`Size_JHK`** — Small stations are below the national 20th-percentile size threshold; Large denotes the remaining stations. This threshold is not recalculated by district or municipality.

By default, the module reads the prepared workbook's `Main` sheet, which is restricted to quality-eligible polling stations with **at least 100 registered voters**. Stations below that threshold are not included in the default diagrams.

## Contours and graphical interpretation

Each group is represented by a separately estimated **two-dimensional kernel density (KDE)**. The groups use a shared pooled bandwidth and coordinate system. `geom_density_2d()` draws common **relative density levels** (fractions of each group's own density maximum); these are not equal absolute-density levels across differently sized groups. Smoothing parameters and the visible plotting window are configurable. Observations outside the visible window still contribute to density estimation.

The **outer contour lines are paler** than those near the density peak. When enabled, the arrow points from the **KDE mode of the Large group to the KDE mode of the Small group**, with optional markers at both modes. It is omitted if the modes are nearly coincident or outside the visible window. This is a descriptive annotation: **it is neither an estimated fraud effect nor the test statistic `delta(p)`**.

A difference in the shapes or locations of two contour families is **not proof of irregularities**. Any substantive interpretation requires local context, source records, observer reports and further analysis.

## Installation and execution

1. Place this directory at `election-forensics-r-toolkit/modules/contours/`, alongside `rzs_data_preparation`.
2. Install the required R packages if missing:

   ```r
   install.packages(c("readxl", "ggplot2", "MASS"))
   ```

3. Set the RStudio working directory to `modules/contours`. In the **EDITABLE SECTION** of `Contours.R`, check `INPUTS` and the prepared workbook paths (normally `../rzs_data_preparation/RZS_prepared/`). Select the elections and settings to analyse.
4. Run the included checks and then generate output:

   ```r
   source("tests/run_tests.R")
   source("tests/test_graphics.R")
   source("Contours.R")
   ```

For an initial run, select one election and `GEOGRAPHIC_LEVELS <- "national"`. For subsequent runs, set `GRAPH_LANGUAGES <- "EN"`, `"SR"` or `c("EN", "SR")`; `TURNOUT_DEFINITIONS <- c("A", "B")`; and select `COMPARISONS <- c("Size", "Size_JHK")`. To restrict district or municipality analyses, set `DISTRICT_CODES` and `MUNICIPALITY_CODES` to the relevant official codes. The script does not modify prepared RZS workbooks.

## Outputs and quality checks

Outputs are written locally under `contours_outputs/`, organised by election, definition and geographic level. They include:

- Bilingual **PNG contour diagrams** (when both languages are selected).
- `standardized_rows.csv` — raw rates, standardised coordinates, eligibility and reference-group information.
- `standardization_qc.csv` — counts of eligible and excluded stations.
- `contour_export_manifest.csv` — status (`PASS` or `SKIP`) and reason for each requested figure set.

A figure set is marked **`SKIP`** when either comparison group has fewer than `MIN_GROUP_STATIONS` suitable observations (default: 15), or when a usable density plot cannot be estimated. For example, a district with fewer than the minimum number of polling stations cannot support a two-group KDE comparison. Such omissions are documented; the script does not substitute a broader geographic reference or manufacture contours.

If an earlier session left `EF_CONTOUR_TEST_MODE=1` enabled, run `Sys.unsetenv("EF_CONTOUR_TEST_MODE")` before generating outputs. The included test scripts normally restore the pre-test setting automatically.

## Reference

Klimek, P., Jiménez, R., Hidalgo, M., Hinteregger, A., & Thurner, S. (2018). *Forensic analysis of Turkish elections in 2017–2018*. **PLOS ONE, 13**(10), e0204975. https://doi.org/10.1371/journal.pone.0204975
