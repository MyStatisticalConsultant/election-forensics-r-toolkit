# Validation — Klimek v0.1.4

[Srpski (latinica)](VALIDATION_SER.md) · [Actual researcher test record](VALIDATION_RECORD_2026-10-23.md)

**Status: researcher-validated for all three supported elections (`presidential_2017`, `presidential_2022`, `parliamentary_2022`) and the tested graphical/numerical behaviours.** The researcher reports PASS for all three. A detailed seven-command RStudio log was supplied for parliamentary 2022; equivalent presidential logs were not supplied. The release assembler did not independently run R.

The confirmed scope includes syntax and synthetic checks, both curve normalisations, group partitions, turnout ties, multilingual plot titles, 10-percentage-point vertical-axis ticks, 0/1/multiple-station behaviour, special RZS categories, real-data national curve-endpoint reconciliation for `parliamentary_2022` and 436 generated figures with a passing export check. The complete test evidence is transcribed in the [validation record](VALIDATION_RECORD_2026-10-23.md).

To reproduce in RStudio, open `modules/klimek` as the working directory and run:

```r
source("tests/run_tests.R")
source("tests/test_graphics_layout.R")
source("tests/test_single_station_plots.R")
source("tests/test_zero_station_groups.R")
source("tests/integration_real_data.R")
source("Klimek.R")
source("tests/check_exports.R")
```

**Evidence boundary:** The supplied detailed final log explicitly lists `parliamentary_2022` as the active `INPUTS` election. The researcher separately confirms all tests PASS for presidential 2017 and 2022. This is sufficient to report researcher-confirmed validation for all three supported elections; separate presidential console transcripts would improve the archived provenance but are **not outstanding test requirements**. No independent R execution was performed when packaging.

For archival reproducibility retain the Git commit, `sessionInfo()`, input hashes, editable configuration, exact test transcript and representative EN/SR figures. This module provides exploratory cumulative curves, not the complete inferential JHK test or proof of wrongdoing.
