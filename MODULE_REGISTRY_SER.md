# Registar modula — Toolkit v1.8.4

[English](MODULE_REGISTRY.md) · [README](README_SER.md) · [Tok rada](WORKFLOW_SER.md)

| Modul | Glavni skript | Izdanje / obim validacije | Ulazi | Lokalni izlazi |
|---|---|---|---|---|
| [Priprema RZS podataka](modules/rzs_data_preparation/README_SER.md) | `RZS_data_preparation.R` | Prethodno validirana za sva tri izbora; dokumentovani REVIEW za broj upisanih 2017. | Zvanični Excel | `RZS_prepared/*.xlsx`, QC CSV |
| [Deskriptivna statistika](modules/descriptive_statistics/README_SER.md) | `Descriptive_statistics.R` | v0.3.1; upoređeno sa nezavisnim rezultatima za tri izbora | `Main`, `Master`, `Options` | `descriptive_outputs/` |
| [Klimek krive](modules/klimek/README_SER.md) | `Klimek.R` | v0.1.4; autor potvrdio PASS za tri izbora | `Main`, `Master`, `Options` | `klimek_outputs/` |
| [Izborni otisci](modules/election_fingerprints/README_SER.md) | `Election_fingerprints.R` | **v0.1.4 stabilna**; autor potvrdio PASS za tri izbora, nacionalni nivo/4 odabrana okruga/2 opštine, sve grupe i geografske i izvozne testove | `Main`, `Options`, `Size`, `Size_JHK` | `fingerprint_outputs/` |

Nizvodni moduli nezavisno čitaju pripremljene podatke. Ne postoji automatski sistem zavisnosti ni grafički korisnički interfejs. Metode koje još nisu uključene ne predstavljaju se kao implementirane. Modul izbornih otisaka ne sadrži formalni test niti procenu obima izborne prevare.
