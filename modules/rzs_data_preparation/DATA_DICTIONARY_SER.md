# Rečnik podataka — standardizovane promenljive

Za punu listu promenljivih i originalne ćiriličke naslove obavezno konsultovati Excel listove **`Source_dictionary` i `Derived_dictionary`** iz konkretnog izvršavanja. Izvorne kolone ostaju `V1`, `V2`, ….

| Promenljiva | Značenje |
|---|---|
| `Year`, `Source_row` | Godina izbora i red izvornog Excel fajla |
| `District_code`, `Municipality_code`, `PS_number` | Oznake okruga, opštine i biračkog mesta; čuvati početne nule |
| `Station_key` | Složeni identifikator `godina|okrug|opština|BM` |
| `District`, `Municipality`, `Station_name`, `Station_address` | Administrativni nazivi; prevod iz ćirilice u srpsku latinicu |
| `E` | Broj upisanih birača |
| `A` | Broj birača evidentiranih kao izašli |
| `C` | Broj ubačenih glasačkih listića |
| `I` | Broj nevažećih listića |
| `B` | Broj važećih listića |
| `Ballots_received`, `Unused_ballots` | Primljeni i neupotrebljeni listići; nema ih u šemi 2022 |
| `Option_XX_votes`, `Option_XX_pct` | Glasovi i procenat pojedinačnog kandidata među važećim listićima |
| `Options_sum` | Zbir glasova kandidata; `NA` ako neki podatak nedostaje |
| `Winner_name`, `Second_name` | Kandidati sa najvećim i drugim najvećim ukupnim brojem glasova |
| `Winner_votes`, `Second_votes` | Brojevi glasova prvoplasiranog i drugoplasiranog |
| `Turnout` | Izlaznost `100*C/E`, procenat |
| `Attendance_pct` | Evidentirani izašli `100*A/E`, procenat |
| `Valid_participation_pct` | Važeći listići `100*B/E`, procenat |
| `Invalid_pct_cast` | Nevažeći među ubačenima `100*I/C` |
| `Invalid_pct_registered` | Nevažeći prema upisanim `100*I/E` |
| `Winner_pct`, `Second_pct` | Procenti među važećim listićima, `100*glasovi/B` |
| `Winner_per_registered_pct`, `Second_per_registered_pct` | Procenti prema upisanim biračima |
| `Log_winner_per_registered` | Prirodni logaritam količnika glasovi prvoplasiranog / upisani |
| `Size` | `Small`, `Middle`, `Large`: repovi kumulativnog biračkog tela |
| `Size_JHK` | `Small`, `Large`: podela prema percentilu veličine BM |
| `Special_category` | Posebna administrativna kategorija |
| `Administrative_status`, `Administrative_comment` | Dokumentovana administrativna odluka/komentar |
| `No_ballots_received`, `Zero_cast`, `Zero_valid` | Različite vrste nultih vrednosti |
| `Missing_core`, `Negative_count`, `Noninteger_count` | Numeričke provere |
| `Ballot_identity_violation`, `Option_identity_violation` | Kršenje identiteta listića/glasova |
| `Duplicate_station_id` | Duplirani složeni identifikator |
| `Attendance_cast_difference` | Potpisana razlika `A−C` |
| `Eligible_primary` | Osnovni kriterijum uključivanja u `Main` |
| `Eligible_*` | Metodski specifična podobnost; nije statistička validnost metode |
| `Exclusion_reason`, `Audit_action` | Razlozi isključenja i revizijski trag |

Procenti su brojčane vrednosti na skali **0–100**, ne udeli 0–1. `NA` nije isto što i nula. Preslikavanje kandidata i zvaničnih naziva nalazi se u listovima `Options` i `Source_dictionary`.


## Predsednički i parlamentarni izbori (v1.2)

Modul obrađuje glasove za **predsedničke kandidate** i **parlamentarne izborne liste** pod zajedničkim nazivom izborna opcija (`Option_*`). U podesivom delu odaberite `election_type`: `presidential` ili `parliamentary`. Moguće je obraditi oba tipa izbora iz iste godine, ali kombinacija vrste izbora i godine mora biti jedinstvena. Parlamentarni rezultati 2022. nalaze se na [zvaničnom linku RZS](https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx), a lokalni naziv fajla je `raw_data/Parliament 2022 ~ G202219002.xlsx`.

**Ograničenje provere:** nije bilo moguće neposredno pregledati strukturu izvornog parlamentarnog XLSX fajla. Zato je šablon `2022` zasad pretpostavka koju treba potvrditi pregledom zaglavlja, zbirnih vrednosti, kolona lista i QC izveštaja pre forenzičke analize. Lokalni izbori zahtevaju posebno provereni šablon, uključujući pravila po izbornim jedinicama.

Radni list **`Main`** ostaje podrazumevani analitički ulaz, a **`Master`** kompletna baza sa revizijskim tragom. List **`Options`** povezuje generičke kolone `Option_01_votes`, `Option_01_pct` itd. s imenima kandidata ili izbornih lista. Polja `Winner_*` i `Second_*` predstavljaju dve opcije s najvećim zbirnim brojem glasova u ulazu: ne određuju pobednika svake izborne jedinice, niti raspodelu mandata. Skript **ne vrši dodelu parlamentarnih mandata**. Ključ biračkog mesta uključuje vrstu izbora, da se izbori iz iste godine ne pomešaju.

Prethodni analitički skriptovi koji koriste `Candidate_*`, `Candidates` ili stara imena izlaznih fajlova moraju biti prilagođeni verziji 1.2.
