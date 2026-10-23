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

### Naslovi B-grafikona, razdvojene krive i panelni prikaz (v0.1.1)

Ranije je puno ime kandidata ili izborne liste bilo sastavni deo glavnog naslova B-grafikona, što je dovodilo do odsecanja teksta. Sada **glavni naslov** sadrži izbore i oblast, a **podnaslov** uvek sadrži `Izborna opcija: <puno ime>`. Pune nazive na oba jezika unosite kao i ranije u `OPTION_LABELS_EN/SR`. Tekst iz `CUSTOM_SUBTITLE_EN/SR`, ako postoji, dodaje se *posle* naziva. Prelamanje kontrolišu `TITLE_WRAP_CHARS` i `SUBTITLE_WRAP_CHARS`, bez izmena originalnih naziva i rezultata.

Kada je `B_SPLIT_COMBINED <- TRUE` (podrazumevano), kombinovani B-grafikon se deli na **dve slike**: `B_Option_XX_votes_combined_standard.png` za standardne grupe (`ALL, GE100, LT100, SMALL, MIDDLE, LARGE`) i `B_Option_XX_votes_combined_jhk.png` za `JHK_SMALL, JHK_LARGE`. Prikazuju se samo grupe iz `PLOT_GROUPS`. Zastarela datoteka `B_Option_XX_votes_combined.png` sa osam preklopljenih krivih uklanja se prilikom ponovnog pokretanja. Kada su `WRITE_FACETED <- TRUE` i `B_TWO_PANEL_FACET <- TRUE`, dobija se **jedna panelna slika** `B_Option_XX_votes_faceted.png`, sa standardnim i JHK grupama u dva panela, na uporedivim osama. `B_PANEL_COLUMNS=1L` znači da su paneli jedan ispod drugog, a `B_PANEL_HEIGHT_MULTIPLIER=1.45` povećava visinu. Ako želite samo panelni B-prikaz, postavite `B_SPLIT_COMBINED <- FALSE`. Ako ne želite panelnu verziju, postavite `B_TWO_PANEL_FACET <- FALSE`. Isto važi za PDF datoteke.

Za A-grafikone sa **tri ili više** kandidata/lista, `A_LEGEND_ROWS_3PLUS=2L` postavlja legendu u **dva reda**; jedna ili dve opcije ostaju u jednom redu. Duga puna imena prelamaju se prema `LEGEND_WRAP_CHARS=31L`, a veličina fonta podešava se kroz `LEGEND_FONT_SIZE=9.5`. Za B-grafikone sa više od dve grupe primenjuje se `B_LEGEND_ROWS_3PLUS=2L`. Po potrebi povećajte `PLOT_WIDTH_IN`/`PLOT_HEIGHT_IN` i koristite Unicode font.

Ovo je **isključivo grafička korekcija**. Nisu menjane kumulativne sume, izlaznost, sastav grupa BM, normalizacije, T90/T95 ili numerički rezultati. Dovoljno je ponovo pokrenuti `Klimek.R`, bez ponavljanja pripreme baze i deskriptivne analize. Izvršite `source("tests/test_graphics_layout.R")` i vizuelno proverite B-grafikon parlamentarne liste i A-grafikon sa tri opcije.

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


### Dorade naslova i osa u verziji v0.1.2-dev

A figure prikazuju puni naziv grupe biračkih mesta u drugom redu glavnog naslova. A i B figure koriste korak od 10 procentnih poena na vertikalnoj osi, a B figure sada prikazuju sve očekivane procentne oznake.


### Dorade lokalizacije naslova u verziji v0.1.3-dev

Glavni naslovi grafikona sada prikazuju čitljive i lokalizovane oznake izbora i oblasti (na primer, "parlamentarni 2022 Srbija"). Kod A figura grupa biračkih mesta prikazuje se u zasebnom drugom redu, u subtitle stilu, manjim fontom i bez bold-a. Ista logika važi i za odabrane okruge i opštine.



### Posebne kategorije RZS (v0.1.3.2-dev)

Za grafikone odabranih okruga (`GEOGRAPHIC_PLOTS = "selected"`) koristite zvanične šifre `SELECT_DISTRICT_CODES`. Šifra `33` prikazuje se kao **Inostranstvo** (EN: **Overseas**), a `55` kao **Zavodi za izvršenje krivičnih sankcija** (EN: **Prisons**). Za ove kategorije ne dodaje se „okrug/district”. U numeričkim tabelama ostaju originalne RZS kategorije. Za šifre `25`–`29` (povezane sa Kosovom u pripremnom modulu) zadržava se izvorni naziv iz RZS, a prevodi se samo već postojeći nastavak „okrug/district”. Takve administrativne oznake same po sebi ne utvrđuju fizičku lokaciju biračkog mesta. Za obične okruge nastavlja se pravilno dodavanje/prevod nastavka „okrug/district”. Važi za A i B figure i oba jezika.


### Grupe sa samo jednim biračkim mestom (v0.1.3.3-dev)

Kod izabranih okruga/opština neka grupa veličine BM može imati samo jedno kvalifikovano biračko mesto. Primer je grupa `Large` za Inostranstvo (šifra 33) na izborima 2022. Takvo opažanje prikazuje se jednom tačkom (parametar `SINGLE_POINT_SIZE`), jer je za kumulativnu liniju potrebno bar dva opažanja. Opažanje ostaje uključeno u sve numeričke rezultate. Ova situacija nije dokaz izborne nepravilnosti niti greška skripta. Jedna kratka poruka po oblasti zamenjuje ponovljena upozorenja funkcije `geom_line()`.


### Nula, jedno i više BM (v0.1.4)

**0 BM:** Grupa se prikazuje u tabelama okruga/opština sa `Stations=0`, brojači su nula, a nedefinisani procenti označeni sa `NA`. A-grafikon se ne crta, a B-grafikoni tu grupu izostavljaju. Ako u oblasti nema podataka za crtanje, ne generišu se nove slike. Stare A/B PNG/PDF datoteke te oblasti uklanjaju se pre novog crtanja; program ispisuje samo jednu zbirnu poruku `zero-station group(s)` po oblasti. **1 BM:** tačka. **2 ili više BM:** linija. Iz foldera `modules/klimek/` pokrenite `source("tests/test_zero_station_groups.R")`, pa postojeće testove i proveru izvoza. Priprema RZS baza se ne ponavlja.
