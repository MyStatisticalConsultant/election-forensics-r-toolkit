# Election Forensics R Toolkit — Modul 01: Priprema podataka RZS (predsednički i parlamentarni izbori)

**Verzija 1.1 · R skript · uputstvo na srpskom (latinica)**

Ovo je prvi, samostalni modul budućeg paketa **Election Forensics R Toolkit**. Skript priprema podatke Republičkog zavoda za statistiku (RZS) o rezultatima predsedničkih i parlamentarnih izbora po biračkim mestima, uz očuvanje izvornog zapisa, transparentnu kontrolu kvaliteta i dokumentovanje kriterijuma za uključivanje u analitički uzorak. Podržani su formati izvora za **2017. i 2022. godinu**, a ne bilo koji izbori. Skript se izvršava lokalno; **ne postoji onlajn Shiny aplikacija**.

**Važno:** Kontrola kvaliteta i budući forenzički indikatori nisu dokaz izborne prevare. Ovaj modul ne izvodi statističke testove izborne forenzike, uključujući kompletan Jiménez–Hidalgo–Klimek (JHK) test, niti popravlja ili zamenjuje zvanično prijavljene glasove.

## Zašto je potreban ovaj modul?

Zvanični Excel fajlovi imaju različite rasporede kolona i zahtevaju standardizaciju, proveru aritmetičkih identiteta, jasno definisanje uzorka i revizijski trag. Dobijena baza poslužiće kao ulaz za buduće metode: opisnu statistiku po okruzima i opštinama, izborne otiske (engl. election fingerprints), izborne konture (engl. election contours), dijagnostiku približne normalnosti, regresione modele i Mebaneove modele konačnih mešavina (engl. finite mixture models – FMM). **Nijedna od tih budućih metoda nije implementirana u ovoj verziji.**

## Šta skript radi?

Skript učitava zvanične Excel fajlove (2017/2022), čuva izvorne kolone `V1`, `V2`, … i broj reda, formira identifikatore biračkih mesta, standardizuje polja `E`, `A`, `C`, `I`, `B` i glasove kandidata, računa izlaznost i izborne udele i obeležava potencijalne numeričke i administrativne probleme. Umesto automatskog brisanja podataka, čuva sve zapise i razloge isključenja iz glavnog uzorka. Primenjuje dve **različite** definicije grupa prema veličini biračkog mesta: donjih/gornjih 20% ukupnog biračkog tela po kumulativnoj raspodeli i razdvajanje prema 20. percentilu veličine biračkih mesta. Generiše zaseban Excel fajl za svaku godinu i zajednički CSV pregled kontrola kvaliteta.

## Najvažnije: koji Excel list koristiti?

**`Main` je podrazumevani ulaz u buduće skripte izborne forenzike.** Sadrži samo zapise za koje važi `Eligible_primary = TRUE`. **`Master` je potpuna pripremljena baza za reviziju**, uključujući i zapise isključene iz `Main`, razloge i metodski specifične indikatore podobnosti. U zavisnosti od statističke metode, istraživač treba ponovo da razmotri uzorak i po potrebi krene od `Master`. `Raw_RZS` predstavlja sačuvane izvorne vrednosti, a `Excluded` pregled isključenih zapisa. Videti [OUTPUT_GUIDE_SER.md](OUTPUT_GUIDE_SER.md) i [DATA_DICTIONARY_SER.md](DATA_DICTIONARY_SER.md).

## Struktura repozitorijuma

```text
election-forensics-r-toolkit/
├── README.md
├── LICENSE
├── .gitignore
└── modules/
    └── rzs_data_preparation/
        ├── RZS_data_preparation.R
        ├── README.md / README_SER.md
        ├── METHODOLOGY.md / METHODOLOGY_SER.md
        ├── DATA_DICTIONARY.md / DATA_DICTIONARY_SER.md
        ├── OUTPUT_GUIDE.md / OUTPUT_GUIDE_SER.md
        ├── REPRODUCIBILITY.md / REPRODUCIBILITY_SER.md
        ├── ARCHITECTURE.md / ARCHITECTURE_SER.md
        ├── CHANGELOG.md / CHANGELOG_SER.md
        ├── CONTRIBUTING.md / CONTRIBUTING_SER.md
        ├── CITATION.cff / LICENSE
        ├── RZS_station_status_overrides_TEMPLATE.csv
        └── tests/run_tests.R
```

Folderi `raw_data/` (izvori) i `RZS_prepared/` (rezultati) postoje samo lokalno i isključeni su iz Git-a. **Originalni RZS Excel fajlovi nisu priloženi na GitHub.**

## Zahtevi i instalacija

Instalirati [R](https://cran.r-project.org/) i opciono [RStudio Desktop](https://posit.co/download/rstudio-desktop/). Potrebni paketi su `readxl` i `openxlsx`:

```r
install.packages(c("readxl", "openxlsx"))
```

Internet je potreban za preuzimanje R-a, paketa i izvora, ali ne i za lokalno izvršavanje već instaliranog skripta. Nisu potrebni Shiny ni Posit Cloud.

## Preuzimanje i priprema podataka

Na GitHub-u izabrati **Code → Download ZIP**, raspakovati arhivu i otvoriti direktorijum `modules/rzs_data_preparation`, odnosno klonirati repozitorijum kada bude objavljen. U tom direktorijumu napraviti folder `raw_data/`. Zvanični izvori:

- Predsednički izbori 2017: <https://publikacije.stat.gov.rs/G2017/Xls/G20176004.xlsx>
- Predsednički izbori 2022: <https://publikacije.stat.gov.rs/G2022/Xls/G202219003.xlsx>
- Parlamentarni izbori 2022: <https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx>

Sačuvati fajlove pod nazivima navedenim u odeljku `INPUTS$source`, ili promeniti putanje u delu **EDITABLE**. Nema automatskog preuzimanja izvora. Ne dodavati lični `setwd("C:/Users/...")` u programski kod.

## EDITABLE — podešavanja koja korisnik menja

Na početku skripta nalaze se `INPUTS$year` (godine), `INPUTS$source` (lokalni XLSX izvori), `INPUTS$template` (`2017` ili `2022` raspored kolona), `OUTPUT_DIR` (izlazni folder), `OVERRIDES_FILE` (opcioni CSV sa dokumentovanim administrativnim odlukama), `MIN_ELECTORATE` (podrazumevano 100), `ELECTORATE_FRACTION` (0,20), i `JHK_PERCENTILE` (0,20). Za jednu godinu ukloniti odgovarajući red u **sve tri kolone** tabele `INPUTS`. Za novije izbore neophodno je proveriti da li format zaista odgovara izabranom šablonu.

Ispod odeljka sa podešavanjima nalazi se istaknuto upozorenje **DO NOT CHANGE THE CODE BELOW THIS LINE / NE MENJAJTE KOD ISPOD OVE LINIJE**. Za redovno korišćenje ne menjati ostatak koda.

## Pokretanje

Iz direktorijuma modula pokrenuti:

```r
source("RZS_data_preparation.R", encoding="UTF-8")
```

Ili u terminalu:

```bash
Rscript RZS_data_preparation.R
```

Skript prijavljuje greške kada paketi, izvori ili struktura podataka nisu odgovarajući. Ponovno pokretanje **prepisuje već generisane izlazne fajlove**, ali ne menja originalne RZS izvore.

## Rezultati: 15 Excel listova

Za svaku godinu dobija se `RZS_prepared/P<GODINA>_RZS_prepared.xlsx`, koji sadrži: `Raw_RZS` (uvoz izvornih kolona), `Master` (cela pripremljena baza), `Main` (**osnovna baza za analizu**), `Excluded` (isključeni zapisi), `Zero_cases` (nulti glasovi/listići), `QC_summary` (zbirni nalazi provere), `QC_records` (detaljni zapisi), `Gap_distribution` i `Gap_direction` (razlike A−C), `Size_summary` i `Size_thresholds` (grupe veličine), `Options` (kandidati), `Source_dictionary`, `Derived_dictionary` i `Metadata` (izvori i parametri). `cross_election_QC_summary.csv` sadrži samo združene QC preglede, **ne** zajedničku bazu biračkih mesta.

## Administrativne odluke (opciono)

CSV mora imati kolone `Year,District_code,Municipality_code,PS_number,Admin_status,Comment`. Dozvoljene vrednosti statusa su `verified_complete`, `verified_no_ballots_received`, `verified_invalid_record`, `unverified`. Dat je prazan šablon bez izmišljenih odluka. Pre kopiranja u `RZS_station_status_overrides.csv` proveriti dokumentovane izvore. Kodovi mogu sadržati početne nule; sve CSV kolone se učitavaju kao tekst radi očuvanja početnih nula, ali identifikatore ipak treba proveriti.

## Osnovna metodologija

Tok: **RZS Excel → uvoz kao tekst → mapiranje šeme → standardizacija → kontrola kvaliteta → uključivanje/isključivanje → grupe veličine → izlazni Excel**. Glavna izlaznost je `100*C/E`, ne `100*A/E`. Udeo kandidata među važećim listićima je `100*glasovi/B`; kada je `B=0`, udeo je nedostajuća vrednost `NA`, a ne nula. Za razliku od 2017, šablon 2022 ne sadrži broj primljenih listića, te nulti broj ubačenih listića **ne dokazuje** da listići nisu primljeni. Videti [METHODOLOGY_SER.md](METHODOLOGY_SER.md).

## Reproduktivnost i testovi

Excel `Metadata` beleži izvor, MD5 kontrolni otisak, UTC vreme i pretpostavke; `Master` i `Source_row` omogućavaju proveru. Za evidenciju softverskog okruženja:

```r
writeLines(capture.output(sessionInfo()), "sessionInfo.txt")
source("tests/run_tests.R", encoding="UTF-8")
```

Testovi pre svega proveravaju strukturu i podešavanja, a ne statističku istinitost konkretnih izbornih podataka. Neophodna je nezavisna provera zvaničnih zbirnih rezultata. Videti [REPRODUCIBILITY_SER.md](REPRODUCIBILITY_SER.md).

## Ograničenja i tumačenje

Podržana su samo dva konkretna rasporeda Excel izvora. Struktura se proverava delimično i po poziciji kolona; promene zvaničnih izvora zahtevaju dodatnu kontrolu. Grupa `Size_JHK` **nije** formalni JHK statistički test niti uključuje geografsku standardizaciju. Podaci o primljenim listićima nedostaju u šablonu 2022. Nacionalni redosled kandidata računa se iz uvezenih kolona. Obeležene nepravilnosti i odstupanja nisu dokaz manipulacija; zahtevaju kontekst, nezavisnu proveru i analizu alternativnih objašnjenja.

## Plan razvoja, problemi i pomoć

Predložena je **modularna arhitektura**, a ne jedan sve veći R skript: zajedničke funkcije za uvoz/proveru, odvojene metode, automatizovani testovi, pa tek onda opciona Shiny aplikacija za javnost. Detaljno: [ARCHITECTURE_SER.md](ARCHITECTURE_SER.md).

Ako se javlja greška „Missing R packages“, instalirati `readxl` i `openxlsx`. Ako izvor nije pronađen, proveriti radni direktorijum i `INPUTS$source`. Ako postoje duplirani ili nepodudarni override ključevi, proveriti sve četiri identifikacione kolone. Ako je izlazni Excel otvoren, zatvoriti ga pre ponovnog pisanja. Uz prijavu greške poslati poruku greške, verziju R-a, `sessionInfo()` i minimalne korake reprodukcije, bez poverljivih podataka.

## Citiranje, saradnja, licenca

Predlog: Kovačić, Z. J. (2026). *Election Forensics R Toolkit: RZS Presidential and Parliamentary Data Preparation* (verzija 1.2) [R skript]. GitHub URL biće dodat nakon objavljivanja. Za naučno citiranje navesti i verziju/commit i zvanični izvor RZS. Pogledati [CITATION.cff](CITATION.cff) i [CONTRIBUTING_SER.md](CONTRIBUTING_SER.md). Komentari i prijave: [Zlatko@MyStatisticalConsultant.com](mailto:Zlatko@MyStatisticalConsultant.com).

Autorsko pravo © 2026 Zlatko J. Kovačić. Softver je objavljen pod [MIT licencom](LICENSE), što ne zamenjuje prava i obaveze pri korišćenju zvaničnih RZS podataka.


## Predsednički i parlamentarni izbori (v1.2)

Modul obrađuje glasove za **predsedničke kandidate** i **parlamentarne izborne liste** pod zajedničkim nazivom izborna opcija (`Option_*`). U podesivom delu odaberite `election_type`: `presidential` ili `parliamentary`. Moguće je obraditi oba tipa izbora iz iste godine, ali kombinacija vrste izbora i godine mora biti jedinstvena. Parlamentarni rezultati 2022. nalaze se na [zvaničnom linku RZS](https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx), a lokalni naziv fajla je `raw_data/Parliament 2022 ~ G202219002.xlsx`.

**Ograničenje provere:** nije bilo moguće neposredno pregledati strukturu izvornog parlamentarnog XLSX fajla. Zato je šablon `2022` zasad pretpostavka koju treba potvrditi pregledom zaglavlja, zbirnih vrednosti, kolona lista i QC izveštaja pre forenzičke analize. Lokalni izbori zahtevaju posebno provereni šablon, uključujući pravila po izbornim jedinicama.

Radni list **`Main`** ostaje podrazumevani analitički ulaz, a **`Master`** kompletna baza sa revizijskim tragom. List **`Options`** povezuje generičke kolone `Option_01_votes`, `Option_01_pct` itd. s imenima kandidata ili izbornih lista. Polja `Winner_*` i `Second_*` predstavljaju dve opcije s najvećim zbirnim brojem glasova u ulazu: ne određuju pobednika svake izborne jedinice, niti raspodelu mandata. Skript **ne vrši dodelu parlamentarnih mandata**. Ključ biračkog mesta uključuje vrstu izbora, da se izbori iz iste godine ne pomešaju.

Prethodni analitički skriptovi koji koriste `Candidate_*`, `Candidates` ili stara imena izlaznih fajlova moraju biti prilagođeni verziji 1.2.


### Provera prema zvaničnim rezultatima RIK-a (novo u v1.3)

Nakon pripreme baze i osnovnog strukturnog testa, iz korena modula pokrenite `source("tests/validate_official_totals.R")`. Referentni zbirovi i glasovi svih kandidata/lista nalaze se u `tests/official_reference_*.csv`, a izveštaj se čuva u `validation_results/` (van Git-a). **Broj upisanih birača 2017. ostaje pod statusom REVIEW (−1.772); ostali nacionalni zbirovi i glasovi svih izbornih opcija se poklapaju.** Detalji: [`tests/VALIDATION_README_SER.md`](tests/VALIDATION_README_SER.md). Nije opravdano tvrditi da je validacija bezuslovno prošla dok se navedena razlika ne razjasni.
## Naredni modul: deskriptivna statistika

Standardizovani listovi `Main`, `Master` i `Options` služe kao ulaz zasebno dokumentovanom [modulu deskriptivne statistike v0.3.1](../descriptive_statistics/README_SER.md). Ova dopuna je samo dokumentaciona: RZS kod i stavka REVIEW za 2017. nisu menjani.
