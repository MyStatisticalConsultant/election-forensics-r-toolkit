# Registar modula — Election Forensics R Toolkit

[English](MODULE_REGISTRY.md) · [Tok rada](WORKFLOW_SER.md)

Trenutni spisak za **objedinjenu verziju v1.7.9**; sam spisak ne predstavlja potvrdu validacije svih modula.

| Modul | R skript | Status | Ulaz | Lokalni izlaz |
|---|---|---|---|---|
| [`rzs_data_preparation`](modules/rzs_data_preparation/README_SER.md) | `RZS_data_preparation.R` | Ranije provereno za predsedničke 2017/2022. i parlamentarne 2022; dokumentovan REVIEW za broj upisanih 2017. | Originalni RZS `raw_data/*.xlsx` | `RZS_prepared/*.xlsx`, QC CSV |
| [`descriptive_statistics`](modules/descriptive_statistics/README_SER.md) | `Descriptive_statistics.R` i funkcije `R/` | v0.3.1 proverena poređenjem sa nezavisnim rezultatima za tri izbora | `Main`, `Master`, `Options` | `descriptive_outputs/` |
| [`klimek`](modules/klimek/README_SER.md) | `Klimek.R` | **v0.1.4 — autor je potvrdio PASS za predsedničke 2017/2022. i parlamentarne 2022; detaljni log postoji za parlamentarne 2022** | `Main`, `Master`, `Options` | `klimek_outputs/` |

Moduli se izvršavaju **lokalno**. Priprema baza predstavlja uslov za postojanje podataka, ali ne mora ponovo da se izvršava pred svaku analizu. Deskriptivni i Klimek modul su **nezavisni potrošači iste pripremljene baze**; jedan ne zahteva izvršavanje drugog. Shiny korisnički interfejs nije implementiran.

Planirani, još nepostojeći moduli: izborni otisci, konture, dijagnostika normalnosti, regresije, Mebane FMM. Prilikom dodavanja potrebno je uskladiti dokumentaciju EN/SR, testove i evidenciju izdanja.

**Ažuriran status Klimek validacije:** autor potvrđuje uspeh testova za sva tri izbora; [zapisnik i poreklo potvrde](modules/klimek/VALIDATION_RECORD_2026-10-23_SER.md).
