# Metodologija pripreme podataka RZS

## Cilj i granice

Ovaj modul standardizuje podatke biračkih mesta za reproduktivne deskriptivne i buduće forenzičke analize. Ne primenjuje inferencijalne testove izborne forenzike, ne utvrđuje prevaru i ne menja izvorne glasove. Svaka buduća metoda mora zasebno opravdati pretpostavke i statistički postupak.

## Uvoz, izvorna šema i identifikatori

Podržane su šeme `2017` i `2022`, u kojima su kolone prepoznate **po položaju**. Uvozi se prvi Excel list kao tekst; zaglavlje je u 5. redu (2017) odnosno u 1. redu (2022). Redovi bez potpunih oznaka okruga, opštine i biračkog mesta preskaču se. Izvorne kolone ostaju `V1...Vn`; `Source_row` beleži red iz Excela. `Station_key` spaja godinu, kod okruga, kod opštine i broj biračkog mesta. To nije univerzalni identifikator biračkog mesta kroz sve godine.

## Osnovne promenljive i indikatori

`E` = upisani birači; `A` = evidentirani izašli birači; `C` = ubačeni listići; `I` = nevažeći listići; `B` = važeći listići. `Ballots_received` i `Unused_ballots` postoje u šemi 2017, ali ne u šemi 2022. Glasovi kandidata mapiraju se prema redosledu kolona, a nacionalni pobednik i drugoplasirani prema zbirovima u podacima.

Izračunavaju se `Turnout = 100*C/E`, `Attendance_pct = 100*A/E`, `Valid_participation_pct = 100*B/E`, `Winner_pct = 100*Winner_votes/B`, `Invalid_pct_cast = 100*I/C`, `Winner_per_registered_pct = 100*Winner_votes/E` i `log(Winner_votes/E)` za pozitivne količnike. Nevažeći ili nulti imenilac daje `NA`, a ne izmišljenu nulu.

## Kontrola kvaliteta i kriterijumi uzorka

Proveravaju se nedostajuće ključne vrednosti, negativni i necelobrojni brojevi, duplirani identifikatori, jednakosti `C = I+B` i `zbir glasova kandidata = B`, prekoračenja `C>E`, `A>E` i, kada postoji podatak, `C>Ballots_received`. Razlika `A−C` se beleži, ali sama po sebi ne znači automatsko isključenje. `Under_100` označava BM sa `E<MIN_ELECTORATE`. `Admin_no_ballots` razlikuje verifikovan izostanak prijema listića od samog broja nula ubačenih listića. `Eligible_primary` isključuje zapise ispod praga, administrativno nevažeće zapise, potvrđeni neprijem listića i ozbiljne numeričke/identitetske probleme; `Main` predstavlja podskup tako označenih zapisa. `Master` čuva sve zapise i razloge.

Opcioni CSV dozvoljava dokumentovane administrativne odluke. Oznaka `verified_complete` može ukloniti automatsku oznaku neprijema listića bez izmene brojeva. CSV se učitava kao tekst da bi se sačuvale početne nule; identifikatori ipak moraju da budu identični izvornim podacima.

## Dve različite definicije veličine biračkih mesta

`Size` izdvaja male i velike BM prema kumulativnom broju **upisanih birača**. Granica se bira tako da kumulativni zbir u svakom repu bude što bliži ciljnom udelu od 20%; sva biračka mesta iste granične veličine ostaju u istoj grupi. Preostala mesta su `Middle`. `Size_JHK` polazi od **20. percentila pojedinačnih veličina BM**: `Small` kada je `E<q`, a `Large` za sve ostale. Ova druga grupa obuhvata i srednje veličine; **nije reč o gornjih 20% BM**. Nijedna podela sama po sebi nije JHK statistički test.

## Metodski specifična podobnost i izuzeci

`Eligible_turnout`, `Eligible_cumulative`, `Eligible_fingerprint`, `Eligible_contour`, `Eligible_regression`, `Eligible_normality` i `Eligible_invalid_share` označavaju tehničku raspoloživost podataka. Buduća metoda mora proveriti i svoje metodološke pretpostavke. BM sa `B=0` može ostati u `Main` ako je administrativno i numerički prihvatljivo, ali `Winner_pct` ostaje `NA`. Šifre 33, 55 i 25–29 služe administrativnom označavanju kategorija (`Overseas`, `Prison`, `Kosovo-associated`), a ne zaključku o fizičkoj lokaciji.

## Tumačenje

Potencijalno anomalni zapisi predstavljaju signale za proveru, a ne dokaz prevare. Za ozbiljne zaključke potrebni su izvorna dokumentacija, pravni kontekst, nezavisna validacija i model-specifična statistička nesigurnost. DOI rada na koji se skript poziva je `10.1126/sciadv.1602363`; u ovom modulu nisu implementirani svi koraci te metode.


## Predsednički i parlamentarni izbori (v1.2)

Modul obrađuje glasove za **predsedničke kandidate** i **parlamentarne izborne liste** pod zajedničkim nazivom izborna opcija (`Option_*`). U podesivom delu odaberite `election_type`: `presidential` ili `parliamentary`. Moguće je obraditi oba tipa izbora iz iste godine, ali kombinacija vrste izbora i godine mora biti jedinstvena. Parlamentarni rezultati 2022. nalaze se na [zvaničnom linku RZS](https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx), a lokalni naziv fajla je `raw_data/Parliament 2022 ~ G202219002.xlsx`.

**Ograničenje provere:** nije bilo moguće neposredno pregledati strukturu izvornog parlamentarnog XLSX fajla. Zato je šablon `2022` zasad pretpostavka koju treba potvrditi pregledom zaglavlja, zbirnih vrednosti, kolona lista i QC izveštaja pre forenzičke analize. Lokalni izbori zahtevaju posebno provereni šablon, uključujući pravila po izbornim jedinicama.

Radni list **`Main`** ostaje podrazumevani analitički ulaz, a **`Master`** kompletna baza sa revizijskim tragom. List **`Options`** povezuje generičke kolone `Option_01_votes`, `Option_01_pct` itd. s imenima kandidata ili izbornih lista. Polja `Winner_*` i `Second_*` predstavljaju dve opcije s najvećim zbirnim brojem glasova u ulazu: ne određuju pobednika svake izborne jedinice, niti raspodelu mandata. Skript **ne vrši dodelu parlamentarnih mandata**. Ključ biračkog mesta uključuje vrstu izbora, da se izbori iz iste godine ne pomešaju.

Prethodni analitički skriptovi koji koriste `Candidate_*`, `Candidates` ili stara imena izlaznih fajlova moraju biti prilagođeni verziji 1.2.
