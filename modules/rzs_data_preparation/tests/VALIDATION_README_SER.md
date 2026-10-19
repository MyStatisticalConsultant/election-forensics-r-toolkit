# Nezavisna validacija prema zvaničnim izbornim rezultatima

Iz direktorijuma `modules/rzs_data_preparation/`, nakon generisanja tri Excel radne sveske u `RZS_prepared/`, pokrenite `source("tests/validate_official_totals.R")`. Potrebni su R i paket `readxl`. Referentne CSV datoteke uključene su u Git repozitorijum; originalne i generisane Excel baze se ne objavljuju. Skript ne preuzima fajlove sa interneta i ne menja rezultate izbora.

Validacija koristi **celu tabelu `Master`**, a ne analitički filtriranu tabelu `Main`. Nezavisno proverava objavljene nacionalne zbirove RIK-a, ukupne glasove svakog predsedničkog kandidata i svake parlamentarne liste (po redosledu na glasačkom listiću), originalne kolone RZS, preslikavanje promenljivih, matematičke identitete, izvedene procente, jedinstvenost ključeva, podelu na `Main` i `Excluded` i izabrane pokazatelje kontrole kvaliteta. Skript `tests/run_tests.R` proverava uglavnom sintaksu i strukturu; treba pokrenuti **oba testa**.

## Razlika u broju upisanih birača 2017.

Zbir birača iz tabele `Master` za predsedničke izbore 2017. iznosi **6.723.177**, dok RIK-ov objavljeni konačni broj birača iznosi **6.724.949** (razlika **−1.772**). Broj izašlih birača, broj listića i glasovi svih kandidata poklapaju se sa objavljenim konačnim rezultatima. Nezavisna arhiva izbora takođe navodi 6.723.177 kao zbir birača u tabeli rezultata. Uzrok razlike **nije utvrđen**: ne treba je bez dokaza pripisati ponovljenom glasanju, grešci ili izbornoj manipulaciji. Ova stavka ima status **REVIEW**, a ne automatski `PASS` niti dokaz greške u pripremi. Za potpuno razjašnjenje potrebno je uporediti biračka mesta sa nadležnom evidencijom biračkog spiska.

Izvor za 2017. je arhiva RIK-a. Za 2022. koriste se **konačni** izveštaji RIK-a (predsednički 9. maja, parlamentarni 5. jula 2022), ne preliminarne projekcije. Brojčani zbirovi moraju se slagati tačno; tolerancija `1e-8` važi samo za izvedene vrednosti u decimalnom obliku.

`PASS` označava podudaranje, `FAIL` neočekivanu razliku, a `REVIEW` poznatu nerešenu razliku između izvora/definicija. Izveštaj se upisuje u `validation_results/official_validation_results.csv`, izvan Git praćenja. Ova validacija ne zamenjuje proveru originalnih zapisnika biračkih odbora, kontrolu svih lokalnih zbirnih rezultata niti reviziju izborne administracije.

Izvori: [RIK 2017](https://arhiva.rik.parlament.gov.rs/english/arhiva-sednice-2017.php), [birački spisak 2017](https://arhiva.rik.parlament.gov.rs/latinica/izbori-za-predsednika-republike-2017-broj-biraca.php), [RIK predsednički 2022](https://www.rik.parlament.gov.rs/vest/sr/317359/70-sednica-republicke-izborne-komisije.php), [RIK parlamentarni 2022](https://www.rik.parlament.gov.rs/vest/sr/324925/79-sednica-republicke-izborne-komisije.php), [Arhiva izbora](https://arhivaizbora.rs/teritorija/RS/srbija/izbori).

Sažetak nalaza: [`../VALIDATION_FINDINGS_SER.md`](../VALIDATION_FINDINGS_SER.md).
