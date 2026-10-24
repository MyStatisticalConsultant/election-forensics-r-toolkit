# Registar modula — Toolkit v1.9.0

[English](MODULE_REGISTRY.md) · [README](README_SER.md) · [Tok rada](WORKFLOW_SER.md)

| Modul | Glavni skript | Izdanje / obim validacije | Ulazi | Lokalni izlazi |
|---|---|---|---|---|
| [Priprema RZS podataka](modules/rzs_data_preparation/README_SER.md) | `RZS_data_preparation.R` | Prethodno validirana za tri podržana izbora; dokumentovani REVIEW za broj upisanih 2017. | Zvanični Excel | `RZS_prepared/*.xlsx`, QC CSV |
| [Deskriptivna statistika](modules/descriptive_statistics/README_SER.md) | `Descriptive_statistics.R` | v0.3.1; upoređeno sa nezavisnim rezultatima za tri podržana izbora | `Main`, `Master`, `Options` | `descriptive_outputs/` |
| [Klimek kumulativne krive](modules/klimek/README_SER.md) | `Klimek.R` | v0.1.4; dokumentovani testovi za tri podržana izbora | `Main`, `Master`, `Options` | `klimek_outputs/` |
| [Izborni otisci](modules/election_fingerprints/README_SER.md) | `Election_fingerprints.R` | v0.1.4; nacionalni i odabrani okružni/opštinski izlazi, Size/JHK, provera šifara i izvoza | `Main`, `Options`, `Size`, `Size_JHK` | `fingerprint_outputs/` |
| [**Konturni dijagrami**](modules/contours/README_SER.md) | `Contours.R` | **v0.1.4**; sintetički testovi definicija A/B, opštinske leave-one-out standardizacije, KDE/legende/strelice i dvojezičnih slika; odabrani izvozi na stvarnim podacima | `Main`, `Size`, `Size_JHK`, `Winner_votes` | `contours_outputs/` |

Analitički moduli nezavisno čitaju pripremljene RZS baze i ne menjaju ih. KDE i konturni dijagrami služe opisnoj analizi, a ne formalnom dokazivanju izborne prevare. Metode koje nisu navedene još nisu uključene u ovo izdanje.
