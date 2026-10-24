# Election Forensics R Toolkit — v1.9.0

[English](README.md) · [Instalacija](INSTALLATION_SER.md) · [Registar modula](MODULE_REGISTRY_SER.md) · [Tok rada](WORKFLOW_SER.md) · [Napomene o izdanju](RELEASE_NOTES_SER_v1.9.0.md)

Otvoreni R alat za reproduktivnu analizu zvaničnih rezultata izbora u Srbiji na nivou biračkih mesta. Obuhvata **jedan modul za pripremu podataka i četiri nezavisna analitička modula**. Nalazi su opisni ili dijagnostički: **statističko odstupanje samo po sebi nije dokaz izborne prevare**.

## Moduli

| Modul | Verzija / status | Namena | Dokumentacija |
|---|---|---|---|
| Priprema RZS podataka | Postojeća, prethodno validirana | Usklađivanje zvaničnih Excel baza, kontrola kvaliteta, listovi `Main`, `Master` i `Options` | [Priprema RZS](modules/rzs_data_preparation/README_SER.md) |
| Deskriptivna statistika | v0.3.1 | Nacionalna, okružna i opštinska statistika, robusne mere i izveštajne tabele | [Deskriptivna statistika](modules/descriptive_statistics/README_SER.md) |
| Klimek kumulativne krive | v0.1.4 | Kumulativne krive izlaznosti i glasova, uključujući klasifikacije Size i JHK | [Klimek](modules/klimek/README_SER.md) |
| Izborni otisci | v0.1.4 | Dvodimenzionalni histogrami broja biračkih mesta prema izlaznosti i udelu glasova, uz dopunski KDE | [Izborni otisci](modules/election_fingerprints/README_SER.md) |
| **Konturni dijagrami** | **v0.1.4** | Geografski standardizovani, dvojezični 2D KDE konturni prikazi grupa Small/Large i JHK na nacionalnom, okružnom i opštinskom nivou | [Contours](modules/contours/README_SER.md) |

Detaljne formule, podešavanja grafikona, testovi i ograničenja dati su **u dokumentaciji pojedinačnih modula**, bez ponavljanja u korenskom pregledu. Analitički moduli nezavisno čitaju pripremljene RZS podatke, ne menjaju izvore niti zahtevaju prethodno izvršavanje drugih analitičkih modula.

## Početak rada

1. Instalirati [R](https://cran.r-project.org/) i po želji [RStudio](https://posit.co/download/rstudio-desktop/), zatim preuzeti repozitorijum. Videti [instalaciju](INSTALLATION_SER.md).
2. Pribaviti zvanične RZS Excel baze i pripremiti ih, **ili ponovo koristiti kompatibilne, već validirane lokalne baze** u `modules/rzs_data_preparation/RZS_prepared/`. Originalni i pripremljeni podaci nisu uključeni u GitHub repozitorijum.
3. Izabrati analitički modul, u RStudio-u postaviti radni direktorijum na njegov folder i pokrenuti odgovarajući skript. Na primer, za konturne dijagrame:

```r
setwd("modules/contours")  # Prilagoditi putanju svom radnom folderu
install.packages(c("readxl", "ggplot2", "MASS"))  # Samo pri prvoj instalaciji
source("tests/run_tests.R")
source("tests/test_graphics.R")
Sys.unsetenv("EF_CONTOUR_TEST_MODE")  # Normalan režim rada
source("Contours.R")
```

Odeljak **EDITABLE SECTION** u skriptu `Contours.R` sadrži izbor izbora, definicije izlaznosti A (`B/E`) i B (`C/E`), klasifikacije veličine, jezike i geografiju. Videti [uputstvo za Contours](modules/contours/README_SER.md) i [tok rada](WORKFLOW_SER.md). Ostali moduli imaju zasebna korisnička uputstva.

## Podaci, reproduktivnost i ograničenja

Podrazumevani uzorak `Main` posle pripreme i QC pravila obuhvata 8.023 biračka mesta za predsedničke izbore 2017. i po 7.787 za izbore 2022. Analize drugih izbora zahtevaju kompatibilne pripremljene baze i dodatnu validaciju.

- Korenski [`.gitignore`](.gitignore) izuzima izvorne i pripremljene Excel baze i lokalno generisane rezultate, uključujući `contours_outputs/`.
- Uz istraživačke rezultate čuvati kontrolne sume ulaznih fajlova, verzije koda, podešavanja i `sessionInfo()`. Premale ili nedostajuće grupe evidentiraju se kao `SKIP`, umesto da se za njih generiše nepouzdana gustina.
- Konturni dijagrami prikazuju geografski standardizovane raspodele. Strelica opisuje pomeranje maksimuma KDE gustine i **nije** test *voter rigging*. Nijedan pojedinačni grafikon ne dokazuje namernu manipulaciju.
- [MANIFEST.sha256](MANIFEST.sha256) sadrži kontrolne sume objavljenih programskih fajlova. Za proveru je potrebna potpuna verzija repozitorijuma, a ne samo arhiva korenskih dokumenata.

MIT licenca: [LICENSE](LICENSE). Podaci za citiranje: [CITATION.cff](CITATION.cff). © 2026 Zlatko J. Kovačić.
