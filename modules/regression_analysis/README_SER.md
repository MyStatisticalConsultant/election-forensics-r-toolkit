# Regresiona analiza — Election Forensics R Toolkit

**Modul:** `regression_analysis` · **Verzija:** v0.1.8 (razvojna) · **Jezici:** engleski i srpski (latinica)

## Pregled

Modul sadrži dve skupine regresionih dijagnostičkih analiza biračkih mesta (BM):

1. **Lukinova i saradnici (2011):** regresija procenta glasova kandidata/lista u odnosu na broj upisanih birača na izlaznost. Upoređuju se nacionalni pobednik i drugoplasirani. Forma obične linearne regresije (*ordinary least squares*, OLS) prati slike 12–29 i strane 613–620 izvornog rada. Interpretacija specifična za ruske izbore ne prenosi se automatski na Srbiju.
2. **Regresije inspirisane Mebaneovim razmatranjem nevažećih listića:** povezanost procenta važećih glasova za pobednika sa **brojem** nevažećih listića (B1), odnosno **stopom** nevažećih listića (B2). Kao zasebne analize osetljivosti procenjuju se modeli uz kontrolu izlaznosti i veličine biračkog mesta, a kada je opravdano i fiksni efekti opština. Ovo nije tvrdnja da se reprodukuje poseban formalni Mebaneov regresioni test.

**Statistička povezanost nije dokaz izborne manipulacije.** Ni značajan ni neznačajan koeficijent sami po sebi ne dokazuju prisustvo ili odsustvo nepravilnosti.

## Fajlovi

`Regression_analysis.R` sadrži podesive parametre. `R/regression_core.R` izvršava proveru podataka, izbor kandidata, OLS, HC3 robusne standardne greške i dijagnostiku; `R/regression_plots.R` crta dvojezične grafikone. U `tests/` su četiri testa. `METHODOLOGY.md` / `METHODOLOGY_SER.md` detaljno opisuju metod, a `OUTPUT_GUIDE.md` / `OUTPUT_GUIDE_SER.md` izlazne fajlove.

## Instalacija i izvršavanje

Postavite radni direktorijum na `modules/regression_analysis/` i izvršite:

```r
install.packages(c('readxl','ggplot2')) # samo ako nedostaju
source('tests/run_tests.R')
source('tests/test_graphics.R')
source('tests/integration_real_data.R')
Sys.unsetenv('EF_REGRESSION_TEST_MODE')
source('Regression_analysis.R')
source('tests/check_exports.R')
```

Podrazumevani ulazi su radni listovi `Master` za predsedničke izbore 2017/2022. i parlamentarne izbore 2022. iz `../rzs_data_preparation/RZS_prepared/`. Lokalni ulazni Excel fajlovi i rezultati nisu deo javnog GitHub repozitorijuma.

### Podesivi parametri

`INPUTS` dopušta dodavanje drugih izbora. Modul automatski bira dve opcije sa najviše glasova na nacionalnom nivou, koristeći `Option_NN_votes`, i proverava da pobednik odgovara `Winner_votes` (ili unapred određenom zamenskom polju). U `SELECTION` mogu se uneti dve eksplicitne kolone po izborima, pri čemu prva mora biti nacionalni pobednik. Imena kandidata/lista automatski se čitaju iz radnog lista `Options` preko `Option_number`, a u `selected_options.csv` beleži se izvor oznake. Ako ne postoji pouzdano mapiranje, izvršavanje prijavljuje grešku i traži eksplicitni `OPTION_LABELS`; identitet se nikad ne nagađa na osnovu `Option_NN`. Delimično ručno mapiranje kroz imenovani `OPTION_LABELS` vektor ili listu je podržano: nedostajući nazivi biraju se iz radnog lista `Options`.

`TURNOUT_DEFINITIONS = c('C/E','B/E')` računa izlaznost pomoću ubačenih, odnosno važećih listića; **primarna definicija je `C/E`**. Broj nevažećih listića iznosi `C-B`, a stopa `100(C-B)/C`, nezavisno od izabrane definicije izlaznosti.

`SIZE_CLASSIFICATIONS = c('Size','Size_JHK')` uključuje **obe** podele BM. Grafikoni `Size` imaju četiri panela: sva podobna BM (E ≥ 100), mala, velika i BM sa manje od 100 birača. Grafikoni `Size_JHK` imaju tri panela: sva BM i JHK mala gore, JHK velika centrirano ispod; izdvojena analiza BM sa manje od 100 birača ostaje u `Size` grafikonima i CSV rezultatima. Grupe se delimično preklapaju. `Size_JHK` potiče iz nacionalne pripreme podataka i **ne preračunava se unutar okruga ili opštine**.

`GEOGRAPHIC_LEVELS` omogućava nacionalni, okružni i opštinski nivo; podrazumevani je nacionalni. Za nedovoljan broj BM ili premalu varijabilnost prediktora upisuje se jasan status preskakanja, umesto nepouzdane regresije.

Rezultati se smeštaju u `regression_analysis_outputs/`. Modul ne menja pripremljene podatke ni druge module.


### Prikaz grafikona (v0.1.8)

Svi fontovi povećani su 1,5 puta u odnosu na v0.1.3. Kod modela A formule su u gornjem levom uglu, sa razmakom koji razdvaja pobednika i drugoplasiranog; kod B1/B2 nalaze se u donjem desnom uglu, dalje od najgušćih delova dijagrama. Legenda sadrži jedan horizontalni red, a donje napomene su povećane. Naslov modela A opisuje regresiju bez pripisivanja autorstva Lukinovoj. Numerički OLS modeli i definicije grupa nisu menjani. JHK grafikoni imaju zajedničku legendu i centrirani donji panel za veliku grupu.

## Tumačenje

U prvom delu zavisna promenljiva je `100 glasovi/E`, a nezavisna `100 izlaznost`. Ove veličine su matematički povezane: pozitivan koeficijent je moguć bez ikakve manipulacije. Nagib blizu ili iznad 1 kod Lukinove i saradnika tumači se u konkretnom istorijskom i geografskom kontekstu, ne kao univerzalni prag.

U drugom delu apsolutni broj nevažećih listića zavisi od veličine BM. Stopa nevažećih i modeli sa kontrolnim promenljivama donekle rešavaju taj problem, ali ne otklanjaju sve izvore heterogenosti ni daju uzročno tumačenje. Pored klasičnih prikazuju se i HC3 robusne standardne greške.

Testovi proveravaju funkcionisanje na kontrolisanim primerima i ugovor o ulaznim RZS podacima, ali ne predstavljaju nezavisno usaglašavanje zvaničnih ukupnih rezultata niti dokaz nepravilnosti.

**Izvor:** Lukinova, E., Myagkov, M., & Ordeshook, P. C. (2011). *Metastasised Fraud in Russia’s 2008 Presidential Election*. Europe-Asia Studies, 63(4), 603–621. Dodatna objašnjenja su u `METHODOLOGY_SER.md`.
