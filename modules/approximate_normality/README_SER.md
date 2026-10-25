# Približna normalnost — Election Forensics R Toolkit

[English](README.md) · [Metodologija](METHODOLOGY_SER.md) · [Vodič kroz rezultate](OUTPUT_GUIDE_SER.md)

**Modul:** `approximate_normality` · **Verzija:** `0.1.2` · **Glavna skripta:** `Approximate_normality.R`

Modul implementira **standardizovanu logaritamsku stopu glasova** prema radu Klimek, Yegorov, Hanel i Thurner (2012), *Statistical detection of systematic election irregularities*, *PNAS* 109(41), 16469–16473, https://doi.org/10.1073/pnas.1210722109. Osnovni grafikoni slede prikaz sa **empirijskim intervalima povezanim dužima** iz slike 2, a ne izglađene procene gustine pomoću kernela (KDE).

## Naučni obuhvat i tumačenje

Glavno poređenje prikazuje raspodele različitih izbora na zajedničkoj skali (sredina nula, standardna devijacija jedan) i upoređuje ih sa očekivanim verovatnoćama normalne raspodele po intervalima. Dodatna, izričito označena adaptacija Toolkit-a poredi sva podobna biračka mesta sa grupama Small i Large iz pripremljene promenljive `Size`, **koristeći iste parametre standardizacije za sve grupe u okviru jednih izbora i područja**. Biračka mesta sa manje od 100 upisanih birača isključena su iz osnovnog uzorka, u skladu sa originalnim radom, ali mogu biti prikazana u **posebnoj analizi osetljivosti**.

Ovo su **opisni dijagnostički prikazi** heterogenosti izbornih rezultata. Približna normalnost ne dokazuje da su izbori regularni; odstupanje od normalnosti ne dokazuje falsifikovanje glasova niti bilo koju drugu nepravilnost. Originalni rad posebno navodi zavisnost od nivoa agregacije i legitimne izvore heterogenosti. Modul **ne implementira** zaseban parametarski model iz rada (`f_i`, `f_e`) i ne označava izbore ili biračka mesta kao prevarne.

## Zahtevi i struktura podataka

Potreban je R i paketi **`readxl`**, **`ggplot2`** i **`scales`**:

```r
install.packages(c("readxl", "ggplot2", "scales"))
```

RStudio radni direktorijum postavite na `election-forensics-r-toolkit/modules/approximate_normality/`. Podrazumevani `INPUTS` čita lokalne pripremljene Excel baze iz `../rzs_data_preparation/RZS_prepared/`:

```text
presidential_2017_RZS_prepared.xlsx
presidential_2022_RZS_prepared.xlsx
parliamentary_2022_RZS_prepared.xlsx
```

Koristi se list `Master`, jer čuva i biračka mesta sa manje od 100 birača. Obavezna polja: `Station_key`, `District_code`, `Municipality_code`, `E` (upisani), `B` (važeći listići), `C` (ubačeni listići), `Size` (ili `Size_JHK`) i `Winner_votes` (glasovi nacionalnog pobednika). Nazivi okruga i opštine su opcioni. Na listu `Options` potrebno je proveriti izbor pobedničkog kandidata/liste. Ako `Winner_votes` nedostaje, koriste se samo eksplicitno navedene alternativne kolone iz `WINNER_FIELD_FALLBACKS`, ako postoje; njihovo značenje treba potvrditi. Modul ne nagađa pobednika.

Originalni i pripremljeni podaci se ne menjaju i nisu deo javnog GitHub paketa.

## Podešavanje i izvršavanje

Na početku `Approximate_normality.R` podesite:

- `INPUTS`: šifra izbora i putanja do pripremljene baze; ovde se dodaju budući izbori.
- `GRAPH_LANGUAGES <- c("EN", "SR")`: engleski i srpski (latinica).
- `GEOGRAPHIC_LEVELS <- c("national")`: moguće je dodati `"district"` i `"municipality"`; opseg se bira preko `DISTRICT_CODES` i `MUNICIPALITY_CODES`.
- `SIZE_FIELD <- "Size"`: izvorne nacionalne kategorije Small/Large; alternativno `"Size_JHK"`.
- `BIN_WIDTH <- 0.2`: podesiva širina intervala u standardizovanim jedinicama. Originalni rad ne navodi egzaktno ponovljivu širinu intervala slike 2.
- `PLOT_X_LIMITS <- c(-5,5)`: samo vidljivi raspon; CSV fajlovi čuvaju i ekstremne intervale.
- `MIN_PRIMARY_STATIONS <- 30L`, `MIN_PLOTTED_GROUP <- 10L`: transparentni pragovi implementacije, a ne pragovi statističke značajnosti iz rada.
- `INCLUDE_UNDER100_SENSITIVITY <- TRUE`, `INCLUDE_CROSS_ELECTION <- TRUE`, `INCLUDE_WITHIN_ELECTION <- TRUE`.

Pokrenite:

```r
Sys.unsetenv("EF_APPROX_NORMALITY_TEST_MODE")
source("Approximate_normality.R", encoding="UTF-8")
```

Rezultati su u `approximate_normality_outputs/`, koji se ne šalje na GitHub.

## Grafikoni i CSV rezultati

Za podobne izbore i područja dobijaju se `Figure2_style_within_EN.png` i `Figure2_style_within_SR.png`. Kada postoji najmanje deset podobnih BM sa manje od 100 upisanih, generišu se i zasebni `Figure2_style_under100_EN.png` / `_SR.png`. Za poređenje najmanje dva izborna ciklusa na istoj teritoriji generišu se `Figure2_style_cross_elections_EN.png` / `_SR.png` u folderu `cross_election/`.

Na slikama se prikazuju **verovatnoće po histogramu**, bez KDE izglađivanja. Obojene tačke i duži označavaju učestalosti u intervalima jednake širine; crna linija predstavlja teorijske verovatnoće standardne normalne raspodele integrisane po tim intervalima i posebno je označena u legendi kao **Standardna normalna raspodela, N(0,1)**. Boje empirijskih krivih i njihovih oznaka u legendi potpuno su usklađene, dok je referentna normalna raspodela uvek crna; sve stavke koriste jednu legendu boja. Legende sa više od tri izbora prelaze u nove redove. Nazivi izbora na slikama nemaju donje crte.

CSV fajlovi čuvaju pravila uključivanja/isključivanja, vrednosti logaritamske stope i Z-skora po BM, parametre standardizacije, **granice i sredine intervala, brojeve i proporcije BM po intervalima, teorijske normalne verovatnoće**, asimetriju (*skewness*), standardnu spljoštenost (*kurtosis*, normalna raspodela = 3), Jarque–Bera statistiku i asimptotske p-vrednosti, kao i konfiguraciju i PASS/SKIP evidenciju. Detalji su u [Vodiču kroz rezultate](OUTPUT_GUIDE_SER.md).

## Testiranje

```r
source("tests/run_tests.R", encoding="UTF-8")
source("tests/test_graphics.R", encoding="UTF-8")
source("tests/integration_real_data.R", encoding="UTF-8")
Sys.unsetenv("EF_APPROX_NORMALITY_TEST_MODE")
source("Approximate_normality.R", encoding="UTF-8")
source("tests/check_exports.R", encoding="UTF-8")
```

Prva dva testa koriste sintetičke podatke. Integracioni test zahteva lokalne pripremljene RZS baze. Testovi novog modula ne zamenjuju prethodnu validaciju zvaničnih rezultata u modulu `rzs_data_preparation`.

## Referenca

Klimek, P., Yegorov, Y., Hanel, R., & Thurner, S. (2012). Statistical detection of systematic election irregularities. *Proceedings of the National Academy of Sciences*, *109*(41), 16469–16473. https://doi.org/10.1073/pnas.1210722109

Reprodukuju se objavljena matematička definicija logaritamske stope i ideja slike 2 sa histogramima. Poređenja grupa, ograničenja malih lokalnih uzoraka, širina intervala 0,2 i analiza BM sa manje od 100 birača jasno su označene **adaptacije Toolkit-a**, a ne tvrdnja o posedovanju izvornog programskog koda autora ili njihovih baza.
