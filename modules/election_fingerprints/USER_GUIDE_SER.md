# Izborni otisci — korisničko uputstvo v0.1.4

[English](USER_GUIDE.md) · [README](README_SER.md) · [Metodologija](METHODOLOGY_SER.md)

## R okruženje i pripremljene baze

Jednom instalirati pakete: `install.packages(c("readxl","ggplot2","MASS","ggExtra","cowplot","readr"))`. U RStudio-u postaviti radni direktorijum na `modules/election_fingerprints/`. U `../rzs_data_preparation/RZS_prepared/` moraju postojati `presidential_2017_RZS_prepared.xlsx`, `presidential_2022_RZS_prepared.xlsx` i `parliamentary_2022_RZS_prepared.xlsx` sa validiranim listovima `Main` i `Options`. Oni **nisu deo GitHub repozitorijuma**.

## Podešavanja u `Election_fingerprints.R`

- `INPUTS`: vrste/godine izbora i pripremljene Excel baze; podrazumevano sva tri izbora, uz mogućnost izbora samo jednog.
- `GRAPH_LANGUAGES <- c("EN","SR")`: oba jezika u jednom izvršavanju.
- `OPTION_MODE <- "national_winner"`: pobednik prema nacionalnom `Options.Total_votes` ostaje ista opcija u svakom okrugu i opštini. `OPTION_MODE <- "manual"` sa `MANUAL_OPTION_BY_ELECTION <- list(parliamentary_2022="Option_01_votes")` omogućava ručni izbor po proveri `Options.Votes_field`. `OPTION_LABELS_EN` / `OPTION_LABELS_SR` menjaju samo prikaz naziva.
- `PLOT_HISTOGRAM <- TRUE`, `HIST_BINS <- 50L`: osnovni 2D histogram **broja BM**; `PLOT_KDE <- TRUE`, `KDE_GRID <- 200L`: dodatni KDE; `MIN_KDE_STATIONS <- 10L`: KDE se preskače pri malom uzorku ili nedovoljnoj varijaciji.
- `TURNOUT_MEASURES <- c("valid","cast")`: izvorna izlaznost po važećim glasovima (`valid`) i dopunska analiza osetljivosti po ubačenim listićima (`cast`).
- `PLOT_SIZE_GROUPS <- TRUE`, `SIZE_GROUPS <- c("SMALL","MIDDLE","LARGE","JHK_SMALL","JHK_LARGE")`: dve nacionalno određene klasifikacije, bez lokalnog pregrupisavanja. Klasifikacije se **preklapaju** i ne sme se sabirati svih pet grupa.
- `MAIN_TITLE_FONT_SIZE <- 17`, `SUBTITLE_FONT_SIZE <- 14`: podešavanje glavnog naslova i običnog podnaslova; `SAVE_PNG`, `SAVE_PDF`, `SAVE_GRID_CSV`, `SAVE_INPUT_AUDIT` podešavaju fajlove.

### Geografski izbor

`AREA_MODE <- "national"` podrazumevano generiše nacionalne prikaze. Za okruge i opštine u skriptu upisati npr.:

```r
AREA_MODE <- "selected"
GENERATE_DISTRICTS <- TRUE
GENERATE_MUNICIPALITIES <- TRUE
SELECT_DISTRICT_CODES <- c("25", "26", "33", "55")
SELECT_MUNICIPALITY_KEYS <- c("18|71021", "26|90239")
INVALID_AREA_POLICY <- "error"  # podrazumevano: zaustaviti pogrešnu šifru
```

Kompozitni ključ opštine ima oblik `District_code|Municipality_code`. Opštinska šifra `90239`, na primer, ide uz okrug `26`, ne `25`. Šifre moraju postojati u `Main` listu konkretnog izbornog skupa i skup raspoloživih šifara može se razlikovati među izborima. Podrazumevani `INVALID_AREA_POLICY <- "error"` zaustavlja rad uz objašnjenje i predlog važeće šifre gde je moguće. Opcioni `"warn"` omogućava nastavak nakon upozorenja i preskakanje nepostojećih šifara. `AREA_MODE <- "all"` generiše sve raspoložive šifre na uključenim teritorijalnim nivoima — potencijalno veliki broj slika.

Nacionalno izabrani kandidat/lista se ne menja po oblastima, a svako BM ostaje zasebno opažanje.

## Prvi test i pokretanje

```r
source("tests/run_tests.R")
source("tests/test_graphics.R")
source("tests/test_geography_validation.R")
source("tests/integration_real_data.R")
Sys.unsetenv("EF_FINGERPRINT_TEST_MODE")
source("Election_fingerprints.R")
source("tests/check_exports.R")
```

Test izvoza proverava sva izabrana nacionalna, okružna i opštinska područja, sve grupe, obe definicije izlaznosti, zbirove histograma, evidencije i PNG/PDF. Promenljiva okruženja `EF_FINGERPRINT_TEST_MODE=1` služi za učitavanje funkcija bez stvarnog izvršavanja, zato je treba ukloniti pre analize. Ako nema poruka `[Fingerprints]`, prvo proveriti `Sys.getenv("EF_FINGERPRINT_TEST_MODE")`.

Pri narednim promenama prikaza dovoljan je `source("Election_fingerprints.R")`; nakon izmene teritorijalnog obima ili verzije modula ponovo izvršiti `tests/check_exports.R`. Publikacione slike sačuvati odvojeno jer ponovljeno izvršavanje može zameniti prethodne izlaze.

## Izlazi i ograničenja

`fingerprint_outputs/<izbori>/<oblast>/EN|SR/` sadrži dvojezične PNG/PDF, a `groups/<ŠIFRA>/EN|SR/` slike klasa veličine BM. Mreže histograma, audit i `fingerprints_status.csv` sadrže sve uključene i izostavljene izlaze. Videti [OUTPUT_GUIDE_SER.md](OUTPUT_GUIDE_SER.md).

Grupe sa nula BM imaju status bez slika. Jedno BM može dati jednu popunjenu ćeliju histograma, ali ne i pouzdanu KDE površinu. BM sa `B=0` ostaju u evidenciji, ali se ne crtaju jer je `W/B` nedefinisano. KDE nije verovatnoća prevare; za tumačenje odstupanja neophodni su alternativna objašnjenja i nezavisni dokazi.
