# Instalacija i prvo pokretanje — Toolkit v1.8.4

[English](INSTALLATION.md) · [README](README_SER.md)

## A. Preuzimanje javnog koda

Instalirati [R](https://cran.r-project.org/) i po želji [RStudio Desktop](https://posit.co/download/rstudio-desktop/). Uz **GitHub Desktop** klonirati javni repozitorijum na računar (Repository > Clone Repository), ili na GitHub stranici izabrati **Code > Download ZIP** i raspakovati arhivu. Javni kod ne sadrži zvanične izborne RZS podatke.

Osnovna struktura:

```text
election-forensics-r-toolkit/
  README.md  INSTALLATION.md  MODULE_REGISTRY.md  WORKFLOW.md
  modules/
    rzs_data_preparation/
      RZS_data_preparation.R
      RZS_prepared/                    # lokalno, van Git-a
    descriptive_statistics/
      Descriptive_statistics.R
    klimek/
      Klimek.R
    election_fingerprints/
      Election_fingerprints.R
      tests/
```

## B. Pripremljene izborne baze

Potrebno je da u `modules/rzs_data_preparation/RZS_prepared/` postoje tri Excel datoteke:

```text
presidential_2017_RZS_prepared.xlsx
presidential_2022_RZS_prepared.xlsx
parliamentary_2022_RZS_prepared.xlsx
```

Ako već postoje odgovarajuće validirane baze, **koristiti postojeće**. U suprotnom pribaviti zvanične RZS izvore, podesiti i izvršiti `modules/rzs_data_preparation/RZS_data_preparation.R`, pa slediti njegove validacione testove. Originalne i pripremljene Excel fajlove ne objavljivati na GitHub-u.

## C. Pokretanje izbornih otisaka

U RStudio-u izabrati **Session > Set Working Directory > Choose Directory…**, zatim `modules/election_fingerprints/`, i proveriti `getwd()`. Potrebne pakete instalirati jednom:

```r
install.packages(c("readxl", "ggplot2", "MASS", "ggExtra", "cowplot", "readr"))
```

Otvoriti `Election_fingerprints.R` i u odeljku **EDITABLE INPUTS** podesiti izbore, `AREA_MODE`, prekidače okruga/opština, njihove šifre, jezike i grafičke opcije. Podrazumevana vrednost `INVALID_AREA_POLICY <- "error"` zaustavlja izvršavanje pri nepostojećoj izabranoj šifri; `"warn"` omogućava nastavak samo sa važećim oblastima.

Za prvu proveru izvršiti:

```r
source("tests/run_tests.R")
source("tests/test_graphics.R")
source("tests/test_geography_validation.R")
source("tests/integration_real_data.R")
Sys.unsetenv("EF_FINGERPRINT_TEST_MODE")
source("Election_fingerprints.R")
source("tests/check_exports.R")
```

Pri kasnijoj promeni samo grafikona dovoljno je `source("Election_fingerprints.R")`, uz proveru izvoza kada se menja geografski obim. Ako se pri izvršavanju ne pojavljuju poruke `[Fingerprints]`, proveriti testni režim rada (`EF_FINGERPRINT_TEST_MODE`).

## D. Rezultati

Svi izlazi nastaju u `modules/election_fingerprints/fingerprint_outputs/<izbori>/<oblast>/`: dvojezični PNG/PDF, tabele mreža, evidencija BM i status. Podgrupe Size/JHK su u `groups/<ŠIFRA>/`; `fingerprints_status.csv` beleži prazne grupe i slučajeve kada KDE nije izračunat. Ulazne baze se ne menjaju.

Videti [korisničko uputstvo](modules/election_fingerprints/USER_GUIDE_SER.md), [opis izlaza](modules/election_fingerprints/OUTPUT_GUIDE_SER.md) i [validaciju](modules/election_fingerprints/VALIDATION_SER.md).
