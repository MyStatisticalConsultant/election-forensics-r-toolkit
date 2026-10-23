# Izborni otisci v0.1.4 — evidencija validacije

[English](VALIDATION.md) · [README](README_SER.md) · [Testovi](tests/)

**Osnov potvrde:** Autor je 24. oktobra 2026. dostavio uspešne rezultate izvršavanja u RStudio-u za kompletnu razvojnu verziju v0.1.3.1. Stabilna v0.1.4 menja samo oznaku izdanja i početno podešavanje `INVALID_AREA_POLICY <- "error"` (ranije `"warn"`); statističke, grafičke, geografske i izvozne funkcije ostaju iste. Ovde su zabeleženi **rezultati izvršavanja koje je dostavio autor**, a ne tvrdnja da je R pokrenut prilikom pravljenja arhive.

## Potvrđeni testovi za tri izborna skupa

| Test ili izvršavanje | Rezultat prema dostavljenom logu |
|---|---|
| `tests/run_tests.R` | PASS: kanonske stope, 2D broj BM, rubovi ćelija, izbor nacionalnog pobednika, dvojezične šifre |
| `tests/test_graphics.R` | PASS: EN/SR slike, stvarna mreža KDE 200×200 bez odbačenih rubnih ćelija, podnaslov 14 pt, slučaj jednog BM |
| `tests/test_geography_validation.R` | PASS: nevažeći ključevi i predlozi, strogi prekid, potpuna kontrola geografskih izlaza, negativni test nedostajućih fajlova |
| `tests/integration_real_data.R` | PASS: predsednički 2017. (8.023 BM), predsednički 2022. (7.787), parlamentarni 2022. (7.787), proverena polja pobednika |
| `source("Election_fingerprints.R")` | Završeno: 1 nacionalni nivo + 4 okruga + 2 opštine, šest ALL/Size grupa po oblasti, oba jezika i obe izlaznosti, bez prijavljenih R upozorenja |
| `tests/check_exports.R` | PASS: National=1, District=4, Municipality=2 po izborima; grupe, izlaznosti, BM i fajlovi su usaglašeni |

Testirani su okruzi `25`, `26`, `33`, `55` i opštine sa ključevima `18|71021`, `26|90239`. Grupe bez BM evidentiraju se bez slika; kada je opažanja premalo ili nema varijacije, histogram se zadržava, a KDE preskače. To su metodološka zaštitna pravila, ne greške programa.

## Uzorak i numerička provera

Validirani `Main` obuhvata podobna BM sa E ≥ 100. Nezavisnom proverom dostavljenih pripremljenih baza dobijeni su sledeći brojevi:

| Izbori | BM u Main | BM u primarnom histogramu | B=0 (bez histograma) |
|---|---:|---:|---:|
| Predsednički 2017. | 8.023 | 8.009 | 14 |
| Predsednički 2022. | 7.787 | 7.782 | 5 |
| Parlamentarni 2022. | 7.787 | 7.787 | 0 |

Zapisi sa B=0 ostaju u izvornoj bazi i auditu, ali je `W/B` nedefinisano, pa zbir ćelija mora odgovarati **broju uključenih BM**, ne nužno svim zapisima `Main`. Pet grupa veličine pripada dvema *klasifikacijama koje se preklapaju*; testovi proveravaju zbir unutar svake klasifikacije, bez nedozvoljenog sabiranja svih pet grupa.

## Ponovljiva provera

Iz `modules/election_fingerprints/`, uz prisutne tri pripremljene baze:

```r
source("tests/run_tests.R")
source("tests/test_graphics.R")
source("tests/test_geography_validation.R")
source("tests/integration_real_data.R")
Sys.unsetenv("EF_FINGERPRINT_TEST_MODE")
source("Election_fingerprints.R")
source("tests/check_exports.R")
sessionInfo()
```

Za odabrana područja u **EDITABLE INPUTS** sačuvati ispravne šifre i `INVALID_AREA_POLICY <- "error"`. Uz istraživačke rezultate sačuvati kontrolne sume baza, podešavanja i `sessionInfo()`. Ovi nalazi ne zamenjuju proveru kvaliteta originalnih podataka, nisu test za sve buduće skupove i ne dokazuju izbornu prevaru.

## Ograničenja

U izvornom radu nije precizirana puna grafička rezolucija slike 1; `HIST_BINS=50` je dokumentovan i reproduktivan izbor. KDE je dopunska Gaussova procena (pristrasna blizu granica), a ne primarni histogram ili verovatnoća prevare. Za male posebne oblasti KDE često nije moguće pouzdano prikazati. Modul ne procenjuje `f_i`, `f_e` niti obavlja formalni statistički test prevare.
