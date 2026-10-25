# Instalacija i prvo pokretanje — Toolkit v1.10.0

[English](INSTALLATION.md) · [README](README_SER.md) · [Registar modula](MODULE_REGISTRY_SER.md)

## 1. Preuzimanje programa

Instalirati [R](https://cran.r-project.org/) i po želji [RStudio Desktop](https://posit.co/download/rstudio-desktop/). Klonirati javni repozitorijum pomoću GitHub Desktop-a ili izabrati **Code > Download ZIP** na GitHub-u. Repozitorijum sadrži kod i dokumentaciju, **ne** originalne RZS Excel baze niti generisane analize.

```text
election-forensics-r-toolkit/
  README.md  INSTALLATION.md  MODULE_REGISTRY.md  WORKFLOW.md
  modules/
    rzs_data_preparation/      # RZS_data_preparation.R
    descriptive_statistics/    # Descriptive_statistics.R
    klimek/                    # Klimek.R
    election_fingerprints/     # Election_fingerprints.R
    contours/                  # Contours.R
    voter_rigging/             # Voter_rigging.R
```

## 2. Priprema ili ponovno korišćenje podataka

Analitički moduli očekuju kompatibilne RZS baze u lokalnom folderu `modules/rzs_data_preparation/RZS_prepared/`:

```text
presidential_2017_RZS_prepared.xlsx
presidential_2022_RZS_prepared.xlsx
parliamentary_2022_RZS_prepared.xlsx
```

Ako već postoje validirane i neizmenjene baze, **koristiti ih bez ponavljanja pripreme**. U suprotnom pribaviti zvanične RZS izvore i pratiti [dokumentaciju pripreme](modules/rzs_data_preparation/README_SER.md). Izvorne i pripremljene Excel fajlove ne objavljivati na GitHub-u. Promena izvora ili pravila zahteva ponovnu validaciju.

## 3. Izbor analize

U RStudio-u izabrati **Session > Set Working Directory > Choose Directory…**, otvoriti folder modula i proveriti `getwd()`. Instalirati samo pakete potrebne za taj modul i izvršiti testove iz odgovarajućeg README-a.

| Modul | Glavni skript | Uputstvo |
|---|---|---|
| Deskriptivna statistika | `Descriptive_statistics.R` | [README](modules/descriptive_statistics/README_SER.md) |
| Klimek kumulativne krive | `Klimek.R` | [README](modules/klimek/README_SER.md) |
| Izborni otisci | `Election_fingerprints.R` | [Korisničko uputstvo](modules/election_fingerprints/USER_GUIDE_SER.md) |
| Konturni dijagrami | `Contours.R` | [README](modules/contours/README_SER.md) |
| Dijagnostika pritiska na birače (voter rigging) | `Voter_rigging.R` | [README](modules/voter_rigging/README_SER.md) |

Na primer, iz foldera `modules/contours/`:

```r
install.packages(c("readxl", "ggplot2", "MASS"))  # Prvi put, ako nedostaju
source("tests/run_tests.R")
source("tests/test_graphics.R")
Sys.unsetenv("EF_CONTOUR_TEST_MODE")
source("Contours.R")
```

Podrazumevana podešavanja obuhvataju tri podržana izbora; odeljak **EDITABLE SECTION** omogućava izbor godina, A/B definicija izlaznosti, klasifikacija, jezika, oblasti i grafičkih parametara. Za kraću proveru može se izabrati samo nacionalni nivo.

## 4. Rezultati i tumačenje

Svaki modul čuva izlaze u svom lokalnom `*_outputs/` folderu, bez izmene pripremljenih baza. Contours generiše PNG grafikone i CSV fajlove sa standardizovanim vrednostima, QC pregledima i statusima PASS/SKIP u `modules/contours/contours_outputs/`. Potpun opis izlaza i ograničenja nalazi se u [README-u modula](modules/contours/README_SER.md).

Za `voter_rigging` koristi se list `Master` (uključujući QC-podobna BM sa E<100); rezultati se čuvaju lokalno u `modules/voter_rigging/voter_rigging_outputs/`. Modul prikazuje opisno `D(p)`, ali ne računa `δ(p)` bez uporedive međunarodne reference.

Statistički nalazi nisu pravna odluka o nepravilnostima. Uz analize čuvati izvor podataka, parametre, verzije koda i `sessionInfo()`.
