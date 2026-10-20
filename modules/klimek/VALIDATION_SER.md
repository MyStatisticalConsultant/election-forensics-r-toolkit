# Testiranje i granice validacije

[English](VALIDATION.md)

**Status v0.1.0-dev: modul JOŠ NIJE validiran izvršavanjem u lokalnom R-u.** Validacija pripremnog i deskriptivnog modula ne potvrđuje automatski novi kod kumulativnih krivih. Pored provere arhive i statičkog koda neophodni su R parser, izvršavanje testova nad stvarnim bazama i pregled slika.

Pokrenite **iz direktorijuma modula**:

```r
source("tests/run_tests.R")
source("tests/integration_real_data.R")
source("Klimek.R")
source("tests/check_exports.R")
```

Prva skripta proverava sintaksu, kontrolisane primere, izjednačenja izlaznosti, obe normalizacije, grupisanje, prazne skupove, Unicode nazive i opcione repne metrike. Druga čita sve tri pripremljene baze i proverava veličine `Main` uzoraka (8.023 / 7.787 / 7.787), identitete podele BM i birača, zbir važećih glasova i krajnje vrednosti svih izbornih opcija. Glavni skript generiše izlaz, a poslednja provera traži očekivane fajlove i kontrolne odnose. Ovo ne garantuje ispravno ponašanje prema budućem neproverenom RZS formatu.

Dodatno pregledajte engleske i srpske slike oba tipa, kombinujuće i panelne grafikone, tačnost punih naziva, krajnje procente prema zbiru glasova i listića, posebne administrativne kategorije i BM ispod 100. Sačuvajte `sessionInfo()` i MD5 ulaznog XLSX. Ako koristite T90/T95, prethodno pregledajte svaku političku grupu. Opisni rezultati sami nemaju potvrđenu statističku značajnost.

Za akademsku publikaciju sačuvajte Git commit, postavke, MD5 izvora i nezavisne kontrole; jasno navedite sve promene u pravilima ulaza i uzorkovanja.
