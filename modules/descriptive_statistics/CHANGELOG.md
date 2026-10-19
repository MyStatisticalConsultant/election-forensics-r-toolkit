# Changelog — Descriptive Statistics module

[Srpski](CHANGELOG_SER.md)

## v0.3.1 — 19 October 2026 — explicit primary analytical group

- Added **`100 or more`** as an explicit national, district and municipality reporting group, exactly equal to upstream `Main`.
- Preserved `All = 100 or more + QC-accepted Less than 100` and both independent size-partition identities.
- Added the **eighth** correlation matrix at each geographic level (`Corr_D_08`, `Corr_M_08`); earlier IDs were not changed.
- Updated robust/statistical, Word, Excel and CSV representations of that group; added test reference totals and export checks.
- **Documentation-only follow-up:** consolidated bilingual README, methodology, data dictionary, validation and GitHub publication guidance; **no new numerical algorithm changes in this documentation package**.

## v0.3.0 — 18 October 2026 — journal and robust statistics

- Added one Word report per election with compact national tables, full geographic appendices and applied inferential tests.
- Added median/IQR, quantiles, Tukey outlier counts, turnout–vote-share joint bins and within-area Pearson/Spearman associations.
- Applied Kruskal–Wallis and JHK Wilcoxon tests with documented BH families and numeric result exports.

## v0.2.1 — 18 October 2026 — correlation edge case

- Fixed generation of correlation pair metadata for zero-area, zero-variable and one-variable inputs; regression tests expanded.

## v0.2.0 — 18 October 2026 — area-level expansion

- Added QC-accepted under-100 group, national/district/municipality presentation summaries, styled outputs and aggregate correlation matrices.

## v0.1.0 — 18 October 2026 — first module

- Canonical prepared-data input, districts/municipalities, two size classifications and all-option aggregation.

**Validation:** scoped to the three tested elections, with independent numerical agreement reported by the researcher; a complete v0.3.1 RStudio log remains to be archived. See [VALIDATION.md](VALIDATION.md).
