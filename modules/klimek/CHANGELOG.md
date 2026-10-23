# Changelog

[Srpski (latinica)](CHANGELOG_SER.md)

## 0.1.4 — 2026-10-23 (consolidated GitHub release)

- Consolidated all development fixes from v0.1.1 to v0.1.3.4 into one coherent module directory. Replaces the public v0.1.0-dev module in full; no sequence of intermediate patches is required.
- Includes bilingual presentation, national/area title localization, RZS special reporting categories, 10-percentage-point y-axis tick labels, separate standard/JHK B graphics, and readable A-subtitles and legends.
- Explicit zero-station district/municipality rows; 0 stations = no plot, 1 = point, 2+ = curve; area-scoped stale-figure cleanup.
- Updated release identifiers, bilingual guides, tests, manifest and citation. Calculation methods and numerical R code are unchanged from v0.1.3.4-dev.
- Researcher confirmed PASS for all supported presidential/parliamentary elections; detailed parliamentary test log is archived in the validation record, while presidential success is attested without separate transcripts (see VALIDATION.md).

## 0.1.1-dev — 2026-10-21 (visual-only patch)

- Moved full candidate/list names on B graphs out of the main title and into wrapped EN/SR subtitles.
- Replaced the crowded eight-curve B combined overlay with separate standard and JHK plots; added a two-panel B facet as an alternative.
- Set A-plot legends to two rows automatically for three or more electoral options, with wrapped full names and adjustable font size.
- Removed obsolete `B_<option>_combined` PNG/PDF files when rerunning the corresponding plots.
- Added `tests/test_graphics_layout.R` and export-layout checks; updated bilingual user and output guides.
- No changes to vote-count arithmetic, turnout, group membership, normalisations or existing analytical data contracts; new visual RStudio tests and inspection remain pending.

## 0.1.0-dev — 2026-10-19

- Consolidated the three historical Klimek scripts into **one** executable R script with a bilingual, extensively annotated EDITABLE section, helper functions and calculation blocks.
- Replaced legacy data columns and ad hoc percentile ranking with canonical `Main`, `Master`, `Options`, `Size` and `Size_JHK` from `RZS_data_preparation.R`.
- Added all eight reporting groups, all-option numerical aggregates, two cumulative denominator conventions, two plot families (overlay and facets), bilingual figure generation, user labels and palettes, optional geographic plots, audit metadata and tests.
- Retained T90/T95 **descriptively only**, with explicit bloc definitions; removed unsupported independent-share permutation p-values.
- Added English and Serbian-Latin GitHub documentation and a detailed User Guide.
- **Validation:** pending full local RStudio tests on three prepared datasets and visual inspection; not yet a final research release.

## v0.1.2-dev

- All A-family figures now place the full polling-station group name on the second line of the main title.
- Y-axis tick marks for A and B figures are now shown every 10 percentage points.
- B-family figures now show full vertical-axis labels (0%, 10%, 20%, ...).
- English and Serbian figure labels were aligned with the agreed full group names.

## v0.1.3-dev

- A-family figures now show the full polling-station group name as a subtitle-like second line (smaller, not bold).
- Main titles for A and B figures now use localized election and area labels, e.g. "parliamentary 2022 Serbia" and "presidential 2017 Kolubarski district".
- Serbian main titles now use forms such as "parlamentarni 2022 Srbija" and "predsednički 2017 Kolubarski okrug".

## v0.1.3.1-dev — title/test compatibility fix (2026-10-23)

- Updated `tests/test_graphics_layout.R` to call the current six-argument `b_titles()` interface introduced in v0.1.3; the previous test used the four-argument interface and failed with `subscript out of bounds`.
- Explicitly reject unknown election-type labels in `pretty_election_label()` with a readable diagnostic.
- Translate district names already ending in Serbian `okrug` to English `district` without duplication.
- Extended SR/EN national/district title and A-subtitle tests. Cumulative/statistical formulas unchanged.


## v0.1.3.2-dev — special RZS reporting categories (2026-10-23)

- Graph titles use `District_code`, not an assumed territorial suffix, for official special categories: **33** → Overseas and **55** → Prisons; corresponding Serbian labels are Inostranstvo and Zavodi za izvršenje krivičnih sankcija.
- For codes **25–29**, keep the official RZS reporting label and translate an existing `okrug` suffix when necessary, without automatically assigning a geographic district designation. These codes do not establish a polling station's physical location.
- Both A and B title helpers receive the district code, with regression tests for ordinary and special categories in both languages. Numerical results and source files are unchanged.

## v0.1.3.3-dev — Single-observation graph handling

- Prevented repeated `geom_line()` warnings when a selected district/size group contains only one valid polling station.
- Singleton observations are shown as points rather than fabricated cumulative lines; all numerical data and analyses remain unchanged.
- Added `SINGLE_POINT_SIZE` in the EDITABLE settings and `tests/test_single_station_plots.R`.
- Added one concise area-level message listing single-station groups, including the Overseas `Large` group in the 2022 election data.

## v0.1.3.4-dev — explicit handling of empty polling-station groups

- District and municipality summaries now include each eligible area × all eight reporting groups × every electoral option, even when a particular group has zero polling stations.
- An empty group is recorded with `Stations=0`, zero count totals, and `NA` for undefined turnout/share percentages; `NA` is written explicitly in territorial CSV and Excel worksheets. No stations, votes, or shares are fabricated.
- For every plotted area, the console reports its selected zero-station groups **once**, not once per PNG/PDF/language/normalisation.
- Before redrawing a selected area, old module-generated A/B PNG/PDF are removed **only for that area**. Empty-group charts are omitted, and other areas/files remain untouched.
- An absent station group has no curve, one station has a dot, and two or more stations have a line (v0.1.3.3 behaviour retained).
- Added `tests/test_zero_station_groups.R` and expanded `tests/check_exports.R`. All cumulative-curve formulas and canonical group classifications are unchanged.
