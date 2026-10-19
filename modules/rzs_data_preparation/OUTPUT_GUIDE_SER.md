# Vodič kroz izlazne rezultate

## Primarni ulaz za buduće analize — `Main`

Posle izvršavanja otvoriti `RZS_prepared/presidential_2017_RZS_prepared.xlsx` ili `RZS_prepared/presidential_2022_RZS_prepared.xlsx`. **`Main` je podrazumevani pripremljeni analitički skup** (`Eligible_primary = TRUE`). Na primer:

```r
x <- readxl::read_excel("RZS_prepared/presidential_2022_RZS_prepared.xlsx", sheet="Main")
fingerprints <- x[!is.na(x$Eligible_fingerprint) & x$Eligible_fingerprint, ]
```

Ovaj primer samo bira zapise; ne implementira forenzički test. Za metodu koja zahteva drugačiji uzorak koristiti `Master` i dokumentovati dodatne uslove.

## Revizija — `Master` i kontrolni listovi

**`Master` čuva svaki pripremljeni zapis**, uključujući isključena BM, sve oznake problema i razloge isključenja. `Excluded`, `QC_records`, `QC_summary` i `Zero_cases` omogućavaju proveru odluka. `Raw_RZS`, `Source_row`, rečnici i `Metadata` omogućavaju poređenje sa izvorima.

## Ostalih 12 listova

Ukupno postoji 15 listova: `Raw_RZS`, `Master`, `Main`, `Excluded`, `Zero_cases`, `QC_summary`, `QC_records`, `Gap_distribution`, `Gap_direction`, `Size_summary`, `Size_thresholds`, `Options`, `Source_dictionary`, `Derived_dictionary`, `Metadata`. Posebno treba razlikovati `Size` i `Size_JHK`; te definicije nisu zamenljive.

## Generisani fajlovi

Za svaku godinu dobija se `P<GODINA>_RZS_prepared.xlsx`, a za sve odabrane godine zajednički `cross_election_QC_summary.csv` sa **zbirnim proverama**, ne bazom svih BM. Ponovnim izvršavanjem skripta prepisuju se izlazne datoteke, ne originalni RZS fajlovi.

## Preporuka za buduće module

Uz svaki metod objaviti tačan izvor i godinu, kriterijum uključivanja BM, metodske parametre, procenu statističke nesigurnosti, analizu osetljivosti, grafike čitljive široj javnosti i ograničenja tumačenja. Uočeni statistički signal nije dokaz namerne manipulacije.


## Predsednički i parlamentarni izbori (v1.2)

Modul obrađuje glasove za **predsedničke kandidate** i **parlamentarne izborne liste** pod zajedničkim nazivom izborna opcija (`Option_*`). U podesivom delu odaberite `election_type`: `presidential` ili `parliamentary`. Moguće je obraditi oba tipa izbora iz iste godine, ali kombinacija vrste izbora i godine mora biti jedinstvena. Parlamentarni rezultati 2022. nalaze se na [zvaničnom linku RZS](https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx), a lokalni naziv fajla je `raw_data/Parliament 2022 ~ G202219002.xlsx`.

**Ograničenje provere:** nije bilo moguće neposredno pregledati strukturu izvornog parlamentarnog XLSX fajla. Zato je šablon `2022` zasad pretpostavka koju treba potvrditi pregledom zaglavlja, zbirnih vrednosti, kolona lista i QC izveštaja pre forenzičke analize. Lokalni izbori zahtevaju posebno provereni šablon, uključujući pravila po izbornim jedinicama.

Radni list **`Main`** ostaje podrazumevani analitički ulaz, a **`Master`** kompletna baza sa revizijskim tragom. List **`Options`** povezuje generičke kolone `Option_01_votes`, `Option_01_pct` itd. s imenima kandidata ili izbornih lista. Polja `Winner_*` i `Second_*` predstavljaju dve opcije s najvećim zbirnim brojem glasova u ulazu: ne određuju pobednika svake izborne jedinice, niti raspodelu mandata. Skript **ne vrši dodelu parlamentarnih mandata**. Ključ biračkog mesta uključuje vrstu izbora, da se izbori iz iste godine ne pomešaju.

Prethodni analitički skriptovi koji koriste `Candidate_*`, `Candidates` ili stara imena izlaznih fajlova moraju biti prilagođeni verziji 1.2.
