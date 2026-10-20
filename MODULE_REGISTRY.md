# Module registry — Election Forensics R Toolkit

[Srpski (latinica)](MODULE_REGISTRY_SER.md) · [Execution workflow](WORKFLOW.md)

This is the current module inventory for the **v1.7 development codebase**, not a certification of all modules.

| Module | Script | Status | Reads | Writes locally |
|---|---|---|---|---|
| [`rzs_data_preparation`](modules/rzs_data_preparation/README.md) | `RZS_data_preparation.R` | Previously tested on presidential 2017/2022 and parliamentary 2022; documented 2017 registered-voter REVIEW | Official RZS `raw_data/*.xlsx` | `RZS_prepared/*.xlsx`, QC CSV |
| [`descriptive_statistics`](modules/descriptive_statistics/README.md) | `Descriptive_statistics.R` plus `R/` helpers | v0.3.1 checked against independent results for three elections, within that scope | `Main`, `Master`, `Options` | `descriptive_outputs/` |
| [`klimek`](modules/klimek/README.md) | `Klimek.R` | **v0.1.0-dev — live RStudio and figure validation pending** | `Main`, `Master`, `Options` | `klimek_outputs/` |

All modules run **locally**. The preparation module is an upstream dependency for their **data products**, not a command that must be rerun before every analysis. Descriptive and Klimek are parallel downstream consumers: neither calls the other's runner. Versioned contracts, data provenance, and method-specific sample rules remain important. No general Shiny interface is implemented.

Future/planned (not present): election fingerprints, contours, normality diagnostics, regressions, Mebane FMM. Each addition requires synchronized EN/SR documentation and the [release checklist](RELEASE_CHECKLIST.md).
