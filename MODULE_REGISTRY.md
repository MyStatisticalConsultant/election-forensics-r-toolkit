# Module registry — Toolkit v1.8.4

[Srpski (latinica)](MODULE_REGISTRY_SER.md) · [README](README.md) · [Workflow](WORKFLOW.md)

| Module | Entry point | Release / validation scope | Inputs | Local outputs |
|---|---|---|---|---|
| [RZS data preparation](modules/rzs_data_preparation/README.md) | `RZS_data_preparation.R` | Previously validated on the three supported elections; official 2017 registered-voter discrepancy remains documented as REVIEW | Official source Excel | `RZS_prepared/*.xlsx`; QC/validation CSV |
| [Descriptive statistics](modules/descriptive_statistics/README.md) | `Descriptive_statistics.R` | v0.3.1; compared with independent results on all three supported elections | `Main`, `Master`, `Options` | `descriptive_outputs/` |
| [Klimek curves](modules/klimek/README.md) | `Klimek.R` | v0.1.4; researcher-confirmed PASS on three supported elections | `Main`, `Master`, `Options` | `klimek_outputs/` |
| [Election fingerprints](modules/election_fingerprints/README.md) | `Election_fingerprints.R` | **v0.1.4 stable**; researcher-confirmed PASS on three elections, national/4 selected districts/2 selected municipalities, all size groups, geographic-key and export QA | `Main`, `Options`, `Size`, `Size_JHK` | `fingerprint_outputs/` |

All downstream modules are independent readers of prepared data. No graphical user interface or automatic dependency manager is included. Methods not present in this release are not claimed as implemented. The fingerprint module offers observed 2D station counts, not formal detection or estimation of electoral fraud.
