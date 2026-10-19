# Objavljivanje Election Forensics R Toolkit na GitHub-u

[English](GITHUB_UPLOAD_GUIDE.md) · [Početna stranica](README_SER.md)

## Preporučena organizacija

Objavite **jedan GitHub repozitorijum** nazvan `election-forensics-r-toolkit` sa oba modula u `modules/`. Nije potreban poseban repozitorijum za deskriptivnu statistiku, osim ako kasnije namerno želite dva nezavisna softverska projekta. Jedan repozitorijum čuva ugovor o strukturi podataka između pripreme i analize. Svaki modul ipak ima sopstveni README, testove, dnevnik promena i podatke o citiranju.

**Verzija koda** ostaje deskriptivni modul **v0.3.1** i modul pripreme **v1.3.1**; ova dorada odnosi se na dokumentaciju. Prethodni razvojni naziv celog repozitorijuma je `v1.6.1-dev`. Završnu GitHub oznaku verzije napravite tek posle [kontrolne liste](RELEASE_CHECKLIST_SER.md).

## Redosled objavljivanja

1. Na GitHub-u otvorite **prazan javni repozitorijum** `election-forensics-r-toolkit`. Dajte sažet opis, na primer *Open R toolkit for reproducible Serbian election data preparation and descriptive election forensics*. Ne tražite automatsko kreiranje README, `.gitignore` ili licence: svi postoje u paketu.
2. **Otpakujte pun ZIP repozitorijuma** na svom računaru. Otvorite njegov unutrašnji folder `election-forensics-r-toolkit/`; prenesite **njegov sadržaj** u osnovni folder GitHub repozitorijuma, a ne sam ZIP fajl. Opcija **Add file > Upload files** omogućava ubacivanje fajlova/foldera u podržanim pregledačima; za veću strukturu praktičniji su Git komande ili GitHub Desktop.
3. Proverite korenske fajlove: `README.md`, `README_SER.md`, `LICENSE`, `CITATION.cff`, `.gitignore`, `GITHUB_UPLOAD_GUIDE*.md`, `RELEASE_CHECKLIST*.md` i beleške o verziji / manifest.
4. Proverite folder `modules/rzs_data_preparation/`: `RZS_data_preparation.R`, dvojezična dokumentacija, `RZS_station_status_overrides_TEMPLATE.csv`, `examples/` i `tests/`, uključujući zvanične referentne CSV i `validate_official_totals.R`.
5. Proverite `modules/descriptive_statistics/`: `Descriptive_statistics.R`, dva R fajla u `R/`, README na oba jezika, ostali dokumenti EN/SR, `tests/` sa skriptama i referencom, `examples/` i `docs/publication/` sa **četiri Word vodiča**.
6. Sačuvajte commit, na primer `Publish tested preparation and descriptive modules with bilingual documentation`. Proverite GitHub prikaz README linkova, srpskih slova, foldera i licence.
7. Lokalno izvršite testove za **istu verziju koda**, sačuvajte potpun RStudio zapis uspešnog izvršavanja v0.3.1, pa tek zatim napravite GitHub **Release** ili tag uz naveden opseg validacije i stavku 2017. REVIEW.

Ako koristite Git naredbe, nakon kreiranja praznog repozitorijuma:

```bash
cd election-forensics-r-toolkit
git init
git add .
git status
git commit -m "Add election data preparation and descriptive modules"
git branch -M main
git remote add origin https://github.com/USERNAME/election-forensics-r-toolkit.git
git push -u origin main
```

Zamenite `USERNAME` tek kada znate naziv GitHub naloga. Nemojte objavljivati tokene/lozinke. U GitHub Desktop-u moguće je dodati postojeći folder, pregledati razlike i izvršiti commit/publish.

## Šta se ne prenosi u Git

| Folder/fajl | Preneti? | Obrazloženje |
|---|---|---|
| `modules/rzs_data_preparation/raw_data/` i tri RZS originalna Excel fajla | **NE** | Izvor se preuzima zasebno; navesti URL i hash |
| `modules/rzs_data_preparation/RZS_prepared/` | **NE** | Generisane Excel/CSV baze; eventualno zaseban Release dodatak |
| `modules/descriptive_statistics/descriptive_outputs/` | **NE** | Generisani Excel/CSV/Word, bolje kao posebni prilozi |
| `**/validation_results/` | **NE** kao automatski radni podaci | Pregledani dokaz validacije može se zasebno objaviti u `docs/validation/` |
| `tests/` u oba modula | **DA** | Testovi i referentni podaci |
| `examples/` u oba modula | **DA** | Uputstva i primeri |
| `docs/publication/` | **DA** | Četiri dvojezična Word objašnjenja |
| `MANIFEST.sha256` | **DA**, nakon ponovnog obračuna | Integritet fajlova objavljene verzije |

`.gitignore` već isključuje izlaze i originalne podatke. Proverite `git status` i ne primenjujte `git add -f` na isključene baze. Ako odlučite da omogućite preuzimanje pripremljenih Excel fajlova preko GitHub Releases, navedite RZS izvor, verziju skripta, pravila podobnosti i SHA-256.

## Bez promena u pripremnom R skriptu

Za ovu dokumentacionu verziju **ne menjati** `modules/rzs_data_preparation/RZS_data_preparation.R`. Njegovi `Main`, `Master`, `Options`, grupe i QC oznake već odgovaraju deskriptivnom modulu. Podrška za buduće kolone RZS mora se izgraditi i testirati posebno, prema [SCHEMA_EVOLUTION_SER.md](modules/rzs_data_preparation/SCHEMA_EVOLUTION_SER.md). Pre završetka proverite [RELEASE_CHECKLIST_SER.md](RELEASE_CHECKLIST_SER.md).
