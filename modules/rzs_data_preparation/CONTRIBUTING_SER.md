# Saradnja i prijava grešaka

Dobrodošli su doprinosi proveri novih zvaničnih formata RZS, dokumentaciji, testovima, statističkim metodama i razumljivoj prezentaciji rezultata. Predlog promene kriterijuma uzorka ili modela treba da sadrži metodološko obrazloženje, poreklo podataka, relevantne testove i pregled posledica na rezultate. Ne mešati statističke indikatore sa neutemeljenim tvrdnjama o kršenju izbornih pravila.

Greške prijaviti preko GitHub Issues nakon objavljivanja ili na `Zlatko@MyStatisticalConsultant.com`. Navesti verziju R-a, `sessionInfo()`, godinu i šemu izvora, tačan tekst greške i korake reprodukcije; ne priložiti poverljive podatke. Kod i dokumentaciju ažurirati usklađeno, na engleskom i srpskom jeziku.


## Predsednički i parlamentarni izbori (v1.2)

Modul obrađuje glasove za **predsedničke kandidate** i **parlamentarne izborne liste** pod zajedničkim nazivom izborna opcija (`Option_*`). U podesivom delu odaberite `election_type`: `presidential` ili `parliamentary`. Moguće je obraditi oba tipa izbora iz iste godine, ali kombinacija vrste izbora i godine mora biti jedinstvena. Parlamentarni rezultati 2022. nalaze se na [zvaničnom linku RZS](https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx), a lokalni naziv fajla je `raw_data/Parliament 2022 ~ G202219002.xlsx`.

**Ograničenje provere:** nije bilo moguće neposredno pregledati strukturu izvornog parlamentarnog XLSX fajla. Zato je šablon `2022` zasad pretpostavka koju treba potvrditi pregledom zaglavlja, zbirnih vrednosti, kolona lista i QC izveštaja pre forenzičke analize. Lokalni izbori zahtevaju posebno provereni šablon, uključujući pravila po izbornim jedinicama.

Radni list **`Main`** ostaje podrazumevani analitički ulaz, a **`Master`** kompletna baza sa revizijskim tragom. List **`Options`** povezuje generičke kolone `Option_01_votes`, `Option_01_pct` itd. s imenima kandidata ili izbornih lista. Polja `Winner_*` i `Second_*` predstavljaju dve opcije s najvećim zbirnim brojem glasova u ulazu: ne određuju pobednika svake izborne jedinice, niti raspodelu mandata. Skript **ne vrši dodelu parlamentarnih mandata**. Ključ biračkog mesta uključuje vrstu izbora, da se izbori iz iste godine ne pomešaju.

Prethodni analitički skriptovi koji koriste `Candidate_*`, `Candidates` ili stara imena izlaznih fajlova moraju biti prilagođeni verziji 1.2.
