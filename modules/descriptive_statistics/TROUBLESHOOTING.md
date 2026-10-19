# Troubleshooting — v0.3.1

[Srpski](TROUBLESHOOTING_SER.md)

| Symptom | Likely cause and remedy |
|---|---|
| `cannot open file 'R/descriptive_core.R'` | Working directory is wrong. Open `modules/descriptive_statistics` in RStudio and check `getwd()`; do not insert a personal `setwd()` into the committed script. |
| `Prepared XLSX not found` | Generate the files with `RZS_data_preparation.R` first; ensure `../rzs_data_preparation/RZS_prepared/` contains all three default inputs or modify the editable `INPUTS` paths. |
| `there is no package called ...` | Install required `readxl`, `openxlsx`, `readr`; `officer`, `flextable` are optional for Word. Restart RStudio if necessary. |
| Word file missing | Check `WRITE_WORD <- TRUE`; install `officer` and `flextable`. With either missing, the runner intentionally skips Word while continuing XLSX/CSV. |
| `check_exports.R` fails after running one election | The export checker is written for all **three** default elections; run the default configuration or adapt the checker explicitly and document the adaptation. |
| Serbian letters appear as `Ä...` in CSV in Excel | The actual export uses UTF-8 BOM. Open CSV using Excel's **Data > From Text/CSV** and select UTF-8 rather than forcing ANSI/Windows-1252. Native `.xlsx` is preferable for manual review. |
| An area has no `Less than 100` observations | Expected in some areas. Empty-group correlation sheets retain their schema, while undefined coefficients and tests remain blank. Do not fill `NA` with zero. |
| Unexpected 14 rather than 16 matrices | Old v0.2.x files/code may be mixed into v0.3.1. Confirm `size_report_order` includes `100 or more` and that `Corr_D_08` and `Corr_M_08` are generated. |
| `100 or more` total does not match `Main` | Check election identity and input workbook versions, and rerun upstream tests. Do not alter QC flags to force a match. |
| Different p-values from another program | Verify sample, tied ranks, exact/approximation settings (`wilcox.test(..., exact=FALSE)`), missing values, BH family, R/software version. Small differences do not necessarily indicate a coding error. |
| A future RZS table imports wrong option columns | Stop; the upstream positional template may interpret newly added administrative columns as electoral options. See upstream `SCHEMA_EVOLUTION.md`. |

When reporting issues, provide the **exact error, election, code version, `sessionInfo()` and reproducible steps**. Do not upload private credentials or unrelated personal files. Contact via GitHub Issues or `Zlatko@MyStatisticalConsultant.com`.
