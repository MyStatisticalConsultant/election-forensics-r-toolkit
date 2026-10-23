# Election Fingerprints — user guide v0.1.4

[Srpski](USER_GUIDE_SER.md) · [README](README.md) · [Methodology](METHODOLOGY.md)

## Environment and prepared workbooks

Install R packages once: `install.packages(c("readxl","ggplot2","MASS","ggExtra","cowplot","readr"))`. In RStudio, set the working directory to `modules/election_fingerprints/`. Required sibling inputs in `../rzs_data_preparation/RZS_prepared/` are `presidential_2017_RZS_prepared.xlsx`, `presidential_2022_RZS_prepared.xlsx` and `parliamentary_2022_RZS_prepared.xlsx`. They contain validated `Main` and `Options` sheets, and **are not distributed in Git**.

## Editable settings in `Election_fingerprints.R`

- `INPUTS`: elections and their prepared-file paths. By default all three are processed; the list may be reduced for a single election.
- `GRAPH_LANGUAGES <- c("EN","SR")`: produces English and Serbian-Latin outputs together.
- `OPTION_MODE <- "national_winner"`: use the highest nationally ranked `Options.Total_votes` option in all territories. `OPTION_MODE <- "manual"` allows overrides with `MANUAL_OPTION_BY_ELECTION <- list(parliamentary_2022="Option_01_votes")`, using verified `Options.Votes_field` values. Labels may be overridden by `OPTION_LABELS_EN` and `OPTION_LABELS_SR` without changing counts.
- `PLOT_HISTOGRAM <- TRUE`, `HIST_BINS <- 50L`: primary station-count 2D histogram. `PLOT_KDE <- TRUE`, `KDE_GRID <- 200L`: separately labelled smoothed supplement. `MIN_KDE_STATIONS <- 10L`: skip KDE for insufficient samples; constant axes are also excluded.
- `TURNOUT_MEASURES <- c("valid","cast")`: primary valid-ballot turnout (`valid`) and optional alternative cast-ballot turnout (`cast`). `valid` is the paper-consistent definition; `cast` is a sensitivity analysis.
- `PLOT_SIZE_GROUPS <- TRUE` with `SIZE_GROUPS <- c("SMALL","MIDDLE","LARGE","JHK_SMALL","JHK_LARGE")`: both national Size classifications, inherited without local regrouping. The classification schemes **overlap**; do not sum their counts across classifications.
- `MAIN_TITLE_FONT_SIZE <- 17` and `SUBTITLE_FONT_SIZE <- 14`: bold title and plain subtitle, respectively. `SAVE_PNG`, `SAVE_PDF`, `SAVE_GRID_CSV`, `SAVE_INPUT_AUDIT` control exports.

### Geographic selection

By default `AREA_MODE <- "national"` generates national plots. For districts and municipalities, save settings such as:

```r
AREA_MODE <- "selected"
GENERATE_DISTRICTS <- TRUE
GENERATE_MUNICIPALITIES <- TRUE
SELECT_DISTRICT_CODES <- c("25", "26", "33", "55")
SELECT_MUNICIPALITY_KEYS <- c("18|71021", "26|90239")
INVALID_AREA_POLICY <- "error"  # default: reject invalid keys
```

`District_code|Municipality_code` is the **composite municipality key**. The municipality code `90239`, for example, belongs with district `26`, not `25`. Selected codes must exist in each chosen election's `Main`; geographic coverage can differ by election. With default `INVALID_AREA_POLICY <- "error"`, an unknown code stops execution and provides a diagnostic (including a suggested existing composite key where possible). `"warn"` is an optional, explicitly chosen alternative to skip invalid requests and process valid ones. `AREA_MODE <- "all"` selects all observed codes at enabled geographic levels; this can create very many figures and use substantial disk space.

National winner is constant across all areas. Each plotting observation remains an individual polling station; no aggregated region-level rows are substituted.

## First run and validation

```r
source("tests/run_tests.R")
source("tests/test_graphics.R")
source("tests/test_geography_validation.R")
source("tests/integration_real_data.R")
Sys.unsetenv("EF_FINGERPRINT_TEST_MODE")
source("Election_fingerprints.R")
source("tests/check_exports.R")
```

The export test verifies national/district/municipality area coverage, groups, both turnout definitions, histogram sums, audits and PNG/PDF files against the selected configuration. The `EF_FINGERPRINT_TEST_MODE=1` environment flag is used internally to load definitions without automatically generating all figures. Clear it as above before the main run; if no `[Fingerprints]` messages appear, first check `Sys.getenv("EF_FINGERPRINT_TEST_MODE")`.

For subsequent plot/style adjustments, run `source("Election_fingerprints.R")`; run `source("tests/check_exports.R")` after new geographic selections or a release update. Because outputs can be replaced, keep archival copies of publication figures separately.

## Where to find results and how to interpret omissions

`fingerprint_outputs/<election>/<area>/EN|SR/` contains primary and supplementary PNG/PDF figures. `groups/<SIZE_CODE>/EN|SR/` contains additional size-classification figures; grid and audit CSV files are stored at the corresponding area/group level. `<election>/fingerprints_status.csv` identifies every generated or omitted output. See [OUTPUT_GUIDE.md](OUTPUT_GUIDE.md).

Zero-station groups have status records but no images. One station is sufficient for one occupied histogram cell; KDE is omitted when there are too few eligible stations or no variability. Polling stations with `B=0` stay in the prepared data/audit but are not plotted because `W/B` is undefined. KDE is not a fraud probability; apparent fingerprint anomalies require external evidence and alternative explanations.
