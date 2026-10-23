# Korisnički tok rada — pokretanje izabranog modula bez ponavljanja cele analize

[English](WORKFLOW.md) · [Registar modula](MODULE_REGISTRY_SER.md)

## 1. Jednokratna priprema podataka

U postojećem lokalnom folderu `modules/rzs_data_preparation/` podesite `INPUTS` i, kada je to potrebno za dati izvor/format, izvršite:

```r
source("RZS_data_preparation.R")
```

Pripremljeni fajlovi ostaju u `modules/rzs_data_preparation/RZS_prepared/`, najčešće:

```text
presidential_2017_RZS_prepared.xlsx
presidential_2022_RZS_prepared.xlsx
parliamentary_2022_RZS_prepared.xlsx
```

List `Main` je osnovni forenzički uzorak (E >= 100 i ispunjeni QC uslovi); `Master` sadrži sve pripremljene zapise sa oznakama; `Options` je šifarnik kandidata/izbornih lista. Sačuvajte lokalne kopije. Naredni moduli ove Excel baze samo **čitaju**, ne menjaju ih. GitHub repozitorijum ne sadrži njihove kopije.

## 2. Samo deskriptivna statistika

U RStudio-u postavite **radni direktorijum** na `election-forensics-r-toolkit/modules/descriptive_statistics`. Proverite putanje u `INPUTS$prepared_file`, a zatim izvršite:

```r
source("Descriptive_statistics.R")
```

Rezultati su u `descriptive_outputs/`. Nema ponovnog izvršavanja pripreme ili modula Klimek. Testovi su preporučljivi posle instalacije ili promene koda/izvora, ali ne moraju se izvršavati pri svakom podešavanju izlaznog prikaza.

## 3. Samo Klimek

U RStudio-u postavite radni direktorijum na `election-forensics-r-toolkit/modules/klimek`. Podrazumevane putanje traže pripremljene fajlove u `../rzs_data_preparation/RZS_prepared/`. Pre prvog rada sa razvojnim modulom:

```r
source("tests/run_tests.R")
source("tests/integration_real_data.R")
source("Klimek.R")
source("tests/check_exports.R")
```

Kada to proverite, za kasnije izmene boja, jezika ili prikazanih opcija dovoljno je:

```r
source("Klimek.R")
```

Rezultati su u `klimek_outputs/`, bez menjanja ulaznih Excel fajlova. Skript obrađuje **sve izbore iz EDITABLE tabele `INPUTS`**. Za samo jedne izbore zadržite jedan odgovarajući red; ostale kasnije možete vratiti. `GRAPH_LANGUAGES <- "EN"`, `"SR"` ili `c("EN","SR")` određuje jezik grafikona; `CURVE_NORMALISATIONS <- "both"` uključuje oba načina normalizacije.

## 4. Dodavanje narednog modula

Sačuvajte postojeći folder Toolkit-a i lokalne pripremljene baze. Dodajte samo `modules/<naziv>/`, zatim usaglasite korensku dokumentaciju i zastarela aktuelna uputstva drugih modula. Novi modul može zahtevati dodatne R pakete, ali to **nije ponovna instalacija celog Toolkit-a**. Proverite njegove ulazne putanje i izvršite njegove testove. Stari moduli ne moraju ponovo da rade ako je njihov ulazni ugovor i sadržaj podataka nepromenjen.

## 5. Kada šta ponovo izvršiti

| Promena | Priprema RZS | Deskriptivna statistika | Klimek |
|---|---|---|---|
| Dodavanje Klimek modula, bez promena Excel baza | Ne | Ne | Testirati/pokrenuti Klimek |
| Promena jezika, boja ili opcija grafikona Klimek | Ne | Ne | Samo Klimek |
| Promena načina prikaza deskriptivnih izveštaja | Ne | Samo deskriptivni modul | Ne |
| Novi ili ispravljeni zvanični RZS podaci | Ponoviti pripremu i proveru | Ponoviti ako koristi te podatke | Ponoviti ako koristi te podatke |
| Izmena QC pravila, `Size`/`Size_JHK` ili kanonskih polja | Pripremiti i proveriti ponovo | Ponoviti relevantne izlaze | Ponoviti relevantne izlaze |
| Dodavanje nezavisne nove statističke metode | Ne, ako je baza kompatibilna | Ne | Ne |

**Važno:** postojeći skriptovi ne poseduju automatski sistem za otkrivanje zastarelih podataka. Ako se ulaz ili QC definicija promeni, stari rezultat može ostati pod istim imenom. Beležite hash izvora, verziju koda, parametre i datum. Rezultati istog naziva mogu biti prepisani pri ponavljanju, pa publikacione kopije čuvajte posebno.

## 6. GitHub naspram lokalnih podataka

Na GitHub-u su *programski kod, metodologija i testovi*; na Vašem računaru su *originalni Excel podaci, pripremljene baze i rezultati*. Pri ažuriranju koda zaštitite lokalne `raw_data/`, `RZS_prepared/`, `descriptive_outputs/` i `klimek_outputs/`. `.gitignore` štiti pri uobičajenom Git radu, ali ne sprečava ručno prepisivanje datoteka tokom kopiranja ZIP arhive.

Pogledajte [GitHub uputstvo](GITHUB_UPLOAD_GUIDE_SER.md) i [kontrolnu listu](RELEASE_CHECKLIST_SER.md).


**Klimek v0.1.4:** Pokrenite i `source("tests/test_zero_station_groups.R")`; prazne teritorijalne grupe eksplicitno se beleže, a zastarele Klimek slike izabrane oblasti uklanjaju se pre crtanja.
