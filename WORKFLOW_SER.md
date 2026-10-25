# Tok rada — nezavisno izvršavanje modula

[English](WORKFLOW.md) · [Instalacija](INSTALLATION_SER.md) · [Registar modula](MODULE_REGISTRY_SER.md)

## 1. Priprema izbornih podataka samo kada je potrebna

`modules/rzs_data_preparation/RZS_data_preparation.R` obrađuje zvanične RZS izvore i pravi validirane lokalne fajlove u `modules/rzs_data_preparation/RZS_prepared/`:

```text
presidential_2017_RZS_prepared.xlsx
presidential_2022_RZS_prepared.xlsx
parliamentary_2022_RZS_prepared.xlsx
```

List `Main` sadrži QC-podobna biračka mesta sa `E >= 100`, `Master` dodatne zapise i statuse, a `Options` šifarnik kandidata i lista. Originalni i pripremljeni Excel fajlovi **nisu deo javnog repozitorijuma**. Kompatibilne baze se mogu ponovo koristiti: dodavanje novog analitičkog modula ne zahteva ponovnu pripremu.

## 2. Pokrenuti samo potreban modul

U RStudio-u postaviti radni direktorijum na folder modula i pokrenuti njegov glavni skript.

| Analiza | Folder | Komanda | Lokalni izlazi |
|---|---|---|---|
| Deskriptivna statistika | `modules/descriptive_statistics/` | `source("Descriptive_statistics.R")` | `descriptive_outputs/` |
| Klimek kumulativne krive | `modules/klimek/` | `source("Klimek.R")` | `klimek_outputs/` |
| Izborni otisci | `modules/election_fingerprints/` | `source("Election_fingerprints.R")` | `fingerprint_outputs/` |
| **Konturni dijagrami** | `modules/contours/` | `source("Contours.R")` | `contours_outputs/` |
| **Voter rigging (dijagnostika pritiska na birače)** | `modules/voter_rigging/` | `source("Voter_rigging.R")` | `voter_rigging_outputs/` |

Pri prvoj instalaciji dodati R pakete i izvršiti testove navedene u dokumentaciji odabranog modula. Za Contours:

```r
install.packages(c("readxl", "ggplot2", "MASS"))  # Ako nedostaju
source("tests/run_tests.R")
source("tests/test_graphics.R")
Sys.unsetenv("EF_CONTOUR_TEST_MODE")
source("Contours.R")
```

Contours uključuje definicije izlaznosti A (`B/E`) i B (`C/E`), `Size` i `Size_JHK`, engleske/srpske PNG grafikone i nacionalni/okružni/opštinski nivo. Opštinski leave-one-out referentni skup računa se **pre** izdvajanja grupa i prikazivanih oblasti. KDE se preskače kada jedna od grupa ima manje od podrazumevanih 15 podobnih zapisa, uz razlog u `contour_export_manifest.csv`. Za pojedinosti videti [README modula](modules/contours/README_SER.md). Posebna pravila provere geografskih šifara izbornih otisaka objašnjena su u njihovom [korisničkom uputstvu](modules/election_fingerprints/USER_GUIDE_SER.md).

Modul `voter_rigging` koristi list `Master` radi obuhvata veoma malih BM. U folderu `modules/voter_rigging/` izvršiti testove i izvozne provere opisane u [README-u](modules/voter_rigging/README_SER.md). Modul računa opisno `D(p)` za definicije A/B i kumulativni udeo glasova; bez međunarodne reference ne računa inferencijalnu `δ(p)`. Prethodni analitički moduli se ne pokreću ponovo.

## 3. Kada ponavljati proračune

| Promena | Ponoviti RZS pripremu? | Dalji postupak |
|---|---|---|
| Novi modul ili promena jezika/izgleda grafikona | Ne | Testirati/izvršiti samo izmenjeni modul |
| Izmena algoritma jednog analitičkog modula | Ne, ako su ulazi i QC isti | Testirati i izvršiti relevantni modul |
| Novi RZS izvori, QC pravila, polja ili `Size`/`Size_JHK` | Da, uz validaciju | Ponoviti sve pogođene analize |
| Novi izbori ili nova ulazna baza | Pripremiti i validirati kompatibilne podatke | Podesiti/testirati potrebne analize |

Skriptovi ne otkrivaju automatski zastarele lokalne baze. Uz istraživačke rezultate čuvati kontrolne sume, parametre, verziju koda i `sessionInfo()`.

## 4. Javni kod i lokalne baze

Verzionisati kod, testove i dokumentaciju; izvorne i pripremljene Excel baze, tabele i slike čuvati lokalno. Korenski [`.gitignore`](.gitignore) izuzima `raw_data/`, `RZS_prepared/`, `descriptive_outputs/`, `klimek_outputs/`, `fingerprint_outputs/`, `contours_outputs/` i `voter_rigging_outputs/`. Pravila ignorisanja ne sprečavaju slučajno ručno brisanje/prepisivanje; sačuvati lokalne kopije pri ažuriranju.
