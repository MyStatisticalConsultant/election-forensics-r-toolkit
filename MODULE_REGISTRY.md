# Module registry — Toolkit v1.9.0

[Srpski (latinica)](MODULE_REGISTRY_SER.md) · [README](README.md) · [Workflow](WORKFLOW.md)

| Module | Entry point | Release / validation scope | Inputs | Local outputs |
|---|---|---|---|---|
| [RZS data preparation](modules/rzs_data_preparation/README.md) | `RZS_data_preparation.R` | Previously validated for the three supported elections; documented 2017 registered-voter REVIEW | Official source Excel | `RZS_prepared/*.xlsx`; QC/validation CSV |
| [Descriptive statistics](modules/descriptive_statistics/README.md) | `Descriptive_statistics.R` | v0.3.1; compared with independent outputs for the three supported elections | `Main`, `Master`, `Options` | `descriptive_outputs/` |
| [Klimek cumulative curves](modules/klimek/README.md) | `Klimek.R` | v0.1.4; documented tests for the three supported elections | `Main`, `Master`, `Options` | `klimek_outputs/` |
| [Election fingerprints](modules/election_fingerprints/README.md) | `Election_fingerprints.R` | v0.1.4; national and selected district/municipality outputs, Size/JHK, geographic-key and export QA | `Main`, `Options`, `Size`, `Size_JHK` | `fingerprint_outputs/` |
| [**Contour diagrams**](modules/contours/README.md) | `Contours.R` | **v0.1.4**; synthetic tests of A/B rates, municipal leave-one-out standardisation, group KDE/legend/arrow and bilingual figures; selected real-data exports | `Main`, `Size`, `Size_JHK`, `Winner_votes` | `contours_outputs/` |

Downstream modules independently read the prepared RZS workbooks; no downstream script changes them. KDE plots and contours are descriptive, not formal fraud tests. Additional methods not listed here have not been implemented in this release.
