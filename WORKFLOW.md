# User workflow — run one module without starting over

[Srpski (latinica)](WORKFLOW_SER.md) · [Module registry](MODULE_REGISTRY.md)

## 1. One-time preparation

From the **existing local toolkit directory** `modules/rzs_data_preparation/`, configure `INPUTS` and run `source("RZS_data_preparation.R")` once per input/source version. The results are stored in `modules/rzs_data_preparation/RZS_prepared/`, normally:

```text
presidential_2017_RZS_prepared.xlsx
presidential_2022_RZS_prepared.xlsx
parliamentary_2022_RZS_prepared.xlsx
```

These workbooks contain `Main` (default forensic sample, E >= 100 and QC-eligible), `Master` (all prepared records with QC flags), and `Options` (candidate/list dictionary). Keep them locally and back them up. Neither downstream runner modifies them. The source files are not part of the GitHub repository, and a new download of repository code will **not** supply them automatically.

## 2. Run descriptive statistics alone

In RStudio set the **working directory** to your existing `election-forensics-r-toolkit/modules/descriptive_statistics` directory. Confirm the `INPUTS$prepared_file` relative paths point to the existing three workbooks. Then run:

```r
source("Descriptive_statistics.R")
```

Outputs appear under `descriptive_outputs/`. The preparation and Klimek scripts are **not** executed. Tests are recommended after installing/updating code or changing data, but do not need to run each time you change only reporting parameters.

## 3. Run Klimek alone

In RStudio set the **working directory** to `election-forensics-r-toolkit/modules/klimek`. Its default `INPUTS` expects the same workbooks in sibling `../rzs_data_preparation/RZS_prepared/`. To verify the Klimek module before first use:

```r
source("tests/run_tests.R")
source("tests/test_graphics_layout.R")
source("tests/test_single_station_plots.R")
source("tests/test_zero_station_groups.R")
source("tests/integration_real_data.R")
source("Klimek.R")
source("tests/check_exports.R")
```

After validation, for ordinary changes to the appearance or choice of plots:

```r
source("Klimek.R")
```

Results are written into `klimek_outputs/`, not the prepared workbooks. The script runs **all elections listed in its editable `INPUTS`**. To analyse only one election, retain just one corresponding row in all `INPUTS` columns; restore rows later as needed. Adjust `GRAPH_LANGUAGES <- "EN"`, `"SR"`, or `c("EN","SR")`; `CURVE_NORMALISATIONS <- "both"` generates both denominators.

## 4. When to rerun what

| Change | RZS preparation | Descriptive | Klimek |
|---|---|---|---|
| Add Klimek module, prepared XLSX unchanged | No | No | Test/run Klimek |
| Change graph language, colours or selected options in Klimek | No | No | Run Klimek only |
| Change descriptive report options | No | Run descriptive only | No |
| New official RZS input workbook or corrected original source | Reprepare + validate | Rerun affected election if used | Rerun affected election if used |
| Change QC thresholds, canonical fields or `Size`/`Size_JHK` definitions | Reprepare + validate | Rerun/check affected outputs | Rerun/check affected outputs |
| Add another independent forensic method | No, if prepared data compatible | No | No |

**Important:** The current scripts use local file presence, not a full dependency manager. They do not automatically detect stale inputs. A previously generated workbook may be out of date after a source/schema/QC change even if its filename is unchanged. Record source checksums, script version, configuration and run dates; if in doubt revalidate/recompute the affected outputs. Generated output filenames can be overwritten on reruns, so save publication snapshots separately.

## 5. GitHub and local files are different layers

GitHub stores *code, methods and tests*. Your PC holds *raw official XLSX, prepared XLSX, and exported graphs/tables*. When syncing new code, preserve `raw_data/`, `RZS_prepared/`, `descriptive_outputs/` and `klimek_outputs/`. `.gitignore` protects them from normal Git commits; copying a full ZIP over a local folder is a different operation and should be reviewed before overwriting anything.

For installation and module instructions, see the repository [README](README.md) and individual module documentation.


**Klimek v0.1.4:** Run `source("tests/test_zero_station_groups.R")` alongside the existing tests; empty district/municipality groups are explicitly exported and old selected-area Klimek images are removed on rerun.
