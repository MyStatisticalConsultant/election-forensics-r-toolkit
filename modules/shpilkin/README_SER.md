# Špiljkin: raspodele izbornih rezultata i uslovni scenariji viška glasova

[English](README.md) · [Metodologija](METHODOLOGY_SER.md) · [Objašnjenje izlaza](OUTPUT_GUIDE_SER.md)

**Modul:** `shpilkin` | **Verzija:** 0.1.3 | **Glavna skripta:** `Shpilkin.R`

Modul je samostalan deo *Election Forensics R Toolkit-a* i sadrži **tri povezana, ali različita** postupka:

1. **Opisni histogrami** izlaznosti i rezultata nacionalnog pobednika, sa centriranim intervalima (podrazumevano 0,5 procentnih poena, opciono 0,25), normiranom površinom i ponovljivim pomeranjem brojioca samo za slike.
2. **Test celobrojnih procenata Kobak–Špiljkin–Pšeničnikov (2016):** originalni ponderisani histogrami širine 0,1 procentni poen, celobrojni prozor ±0,05 poena, nezavisne binomne Monte Karlo simulacije i kontrola polucelobrojnih procenata.
3. **Uslovni neparametarski scenario Špiljkinovog viška glasova:** krive pobednika i ostalih važećih glasova prema izlaznosti, određivanje referentnog područja, skaliranje i analiza osetljivosti. Treći postupak je eksplicitno definisano prilagođavanje, **ne doslovna reprodukcija jedinstvenog algoritma iz dostavljenog PDF-a**.

Modul ne proglašava izborne rezultate ili biračka mesta falsifikovanim. Monte Karlo test proverava ograničenu hipotezu o učestalosti celobrojnih procenata; scenario viška glasova nije utvrđen broj ilegalnih glasova.

## Zahtevi i ulazni podaci

- R 4.2+ (preporučeno); paketi `readxl` i `ggplot2`. Nije potreban EFToolkit.
- Radni direktorijum `modules/shpilkin/`.
- Pripremljene baze `../rzs_data_preparation/RZS_prepared/*_RZS_prepared.xlsx`, list **Master**, čuvaju se lokalno.
- Kolone: `Station_key`, `District_code`, `Municipality_code`, `E`, `B`, `C`, `Winner_votes`. Alternativna kolona pobednika koristi se isključivo ako zajedničko polje ne postoji; pobednika je potrebno proveriti u listu `Options`.
- Osnovna izlaznost `C/E`, dopunska `B/E`, udeo glasova pobednika `W/B`. Definicije se razlikuju od originalnih ruskih administrativnih podataka; detalji su u metodologiji.
- BM sa E < 100 ne ulaze u osnovne analize; kriterijumi su detaljno zabeleženi. Iz prikaza se isključuju granice od 100%, a iz celobrojnog testa BM sa posmatranim procentom iznad 99%.

## Pokretanje u RStudio-u

Postavite radni direktorijum na `modules/shpilkin`, zatim:

```r
install.packages(c('readxl','ggplot2')) # samo ako nedostaju
source('tests/run_tests.R')
source('tests/test_graphics.R')
source('tests/integration_real_data.R')
Sys.unsetenv('EF_SHPILKIN_TEST_MODE')
source('Shpilkin.R')
source('tests/check_exports.R')
```

Rezultati su u `shpilkin_outputs/`. Puna obrada više izbornih ciklusa i dve definicije izlaznosti može zahtevati više vremena. Sintetički testovi koriste mali broj simulacija, dok glavna analiza koristi vrednost iz podesivog dela skripte.

## Ključna podešavanja

U početnom delu `Shpilkin.R` biraju se izbori, putanje, nacionalni/okružni/opštinski nivo, jezici (`EN`,`SR`), širina intervala, broj Monte Karlo simulacija, seme i referentni opseg za procenu viška.

**Razlika između širina intervala je ključna:** `DESCRIPTIVE_BIN_WIDTH <- 0.5` daje preglednije grafikone za Srbiju, ali **ne menja** statistički test sa `INTEGER_BIN_WIDTH <- 0.1` i `INTEGER_WINDOW_HALF_WIDTH <- 0.05`. Originalna ilustracija iz časopisa *Significance* koristila je 0,25; preporučuje se uporedna provera i sa tom vrednošću.

`MONTE_CARLO_REPS <- 999L` podrazumevano služi eksplorativnoj analizi. Za isti broj simulacija kao u izvornom radu podesite **10.000 ponavljanja**. Najmanja prijavljiva Monte Karlo p-vrednost je `1/(reps+1)`.

Najbolje je da se `EXCESS_CORE_RANGE <- c(donja,gornja)` odredi pre razmatranja rezultata. Ako je NULL, skripta bira raspon oko modalne izlaznosti i izlaz označava kao automatski opisni scenario. CSV prikazuje rezultate za različite poluširine referentnog područja.

**Tumačenje grafikona viška glasova:** `Excess_scenario_EN/SR.png` prikazuje crvenu krivu stvarnih glasova pobednika i plavu **referentnu krivu skaliranih ostalih važećih glasova** (plava kriva *nije* Monte Karlo srednja vrednost). Sivo su prikazani samo pozitivni viškovi iznad gornje tačkaste granice referentnog opsega. Podnaslov daje zbir u glasovima i udeo u stvarnim glasovima pobednika. To nije dokazani broj falsifikovanih glasova. Tačna, nezaokružena vrednost je u `excess_summary.csv`, a doprinosi po intervalima u `excess_turnout_bins.csv`. Sive oblasti na odvojenim Monte Karlo dijagramima označavaju simulacione referentne intervale i imaju drugačije značenje.

## Izlazi

Za svaku kombinaciju izbora, izlaznosti i teritorijalne jedinice čuvaju se CSV fajlovi sa QC kriterijumima, izvornim i eventualno pomerenim procentima za grafikone, histogramima, ponavljanjima Monte Karlo testa, statistikom odstupanja, referentnim opsezima i scenarijima viška. Grafici su na engleskom i srpskom (latinica). U korenskom izlaznom folderu nalaze se konfiguracija, evidencija izvršavanja i uporedni grafikoni izbora. Pogledajte [OUTPUT_GUIDE_SER.md](OUTPUT_GUIDE_SER.md).

## Literatura i ograničenja

- Kobak, Shpilkin i Pshenichnikov (2016), *Integer percentages as electoral falsification fingerprints*, **Annals of Applied Statistics** 10(1), 54–73. https://doi.org/10.1214/16-AOAS904
- Kobak, Shpilkin i Pshenichnikov (2016), *Statistical fingerprints of electoral fraud?*, **Significance** 13(4), 20–23. https://doi.org/10.1111/j.1740-9713.2016.00936.x
- Dopunsko objašnjenje modela viška: https://cedarus.io/research/evolution-of-russian-elections ; dokumentacija funkcije `NonparamElectionForensics()` u originalnom EFToolkit-u. Taj paket nije korišćen kao zavisnost niti je njegov kod preuzet.

### Opseg validacije

Prošli su sintetički testovi formula, testovi dvojezičnih grafikona, integraciona provera pripremljenih baza i test izvoza za predsedničke izbore 2017. i 2022. i parlamentarne izbore 2022. U opisne histograme ulazi redom **7.988**, **7.772** i **7.787** BM; u test celobrojnih procenata **7.983**, **7.768** i **7.786** BM. Grafikoni i CSV izlazi generisani su za sva tri izbora. Ove provere potvrđuju kompatibilnost ulaznog formata i kontrolu kvaliteta na nivou BM, ali **ne predstavljaju** nezavisno usaglašavanje sa zvaničnim nacionalnim zbirovima, nezavisnu replikaciju objavljenih rezultata niti utvrđivanje izborne prevare. Podrazumevanih 999 Monte Karlo ponavljanja nije jednako izvornom standardu od 10.000 ponavljanja. Za naučno tumačenje treba dodatno proveriti poreklo podataka, imenioce, referentni opseg za procenu viška i osetljivost rezultata. Lokalne ulazne baze i generisani rezultati nisu sastavni deo javnog paketa.

**Prikaz viška glasova:** Siva oblast pri visokoj izlaznosti ograničena je crvenom i plavom krivom, a njihovi preseci računaju se interpolacijom. Ne koriste se pravougaonici. Prikazani broj glasova i dalje je **zbir pozitivnih odstupanja po intervalima** iz CSV fajlova, a ne geometrijska površina na slici.


**Provera grafikona:** Pokrenite `source("tests/test_graphics.R")` radi provere zasenčenja koje prati krive, interpoliranih preseka, napomena u dva reda na oba jezika i PNG izvoza.
