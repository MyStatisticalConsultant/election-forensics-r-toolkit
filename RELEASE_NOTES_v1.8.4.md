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

The researcher reported PASS for unit, graphics, geographic QA, integration and export checks on presidential 2017/2022 and parliamentary 2022 data. An operational run produced and reconciled 1 national area, 4 districts and 2 municipalities per election, including both Size classifications; no unexpected execution warnings were reported. These checks establish the tested scope, not validity for every geographic code or a future election dataset. The model provides exploratory diagnostics, not a fraud verdict.

The first three modules' 19 R source/test files are byte-for-byte unchanged from the prior public v1.7.9 baseline. The v1.8.4 stable promotion makes no changes to the fingerprint numerical/statistical or graphical algorithms relative to the locally tested v0.1.3.1 development code; its code edits are release metadata and the default strict key-selection policy.
