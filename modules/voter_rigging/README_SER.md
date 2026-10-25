# Statistička analiza pritisaka na birače na malim biračkim mestima

[English](README.md) · [Metodologija](METHODOLOGY_SER.md) · [Methodology](METHODOLOGY.md)

**Modul:** `voter_rigging` · **Skript:** `Voter_rigging.R` · **Verzija:** 0.1.1

Modul primenjuje **meru razlike između malih i velikih biračkih mesta** prema Jimenez, Hidalgo i Klimek (2017): geografsku standardizaciju, isključivanje vrednosti van 95% elipse, razliku medijana `D(p)` za pragove `p = 0,5%, 1%, …, 90%` i kumulativnu krivu udela glasova pobednika. Rezultati se čuvaju u CSV formatu, a grafikoni po uzoru na sliku 4 generišu se na engleskom i srpskom (latinica), za izabrani nacionalni, okružni i opštinski obuhvat.

## Važno metodološko ograničenje — faza B

**Ova verzija računa `D(p)`, ali NE računa međunarodno standardizovanu statistiku `δ(p)` iz originalnog rada.** Zato nije moguće verodostojno reprodukovati sivu „oblast prihvatanja” sa slike 4A, niti donositi zaključak da je izborni rezultat statistički značajan prema izvornom međunarodnom testu.

Autori su upoređivali **21 izborni ciklus iz deset država**. Za svaki prag `p` računali su `D(p)`, zatim modifikovanim Thompson tau postupkom utvrdili referentne izbore i standardizovali odstupanje pomoću referentne sredine i standardne devijacije. Tri trenutno pripremljena skupa podataka za Srbiju (predsednički 2017. i 2022; parlamentarni 2022) **nisu odgovarajuća nezavisna međunarodna referenca**. Dodatak radu daje veličine uzoraka i prosečne veličine BM, ali **ne daje potpune vrednosti `D(p)`** za 21 izborni ciklus. Ne bi bilo naučno prihvatljivo zameniti referencu sa tri srpska izbora, pretpostaviti normalnu referentnu raspodelu ili upisati nule umesto nedostajuće `δ(p)`.

U svim CSV rezultatima je zato `delta_reference=NA`, uz `reference_status=NOT_AVAILABLE`. Kada se pribavi odgovarajuća, metodološki uporediva međunarodna baza (faza A), modul se može proširiti originalnim referentnim testom.

Opciono se računaju **eksplorativne permutacije oznaka veličine biračkog mesta**. Njihove empirijske repne verovatnoće **nisu** zamena za međunarodni test autora. Rezultati se koriste samo za proveru osetljivosti i zavise od načina mešanja oznaka veličine. Izlaznost pritom u samom imeniocu sadrži broj upisanih birača.

## Ulazni podaci i izbor uzorka

Koriste se pripremljene RZS baze iz modula `rzs_data_preparation`, i to list **`Master`**, a ne `Main`. `Main` po pravilu isključuje biračka mesta sa E<100, dok su veoma mala BM posebno važna za ovo istraživačko pitanje.

Potrebne kolone su `Station_key`, `District_code`, `Municipality_code`, `E` (upisani birači), `B` (važeći glasovi), `C` (listići u kutiji/glasali prema definiciji baze) i `Winner_votes` (glasovi izabrane nacionalne pobedničke opcije). Ako kolona `Winner_votes` ne postoji, unapred su navedeni alternativni nazivi `Option_06_votes` za predsedničke izbore i `Option_01_votes` za parlamentarne 2022. **Pre upotrebe alternativnog naziva proveriti pobedničku opciju u listu `Options`.**

Provere uključuju jedinstven ID BM, geografske oznake, celobrojne nenegativne glasove, `E≥1`, `B>0`, `B≤C≤E` i `0≤W≤B`. **BM sa manje od 100 upisanih birača zadržavaju se** ako ispunjavaju ova pravila. Ne preuzimaju se oznake `Eligible_primary` ili `Eligible_contour`, jer one mogu sadržati ograničenje E≥100 iz drugih modula. Svako isključivanje evidentira se u `station_level_qc.csv`.

## Računska pravila

- **A:** izlaznost `B/E`; udeo pobednika `W/B` (varijanta bliža izvornom radu).
- **B:** izlaznost `C/E`; udeo pobednika `W/B` (provera robusnosti u skladu sa Toolkit-om).
- Svako BM standardizuje se prema **svim ostalim podobnim BM iste opštine** (*leave-one-out*). Opština mora imati **najmanje deset** podobnih BM, odnosno najmanje devet referentnih BM za konkretno mesto. Ovo je strože od pravila iz modula `contours`.
- Izračunava se **95% elipsa** na osnovu sredine i kovarijacione matrice standardizovanih vrednosti za sve izbore tog ciklusa, a tačke izvan elipse se ne uključuju u računanje `D(p)`. Njihovo isključivanje **nije znak da su BM bila predmet prevare**.
- Za svaki prag `p`, mala BM imaju broj upisanih birača **strogo manji** od p-tog percentila veličine BM u prikazanoj geografskoj jedinici nakon elipse; ostala su velika. U svakoj grupi mora biti najmanje **deset** BM.
- `D(p)` je euklidsko rastojanje između **koordinatnih medijana** dve grupe. Ne koristi KDE maksimume iz strelica modula `contours`.
- Kumulativni udeo iz panela 4B računa se nakon poređivanja BM od najvećeg ka najmanjem, kao **zbir glasova pobednika / zbir važećih glasova**. Za taj prikaz koriste se sva aritmetički podobna BM, bez filtera 95% elipse.
- Na okružnom i opštinskom nivou percentile veličine računamo u okviru prikazane teritorije, ali opštinsku standardizaciju i elipsu zadržavamo sa nivoa celog izbornog ciklusa. Lokalni rezultati su **eksplorativni**.

## Instalacija i izvršavanje u RStudio-u

1. Kopirati folder `voter_rigging` u `election-forensics-r-toolkit/modules/`.
2. U RStudio-u postaviti radni direktorijum na `modules/voter_rigging/`.
3. Instalirati pakete ako nedostaju: `install.packages(c("readxl", "ggplot2"))`.
4. Proveriti **EDITABLE SECTION** u skriptu `Voter_rigging.R`: putanje, izborni ciklusi, teritorijalni obuhvat i naziv kolone za glasove pobednika.
5. Pokrenuti:

```r
source("tests/run_tests.R")
source("tests/test_graphics.R")
source("tests/integration_real_data.R")  # opciono; zahteva lokalne Excel baze
source("Voter_rigging.R")
source("tests/check_exports.R")
```

Podrazumevano se obrađuju tri izbora na nacionalnom nivou. Za dodatne nivoe promeniti `GEOGRAPHIC_LEVELS <- c("national", "district", "municipality")` i, prema potrebi, izabrati `DISTRICT_CODES` / `MUNICIPALITY_CODES`. Za početni test može se izabrati samo jedan izborni ciklus. `RUN_EXPLORATORY_PERMUTATIONS <- FALSE` isključuje dopunsku randomizaciju.

## Izlazni fajlovi

Svi izlazi nalaze se u lokalnom `voter_rigging_outputs/`, koji se ne postavlja na GitHub. Čuvaju se `run_configuration.csv`, `export_manifest.csv`, `station_level_qc.csv`, `quality_summary.csv`, `ellipse_parameters.csv`, `D_by_size_threshold.csv`, `cumulative_vote_share.csv`, a opciono `permutation_summary.csv` i `permutation_draws.csv`. Detaljna struktura je navedena u [engleskom README-u](README.md).

Grafikoni `Figure4A_D_EN/SR.png` prikazuju **D(p), a ne originalnu δ(p)**; `Figure4B_cumulative_EN/SR.png` prikazuju kumulativni udeo glasova. Generiše se i objedinjeni dvopanelni prikaz, kao i poređenja više srpskih izbornih ciklusa na nacionalnom nivou. U slučaju nedovoljnog broja biračkih mesta pragovi ostaju u CSV datoteci sa `SKIP`/`INSUFFICIENT_GROUP` oznakom, bez izmišljanja rezultata.

## Tumačenje i literatura

Razlika između distribucija malih i velikih BM predstavlja **statistički obrazac za dodatnu proveru**, a ne dokaz pritiska na birače ili izborne prevare. Demografske, geografske, administrativne i druge okolnosti mogu uticati na ovakve obrasce. Izveštaji posmatrača, izvorni zapisnici i zakonski postupci ostaju neophodni za tumačenje.

Jimenez, R., Hidalgo, M., & Klimek, P. (2017). *Testing for voter rigging in small polling stations*. **Science Advances, 3**(6), e1602363. https://doi.org/10.1126/sciadv.1602363. Osnova: str. 3–6 i Supplementary Materials, str. 2–4.

### Tumačenje objedinjenih prikaza za definicije A i B

`Figure4_style_comparison_A_SR.png` u panelu sa **D(p)** koristi **definiciju izlaznosti A**, `B/E` (važeći glasovi / upisani birači), dok `Figure4_style_comparison_B_SR.png` koristi **definiciju B**, `C/E` (listići u kutiji / upisani birači). Definicija je označena u podnaslovu panela A. Kada je udeo nevažećih listića mali, krive `D(p)` mogu biti gotovo identične. **Panel 4B je potpuno isti** u obe objedinjene slike: računa kumulativne glasove pobednika podeljene kumulativnim važećim glasovima, nezavisno od definicije izlaznosti. Vertikalna osa panela 4A nosi naslov *Veličina efekta, D(p)*, **a ne** izvornu inferencijalnu statistiku `δ(p)`. U panelu 4B isprekidana linija označava 50%. Legenda koristi čitljive nazive izbora i prelazi u novi red posle najviše tri stavke.
