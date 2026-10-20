# Registar modula — Election Forensics R Toolkit

[English](MODULE_REGISTRY.md) · [Tok rada](WORKFLOW_SER.md)

Trenutni spisak za **razvojnu verziju v1.7**; sam spisak ne predstavlja potvrdu validacije svih modula.

| Modul | R skript | Status | Ulaz | Lokalni izlaz |
|---|---|---|---|---|
| [`rzs_data_preparation`](modules/rzs_data_preparation/README_SER.md) | `RZS_data_preparation.R` | Ranije provereno za predsedničke 2017/2022. i parlamentarne 2022; dokumentovan REVIEW za broj upisanih 2017. | Originalni RZS `raw_data/*.xlsx` | `RZS_prepared/*.xlsx`, QC CSV |
| [`descriptive_statistics`](modules/descriptive_statistics/README_SER.md) | `Descriptive_statistics.R` i funkcije `R/` | v0.3.1 proverena poređenjem sa nezavisnim rezultatima za tri izbora | `Main`, `Master`, `Options` | `descriptive_outputs/` |
| [`klimek`](modules/klimek/README_SER.md) | `Klimek.R` | **v0.1.0-dev — čekaju se izvršavanje RStudio testova i pregled grafikona** | `Main`, `Master`, `Options` | `klimek_outputs/` |

Moduli se izvršavaju **lokalno**. Priprema baza predstavlja uslov za postojanje podataka, ali ne mora ponovo da se izvršava pred svaku analizu. Deskriptivni i Klimek modul su **nezavisni potrošači iste pripremljene baze**; jedan ne zahteva izvršavanje drugog. Shiny korisnički interfejs nije implementiran.

Planirani, još nepostojeći moduli: izborni otisci, konture, dijagnostika normalnosti, regresije, Mebane FMM. Prilikom dodavanja obavezno uskladiti dokumentaciju EN/SR i [kontrolnu listu](RELEASE_CHECKLIST_SER.md).
