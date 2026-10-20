# Election Forensics R Toolkit — R alati za izbornu forenziku

**Reproduktivna analiza izbornih podataka Srbije** · [English](README.md)

Election Forensics R Toolkit je otvoren, **lokalno pokretan** skup R modula za preuzimanje i pripremu zvaničnih podataka po biračkim mestima, dokumentovanje kontrole kvaliteta i izradu deskriptivnih analiza. Kasnije će biti dodati posebni statistički modeli izborne forenzike. Ovo **nije aktivna Shiny aplikacija**. Statistički neuobičajeni rezultati ili značajne veze između promenljivih nisu sami po sebi dokaz izborne prevare.

## Dostupni moduli

| Modul | Namena | Dokumentacija |
|---|---|---|
| `rzs_data_preparation` | Standardizacija RZS Excel podataka za predsedničke izbore 2017. i 2022. i parlamentarne izbore 2022; radni listovi `Master`, `Main`, `Options`, kontrola kvaliteta i metapodaci | [Srpski](modules/rzs_data_preparation/README_SER.md) · [English](modules/rzs_data_preparation/README.md) |
| `descriptive_statistics` **v0.3.1** | Srbija, okruzi, opštine; osam grupa biračkih mesta, 16 korelacionih matrica po izborima, robusne mere, testovi, Excel/CSV i opcioni Word izveštaji | [Srpski](modules/descriptive_statistics/README_SER.md) · [English](modules/descriptive_statistics/README.md) |
| `klimek` **v0.1.0-dev** | Kumulativne krive glasova u funkciji izlaznosti: osam grupa BM, dve normalizacije, EN/SR grafikoni i opisne T90/T95 metrike | [Srpski](modules/klimek/README_SER.md) · [English](modules/klimek/README.md) |


**Domet validacije:** rezultati za tri navedena izbora upoređeni su sa nezavisno izračunatim referentnim rezultatima, prema potvrdi istraživača. U repozitorijumu se nalaze testovi za ponavljanje provera. To nije garancija ispravnosti za buduće formate ulaza, druge izbore ili zaključke o uzrocima nepravilnosti. Kod pripreme podataka ostaje dokumentovana stavka **REVIEW** za broj upisanih birača na predsedničkim izborima 2017: [nalazi validacije](modules/rzs_data_preparation/VALIDATION_FINDINGS_SER.md); [validacija deskriptivnog modula](modules/descriptive_statistics/VALIDATION_SER.md).

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


**Status modula Klimek:** razvojna verzija v0.1.0-dev zahteva samostalne RStudio testove na tri baze i proveru izvoza. Krive su eksploratorne i ne predstavljaju kompletan JHK test.

## Struktura repozitorijuma

Repozitorijum sadrži `README.md`, `README_SER.md`, `LICENSE`, `CITATION.cff`, `.gitignore`, uputstva za GitHub i tri podfoldera u `modules/`: `rzs_data_preparation/`, `descriptive_statistics/` i `klimek/`. Svaki modul ima svoj izvršni R skript, testove i dokumentaciju; deskriptivni modul dodatno ima `R/` sa funkcijama, `examples/` i `docs/publication/` sa četiri obrazovna Word dokumenta.

**Ne objavljuju se u glavnom Git repozitorijumu:** lokalni `raw_data/` sa originalnim Excel fajlovima, `RZS_prepared/` sa izvedenim bazama, `descriptive_outputs/`, `klimek_outputs/` i automatski dobijeni `validation_results/`. Njih korisnik dobija izvršavanjem koda. Dokumentovana i proverena validaciona evidencija može se objaviti posebno. Videti [detaljno uputstvo za objavljivanje](GITHUB_UPLOAD_GUIDE_SER.md).

## Korišćenje postojećih pripremljenih baza — bez ponavljanja od početka

Kada `modules/rzs_data_preparation/RZS_prepared/*.xlsx` već postoji, pokrenite **samo modul koji Vam je potreban**. Deskriptivni i Klimek modul su nezavisni i čuvaju rezultate u odvojenim lokalnim folderima. Pogledajte [detaljni tok rada](WORKFLOW_SER.md), [registar modula](MODULE_REGISTRY_SER.md) i [ažuriranje GitHub-a](GITHUB_UPLOAD_GUIDE_SER.md). Dodavanje novog modula ne zahteva ponovno izvršavanje prethodnih.

## Početak korišćenja

Instalirajte [R](https://cran.r-project.org/) i po želji [RStudio](https://posit.co/download/rstudio-desktop/). Preuzmite zvanične RZS podatke sa adresa u [uputstvu za pripremu](modules/rzs_data_preparation/README_SER.md). Ako baze još nisu pripremljene ili su se zvanični izvori promenili, u podesivom odeljku pripremnog skripta unesite putanje i izvršite pripremu i njene testove. Ako baze već postoje i nisu menjane, ovaj korak preskočite. Zatim pokrenite deskriptivni modul iz njegovog foldera. Detaljno: [INSTALLATION_SER.md](modules/descriptive_statistics/INSTALLATION_SER.md). Treći, razvojni modul pokrenite iz `modules/klimek/`, prema [uputstvu za korisnika](modules/klimek/USER_GUIDE_SER.md).

**Važno za buduće podatke:** trenutni RZS importer koristi položaj kolona. Nove administrativne kolone ne mogu se bezbedno automatski tumačiti kao kandidati/liste. Planirane izmene opisane su u [SCHEMA_EVOLUTION_SER.md](modules/rzs_data_preparation/SCHEMA_EVOLUTION_SER.md).

Planirani zasebni moduli su izborni otisci (*election fingerprints*), izborne konture, dijagnostika normalnosti, regresije i Mebane FMM. **Nisu još implementirani.** Arhitektura: [ARCHITECTURE_SER.md](modules/rzs_data_preparation/ARCHITECTURE_SER.md).

Autorsko pravo © 2026 **Zlatko J. Kovačić**. [MIT licenca](LICENSE). Kontakt: `Zlatko@MyStatisticalConsultant.com`.
