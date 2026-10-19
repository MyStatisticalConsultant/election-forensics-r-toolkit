# Deskriptivna statistika — Election Forensics R Toolkit

**R modul v0.3.1** · Predsednički i parlamentarni izbori u Srbiji · [English](README.md) · [Početna stranica alata](../../README_SER.md)

## Namena i ograničenja

Modul lokalno učitava **neizmenjene listove `Master`, `Main` i `Options`** koje generiše [`RZS_data_preparation.R`](../rzs_data_preparation/README_SER.md). Izračunava deskriptivne pokazatelje za **Srbiju, okruge i kombinacije okrug–opština** za predsedničke izbore 2017. i 2022. i parlamentarne izbore 2022. Ne utvrđuje izbornu prevaru i ne sprovodi kompletan Jiménez–Hidalgo–Klimek test. Izvorni Excel fajlovi ostaju neizmenjeni.

Glavna namena je priprema proverljivih tabela za istraživače, posmatrače izbora, novinare i studente. Razlikuju se **stope izračunate iz zbirnih brojeva** i **neponderisane distribucione mere po biračkom mestu (BM)** — to nisu isti pokazatelji.

## Funkcionalnosti

- **Osam grupa BM:** `All` (sva QC-prihvaćena), `100 or more` (100 ili više), `Less than 100` (ispod 100), `Small`, `Middle`, `Large`, `JHK Small` i `JHK Large`; grupe nisu sve međusobno isključive.
- **Dve sažete tabele** na sva tri teritorijalna nivoa: BM, upisani birači, evidentirani izlazak, ubačeni, važeći i nevažeći listići, izlaznost, udeli opcija, disperzija i efektivan broj izbornih opcija.
- **Sve predsedničke kandidate/izborne liste.** Nacionalno prvo- i drugoplasirana opcija ostaju iste u svim okruzima/opštinama; lokalno prvoplasirana se obeležava zasebno.
- **Robusne mere:** raspoloživi N, aritmetička sredina, medijana, standardna devijacija uzorka, Q1/Q3, interkvartilni raspon (IQR), 10. i 90. percentil, broj i procenat autlajera prema Tukijevom pravilu 1,5×IQR.
- **Zajednički prikaz izlaznosti i udela nacionalnog pobednika:** Pirsonov i Spirmanov koeficijent po BM, nominalne p-vrednosti, BH-korigovane q-vrednosti i dvodimenzionalni intervali širine 10 procentnih poena.
- **Sprovedeni testovi:** Kruskal–Volisov test za međusobno isključive grupe `Small/Middle/Large` i Vilkoksonov test rang-suma za `JHK Small/JHK Large`, za Srbiju i pojedinačne okruge/opštine gde postoje uslovi.
- **16 ekoloških korelacionih matrica po izborima:** 8 grupa × 2 agregaciona nivoa (okruzi/opštine), sa koeficijentima, brojem parova, p i BH q-vrednostima.
- Excel (`.xlsx`), CSV u formatu **UTF-8 sa BOM** i po želji zaseban Word (`.docx`) za svake izbore — sa glavnim tabelama i detaljnim prilozima.

## Ulazne baze i analitički uzorak

| Izbori | Ulazni Excel | BM u osnovnom uzorku `Main` |
|---|---|---:|
| Predsednički 2017. | `presidential_2017_RZS_prepared.xlsx` | 8.023 |
| Predsednički 2022. | `presidential_2022_RZS_prepared.xlsx` | 7.787 |
| Parlamentarni 2022. | `parliamentary_2022_RZS_prepared.xlsx` | 7.787 |

`Main` obuhvata BM sa **najmanje 100 upisanih birača** koja zadovoljavaju uslove kontrole kvaliteta. `100 or more` je **tačno** `Main`. `All` je `Main` zajedno sa kontrolom kvaliteta prihvaćenim BM sa manje od 100 birača preuzetim iz `Master`; nisu uključeni administrativno ili numerički neispravni zapisi.

Klasifikacija `Size` deli `Main` na `Small/Middle/Large` prema približno 20% *ukupno upisanih birača* u donjem i gornjem delu veličina BM, uz očuvanje svih BM na graničnoj veličini. `Size_JHK` koristi 20. percentil *veličine biračkog mesta*: `JHK Large` čine **sva preostala BM**, ne samo najvećih 20%. Pragovi se računaju za izbore na nivou države, a ne ponovo u svakom okrugu. Opširnije: [MAIN_SAMPLE_GUIDE_SER.md](MAIN_SAMPLE_GUIDE_SER.md).

**Ne sabirati osam redova.** Za broj BM i zbirne glasove/listiće važi `All = 100 or more + Less than 100`, a nezavisno `100 or more = Small + Middle + Large = JHK Small + JHK Large`.

## Instaliranje i pokretanje

Instalirajte [R](https://cran.r-project.org/) i po želji [RStudio](https://posit.co/download/rstudio-desktop/), zatim pakete:

```r
install.packages(c("readxl", "openxlsx", "readr"))
# Za Word:
install.packages(c("officer", "flextable"))
```

Preuzmite ceo repozitorijum. Tri pripremljena Excel fajla dobijena prethodnim RZS modulom smestite u `modules/rzs_data_preparation/RZS_prepared/` (ne objavljuju se na GitHub-u). Kao radni folder u RStudio izaberite **`modules/descriptive_statistics`**. U početnom delu skripta `Descriptive_statistics.R` menjajte **samo `EDITABLE USER CONFIGURATION`** (`INPUTS`, `OUTPUT_DIR`, `DISPLAY_DECIMALS`, `WRITE_CSV`, `WRITE_WORD`).

```r
source("tests/run_tests.R", encoding="UTF-8")
source("tests/run_tests_extended.R", encoding="UTF-8")
source("tests/run_tests_robust.R", encoding="UTF-8")
source("tests/integration_real_data.R", encoding="UTF-8")
source("tests/integration_extended.R", encoding="UTF-8")
source("Descriptive_statistics.R", encoding="UTF-8")
source("tests/check_exports.R", encoding="UTF-8")
```

Provera izvezenih fajlova izvodi se **posle** izvršavanja glavnog skripta. Ako se radi bez RStudio, može se upotrebiti `Rscript Descriptive_statistics.R` iz istog foldera. Detalji: [INSTALLATION_SER.md](INSTALLATION_SER.md) i [TROUBLESHOOTING_SER.md](TROUBLESHOOTING_SER.md).

## Izlazni fajlovi

Za svake izbore u `descriptive_outputs/` nastaju `<tip>_<godina>_descriptive.xlsx`, opcioni `<tip>_<godina>_descriptive_journal_tables.docx` i podfolder `<tip>_<godina>_descriptive/` sa CSV fajlovima: nacionalne/okružne/opštinske tabele brojeva i stopa, sve kandidate/liste, robusne mere, zajedničke intervale izlaznosti i udela pobednika, `group_significance_tests.csv`, `correlation_overview.csv` i `correlation_pairs_p_q_n.csv`.

Excel sadrži `Nat_*`, `Dist_*`, `Mun_*`, `Options_dictionary`, `Group_tests`, `Correlation_overview` i matrice `Corr_D_01`–`Corr_D_08` i `Corr_M_01`–`Corr_M_08`. Kodovi `01–07` zadržavaju prethodnih sedam grupa, a **`08` označava `100 or more`**. Sve numeričke vrednosti ostaju precizne u CSV-u; Word/Excel prikazuje najčešće dve decimale za mere, ceo broj za glasove, a p/q vrednosti sa tri decimale ili `<0.001`. [OUTPUT_GUIDE_SER.md](OUTPUT_GUIDE_SER.md) · [JOURNAL_REPORTS_SER.md](JOURNAL_REPORTS_SER.md).

## Tumačenje nalaza

Agregatna izlaznost je `100 × zbir(C) / zbir(E)`, a ne prosek izlaznosti BM. U korelacionim matricama **jedinica posmatranja je okrug odnosno opština**. Nasuprot tome, varijable `Joint_*` računaju korelacije po **biračkim mestima** unutar oblasti i grupe. `correlation_overview.csv` broji **parove promenljivih** (ne sumnjiva BM). Zvezdica kod Pirsonovog r označava nominalno dvostrano `p < 0,05`; za veliki broj poređenja treba pregledati BH-korigovanu q-vrednost. Nijedna takva razlika ili korelacija ne dokazuje prevaru. [METHODOLOGY_SER.md](METHODOLOGY_SER.md) · [DATA_DICTIONARY_SER.md](DATA_DICTIONARY_SER.md) · [CORRELATIONS_SER.md](CORRELATIONS_SER.md).

## Validacija, podrška i licenca

**Domet validacije v0.3.1:** istraživač je potvrdio slaganje rezultata za tri navedena izborna skupa sa nezavisnim referentnim proračunima. Testovi su uključeni, ali **celokupan RStudio zapis o izvršavanju svih testova v0.3.1 nije priložen ovom paketu**. Pre konačnog objavljivanja preporučuje se sačuvati izlaz sedam navedenih komandi. Nije testirana automatska kompatibilnost sa budućim RZS formatima. U pripremi podataka ostaje jedna dokumentovana stavka **REVIEW** za upisane birače 2017. [VALIDATION_SER.md](VALIDATION_SER.md) · [REPRODUCIBILITY_SER.md](REPRODUCIBILITY_SER.md).

U `R/` su osnovne i proširene funkcije, u `tests/` testovi i referentni ukupni brojevi, a u `docs/publication/` četiri opširna Word objašnjenja (engleski/srpski). Prijava problema: verzija R, `sessionInfo()`, izbori, poruka greške i koraci reprodukcije — GitHub Issues ili `Zlatko@MyStatisticalConsultant.com`. [Doprinosi](CONTRIBUTING_SER.md). Predlog citiranja: Kovačić, Z. J. (2026). *Election Forensics R Toolkit: Descriptive Statistics* (v0.3.1) [R softver], GitHub, verzija/commit. [CITATION.cff](CITATION.cff). Važi [MIT licenca](../../LICENSE). © 2026 Zlatko J. Kovačić.
