# Konturni dijagrami — v0.1.4

**Status:** verzija v0.1.4 je pripremljena za objavljivanje na GitHub-u. Korisnik je prijavio uspešne sintetičke testove i generisanje grafikona za odabrane nacionalne i okružne analize. Nije prijavljena potpuna nezavisna end-to-end provera svih mogućih geografskih izbora.

Modul pravi samo **opisne dvodimenzionalne konturne dijagrame standardizovane izlaznosti i udela glasova pobednika**. Geografska standardizacija prati pristup iz rada Klimek i sar. (2018), odeljak *Voter rigging test*, jednačine (3) i (4) i slika 2(C–F). U ovom modulu **nema** testa pomeranja malih i velikih mesta, funkcije `delta(p)`, referentnih intervala, p-vrednosti ili zaključaka o izbornoj prevari. Za takav test biće razvijen poseban modul.

## Dve definicije izlaznosti

- **A (originalni rad):** `B/E` = važeći glasovi / upisani birači; udeo pobednika `Winner_votes/B`.
- **B (Toolkit):** `C/E` = listići u kutiji / upisani birači; udeo pobednika `Winner_votes/B`.

Za svaki od ova dva para izračunavaju se z-vrednosti u odnosu na **sva druga podobna biračka mesta iste opštine**. Standardizacija se računa pre izbora geografskog područja i pre razdvajanja grupa malih i velikih mesta. Ukoliko nema dovoljno suseda ili varijabilnosti, standardizacija se **ne zamenjuje** okružnim prosekom: preskače se, a razlog beleži.

## Klasifikacije

- `Size`: **Small** naspram **Large**; srednja kategorija nije prikazana na dijagramu, ali ostaje deo opštinskog referentnog skupa.
- `Size_JHK`: **Small** = donji približno 20. percentil broja upisanih; **Large** = preostala biračka mesta. Koriste se postojeće, nacionalno određene grupe iz RZS pripreme — ne računaju se novi opštinski pragovi.
- Podrazumevani list `Main` sadrži podobna biračka mesta sa `E >= 100`, tako da analiza ne obuhvata biračka mesta sa manje od 100 birača.
- Za obe grupe na jednom grafikonu koriste se isti KDE bandwidth i opseg osa; nivoi izolinija predstavljaju iste relativne delove maksimalne gustine svake grupe. Ovo je grafička odluka radi uporedivosti, a ne statistički test iz rada.

## Postavljanje i izvršavanje

1. Kopirati folder `contours` u postojeći `election-forensics-r-toolkit/modules/`.
2. U RStudio-u postaviti radni folder na `modules/contours`.
3. Po potrebi instalirati pakete: `install.packages(c("readxl", "ggplot2", "MASS"))`.
4. U odeljku `EDITABLE SECTION` proveriti `INPUTS`, jezike (`EN`, `SR`), definicije izlaznosti (`A`, `B`) i geografiju (`national`, `district`, `municipality`).
5. Prvo probati jedne izbore, `GEOGRAPHIC_LEVELS <- "national"`, zatim pokrenuti:

```r
source("tests/run_tests.R")
source("tests/test_graphics.R")
source("Contours.R")
```

6. Proveriti PNG slike i `contour_export_manifest.csv`. Zatim uključiti okruge i opštine ili odabrati samo neke preko `DISTRICT_CODES` i `MUNICIPALITY_CODES`.
7. Izlazi se zapisuju u `contours_outputs/` bez ikakvih izmena ulaznih baza.

Uz svaki metod A/B čuva se `standardized_rows.csv` radi provere referentnog skupa i budućeg zasebnog *voter rigging* modula. `standardization_qc.csv` sadrži broj izostavljenih jedinica, dok manifest navodi generisane i preskočene grafikone.

**Metodološka ograda:** konturni dijagram može otkriti razliku između distribucija, ali nije dokaz prevare ili statističke značajnosti te razlike. Za tumačenje su neophodni lokalni kontekst, zapisnici i izveštaji posmatrača.

**Referenca:** Klimek P, Jiménez R, Hidalgo M, Hinteregger A, Thurner S. (2018). *Forensic analysis of Turkish elections in 2017–2018.* PLOS ONE 13(10): e0204975. https://doi.org/10.1371/journal.pone.0204975

## Rešavanje problema: testovi PASS, ali nema izlaza (ispravljeno u v0.1.4)

Testovi u v0.1.0 su ostavljali `EF_CONTOUR_TEST_MODE=1`, zbog čega
`source("Contours.R")` nije pokretao generisanje grafikona. Ako ste već
pokrenuli stare testove u otvorenoj RStudio sesiji, uradite:

```r
Sys.unsetenv("EF_CONTOUR_TEST_MODE")
source("Contours.R")
```

U verziji v0.1.4 oba testa automatski vraćaju prethodnu vrednost
promenljive okruženja, uključujući slučaj kada test prijavi grešku.


## Vizuelna dorada — v0.1.4

- Parametar `CONTOUR_ALPHA_RANGE <- c(0.18, 0.95)` čini spoljne, ređe konture bleđim, a centralne izraženijim; geometrija kontura iz v0.1.3 ostaje ista.
- `SHOW_MODE_ARROW <- TRUE` prikazuje crnu strelicu **od maksimuma KDE gustine velikih ka maksimumu KDE gustine malih biračkih mesta**. Po želji, `SHOW_MODE_MARKERS <- TRUE` označava oba centra malim kružićima.
- Centar je ovde **mod dvodimenzionalne KDE gustine**, a ne aritmetička sredina. Obe grupe koriste isti bandwidth i istu mrežu za izračunavanje modova. Ako su centri praktično isti ili neki nije u prikazanom prozoru, strelica se ne crta.
- Strelica je **samo opisna oznaka pravca razlike distribucija**. Ona nije mera `delta(p)`, test statističke značajnosti niti dokaz izborne prevare. Test *voter rigging* ostaje predmet posebnog modula.
- Za testiranje pokrenite `source("tests/run_tests.R")`, zatim `source("tests/test_graphics.R")`, pa `source("Contours.R")`. Korisnik je prijavio uspešno lokalno izvršavanje oba testa u RStudio-u (24. oktobar 2026); R interpreter nije bio dostupan u okruženju za pakovanje. Novi korisnici treba da izvrše oba testa na sopstvenom računaru.

## Očekivana preskakanja i opseg provere

U okrugu `26` (Pećki okrug) raspoloživa su samo tri biračka mesta, pa je ispravno da KDE poređenje bude označeno kao `SKIP`. Za okrug `00` u 2017. godini JHK Small grupa ima 12 standardizovanih biračkih mesta, manje od minimuma od 15. To nisu programske greške; ne treba smanjivati prag radi slike niti koristiti naknadnu okružnu standardizaciju.

**Prijavljeni rezultat lokalne provere:** sintetički `run_tests.R` i `test_graphics.R` oba `PASS`; ukupno 22 `PASS` i 14 `SKIP` skupova grafikona, odnosno 44 PNG fajla na EN/SR za odabrane konfiguracije i tri izbora.
