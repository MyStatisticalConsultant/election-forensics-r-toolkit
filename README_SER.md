# Election Forensics R Toolkit — v1.8.4

[English](README.md) · [Instalacija](INSTALLATION_SER.md) · [Registar modula](MODULE_REGISTRY_SER.md) · [Tok rada](WORKFLOW_SER.md) · [Napomene o izdanju](RELEASE_NOTES_SER_v1.8.4.md)

Otvoreni R alat za reproduktivnu analizu zvaničnih rezultata izbora u Srbiji. Toolkit obuhvata pripremu podataka Republičkog zavoda za statistiku (RZS) i **tri nezavisna analitička modula**. Statističke pravilnosti i odstupanja služe kao dijagnostički pokazatelji, ali **sami po sebi ne dokazuju izbornu prevaru**.

## Četiri modula

| Modul | Verzija | Namena | Dokumentacija |
|---|---|---|---|
| Priprema RZS podataka | Prethodno validirana implementacija | Uvoz zvaničnih Excel baza, usklađivanje polja, kontrola kvaliteta, listovi `Main`, `Master`, `Options` | [Priprema podataka](modules/rzs_data_preparation/README_SER.md) |
| Deskriptivna statistika | v0.3.1 | Nacionalne, okružne i opštinske tabele, robusna statistika | [Deskriptivna statistika](modules/descriptive_statistics/README_SER.md) |
| Klimek kumulativne krive | v0.1.4 | Eksploratorne kumulativne krive izlaznosti i glasova, uključujući grupe Size/JHK | [Klimek](modules/klimek/README_SER.md) |
| **Izborni otisci** | **v0.1.4 (stabilna)** | Dvodimenzionalni histogrami broja biračkih mesta; dopunski KDE, provera osetljivosti, geografske i Size/JHK grupe | [Izborni otisci](modules/election_fingerprints/README_SER.md) |

Svaki analitički modul **čita** pripremljene podatke, bez njihovog menjanja i bez pozivanja drugih nizvodnih modula. Pripremu nije potrebno ponavljati ukoliko se zvanični izvori, pravila ili šema podataka nisu promenili.

## Šta prikazuje modul izbornih otisaka

Za biračko mesto sa `E` upisanih, `B` važećih listića, `C` ubačenih listića i `W` glasova nacionalno izabrane liste/kandidata, primarne ose su `100 B/E` (izlaznost) i `100 W/B` (udeo glasova). Jedno biračko mesto doprinosi jednoj ćeliji 2D histograma. Alternativna izlaznost `100 C/E` i procena gustine jezgrom (KDE) su **dopunski**, a ne osnovni prikazi. Nacionalno izabrana lista/kandidat ostaje isti u svim oblastima. Izvorne klasifikacije `Size` i `Size_JHK` preuzimaju se iz nacionalnog `Main` lista.

Metodološka osnova: Klimek i saradnici (2012), *Statistical detection of systematic election irregularities*, PNAS, 109(41), 16469–16473, https://doi.org/10.1073/pnas.1210722109. Različiti mehanizmi izlaznosti i glasanja mogu dati različite oblike otisaka i bez izborne manipulacije. Videti [metodologiju](modules/election_fingerprints/METHODOLOGY_SER.md) i [validaciju](modules/election_fingerprints/VALIDATION_SER.md).

## Početak korišćenja

1. Instalirati R i, po želji, RStudio; preuzeti/klonirati GitHub repozitorijum. Videti [instalaciju](INSTALLATION_SER.md).
2. Pribaviti zvanične RZS Excel izvore ili koristiti **postojeće, lokalno validirane** baze u `modules/rzs_data_preparation/RZS_prepared/`. One nisu deo javnog GitHub paketa.
3. U RStudio-u postaviti radni direktorijum na `modules/election_fingerprints/` i pokrenuti:

```r
install.packages(c("readxl", "ggplot2", "MASS", "ggExtra", "cowplot", "readr"))
source("tests/run_tests.R")
source("tests/test_graphics.R")
source("tests/test_geography_validation.R")
source("tests/integration_real_data.R")
Sys.unsetenv("EF_FINGERPRINT_TEST_MODE")
source("Election_fingerprints.R")
source("tests/check_exports.R")
```

U odeljku **EDITABLE INPUTS** nalaze se izbori, jezici, geografski izbor, parametri slike i izbor kandidata/liste. Podrazumevano `INVALID_AREA_POLICY <- "error"` zaustavlja izvršavanje pri pogrešnoj šifri izabrane oblasti; `"warn"` omogućava svestan nastavak bez nepostojećih šifara. Podrazumevani su nacionalni prikazi; za okruge i opštine treba uključiti odgovarajuće prekidače i `AREA_MODE`. Videti [korisničko uputstvo](modules/election_fingerprints/USER_GUIDE_SER.md).

Lokalni izlazi nastaju u `modules/election_fingerprints/fingerprint_outputs/`. Prazne grupe imaju status bez slika, dok se KDE preskače kada je uzorak premali ili nema varijacije; izvorni 2D histogram se zadržava.

## Podaci i validacija

- **Van GitHub-a:** originalni RZS Excel, pripremljene baze, izlazne slike i tabele, korisnički lokalni rezultati, stanje RStudio-a. Putanje su obuhvaćene [`.gitignore`](.gitignore).
- **Potvrđeni testovi:** autor je dostavio PASS rezultate numeričkih, grafičkih (KDE 200×200, EN/SR), geografskih i integracionih testova i izvoza za sva tri izbora. Izabrani testovi obuhvatili su po **jedan nacionalni nivo, četiri okruga i dve opštine** za svake izbore, šest osnovnih/grupnih izlaza po oblasti, obe definicije izlaznosti i usaglašenost izvoza. Ovo nije automatska potvrda svih budućih podešavanja ili drugih izbora.
- `Main` sadrži 8.023 BM za predsedničke izbore 2017. i po 7.787 BM za izbore 2022. BM sa `B=0` ostaju u evidenciji, ali se ne crtaju jer `W/B` nije definisano.
- Uz rezultate čuvati kontrolne sume ulaznih podataka, podešavanja i `sessionInfo()`. [MANIFEST.sha256](MANIFEST.sha256) sadrži kontrolne sume javnih programskih i dokumentacionih fajlova.

R kod i testovi prethodna tri modula ostali su nepromenjeni. Planirane metode, uključujući modele mešavina, nisu predstavljene kao već implementirane.

MIT licenca: [LICENSE](LICENSE). Podaci za citiranje: [CITATION.cff](CITATION.cff). © 2026 Zlatko J. Kovačić.
