# Arhitektura i modularni razvoj paketa Election Forensics R Toolkit

[English](ARCHITECTURE.md) · [Registar modula](../../MODULE_REGISTRY_SER.md) · [Tok rada](../../WORKFLOW_SER.md)

## Zašto postepeni razvoj ima smisla

Jedan modul po statističkoj metodi jeste primeren pristup ako svaki modul ima nezavisne testove, stabilan ugovor o ulaznim podacima i dokumentovane rezultate. Jedan sve duži R skript povećavao bi međuzavisnost, otežao otkrivanje grešaka, ponavljao uvoz podataka i ugrožavao doslednost kriterijuma za uključivanje biračkih mesta.

## Stvarna struktura — razvojna verzija v1.7

```text
election-forensics-r-toolkit/
├── README.md / README_SER.md
├── MODULE_REGISTRY.md / MODULE_REGISTRY_SER.md
├── WORKFLOW.md / WORKFLOW_SER.md
└── modules/
    ├── rzs_data_preparation/      # implementiran; proveren za tri izbora
    │   └── RZS_data_preparation.R
    ├── descriptive_statistics/    # implementiran v0.3.1; validacija u određenom dometu
    │   ├── Descriptive_statistics.R
    │   └── R/                     # pomoćne deskriptivne funkcije
    └── klimek/                    # v0.1.4; autor validirao za parlamentarne izbore 2022.
        └── Klimek.R
```

**Planirani, ali još neimplementirani:** izborni otisci, konture, normalnost, regresije, Mebane FMM, zajednički orkestrator, standardna struktura R paketa i javni Shiny interfejs. Ne treba ih prikazivati kao postojeće komponente.

## Ugovor o podacima i nezavisno izvršavanje

Pripremni modul obrađuje originalne RZS Excel podatke i stvara posebne pripremljene knjige sa `Master`, `Main`, `Options`, QC i metapodacima. Deskriptivni i Klimek modul **nezavisno čitaju iste pripremljene knjige**. Jedan ne mora da se izvrši pre drugog. Priprema se ponavlja samo ako datoteke nedostaju, promenjene su ili nisu kompatibilne sa kodom. Videti [tok rada](../../WORKFLOW_SER.md).

`Master` čuva kontekst kontrole kvaliteta, `Main` je osnovni podobni uzorak (E >= 100), a `Options` šifarnik svih kandidata/lista u neutralnim poljima `Option_*`. Svaki metod definiše sopstvene kriterijume uzorka i imenioce. QC prihvaćena biračka mesta ispod 100 upisanih mogu se prikazati kao posebna grupa, bez prikrivenog ubacivanja u `Main`.

Svaki statistički metod mora objaviti polazne pretpostavke, parametre, rezultate, upozorenja, domet validacije i ograničenja tumačenja. Značajna korelacija ili neobična kriva nisu sami po sebi dokaz izborne manipulacije.

## Kako proširivati bez narušavanja postojećih modula

1. Dokumentovati ulaznu šemu i izlazni ugovor, sa hash vrednostima izvora, parametrima i R okruženjem.
2. Novu metodu razvijati kao odvojen `modules/<naziv>/`, najpre sintetičkim, zatim integracionim testovima, gde je primenljivo.
3. Novi modul treba da čita pripremljene baze, a ne da prepisuje izvorne ili rezultate drugih modula.
4. Pripremiti EN/SR dokumentaciju i ažurirati **sve pogođene aktuelne dokumente** u korenu i starijim modulima; izvršiti kontrolnu listu.
5. Kasnije, po stabilizaciji ugovora, razmotriti zajedničke `R/` funkcije, `testthat`, `renv`, automatizovane testove, orkestraciju i Shiny prikaz, uz očuvanje nezavisnog izvršavanja.

## Ograničenja

Pripremni modul koristi proverene pozicione šablone predsedničkih/parlamentarnih izvora za 2017/2022. Ako RZS doda nove kolone, postojeći položaji izbornih opcija mogu postati nevažeći; pre rada sa proširenim izvorom potrebna je verzionisana mapa zaglavlja i uloga. Lokalni izbori zahtevaju posebnu proveru strukture i izbornih jedinica.

Razlika upisanih birača RZS/RIK iz 2017. ostaje dokumentovana kao **REVIEW**, bez automatskog menjanja izvornog broja. Videti [nalaze validacije](VALIDATION_FINDINGS_SER.md).
