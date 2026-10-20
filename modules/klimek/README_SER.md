# Kumulativne izborne krive u stilu Klimeka — R modul v0.1.0-dev

**Election Forensics R Toolkit** · [English](README.md) · [Detaljno korisničko uputstvo](USER_GUIDE_SER.md)

Ovaj lokalno pokretani modul je **jedan R skript** koji generiše kumulativne krive glasova u funkciji izlaznosti, uporedne grafikone i reproduktivne numeričke preglede na osnovu listova `Main`, `Master` i `Options` koje kreira `RZS_data_preparation.R`. Predviđen je za prethodno proverene formate predsedničkih izbora 2017. i 2022. i parlamentarnih izbora 2022. Novi formati Republičkog zavoda za statistiku (RZS) zahtevaju posebnu proveru.

**Status:** razvojna verzija. Ugrađene su formule i sintetički testovi, ali je potrebno izvršiti novi skript u RStudio okruženju nad tri baze i pregledati grafikone. Modul **ne sprovodi kompletan statistički test Jiménez–Hidalgo–Klimek (JHK)**; neuobičajena kriva nije dokaz izborne prevare.

## Šta modul radi

Pravi dve porodice grafikona: **A** poredi izabrane kandidate/izborne liste unutar jedne grupe biračkih mesta (BM), a **B** jednu opciju između grupa BM. Postoje kombinovane i panelne verzije, PNG/PDF izvoz, engleski i srpski (latinica) u **jednom izvršavanju**, korisnički prevodi naziva i boje po šifri opcije/grupe. Standardno prikazuje nacionalne krive, a po izboru i konkretne okruge/opštine. Numerički pregledi uključuju sve opcije na nacionalnom, okružnom i opštinskom nivou; nacionalne kumulativne krive računaju se za sve opcije bez obzira na to koliko se prikazuje.

Osam grupa su `ALL` (sva QC prihvaćena BM), `GE100` (glavni uzorak `Main`), `LT100` (QC prihvaćena BM ispod 100 birača), `SMALL`, `MIDDLE`, `LARGE`, `JHK_SMALL`, `JHK_LARGE`. Klasifikacije `Size` i `Size_JHK` se samo čitaju, ne preračunavaju. Grupe se delimično preklapaju i zato se **ne sabiraju međusobno**. Opcione opisne metrike T90/T95 traže eksplicitno definisana dva politička bloka. **Permutacioni test nije automatski uključen.**

Dve normalizacije krivih: `valid` = kumulativni glasovi opcije / svi važeći listići (završetak je udeo opcije); `option` = kumulativni glasovi / svi glasovi te opcije (završetak je 100% ako je opcija dobila glasove). Detalji u [METHODOLOGY_SER.md](METHODOLOGY_SER.md).

## Instalacija i pokretanje

Instalirajte R i, po želji, RStudio. U R konzoli:

```r
install.packages(c("readxl", "openxlsx", "ggplot2", "readr"))
```

Napravite pripremljene baze prethodnim modulom, sačuvajte ih **lokalno** u `../rzs_data_preparation/RZS_prepared/`, a zatim otvorite `modules/klimek` kao radni direktorijum. Izmenite isključivo odeljak **EDITABLE** u `Klimek.R` i pokrenite:

```r
source("tests/run_tests.R")
source("tests/integration_real_data.R")
source("Klimek.R")
source("tests/check_exports.R")
```

Rezultati se odvojeno čuvaju po izborima u `klimek_outputs/`: `tables/`, `curves/`, `figures/<EN|SR>/<valid|option>/...`. Izvorni Excel fajlovi se ne menjaju. CSV se čuva kao UTF-8 sa BOM, radi pravilnog prikaza slova Š, Đ, Ž, Č i Ć u Excel-u. Za PDF grafikone po potrebi odaberite odgovarajući Unicode font.

## Dokumentacija i ograničenja

[USER_GUIDE_SER.md](USER_GUIDE_SER.md) objašnjava svako korisničko podešavanje, [METHODOLOGY_SER.md](METHODOLOGY_SER.md) formule i ograničenja, [DATA_DICTIONARY_SER.md](DATA_DICTIONARY_SER.md) promenljive, [OUTPUT_GUIDE_SER.md](OUTPUT_GUIDE_SER.md) rezultate, a [VALIDATION_SER.md](VALIDATION_SER.md) provere.

Oblik krive može odražavati demografiju, geografiju, mobilizaciju ili greške u podacima, bez nužne veze sa manipulacijom. Dalja provera može zahtevati poređenje uporedivih područja, zapisnike, izveštaje posmatrača i odgovarajuće statističke modele. Predlog citiranja: Kovačić, Z. J. (2026). *Election Forensics R Toolkit: Klimek-style cumulative curves* (v0.1.0-dev) [R skript]. GitHub repozitorijum, dopuniti konkretnim izdanjem. Licenca: [MIT](../../LICENSE).
