# Changelog — regression_analysis

## v0.1.8 — Readability and layout corrections
- Model A now places winner and runner-up equations at two fixed, widely separated positions on a standard 0–100% vertical axis; the Large Size panel no longer compresses the annotation spacing.
- JHK figures use a taller 17.5 × 13.0 inch canvas, one shared vertical axis title, and one shared horizontal axis title, avoiding the previous cross-panel and legend collisions.
- JHK footer notes are not artificially hard-wrapped: the B1 note, including “CSV.”, remains on a single line.
- Graphic fixtures assert separated Model A equations, shared JHK axes and captions without newline.
- No change to model specifications, numerical regression code, validation flags or CSV export structure.

## v0.1.7 — Graphics-test synchronization
- Updated the graphic test's obsolete 12-point caption assertion to 13.875 points, matching v0.1.6 rendering.
- Added assertions for the JHK classification subtitle, winner/runner equation separation, bottom-right invalid-ballot annotations and single-row legend when the plotting library exposes guide parameters.
- Normalized a plotting source newline literal. No change to numerical regression routines, quality control or CSV outputs.

## v0.1.6 — JHK dispatch and plot-annotation refinements
- Corrected `Size_JHK` routing from the runner to the custom three-panel JHK renderer, with explicit classification wording in subtitles.
- Moved B1/B2 regression equations to the bottom-right and separated the winner/runner-up lines consistently near the top-left in A panels.
- Changed the standard legend to a single row and increased bottom captions to 13.875 pt (JHK footer 14 pt).
- Preserved numerical regression calculations, quality-control rules and CSV outputs.

## v0.1.5 — Partial named-override lookup fix

- Fixed `subscript out of bounds` in `ra_option_labels_from_table()` when a named character-vector override supplies a label for only one of the two selected options. The function now checks whether each option field exists among the override names before indexing.
- Accepts named character vectors and named lists, and rejects unnamed, duplicate, missing or blank-name overrides with explicit messages. Non-overridden names continue to come from the verified `Options` dictionary.
- Extended numeric unit tests to cover winner-only, runner-only, both-option and list-form overrides, plus invalid unnamed override input.
- **No changes** to regression formulae, numerical fitting, QC eligibility or plot functions. RStudio tests must be rerun for this development release.


## v0.1.4 — Larger type, JHK three-panel layout and verified option names

- Enlarged all figure typography by a factor of 1.5 and inset two-row OLS annotations from the top-left panel frame (approximately 5 mm at the configured export sizes).
- Removed personal attribution from Model A plot titles; source attribution remains in methodology and citations.
- Replaced the JHK display with All and JHK Small above, and JHK Large centred below, using a shared legend. The `Size` figure retains the under-100 sensitivity panel.
- Resolved candidate/list names from the RZS `Options` worksheet via ballot `Option_number`; verified `OPTION_LABELS` overrides are supported, while unresolved/ambiguous labels produce a clear error rather than invented identities. Names and their source are saved to `selected_options.csv`.
- Updated bilingual plotting tests, option-label fixture tests, documentation and module checksums.
- **Statistical specification, regression fitting and coefficient calculations are unchanged.** The new rendering and option-label lookup require RStudio confirmation.

## v0.1.3 — Graphics-test label-case correction

- Corrected the bilingual graphics-test fixture: the English B1 axis is accurately labelled `Number of invalid ballots`, but the test mistakenly searched for capitalised `Invalid` using case-sensitive matching.
- Extended the assertions to cover both B1 (invalid-ballot count) and B2 (invalid-ballot rate) labels in English and Serbian Latin.
- Production regression, graphics generation, model parameters and CSV exports are unchanged. This is a test-only functional correction; local RStudio graphics validation remains necessary.

## v0.1.2 — Selected-runner QC test correction

- Fixed the QC test fixture to modify the **actually selected runner-up vote column**, obtained from `ra_choose_options()`, instead of modifying an unrelated `Option_02_votes` column.
- The fixture now deliberately ensures `Winner + RunnerUp > B` and verifies rejection with `INVALID_COUNTS`.
- The tested production regression core, plotting functions, model configuration and CSV specifications are **unchanged**. This is a synthetic-test correction only; RStudio validation is still required.

## v0.1.1 — Synthetic test-fixture correction

- Corrected the invalid-ballot fixture: the previous `pmin(3, ...)` cap left only four distinct `invalid_count` values, and the correctly enforced five-value minimum returned `INSUFFICIENT_X_VARIATION`. B1 and B2 now test data with sufficient variation.
- Retained an explicit test that deliberately limited x-variation is reported as `INSUFFICIENT_X_VARIATION` rather than forced into an OLS fit.
- Replaced exactly straight-line synthetic fixtures with small deterministic perturbations to prevent misleading `summary.lm` perfect-fit warnings. The Lukinova coefficient fixture uses perturbations orthogonal to turnout so its expected slope and intercept remain exact.
- **No changes** to production numerical regression functions, graphical functions, sample eligibility, or CSV definitions. Local RStudio test confirmation is required before publication.

## v0.1.0 — First development release

- Added Lukinova et al. (2011) original-form OLS vote-to-electorate regressions for the nationally identified winner and runner-up.
- Added winner valid-vote share versus invalid-ballot count and invalid-ballot rate regressions; controlled turnout/size sensitivity and optional municipality fixed effects.
- Added both existing prepared size classifications (`Size`, `Size_JHK`), plus separate `E < 100` sensitivity; national groups are never recalculated locally.
- Added geographic analysis, bilingual EN / Serbian-Latin four-panel figures, station-level diagnostics and numeric CSV exports.
- Added four tests and bilingual README/methodology/output guides.

The locally tested v0.1.3 computations remain the baseline; v0.1.4 graphical and Options-dictionary integration require renewed RStudio validation before GitHub publication.
