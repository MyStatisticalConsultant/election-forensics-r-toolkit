# Election Forensics R Toolkit — v1.8.4 (stable)

Release date: 24 October 2026. Includes **Election Fingerprints v0.1.4 (stable)**.

## New in this release

- Added observed count-based two-dimensional election fingerprints following the Figure 1 approach of Klimek et al. (2012), with a separately labelled KDE supplement and alternative ballots-cast turnout definition.
- Added bilingual PNG/PDF for national, selected/all districts and municipalities and the two pre-existing polling-station-size classifications (`Size`: Small/Middle/Large; `Size_JHK`: Small/Large), while preserving the baseline ALL plots.
- Preserved the nationally selected candidate/list at every territorial level; included auditable station inclusion/exclusion, grids and stable area identifiers.
- Fixed KDE raster display limits so that 200×200 supplemental heatmaps render without spurious boundary-cell warnings; increased editable subtitle font to 14 pt.
- Added explicit validation of selected district/municipality identifiers and **strict default** `INVALID_AREA_POLICY <- "error"`. `"warn"` remains an opt-in alternative.
- Expanded automated tests to include geographic-key diagnostics, strict failure, incomplete-export rejection and reconciliation across all selected levels, size groups, turnout definitions and generated files.
- Updated **all root documentation**, citation version, bilingual installation/workflow and module registry. The public archive excludes development packages, private maintainer instructions, original RZS workbooks and generated figures.

## Validation and limitations

Unit, graphics, geographic-key, integration and export checks were recorded as PASS for presidential 2017/2022 and parliamentary 2022 data. Export reconciliation covered one national area, four selected districts and two selected municipalities per election, including both Size classifications. These checks document the tested scope, not every possible geographic selection or future dataset. The figures are exploratory diagnostics, not a fraud verdict.

The first three modules' R source and test files were unchanged from the previous v1.7.9 release. The fingerprint numerical and graphical algorithms were preserved from the tested implementation; the stable release added metadata and strict geographic-key selection by default.
