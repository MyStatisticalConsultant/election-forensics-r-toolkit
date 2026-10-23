# Testiranje i granice validacije

**Stanje izdanja v0.1.4 (23. oktobar 2026):** Autor je potvrdio očekivan izgled slika za grupe sa nula, jednim i više BM. Sve dole navedene R provere **nisu nezavisno izvršene u ovom okruženju za pakovanje**. Pre tvrdnje o potpunoj validaciji sačuvati zapisnik uspešnog izvršavanja šest provera (uz izvršavanje glavnog skripta) u RStudio. Starije napomene *-dev ispod su istorijske.


[English](VALIDATION.md)

**Status v0.1.3.3-dev: vizuelna korekcija zahteva novo izvršavanje testova i pregled slika.** Korisnik je generisao grafikone prethodnom verzijom; to ne validira automatski izmenjeno iscrtavanje. Pored provere arhive i statičkog koda neophodni su R parser, izvršavanje testova nad stvarnim bazama i pregled slika.

Pokrenite **iz direktorijuma modula**:

```r
source("tests/run_tests.R")
source("tests/test_graphics_layout.R")
source("tests/test_single_station_plots.R")
source("tests/test_zero_station_groups.R")
source("tests/integration_real_data.R")
source("Klimek.R")
source("tests/check_exports.R")
```

Prva skripta proverava sintaksu, kontrolisane primere, izjednačenja izlaznosti, obe normalizacije, grupisanje, prazne skupove, Unicode nazive i opcione repne metrike. Druga čita sve tri pripremljene baze i proverava veličine `Main` uzoraka (8.023 / 7.787 / 7.787), identitete podele BM i birača, zbir važećih glasova i krajnje vrednosti svih izbornih opcija. Glavni skript generiše izlaz, a poslednja provera traži očekivane fajlove i kontrolne odnose. Ovo ne garantuje ispravno ponašanje prema budućem neproverenom RZS formatu.

Dodatno pregledajte engleske i srpske slike oba tipa, kombinujuće i panelne grafikone, tačnost punih naziva, krajnje procente prema zbiru glasova i listića, posebne administrativne kategorije i BM ispod 100. Sačuvajte `sessionInfo()` i MD5 ulaznog XLSX. Ako koristite T90/T95, prethodno pregledajte svaku političku grupu. Opisni rezultati sami nemaju potvrđenu statističku značajnost.

Za akademsku publikaciju sačuvajte Git commit, postavke, MD5 izvora i nezavisne kontrole; jasno navedite sve promene u pravilima ulaza i uzorkovanja.

**Vizuelna provera v0.1.1:** (a) glavni naslov B-slike bez imena liste, puno ime u podnaslovu, (b) `combined_standard` bez JHK krivih, (c) `combined_jhk` samo JHK par, (d) `faceted` sa dva panela, (e) A-legenda u dva reda za tri ili više opcija, bez odsecanja. Proveriti da nisu ostale stare datoteke `B_*_combined.png`/PDF. Statistički proračuni nisu menjani; novu vizuelnu verziju ipak treba proveriti u RStudio.


**v0.1.3.2-dev ispravka:** `tests/test_graphics_layout.R` sada koristi šest argumenata funkcije `b_titles()` i proverava nacionalne i okružne naslove na oba jezika. Nepoznat tip izbora daje razumljivu poruku. Naslovi grupa na A-figurama ostaju u zasebnom podnaslovu. Računanje krivih nije menjano.



**Provera posebnih kategorija u v0.1.3.2-dev:** `tests/test_graphics_layout.R` dodatno proverava nazive Inostranstvo (`33`), Zavodi za izvršenje krivičnih sankcija (`55`), obične okruge i kategorije 25–29 na oba jezika. Ponovo izvršite kompletan niz od pet komandi i, ako se ove kategorije nalaze u podacima, pregledajte A i B grafikone za izabranu oblast na oba jezika. Potvrda izvršavanja u RStudio je neophodna pre proglašenja verzije validiranom. Numerički proračuni nisu menjani.


### Regresioni test v0.1.3.3 za jednu tačku

Pokrenite `source("tests/test_single_station_plots.R")` da proverite prikaz grupe sa jednim BM kao tačke, bez lažne linije ili upozorenja `geom_line()`. Ovaj test ne zamenjuje numeričke/integracione provere. Za validaciju razvojne verzije potrebno je izvršavanje u RStudio i vizuelna kontrola.


### Testiranje praznih grupa u v0.1.3.4

`tests/test_zero_station_groups.R` proverava sintetičke slučajeve 0/1/2 BM, potpune teritorijalne kombinacije, `Stations=0`, nedefinisane procente `NA`, nepromenjene neprazne redove i brisanje starih slika samo određene oblasti. `tests/check_exports.R` dodatno proverava osam grupa za svaku oblast i opciju, kao i ispravan povratni uvoz praznih procenata. Testove treba izvršiti u lokalnom RStudio; ZIP arhiva sama po sebi nije potvrda validacije.
