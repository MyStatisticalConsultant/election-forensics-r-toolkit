# Kumulativne izborne krive u stilu Klimeka — R modul v0.1.4

**Election Forensics R Toolkit** · [English](README.md) · [Detaljno korisničko uputstvo](USER_GUIDE_SER.md)

Ovaj lokalno pokretani modul je **jedan R skript** koji generiše kumulativne krive glasova u funkciji izlaznosti, uporedne grafikone i reproduktivne numeričke preglede na osnovu listova `Main`, `Master` i `Options` koje kreira `RZS_data_preparation.R`. Predviđen je za prethodno proverene formate predsedničkih izbora 2017. i 2022. i parlamentarnih izbora 2022. Novi formati Republičkog zavoda za statistiku (RZS) zahtevaju posebnu proveru.

**Izdanje v0.1.4 (23. oktobar 2026):** Ovo objedinjeno izdanje zamenjuje razvojne zakrpe do v0.1.3.4-dev. Autor je potvrdio da grafikoni za nula, jedno i više biračkih mesta izgledaju kako je očekivano. **Autor je potvrdio PASS za regresione, integracione i izvozne testove za sva tri izbora: predsedničke 2017. i 2022. i parlamentarne 2022.** Dostavljeni detaljni log odnosi se na parlamentarne 2022. (7.787 Main BM, 436 figura); [zapisnik validacije](VALIDATION_RECORD_2026-10-23_SER.md). Za predsedničke izbore nisu priloženi zasebni logovi. Testovi nisu nezavisno ponovljeni u okruženju za pakovanje. Analitičke definicije i formule nisu menjane. Modul **ne sprovodi kompletan Jiménez–Hidalgo–Klimek (JHK) forenzički test**, niti neuobičajena kriva dokazuje izbornu prevaru.

## Šta modul radi

Pravi dve porodice grafikona: **A** poredi izabrane kandidate/izborne liste unutar jedne grupe biračkih mesta (BM), a **B** jednu opciju između grupa BM. Za A-grafikone sa tri ili više lista legenda je u **dva reda**. B-grafikoni odvojeno prikazuju **standardne grupe (do šest krivih)** i **JHK grupe (dve krive)**, a panelna verzija prikazuje obe klasifikacije na jednoj slici sa dva panela. Puno ime liste/kandidata nalazi se u **podnaslovu**. Postoje PNG/PDF izvoz, engleski i srpski (latinica) u **jednom izvršavanju**, korisnički prevodi naziva i boje po šifri opcije/grupe. Standardno prikazuje nacionalne krive, a po izboru i konkretne okruge/opštine. Numerički pregledi uključuju sve opcije na nacionalnom, okružnom i opštinskom nivou; nacionalne kumulativne krive računaju se za sve opcije bez obzira na to koliko se prikazuje.

Osam grupa su `ALL` (sva QC prihvaćena BM), `GE100` (glavni uzorak `Main`), `LT100` (QC prihvaćena BM ispod 100 birača), `SMALL`, `MIDDLE`, `LARGE`, `JHK_SMALL`, `JHK_LARGE`. Klasifikacije `Size` i `Size_JHK` se samo čitaju, ne preračunavaju. Grupe se delimično preklapaju i zato se **ne sabiraju međusobno**. Opcione opisne metrike T90/T95 traže eksplicitno definisana dva politička bloka. **Permutacioni test nije automatski uključen.**

Dve normalizacije krivih: `valid` = kumulativni glasovi opcije / svi važeći listići (završetak je udeo opcije); `option` = kumulativni glasovi / svi glasovi te opcije (završetak je 100% ako je opcija dobila glasove). Detalji u [METHODOLOGY_SER.md](METHODOLOGY_SER.md).

**Posebne RZS kategorije:** naslovi koriste šifru `District_code`: `33` = Inostranstvo, `55` = Zavodi za izvršenje krivičnih sankcija (bez nastavka „okrug”). Za šifre `25–29` zadržava se zvanični naziv, bez dodavanja teritorijalnog nastavka. Videti [USER_GUIDE_SER.md](USER_GUIDE_SER.md).

## Instalacija i pokretanje

Instalirajte R i, po želji, RStudio. U R konzoli:

```r
install.packages(c("readxl", "openxlsx", "ggplot2", "readr"))
```

Napravite pripremljene baze prethodnim modulom, sačuvajte ih **lokalno** u `../rzs_data_preparation/RZS_prepared/`, a zatim otvorite `modules/klimek` kao radni direktorijum. Izmenite isključivo odeljak **EDITABLE** u `Klimek.R` i pokrenite:

```r
source("tests/run_tests.R")
source("tests/test_graphics_layout.R")
source("tests/test_single_station_plots.R")
source("tests/test_zero_station_groups.R")
source("tests/integration_real_data.R")
source("Klimek.R")
source("tests/check_exports.R")
```

Rezultati se odvojeno čuvaju po izborima u `klimek_outputs/`: `tables/`, `curves/`, `figures/<EN|SR>/<valid|option>/...`. Izvorni Excel fajlovi se ne menjaju. CSV se čuva kao UTF-8 sa BOM, radi pravilnog prikaza slova Š, Đ, Ž, Č i Ć u Excel-u. Za PDF grafikone po potrebi odaberite odgovarajući Unicode font.

## Dokumentacija i ograničenja

[USER_GUIDE_SER.md](USER_GUIDE_SER.md) objašnjava svako korisničko podešavanje, [METHODOLOGY_SER.md](METHODOLOGY_SER.md) formule i ograničenja, [DATA_DICTIONARY_SER.md](DATA_DICTIONARY_SER.md) promenljive, [OUTPUT_GUIDE_SER.md](OUTPUT_GUIDE_SER.md) rezultate, a [VALIDATION_SER.md](VALIDATION_SER.md) provere.

Oblik krive može odražavati demografiju, geografiju, mobilizaciju ili greške u podacima, bez nužne veze sa manipulacijom. Dalja provera može zahtevati poređenje uporedivih područja, zapisnike, izveštaje posmatrača i odgovarajuće statističke modele. Predlog citiranja: Kovačić, Z. J. (2026). *Election Forensics R Toolkit: Klimek-style cumulative curves* (v0.1.4) [R skript]. GitHub repozitorijum, dopuniti konkretnim izdanjem. Licenca: [MIT](../../LICENSE).


### Prazne grupe (uključeno u v0.1.4)

U teritorijalne tabele unose se kombinacije oblast × svih osam grupa BM × izborna opcija i kada nema nijednog BM (`Stations=0`, zbirni brojači nula, nedefinisani procenti kao doslovni `NA` u tabelama za okruge i opštine). Za takvu grupu **ne crta se kriva**. Jedno BM prikazuje se tačkom, a dva ili više linijom. Program ispisuje jednu poruku po oblasti. Pri ponovnom izvršavanju brišu se ranije Klimek A/B slike samo te izabrane oblasti, čime se izbegavaju zastareli grafikoni. Videti `tests/test_zero_station_groups.R` i `USER_GUIDE_SER.md`. Teritorijalne tabele obuhvataju samo oblasti koje postoje u prihvaćenoj populaciji `ALL`.

**Završna potvrda testiranja:** Autor je potvrdio uspeh svih testova za sva tri izbora. Detaljni završni log dostavljen je za `parliamentary_2022`, a za predsedničke 2017. i 2022. PASS je potvrđen bez zasebnog loga. [Zapisnik validacije](VALIDATION_RECORD_2026-10-23_SER.md).
