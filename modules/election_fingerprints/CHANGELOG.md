# Election Fingerprints — changelog

## v0.1.4 — stable (24 October 2026)

First publication-ready module, consolidating the tested development implementation (v0.1.3.1) into one stable release. Implements count-based two-dimensional turnout–vote-share histograms; optional KDE and alternative turnout; bilingual output; national, district and municipality selection; both validated national Size/JHK partitions; station audits, grid exports and status reports.

The 200×200 KDE raster is evaluated at cell centres and clipped through `coord_equal`, preventing scale-censoring warnings. The subtitle font is configurable (14 pt default). Invalid selected geographic identifiers receive explicit diagnostics with suggested keys where available. **Default `INVALID_AREA_POLICY` is now `"error"`**, rather than the permissive `"warn"`; users may opt into warnings instead. Geographical export checks cover all requested levels, all size groups and all output types.

The researcher reported PASS for the numerical, rendering, geographic QA, real-data integration and export tests on three election datasets (national + four districts + two municipalities per election), without unexpected warnings. Promotion to v0.1.4 changes no numerical, estimator, histogram, rendering or validation algorithms relative to v0.1.3.1.
