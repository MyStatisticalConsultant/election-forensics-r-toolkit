# Tok rada — nezavisno izvršavanje modula

[English](WORKFLOW.md) · [Instalacija](INSTALLATION_SER.md) · [Registar modula](MODULE_REGISTRY_SER.md)

## 1. Priprema baza je odvojeni početni korak

Zvanični RZS fajlovi se skriptom `modules/rzs_data_preparation/RZS_data_preparation.R` obrađuju i čuvaju lokalno u `modules/rzs_data_preparation/RZS_prepared/`:

```text
presidential_2017_RZS_prepared.xlsx
presidential_2022_RZS_prepared.xlsx
parliamentary_2022_RZS_prepared.xlsx
```

`Main` je QC-podobni uzorak sa E ≥ 100; `Master` sadrži dodatne pripremljene zapise i statuse, a `Options` šifarnik kandidata/lista. Originalni i pripremljeni Excel fajlovi **nisu deo javnog repozitorijuma**. Ako već postoje i nisu menjani, **ne treba** ponovo pokretati pripremu samo zbog novog/izmenjenog modula.

## 2. Izabrati analitički modul

U RStudio-u postaviti radni direktorijum na odgovarajući folder:

| Analiza | Folder | Komanda | Folder rezultata |
|---|---|---|---|
| Deskriptivne tabele | `modules/descriptive_statistics/` | `source("Descriptive_statistics.R")` | `descriptive_outputs/` |
| Klimek krive | `modules/klimek/` | `source("Klimek.R")` | `klimek_outputs/` |
| Dvodimenzionalni izborni otisci | `modules/election_fingerprints/` | `source("Election_fingerprints.R")` | `fingerprint_outputs/` |

Prilikom **prvog izvršavanja izbornih otisaka**, instalirati potrebne R pakete, izvršiti četiri `tests/*.R` testa (uključujući `test_geography_validation.R`), ukloniti `EF_FINGERPRINT_TEST_MODE`, izvršiti `Election_fingerprints.R`, a zatim `tests/check_exports.R`. Kompletan sled dat je u [korisničkom uputstvu](modules/election_fingerprints/USER_GUIDE_SER.md). U **EDITABLE INPUTS** podešavaju se oblast, pobednik, jezik, histogram/KDE, definicije izlaznosti i pet Size/JHK grupa. Podrazumevano `INVALID_AREA_POLICY <- "error"` sprečava tiho preskakanje nepostojećih geografskih šifara.

## 3. Promene i ponovni proračun

| Promena | Ponoviti RZS pripremu? | Ponoviti module? |
|---|---|---|
| Izmena boja, jezika, podnaslova ili odabranih oblasti | Ne | Samo relevantni modul |
| Dodavanje izbornih otisaka uz postojeće baze | Ne | Testovi i izvršavanje izbornih otisaka |
| Izmena numeričkog algoritma jednog modula | Ne, ako šema ulaza ostaje ista | Testirati i izvršiti taj modul |
| Izmena zvaničnog RZS izvora, QC pravila, šeme ili Size/JHK definicija | Da, uz proveru | Izvršiti sve analize na koje promena utiče |

Uz rezultate čuvati kontrolne sume, podešavanja i `sessionInfo()`. Izlazi se mogu prepisivati pri ponovnom izvršavanju; publikacione primerke čuvati posebno.

## 4. Javni kod i lokalne baze

`.gitignore` izuzima originalne/pripremljene podatke, rezultate i lokalne testne fajlove. **Ne kopirati** lične Excel baze i izlaze u javno preuzetu kopiju. Prilikom ažuriranja postojećeg lokalnog Git repozitorijuma sačuvati podatke i zameniti samo programske i dokumentacione fajlove. `.gitignore` ne štiti od ručnog brisanja pri prepisivanju.
