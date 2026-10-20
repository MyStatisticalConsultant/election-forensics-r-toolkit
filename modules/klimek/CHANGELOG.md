# Changelog

[Srpski (latinica)](CHANGELOG_SER.md)

## 0.1.0-dev — 2026-10-19

- Consolidated the three historical Klimek scripts into **one** executable R script with a bilingual, extensively annotated EDITABLE section, helper functions and calculation blocks.
- Replaced legacy data columns and ad hoc percentile ranking with canonical `Main`, `Master`, `Options`, `Size` and `Size_JHK` from `RZS_data_preparation.R`.
- Added all eight reporting groups, all-option numerical aggregates, two cumulative denominator conventions, two plot families (overlay and facets), bilingual figure generation, user labels and palettes, optional geographic plots, audit metadata and tests.
- Retained T90/T95 **descriptively only**, with explicit bloc definitions; removed unsupported independent-share permutation p-values.
- Added English and Serbian-Latin GitHub documentation and a detailed User Guide.
- **Validation:** pending full local RStudio tests on three prepared datasets and visual inspection; not yet a final research release.
