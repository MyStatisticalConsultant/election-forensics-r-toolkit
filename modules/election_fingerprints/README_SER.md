# Izborni otisci — v0.1.4 (stabilna verzija)

[English](README.md) · [Korisničko uputstvo](USER_GUIDE_SER.md) · [Metodologija](METHODOLOGY_SER.md) · [Izlazi](OUTPUT_GUIDE_SER.md) · [Validacija](VALIDATION_SER.md) · [Promene](CHANGELOG_SER.md)

Nezavisni modul Election Forensics R Toolkit-a za **posmatrane dvodimenzionalne izborne otiske** prema slici 1 rada Klimek i saradnika (2012). Primarni prikaz predstavlja histogram **broja biračkih mesta (BM)** po ćelijama izlaznosti i udela glasova, a ne procenu gustine niti dokaz izborne manipulacije. KDE i alternativna izlaznost po ubačenim listićima su jasno izdvojeni kao dopunske analize. Parametri prevare `f_i`/`f_e` **nisu** predmet ovog modula.

## Definicije

Iz prethodno pripremljenog RZS lista `Main`, za podobna BM sa `E ≥ 100` upisanih birača:

- Primarna izlaznost (`x`) je `100 × B/E`, gde je `B` broj važećih glasova; udeo glasova nacionalno izabrane opcije (`y`) je `100 × W/B`.
- Dopunska izlaznost (`x`) je `100 × C/E`, gde je `C` broj ubačenih listića; imenilac udela glasova ostaje `B`.
- Svako BM sa definisanim stopama daje jedan broj u ćeliji 2D histograma. `HIST_BINS <- 50` daje 50×50 ćelija širine dva procentna poena.
- Opcija se bira prema nacionalnom `Options.Total_votes` i ostaje ista na svim teritorijalnim nivoima; moguć je ručni izbor.
- Dopunski KDE (`MASS::kde2d`) normalizovan je na maksimum na mreži 200×200, nije izvorni histogram i može biti pristrasan pri granicama. Preskače se za premalo BM ili bez varijabilnosti.

## Pokretanje

Radni direktorijum: `modules/election_fingerprints/`. Pripremljene Excel baze treba da postoje u `../rzs_data_preparation/RZS_prepared/`. Jednokratna instalacija paketa:

```r
install.packages(c("readxl", "ggplot2", "MASS", "ggExtra", "cowplot", "readr"))
```

Provera, analiza i kontrola izlaza:

```r
source("tests/run_tests.R")
source("tests/test_graphics.R")
source("tests/test_geography_validation.R")
source("tests/integration_real_data.R")
Sys.unsetenv("EF_FINGERPRINT_TEST_MODE")
source("Election_fingerprints.R")
source("tests/check_exports.R")
```

U **EDITABLE INPUTS** podesiti `AREA_MODE` (`national`, `selected`, `all`), `GENERATE_DISTRICTS`, `GENERATE_MUNICIPALITIES`, šifre, `GRAPH_LANGUAGES`, izbor kandidata/liste i grafičke opcije. **`INVALID_AREA_POLICY <- "error"` je uključen i podrazumevan:** nepostojeća izabrana šifra zaustavlja izvršavanje. Alternativa `"warn"` nastavlja sa važećim oblastima uz dijagnostiku i eventualni predlog ispravke.

Pet dodatnih grupa po veličini BM podrazumevano je uključeno: `SMALL`, `MIDDLE`, `LARGE` iz `Size` i `JHK_SMALL`, `JHK_LARGE` iz `Size_JHK`. Pripadnost je određena u nacionalnom pripremnom modulu, a ne ponovo računata po opštinama ili okruzima. Ove dve klasifikacije se preklapaju: ne sabirati svih pet grupa.

Rezultati su u `fingerprint_outputs/<izbori>/<oblast>/`, a grupe u `<oblast>/groups/<GRUPA>/`. Slike PNG/PDF nastaju odvojeno na engleskom i srpskom (latinica), uz CSV histograme, statuse i evidenciju BM. Prazne grupe nemaju slike, ali imaju status; sa jednim BM histogram je moguć, KDE se preskače. Skript ne menja ulazne baze.

**Validacija:** Autor je dostavio PASS rezultate numeričkih, grafičkih (KDE 200×200, podnaslov 14 pt), geografskih i integracionih testova i provere svih izvoznih nivoa za tri podržana izbora. Operativno su provereni nacionalni nivo, četiri okruga i dve opštine po izborima, bez neočekivanih R upozorenja. Tačan obim i ograničenja: [VALIDATION_SER.md](VALIDATION_SER.md).

Izvor: Klimek, P., Yegorov, Y., Hanel, R., & Thurner, S. (2012), *Statistical detection of systematic election irregularities*, PNAS 109(41), 16469–16473. https://doi.org/10.1073/pnas.1210722109
