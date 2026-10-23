# Workflow — run modules independently

[Srpski](WORKFLOW_SER.md) · [Installation](INSTALLATION.md) · [Module registry](MODULE_REGISTRY.md)

## 1. Data preparation is a separate upstream step

Official RZS files are transformed by `modules/rzs_data_preparation/RZS_data_preparation.R` into locally retained validated Excel workbooks in `modules/rzs_data_preparation/RZS_prepared/`:

```text
presidential_2017_RZS_prepared.xlsx
presidential_2022_RZS_prepared.xlsx
parliamentary_2022_RZS_prepared.xlsx
```

`Main` is the QC-eligible sample with registered electorate E ≥ 100; `Master` retains additional prepared records and status flags, while `Options` describes candidates/lists. The original and prepared workbooks **are not included in this public repository**. If those prepared files already exist and have not changed, **do not rerun** the preparation script merely because a downstream module was added or updated.

## 2. Choose a downstream module

Set the RStudio working directory to that module before sourcing its entry-point script:

| Required analysis | Module directory | Command | Output directory |
|---|---|---|---|
| Descriptive summaries | `modules/descriptive_statistics/` | `source("Descriptive_statistics.R")` | `descriptive_outputs/` |
| Klimek cumulative curves | `modules/klimek/` | `source("Klimek.R")` | `klimek_outputs/` |
| Two-dimensional election fingerprints | `modules/election_fingerprints/` | `source("Election_fingerprints.R")` | `fingerprint_outputs/` |

For a **first fingerprint run**, install its packages, run the four `tests/*.R` tests (including `test_geography_validation.R`), unset `EF_FINGERPRINT_TEST_MODE`, run `Election_fingerprints.R`, then run `tests/check_exports.R`. Full commands: [Fingerprint user guide](modules/election_fingerprints/USER_GUIDE.md). Its `EDITABLE INPUTS` section controls geographic level, winners, languages, histogram vs KDE, the two turnout definitions, and the five Size/JHK groups. `INVALID_AREA_POLICY <- "error"` is the safe default; only valid requested geographic keys are accepted.

## 3. Changes and recalculation

| Change | Reprepare RZS? | Rerun downstream modules? |
|---|---|---|
| New figures, graph language, subtitle size, selected district/municipality | No | Only the affected downstream module |
| Add an independent fingerprint module with existing prepared inputs | No | Only fingerprint tests and script |
| Change analytical algorithm or version in one downstream module | No (if input schema unchanged) | Test/rerun that module; record version |
| Official RZS source, QC eligibility, preparation schema or Size/JHK definitions change | Yes; validate again | Rerun every affected downstream analysis |

Keep research snapshots, source hashes, config and `sessionInfo()`. Output directories can be regenerated or overwritten by their own modules; keep publication copies separately.

## 4. Public repository versus local datasets

The `.gitignore` excludes raw/prepared Excel data, local output directories and test artefacts. **Never copy raw data or output directories into a clean public checkout.** When updating an existing Git working copy, preserve those private local folders and replace only the tracked source/docs. `.gitignore` does not protect against manual copying or deleting local files.
