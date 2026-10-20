# Korisničko uputstvo — kumulativne krive Klimekovog tipa

[English](USER_GUIDE.md)

## 1. Preduslovi

Potreban je R (RStudio je poželjan) i paketi `readxl`, `openxlsx`, `ggplot2`, `readr`. Pokrenite `RZS_data_preparation.R` **samo ako pripremljene Excel baze još ne postoje ili zahtevaju novo generisanje**; u suprotnom koristite postojeće fajlove u `../rzs_data_preparation/RZS_prepared/`, bez ponavljanja prethodnih modula. Novi modul čita listove `Main`, `Master` i `Options`; ne čita originalne RZS Excel tabele bez pripreme. Radni direktorijum mora biti `modules/klimek`.

## 2. Granica izmena i izbori

Menjajte samo odeljak **EDITABLE** iznad upozorenja `DO NOT CHANGE THE CODE BELOW THIS LINE`. Jedan red `INPUTS` određuje tip izbora, godinu i putanju do pripremljenog Excel fajla. Predsednički i parlamentarni izbori iste godine imaju različitu oznaku. Za samo jedne izbore sačuvajte jedan red u sva tri vektora. `OUTPUT_DIR` određuje lokalni izlazni folder. Ponovljeno pokretanje može zameniti prethodne rezultate istog naziva, ali ne menja ulazni Excel.

## 3. Jezik, puni nazivi opcija i naslovi

`GRAPH_LANGUAGES <- "EN"` pravi grafikone na engleskom, `"SR"` na srpskom latinicom, a `c("EN","SR")` obe jezičke verzije u jednom prolazu. Za prevođenje punih naziva koristite liste čiji su ključevi tip i godina izbora, a unutrašnji nazivi **tačne** šifre iz `Options.Votes_field`:

```r
OPTION_LABELS_EN <- list(
  presidential_2022=c(Option_01_votes="Full candidate name in English")
)
OPTION_LABELS_SR <- list(
  presidential_2022=c(Option_01_votes="Puno ime kandidata na srpskom")
)
```

Primeri nisu stvarni nazivi; proverite `Options` pre unosa. `Option_01` je redosled u izvornom fajlu, **ne obavezno pobednik**. Bez ručno unetog prevoda skript preuzima izvorni naziv na srpskoj latinici, bez mašinskog prevođenja. `CUSTOM_MAIN_TITLE_EN/SR`, `CUSTOM_SUBTITLE_EN/SR`, `CUSTOM_X_LABEL_EN/SR` i četiri podešavanja `CUSTOM_Y_...` kontrolišu natpise na svakom jeziku. Ako dijakritici izostaju, u `BASE_FONT_FAMILY` unesite font sa podrškom za Š, Đ, Ž, Č, Ć, npr. `Arial` na Windows računaru.

## 4. Koji kandidati/liste se prikazuju

`OPTION_SELECTION_MODE="top_n"` sa `DISPLAY_TOP_N=3L` bira tri opcije sa najvećim ukupnim glasovima na nacionalnom nivou; `"all"` crta sve; `"selected"` koristi `SELECT_OPTION_FIELDS <- c("Option_01_votes","Option_04_votes")`. Posebna lista `OPTION_FIELDS_BY_ELECTION` može postaviti drugačiji izbor za pojedine izbore. Broj prikazanih krivih ne utiče na numeričke rezultate: nacionalne krive i zbirne tabele obrađuju **sve** kandidate/liste.

Osam grupa su `ALL` (sva QC prihvaćena BM), `GE100` (`Main`), `LT100` (prihvaćena BM ispod 100), `SMALL`, `MIDDLE`, `LARGE`, `JHK_SMALL`, `JHK_LARGE`. Grupe `SMALL/MIDDLE/LARGE` i `JHK_SMALL/JHK_LARGE` predstavljaju dve različite podele istog skupa `GE100`. Nacionalne granice iz pripremnog modula se ne preračunavaju po okruzima. Osmoro prikaza nisu međusobno nezavisni uzorci.

## 5. Dva imenitelja, dve vrste krivih

BM se sortiraju po izlaznosti `100*C/E` rastuće, a mesta sa istom izlaznošću po `Station_key`. Apscisa je izlaznost pojedinačnog BM u procentima, **ne** procenat obrađenih BM ili birača. Ako kandidat ima 800 glasova u grupi sa 2.000 važećih listića, kriva `valid` se završava na **40%** jer je imenitelj zbir svih važećih listića. Kriva `option` ima isti redosled kumulativnog sabiranja, ali se deli sa **800**, pa se završava na **100%**. Druga kriva pokazuje gde se duž ose izlaznosti nalaze glasovi same opcije, ne ukupnu podršku opciji. Ako opcija nije dobila nijedan glas, druga normalizacija je nedefinisana (`NA`).

`CURVE_NORMALISATIONS <- "both"` pravi obe verzije; `"valid"` ili `"option"` samo jednu. Skript koristi apsolutne brojeve glasova, ne zaokružene procente, i ne skraćuje ulaznu izlaznost na interval 0–100.

## 6. Podešavanje grafikona

`PLOT_FAMILY_A` daje više opcija u jednoj grupi; `PLOT_FAMILY_B` jednu opciju u više grupa. `WRITE_COMBINED` uključuje zbirni linijski grafikon, a `WRITE_FACETED` odvojene panele. Ako postavite `FACET_FREE_Y=TRUE`, svaki panel može imati drugačiju Y skalu, pa visine panela nisu direktno uporedive. `COLOR_SCHEME` bira `"OkabeIto"`, `"Dark2"`, `"Viridis"` ili `"Custom"`; pojedinačne boje daju se imenovanim vektorima, npr. `OPTION_COLORS <- c(Option_01_votes="#0072B2")` i `GROUP_COLORS <- c(ALL="#333333")`. Važe šifre `#RRGGBB`.

`PLOT_WIDTH_IN`, `PLOT_HEIGHT_IN`, `PNG_DPI`, `BASE_FONT_SIZE`, `BASE_FONT_FAMILY`, `LINE_WIDTH`, `ADD_POINTS`, `POINT_SIZE`, `POINT_ALPHA`, `LEGEND_POSITION` i `FACET_COLUMNS` regulišu izgled. `SAVE_PNG` i `SAVE_PDF` uključuju formate. `LIMIT_X_TO_100=TRUE` samo zumira prikaz, bez izmene ulaznih podataka; podrazumevano je FALSE. Za 19 parlamentarnih lista uglavnom je čitljiviji izbor tri najveće, a ne svih 19 zajedno.

## 7. Geografski prikaz

Numerički rezimei se **uvek** računaju za sve okruge i opštine. Grafikoni su nacionalni ako je `GEOGRAPHIC_PLOTS="national"`. Za pojedinačne oblasti stavite `"selected"` i unesite `SELECT_DISTRICT_CODES <- c("01")` ili `SELECT_MUNICIPALITY_KEYS <- c("01|001")`, koristeći **stvarne šifre** iz `tables/areas.csv`. Složeni ključ sprečava pogrešno spajanje opština istog naziva u različitim okruzima.

## 8. Opcione metrike T90 i T95

Uključite `ENABLE_BLOC_TAIL_METRICS=TRUE` samo ako ste eksplicitno definisali dva različita bloka u svakim izabranim izborima. Na primer:

```r
BLOC_A_BY_ELECTION <- list(parliamentary_2022=c("Option_01_votes"))
BLOC_B_BY_ELECTION <- list(parliamentary_2022=c("Option_02_votes","Option_03_votes"))
TAIL_PERCENTILES <- c(0.90,0.95)
```

Ove šifre su **ilustracija**, ne stvarno političko razvrstavanje. Grupe opcija se ne smeju preklapati. Gornjih 10% odnosno 5% BM određuje se prema odgovarajućem percentilu izlaznosti, uključujući sva izjednačenja. `Mean_station_margin_pp` je aritmetička sredina razlike udela opcija između BM; `Pooled_margin_pp` razlika ukupnih glasova blokova podeljena ukupnim brojem važećih glasova u repu. Ove vrednosti mogu biti različite zbog različite veličine BM. Ne izračunava se p-vrednost bez posebno definisane, statistički odbranjive nulte hipoteze.

## 9. Izlazi i kontrole

Pod `klimek_outputs/<izbori>/tables/` nalaze se Excel-kompatibilni CSV fajlovi, a zbirni XLSX direktno u folderu izbora. `curves/national/` sadrži niz tačaka svih nacionalnih krivih ako je `SAVE_CURVE_POINTS=TRUE`. `figures/<jezik>/<normalizacija>/<oblast>/` sadrži PNG/PDF grafikone. Obavezne provere su `ALL = GE100 + LT100`, `GE100 = SMALL + MIDDLE + LARGE` i `GE100 = JHK_SMALL + JHK_LARGE` za broj BM i upisane birače. `tables/curve_endpoints.csv` navodi krajnje vrednosti za sve opcije.

Pokrenite redom `source("tests/run_tests.R")`, `source("tests/integration_real_data.R")`, `source("Klimek.R")`, `source("tests/check_exports.R")`. Proverite bar jedan grafikon na oba jezika i krajnje vrednosti u odnosu na pripremljene glasove. Dodatna uputstva: [VALIDATION_SER.md](VALIDATION_SER.md).

## 10. Šta kriva znači, a šta ne znači

Nagao rast krive kod visoke izlaznosti označava relativno veliko prikupljanje glasova opcije na BM sa takvom izlaznošću, uz izabrani imenitelj. Uzroci mogu biti regionalna struktura, veličina biračkih mesta, sociodemografske razlike, mobilizacija, posebna BM ili problemi evidencije. **Kriva nije dokaz krađe**; za dalju proveru potrebni su uporedivi uzorci, kontrola geografije, zapisnici, izveštaji posmatrača i drugi nezavisni nalazi.
