# Output guide

[Serbian](OUTPUT_GUIDE_SER.md)

Under `fingerprint_outputs/<election_id>/`:

- `fingerprints_status.csv`: one row per processed area and turnout measure, with source MD5, option selection, sample and exclusion counts, KDE status and expected histogram figure counts.
- `<area_dir>/audit_valid.csv`, `audit_cast.csv`: every Main station in that area with computed x/y and QC inclusion reason.
- `<area_dir>/grid_hist_valid.csv`, `grid_hist_cast.csv`: complete 50×50 (or configured) 2D grid; columns `turnout_pct`, `share_pct`, `N_stations`. **Cell counts always sum to included stations.**
- `<area_dir>/grid_kde_valid.csv`, `grid_kde_cast.csv`: complete supplement grid, `density_normalized` in [0,1], only when estimable.
- `<area_dir>/EN/` and `<area_dir>/SR/`: `fingerprint_hist_valid.png/.pdf`, `fingerprint_hist_cast.png/.pdf`, `fingerprint_kde_valid.png/.pdf`, `fingerprint_kde_cast.png/.pdf` (subject to settings, QC sample size).

Area directory names include `National`, `District_<official code>` and `Municipality_<district code>_<municipality code>`. Figure titles contain official human-readable names; directories remain stable by ID.

Histograms use an **integer-count legend**, KDE a **relative-density legend**. Sensitivity outputs include `cast` and explicit labels. An empty area generates audit/status, but no images; small-variance/small-n cases skip KDE and record `insufficient_data`.


## Size-group outputs

The original `<area_dir>/EN|SR/` figures remain unchanged. Each of the five default size groups adds `<area_dir>/groups/<SIZE_CODE>/audit_<measure>.csv`, `grid_hist_<measure>.csv`, optional `grid_kde_<measure>.csv`, and separate `EN/` and `SR/` PNG/PDF figures using the same names as the baseline. `fingerprints_status.csv` now has `Group`, `Group_classification`, `Group_label_EN`, `Group_label_SR`, `N_area_main`, `N_main` (the subgroup's number of stations), and existing QC/count fields. It contains a row for zero-station subgroup/measure combinations with `N_main=0`, `N_included=0`, no rendered figure and `KDE_status=empty`. Previous module-owned figures/grids are deleted on reruns so stale outputs do not masquerade as current ones.

### Geographic-key QA and territorial export validation

For a selected municipality, set `AREA_MODE <- "selected"` and `SELECT_MUNICIPALITY_KEYS <- c("26|90239")` (Peć, where present). A mismatched key such as `25|90239` now emits a warning with a matching-key suggestion when available. Use `INVALID_AREA_POLICY <- "error"` (default) or `"warn"`. After generation, `source("tests/check_exports.R")` validates all configured geographic levels, rather than only national exports. Statistical calculations and graphics are unchanged.
