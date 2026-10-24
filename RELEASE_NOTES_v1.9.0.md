# Election Forensics R Toolkit — v1.9.0

Release date: 25 October 2026.

## Added in this release

- **Contour diagrams v0.1.4**, a new independent downstream module at `modules/contours/`.
- Descriptive two-dimensional kernel-density contours of geographically standardised turnout and vote share for the nationally selected winning candidate or list.
- Two turnout specifications for sensitivity checks: A = valid ballots/registered voters (`B/E`), B = ballots cast/registered voters (`C/E`); winner share is `Winner_votes/B` in both.
- Municipal leave-one-out standardisation using all other QC-eligible polling stations in the municipality before division into Size/JHK groups or reporting areas.
- Small/Large and JHK comparisons; EN/SR-Latin PNG figures at national, district and municipality levels.
- Smooth contour display, faded low-density contours, legend, and a descriptive arrow from the Large-group to the Small-group KDE mode.
- `standardized_rows.csv`, `standardization_qc.csv`, `contour_export_manifest.csv`, and unit/graphics test scripts.
- Updated root module list, installation/workflow guides, Git ignore rules and citation metadata on an equal footing across all modules.

## Scope and interpretation

The contour plots are **descriptive**. They do not implement a voter-rigging hypothesis test or `delta(p)` statistic. A visible shift between groups does not establish fraud. The module documents `SKIP` cases where a group is too small, its reference set is inadequate or a density cannot be estimated; it does not relax geographic QC rules to manufacture a plot. Supported prepared elections are presidential 2017/2022 and parliamentary 2022.

Existing analytical module code and its previous release notes are unaffected by this root-documentation update. See [module documentation](modules/contours/README.md) for execution details and method limitations; [historical v1.8.4 notes](RELEASE_NOTES_v1.8.4.md) remain available.
