# Arhitektura i razvojni plan paketa Election Forensics R Toolkit

## Da li je postepena izgradnja optimalna?

**Da — pod uslovom da gradimo samostalne, proverljive module, a ne jedan sve veći R skript.** Postojeći skript pripreme podataka predstavlja odličnu polaznu osnovu jer stvara ponovljiv, dokumentovan ulaz za sve kasnije metode. Razvoj treba da bude iterativan: jedna nova metoda, verifikacija i testovi, zatim sledeća metoda.

## Prednosti i nedostaci

**Prednosti postepenog razvoja:** brža isporuka rezultata, manji razvojni trošak na početku, lakša revizija matematičkih pretpostavki, jednostavniji testovi, mogućnost nezavisne naučne ocene svake metode i dokumentovane promene. **Nedostaci monolitnog razvoja:** sve više globalnih parametara, međusobno zavisni blokovi, ponavljanje koraka pripreme, neslaganje definicija uzorka, rizik da izmena u jednom delu neopaženo promeni drugi, teško održavanje i kasnija komplikovana integracija korisničkog interfejsa. Međutim, i nezavisni moduli mogu se razići u definicijama ako nemaju zajednički ugovor o podacima.

## Preporučena struktura

```text
election-forensics-r-toolkit/
├── modules/
│   ├── rzs_data_preparation/     # jedini realizovan modul sada
│   ├── descriptive_statistics/           # planirano
│   ├── election_fingerprints/            # planirano
│   ├── election_contours/                # planirano
│   ├── normality_diagnostics/            # planirano
│   ├── turnout_vote_regression/          # planirano
│   └── mebane_fmm/                       # planirano
├── R/                                    # buduće zajedničke funkcije
├── tests/                                # budući integracioni testovi
├── inst/                                 # primeri i šeme bez osetljivih podataka
├── docs/                                 # buduća metodološka dokumentacija
└── app/                                  # opciona buduća Shiny aplikacija
```

**Sada** postoji samo pripremni modul. Ostali direktorijumi u ovoj skici predstavljaju predlog i nisu deo isporučenog funkcionalnog koda.

## Ugovori između modula

**Ulaz:** usaglašeni kodovi BM, godina, administrativne oznake, brojevi birača/listića, glasovi kandidata i metapodaci sa eksplicitnom verzijom šeme. **Uzorak:** `Master` je potpuna baza; `Main` je podrazumevani podskup, ali ne odgovara automatski svakoj metodi. Svaka metoda mora precizirati sopstvene kriterijume i imenioce. **Izlaz:** strukturisane tabele sa parametrima, upozorenjima, dokazima reproduktivnosti i razumljivim tumačenjem. **Javna prezentacija:** naslov, ose, jedinice, veličina uzorka, statistička nesigurnost i alternativna objašnjenja.

Kada dva ili više modula koriste isti deo programskog koda, izdvojiti ga u zajedničke funkcije (`R/`), uz automatizovane testove. Nakon stabilizacije šeme razmotriti prelazak u standardni R paket (`DESCRIPTION`, `NAMESPACE`, `renv.lock`, `testthat`, kontinuirana integracija). Centralni orkestrator trebalo bi da povezuje uvoz → QC → izbor metoda → analize → izveštavanje. **Shiny nije statistički motor**: treba samo da poziva proverene funkcije ili da prikazuje unapred generisane rezultate. Važno je zadržati i mogućnost izvršavanja bez grafičkog interfejsa.

## Faze

**Faza 1:** objaviti i nezavisno proveriti pripremu RZS podataka. **Faza 2:** zajednički ugovor o poljima, verzioniranje šema, testovi i zavisnosti. **Faza 3:** deskriptivne statistike, otisci i konture. **Faza 4:** regresije, dijagnostika normalnosti i FMM uz testove pretpostavki, nesigurnosti i osetljivosti. **Faza 5:** dvojezični izveštaji i eventualni Shiny interfejs za širu javnost. **Faza 6:** kontrolisane verzije i kontinuirano prilagođavanje budućim zvaničnim podacima.

Svaki statistički modul treba da ima „pasoš modela“ sa pretpostavkama, ograničenjima, rizikom lažno pozitivnih nalaza i standardom nezavisne validacije. Nije opravdano automatski prevoditi anomalije u zaključke o izbornim manipulacijama.


## Predsednički i parlamentarni izbori (v1.2)

Modul obrađuje glasove za **predsedničke kandidate** i **parlamentarne izborne liste** pod zajedničkim nazivom izborna opcija (`Option_*`). U podesivom delu odaberite `election_type`: `presidential` ili `parliamentary`. Moguće je obraditi oba tipa izbora iz iste godine, ali kombinacija vrste izbora i godine mora biti jedinstvena. Parlamentarni rezultati 2022. nalaze se na [zvaničnom linku RZS](https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx), a lokalni naziv fajla je `raw_data/Parliament 2022 ~ G202219002.xlsx`.

**Ograničenje provere:** nije bilo moguće neposredno pregledati strukturu izvornog parlamentarnog XLSX fajla. Zato je šablon `2022` zasad pretpostavka koju treba potvrditi pregledom zaglavlja, zbirnih vrednosti, kolona lista i QC izveštaja pre forenzičke analize. Lokalni izbori zahtevaju posebno provereni šablon, uključujući pravila po izbornim jedinicama.

Radni list **`Main`** ostaje podrazumevani analitički ulaz, a **`Master`** kompletna baza sa revizijskim tragom. List **`Options`** povezuje generičke kolone `Option_01_votes`, `Option_01_pct` itd. s imenima kandidata ili izbornih lista. Polja `Winner_*` i `Second_*` predstavljaju dve opcije s najvećim zbirnim brojem glasova u ulazu: ne određuju pobednika svake izborne jedinice, niti raspodelu mandata. Skript **ne vrši dodelu parlamentarnih mandata**. Ključ biračkog mesta uključuje vrstu izbora, da se izbori iz iste godine ne pomešaju.

Prethodni analitički skriptovi koji koriste `Candidate_*`, `Candidates` ili stara imena izlaznih fajlova moraju biti prilagođeni verziji 1.2.
