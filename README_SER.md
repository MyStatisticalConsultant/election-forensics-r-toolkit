# Election Forensics R Toolkit — R alati za izbornu forenziku

**Reproduktivna analiza izbornih podataka Srbije** · [English](README.md)

Election Forensics R Toolkit je otvoren, **lokalno pokretan** skup R modula za preuzimanje i pripremu zvaničnih podataka po biračkim mestima, dokumentovanje kontrole kvaliteta i izradu deskriptivnih analiza. Kasnije će biti dodati posebni statistički modeli izborne forenzike. Ovo **nije aktivna Shiny aplikacija**. Statistički neuobičajeni rezultati ili značajne veze između promenljivih nisu sami po sebi dokaz izborne prevare.

## Dostupni moduli

| Modul | Namena | Dokumentacija |
|---|---|---|
| `rzs_data_preparation` | Standardizacija RZS Excel podataka za predsedničke izbore 2017. i 2022. i parlamentarne izbore 2022; radni listovi `Master`, `Main`, `Options`, kontrola kvaliteta i metapodaci | [Srpski](modules/rzs_data_preparation/README_SER.md) · [English](modules/rzs_data_preparation/README.md) |
| `descriptive_statistics` **v0.3.1** | Srbija, okruzi, opštine; osam grupa biračkih mesta, 16 korelacionih matrica po izborima, robusne mere, testovi, Excel/CSV i opcioni Word izveštaji | [Srpski](modules/descriptive_statistics/README_SER.md) · [English](modules/descriptive_statistics/README.md) |
| `klimek` **v0.1.4** | Kumulativne krive glasova u funkciji izlaznosti: osam grupa BM, dve normalizacije, EN/SR grafikoni i opisne T90/T95 metrike | [Srpski](modules/klimek/README_SER.md) · [English](modules/klimek/README.md) |


**Status validacije:** Autor potvrđuje da je **Klimek v0.1.4 uspešno prošao testove za sva tri podržana izbora: predsedničke 2017. i 2022. i parlamentarne 2022.** Svi regresioni, integracioni i izvozni testovi završeni su rezultatom PASS. Dostavljeni detaljni konzolni zapis za parlamentarne 2022. potvrđuje 7.787 BM iz `Main` i 436 generisanih figura; za oba predsednička izbora uspešno testiranje je dodatno potvrđeno, bez zasebnih konzolnih zapisa. Videti [zapisnik validacije](modules/klimek/VALIDATION_RECORD_2026-10-23_SER.md). Testovi nisu nezavisno ponavljani pri pakovanju. Provere ne predstavljaju automatsku potvrdu za nove RZS formate niti dokaz izbornih nepravilnosti. Pripremni modul sadrži dokumentovanu stavku **REVIEW** za broj upisanih birača 2017. godine: [nalazi validacije](modules/rzs_data_preparation/VALIDATION_FINDINGS_SER.md).

## Tok rada

```text
Zvanični RZS Excel fajlovi (preuzimaju se lokalno)
            |
            v
RZS_data_preparation.R
            |
            v
RZS_prepared/<izbori>_RZS_prepared.xlsx
  Master — svi izvorni zapisi i oznake kvaliteta
  Main   — osnovni analitički uzorak, E >= 100 i QC
  Options — šifarnik kandidata/izbornih lista
            |
            v
  +---------+--------------------------------+
  |                                          |
  v                                          v
Descriptive_statistics.R                    Klimek.R
  |                                          |
  v                                          v
descriptive_outputs/                        klimek_outputs/
Excel, CSV, opcioni Word                    CSV, XLSX, EN/SR PNG/PDF
```

Osnovni uzorak za buduće forenzičke metode je `Main`. Deskriptivni modul ima i posebno prikazana, kontrolom kvaliteta prihvaćena biračka mesta sa manje od 100 upisanih birača. **Osam redova u zbirnim tabelama nisu osam međusobno isključivih grupa** i ne smeju se sabirati.


**[Aktuelno izdanje Klimek modula](modules/klimek/README_SER.md)**.

**Status modula Klimek:** v0.1.4 ispravlja nazive posebnih RZS kategorija (33 Inostranstvo, 55 Zavodi, 25–29 izvorni nazivi); testiranje je potvrđeno za sve tri podržane izborne baze. Krive su eksploratorne i ne predstavljaju kompletan JHK test.

## Struktura repozitorijuma

Repozitorijum sadrži `README.md`, `README_SER.md`, `LICENSE`, `CITATION.cff`, `.gitignore`, javne vodiče za rad sa modulima i tri podfoldera u `modules/`: `rzs_data_preparation/`, `descriptive_statistics/` i `klimek/`. Svaki modul ima svoj izvršni R skript, testove i dokumentaciju; deskriptivni modul dodatno ima `R/` sa funkcijama, `examples/` i `docs/publication/` sa četiri obrazovna Word dokumenta.

**Ne objavljuju se u glavnom Git repozitorijumu:** lokalni `raw_data/` sa originalnim Excel fajlovima, `RZS_prepared/` sa izvedenim bazama, `descriptive_outputs/`, `klimek_outputs/` i automatski dobijeni `validation_results/`. Njih korisnik dobija izvršavanjem koda. Dokumentovana i proverena validaciona evidencija može se objaviti posebno.

## Korišćenje postojećih pripremljenih baza — bez ponavljanja od početka

Kada `modules/rzs_data_preparation/RZS_prepared/*.xlsx` već postoji, pokrenite **samo modul koji Vam je potreban**. Deskriptivni i Klimek modul su nezavisni i čuvaju rezultate u odvojenim lokalnim folderima. Pogledajte [detaljni tok rada](WORKFLOW_SER.md) i [registar modula](MODULE_REGISTRY_SER.md). Dodavanje novog modula ne zahteva ponovno izvršavanje prethodnih.

## Početak korišćenja

Instalirajte [R](https://cran.r-project.org/) i po želji [RStudio](https://posit.co/download/rstudio-desktop/). Preuzmite zvanične RZS podatke sa adresa u [uputstvu za pripremu](modules/rzs_data_preparation/README_SER.md). Ako baze još nisu pripremljene ili su se zvanični izvori promenili, u podesivom odeljku pripremnog skripta unesite putanje i izvršite pripremu i njene testove. Ako baze već postoje i nisu menjane, ovaj korak preskočite. Zatim pokrenite deskriptivni modul iz njegovog foldera. Detaljno: [INSTALLATION_SER.md](modules/descriptive_statistics/INSTALLATION_SER.md). Treći, Klimek modul pokrenite iz `modules/klimek/`, prema [uputstvu za korisnika](modules/klimek/USER_GUIDE_SER.md).

**Važno za buduće podatke:** trenutni RZS importer koristi položaj kolona. Nove administrativne kolone ne mogu se bezbedno automatski tumačiti kao kandidati/liste. Planirane izmene opisane su u [SCHEMA_EVOLUTION_SER.md](modules/rzs_data_preparation/SCHEMA_EVOLUTION_SER.md).

Planirani zasebni moduli su izborni otisci (*election fingerprints*), izborne konture, dijagnostika normalnosti, regresije i Mebane FMM. **Nisu još implementirani.** Arhitektura: [ARCHITECTURE_SER.md](modules/rzs_data_preparation/ARCHITECTURE_SER.md).

Autorsko pravo © 2026 **Zlatko J. Kovačić**. [MIT licenca](LICENSE). Kontakt: `Zlatko@MyStatisticalConsultant.com`.

**Prikaz malih grupa (v0.1.4):** Za 0 BM nema grafikona, za 1 BM prikazuje se tačka, a za 2+ BM kriva. Videti [korisničko uputstvo](modules/klimek/USER_GUIDE_SER.md).



**Klimek v0.1.4 — potvrda za sva tri izbora:** autor je potvrdio uspešno izvršavanje svih testova za predsedničke 2017. i 2022. i parlamentarne 2022; detaljni prikaz RStudio konzole dostavljen je za parlamentarne 2022. [Zapisnik](modules/klimek/VALIDATION_RECORD_2026-10-23_SER.md).
