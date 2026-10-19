# Instaliranje i lokalno pokretanje — v0.3.1

[English](INSTALLATION.md) · [README_SER.md](README_SER.md)

1. Instalirajte R sa CRAN-a i po želji RStudio Desktop. Nisu potrebni Shiny server, Posit Cloud ni objavljena aplikacija.
2. Jednokratno instalirajte `install.packages(c("readxl","openxlsx","readr"))`; za Word izlaz dodatno `install.packages(c("officer","flextable"))`.
3. Preuzmite ZIP celog repozitorijuma ili ga klonirajte. Otpakujte ga i zadržite oba modula unutar `modules/`.
4. Posebno preuzmite zvanične RZS Excel fajlove i izvršite `modules/rzs_data_preparation/RZS_data_preparation.R`, uz podešavanje njegovog ulaznog odeljka. Izvorni fajlovi ne idu u Git repozitorijum.
5. Proverite da u `modules/rzs_data_preparation/RZS_prepared/` postoje `presidential_2017_RZS_prepared.xlsx`, `presidential_2022_RZS_prepared.xlsx` i `parliamentary_2022_RZS_prepared.xlsx`.
6. U RStudio postavite radni folder na `modules/descriptive_statistics`. Proverite `getwd()` i `file.exists("Descriptive_statistics.R")`.
7. U početnom podesivom odeljku promenite samo `INPUTS`, `OUTPUT_DIR`, `DISPLAY_DECIMALS`, `WRITE_CSV` i `WRITE_WORD`, prema potrebi. Koristite relativne putanje; ne unosite trajne putanje konkretnog računara u javni kod.
8. Pokrenite testove i glavnu skriptu redosledom datim u [README_SER.md](README_SER.md). Proveru izvezenih fajlova `tests/check_exports.R` pokrenite **nakon** generisanja rezultata.

Rezultati se čuvaju u `descriptive_outputs/`; ulazni Excel fajlovi ostaju neizmenjeni. Pri obradi samo jednih izbora promenite redove u `INPUTS`, ali znajte da postojeći `check_exports.R` podrazumeva sva **tri** podrazumevana izborna skupa. Problemi: [TROUBLESHOOTING_SER.md](TROUBLESHOOTING_SER.md).
