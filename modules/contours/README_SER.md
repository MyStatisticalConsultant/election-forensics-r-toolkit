# Konturni dijagrami

**Verzija:** 0.1.4 · [English](README.md)

Modul `contours` generiše **opisne dvodimenzionalne konturne dijagrame procenjene gustine** za poređenje izlaznosti i udela glasova nacionalno izabranog pobedničkog kandidata ili liste na biračkim mestima. Primenjuje pristup standardizaciji unutar geografskih jedinica koji razmatraju Klimek i saradnici (2018). Grafikoni se generišu na srpskom (latinica) i engleskom jeziku, na nacionalnom, okružnom i opštinskom nivou.

Modul **ne sprovodi test *voter rigging***, ne ocenjuje statističku značajnost razlika i ne dokazuje izbornu prevaru. Statistika pomeranja i pripadajući postupci statističkog zaključivanja biće predmet posebnog modula.

## Promenljive i geografska standardizacija

Pripremljene RZS baze sadrže `E` (upisani birači), `B` (važeći glasovi), `C` (listići u kutiji) i `Winner_votes` (glasovi nacionalno izabranog pobednika). Koriste se dve definicije izlaznosti, radi provere robusnosti:

| Specifikacija | Izlaznost (x) | Udeo glasova pobednika (y) |
| --- | --- | --- |
| **A — prema radu** | `B/E` | `Winner_votes/B` |
| **B — prema Toolkit-u** | `C/E` | `Winner_votes/B` |

Za svaku definiciju izlaznost i udeo glasova pobednika standardizuju se zasebno u odnosu na **sva druga podobna biračka mesta iste opštine** (*leave-one-out* z-vrednosti). Referentni skup formira se pre izdvajanja grupa prema veličini i pre izbora geografskog nivoa prikaza. Referentna sredina i standardna devijacija ne izračunavaju se posebno za mala i velika biračka mesta. Ako ima manje od `MIN_REFERENCE_NEIGHBORS` drugih podobnih mesta ili nema varijabilnosti u nekoj promenljivoj, odgovarajući par standardizovanih vrednosti nije dostupan.

Koriste se nacionalno određene klasifikacije iz pripreme podataka:

- **`Size`** — Small (mala) i Large (velika) biračka mesta. Grupa Middle se ne prikazuje, ali učestvuje u opštinskom referentnom skupu za standardizaciju.
- **`Size_JHK`** — Small obuhvata biračka mesta ispod nacionalnog praga 20. percentila veličine; Large obuhvata preostala mesta. Prag se ne izračunava ponovo za pojedinačne okruge ili opštine.

Podrazumevani ulazni radni list `Main` sadrži podobna biračka mesta sa **najmanje 100 upisanih birača**. Manja biračka mesta nisu obuhvaćena podrazumevanim dijagramima.

## Konturni dijagrami i tumačenje

Za svaku grupu posebno procenjuje se **dvodimenzionalna gustina (KDE)**, uz zajednički parametar uglađivanja i koordinatni sistem. `geom_density_2d()` prikazuje iste **relativne nivoe gustine** (udele maksimuma gustine svake grupe), a ne nužno iste apsolutne nivoe gustine. Parametri uglađivanja i vidljivi deo grafikona mogu se podesiti. Biračka mesta izvan prikazanog dela i dalje učestvuju u proceni gustine.

**Spoljne konture su bleđe** od unutrašnjih. Kada je uključena, strelica je usmerena **od maksimuma KDE gustine velikih ka maksimumu KDE gustine malih biračkih mesta**. Obe tačke mogu biti označene kružićima. Ako se maksimumi praktično poklapaju ili su van vidljivog prikaza, strelica se izostavlja. Ona ima isključivo opisnu ulogu: **nije procena efekta manipulacije niti statistika `delta(p)`**.

Razlike u položaju ili obliku konturnih linija **nisu dokaz nepravilnosti**. Za tumačenje su potrebni lokalni kontekst, zapisnici, nalazi posmatrača i dodatne analize.

## Instalacija i pokretanje

1. Postavite ceo folder na `election-forensics-r-toolkit/modules/contours/`, pored foldera `rzs_data_preparation`.
2. Ako je potrebno, instalirajte R pakete:

   ```r
   install.packages(c("readxl", "ggplot2", "MASS"))
   ```

3. U RStudio-u postavite radni direktorijum na `modules/contours`. U odeljku **EDITABLE SECTION** skripte `Contours.R` proverite `INPUTS` i putanje do pripremljenih baza (obično `../rzs_data_preparation/RZS_prepared/`). Odaberite izbore i željene opcije.
4. Pokrenite testove, a zatim generisanje grafikona:

   ```r
   source("tests/run_tests.R")
   source("tests/test_graphics.R")
   source("Contours.R")
   ```

Za prvu proveru možete izabrati jedne izbore i `GEOGRAPHIC_LEVELS <- "national"`. Zatim podesite `GRAPH_LANGUAGES <- "SR"`, `"EN"` ili `c("EN", "SR")`, `TURNOUT_DEFINITIONS <- c("A", "B")` i `COMPARISONS <- c("Size", "Size_JHK")`. Za odabrane okruge i opštine koristite zvanične šifre u `DISTRICT_CODES` i `MUNICIPALITY_CODES`. Skripta ne menja pripremljene RZS baze.

## Izlazni fajlovi i kontrola kvaliteta

Rezultati se čuvaju lokalno u `contours_outputs/`, organizovani po izborima, definiciji izlaznosti i geografskom nivou. Glavni izlazi su:

- **PNG konturni dijagrami** na izabranim jezicima.
- `standardized_rows.csv` — sirove stope, standardizovane vrednosti, podobnost i informacije o referentnom skupu.
- `standardization_qc.csv` — broj podobnih i isključenih biračkih mesta.
- `contour_export_manifest.csv` — status (`PASS` ili `SKIP`) i obrazloženje za svaki traženi skup grafikona.

Skup grafikona dobija oznaku **`SKIP`** ako neka grupa ima manje od `MIN_GROUP_STATIONS` podobnih standardizovanih opažanja (podrazumevano 15) ili ako nije moguće proceniti odgovarajuću gustinu. Na primer, okrug sa premalo biračkih mesta ne omogućava uporedivu procenu KDE za dve grupe. Takva preskakanja se evidentiraju; ne uvodi se zamenska okružna standardizacija niti se generišu nepouzdane konture.

Ako je iz ranije RStudio sesije ostala aktivna promenljiva `EF_CONTOUR_TEST_MODE=1`, pre generisanja izlaza izvršite `Sys.unsetenv("EF_CONTOUR_TEST_MODE")`. Priložene test-skripte inače automatski vraćaju prethodnu vrednost.

## Referenca

Klimek, P., Jiménez, R., Hidalgo, M., Hinteregger, A., & Thurner, S. (2018). *Forensic analysis of Turkish elections in 2017–2018*. **PLOS ONE, 13**(10), e0204975. https://doi.org/10.1371/journal.pone.0204975
