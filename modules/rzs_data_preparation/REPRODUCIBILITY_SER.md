# Protokol reproduktivnosti

1. Preuzeti originalne XLSX fajlove RZS sa linkova u `README_SER.md`. Sačuvati njihov izvorni sadržaj; ne uključivati ih u javni GitHub repozitorijum.
2. Zabeležiti izvorni URL, datum pristupa, verziju šeme, kontrolni otisak izvornog fajla, verzije R-a i paketa. Excel list `Metadata` već sadrži MD5 izvora i UTC vreme; MD5 je ovde oznaka identiteta, a ne garancija kriptografske sigurnosti.
3. Podešavati isključivo odeljak `EDITABLE`; sačuvati verziju konfiguracije, sve administrativne odluke i njihovo dokumentarno poreklo.
4. Iz foldera modula izvršiti `source("RZS_data_preparation.R", encoding="UTF-8")`. Proveriti poruke i očekivane izlazne listove.
5. Proveriti `QC_summary`, `QC_records`, `Excluded`, `Zero_cases`, `Size_thresholds`, `Options` i uporediti ukupne glasove sa zvaničnim objavljenim rezultatima.
6. Sačuvati `writeLines(capture.output(sessionInfo()), "sessionInfo.txt")` kao evidenciju softverskog okruženja.
7. Pokrenuti `source("tests/run_tests.R", encoding="UTF-8")`. Dostupni testovi uglavnom proveravaju strukturu i izlaze; ne dokazuju ispravnost zvaničnih brojeva ili zaključke forenzičkih analiza.
8. Pri objavi navesti verziju skripta (commit/release), godinu izbora, tačan izvor, primenjene odluke o isključenjima i pravila metodskog uzorka.

Za iste podatke, podešavanja i verzije programa numerički rezultati treba da budu isti; **sama Excel datoteka ne mora imati identične bajtove** zbog vremena nastanka i metapodataka. Kada se projekat razvije, preporučuje se `renv` za zaključavanje zavisnosti i testiranje na nezavisnim sistemima. Nikada ne popravljati izvorne glasove radi usklađivanja aritmetičkih identiteta.


## Predsednički i parlamentarni izbori (v1.2)

Modul obrađuje glasove za **predsedničke kandidate** i **parlamentarne izborne liste** pod zajedničkim nazivom izborna opcija (`Option_*`). U podesivom delu odaberite `election_type`: `presidential` ili `parliamentary`. Moguće je obraditi oba tipa izbora iz iste godine, ali kombinacija vrste izbora i godine mora biti jedinstvena. Parlamentarni rezultati 2022. nalaze se na [zvaničnom linku RZS](https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx), a lokalni naziv fajla je `raw_data/Parliament 2022 ~ G202219002.xlsx`.

**Ograničenje provere:** nije bilo moguće neposredno pregledati strukturu izvornog parlamentarnog XLSX fajla. Zato je šablon `2022` zasad pretpostavka koju treba potvrditi pregledom zaglavlja, zbirnih vrednosti, kolona lista i QC izveštaja pre forenzičke analize. Lokalni izbori zahtevaju posebno provereni šablon, uključujući pravila po izbornim jedinicama.

Radni list **`Main`** ostaje podrazumevani analitički ulaz, a **`Master`** kompletna baza sa revizijskim tragom. List **`Options`** povezuje generičke kolone `Option_01_votes`, `Option_01_pct` itd. s imenima kandidata ili izbornih lista. Polja `Winner_*` i `Second_*` predstavljaju dve opcije s najvećim zbirnim brojem glasova u ulazu: ne određuju pobednika svake izborne jedinice, niti raspodelu mandata. Skript **ne vrši dodelu parlamentarnih mandata**. Ključ biračkog mesta uključuje vrstu izbora, da se izbori iz iste godine ne pomešaju.

Prethodni analitički skriptovi koji koriste `Candidate_*`, `Candidates` ili stara imena izlaznih fajlova moraju biti prilagođeni verziji 1.2.


## Nezavisna provera prema rezultatima RIK-a

Nakon pripreme baza pokrenite `source("tests/validate_official_totals.R")`. Proveravaju se glasovi svih 38 kandidata/lista, zvanični nacionalni zbirovi, podele radnih tabela, izvorne kolone i izvedene vrednosti. Razlika u broju upisanih birača 2017. označena je sa `REVIEW`, bez prepravljanja podataka. Videti [`tests/VALIDATION_README_SER.md`](tests/VALIDATION_README_SER.md).
