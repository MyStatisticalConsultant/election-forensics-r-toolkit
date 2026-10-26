# Election Forensics R Toolkit — v1.12.0

[English](README.md) · [Instalacija](INSTALLATION_SER.md) · [Registar modula](MODULE_REGISTRY_SER.md) · [Tok rada](WORKFLOW_SER.md) · [Napomene o izdanju](RELEASE_NOTES_SER_v1.12.0.md)

Otvoreni R alat za reproduktivnu analizu zvaničnih rezultata izbora u Srbiji na nivou biračkih mesta. Obuhvata **jedan modul za pripremu podataka i sedam nezavisnih analitičkih modula**. Nalazi su opisni ili dijagnostički: **statističko odstupanje samo po sebi nije dokaz izborne prevare**.

## Moduli

| Modul | Verzija / status | Namena | Dokumentacija |
|---|---|---|---|
| Priprema RZS podataka | Postojeća, prethodno validirana | Usklađivanje zvaničnih Excel baza, kontrola kvaliteta, listovi `Main`, `Master` i `Options` | [Priprema RZS](modules/rzs_data_preparation/README_SER.md) |
| Deskriptivna statistika | v0.3.1 | Nacionalna, okružna i opštinska statistika, robusne mere i izveštajne tabele | [Deskriptivna statistika](modules/descriptive_statistics/README_SER.md) |
| Klimek kumulativne krive | v0.1.4 | Kumulativne krive izlaznosti i glasova, uključujući klasifikacije Size i JHK | [Klimek](modules/klimek/README_SER.md) |
| Izborni otisci | v0.1.4 | Dvodimenzionalni histogrami broja biračkih mesta prema izlaznosti i udelu glasova, uz dopunski KDE | [Izborni otisci](modules/election_fingerprints/README_SER.md) |
| **Konturni dijagrami** | **v0.1.4** | Geografski standardizovani, dvojezični 2D KDE konturni prikazi grupa Small/Large i JHK na nacionalnom, okružnom i opštinskom nivou | [Contours](modules/contours/README_SER.md) |
| **Dijagnostika pritiska na birače (voter rigging)** | **v0.1.1** | Medijansko rastojanje `D(p)` između malih i velikih BM, kumulativne krive glasova pobednika, dvojezične slike po uzoru na Fig. 4 i numerički CSV izlazi | [Voter rigging](modules/voter_rigging/README_SER.md) |
| **Približna normalnost** | **v0.1.2** | Standardizovane logaritamske stope glasova pobednika, povezane tačke empirijskih histograma, normalna referentna kriva i statistike normalnosti (EN/SR-Lat) | [Približna normalnost](modules/approximate_normality/README_SER.md) |
| **Špiljkin/Kobak dijagnostika** | **v0.1.3** | Opisni histogrami izlaznosti i glasova pobednika; Monte Karlo test celobrojnih procenata sa ponderisanjem upisanim biračima; uslovna procena viška glasova pri visokoj izlaznosti | [Shpilkin](modules/shpilkin/README_SER.md) |

Detaljne formule, podešavanja grafikona, testovi i ograničenja dati su **u dokumentaciji pojedinačnih modula**, bez ponavljanja u korenskom pregledu. Analitički moduli nezavisno čitaju pripremljene RZS podatke, ne menjaju izvore niti zahtevaju prethodno izvršavanje drugih analitičkih modula.

## Početak rada

1. Instalirati [R](https://cran.r-project.org/) i po želji [RStudio](https://posit.co/download/rstudio-desktop/), zatim preuzeti repozitorijum. Videti [instalaciju](INSTALLATION_SER.md).
2. Pribaviti zvanične RZS Excel baze i pripremiti ih, **ili ponovo koristiti kompatibilne, već validirane lokalne baze** u `modules/rzs_data_preparation/RZS_prepared/`. Originalni i pripremljeni podaci nisu uključeni u GitHub repozitorijum.
3. Izabrati analitički modul, u RStudio-u postaviti radni direktorijum na odgovarajući folder `modules/<naziv>/` i pokrenuti glavni skript. Zavisnosti, parametri i testovi navedeni su u dokumentaciji svakog modula. Videti [tok rada](WORKFLOW_SER.md), [registar modula](MODULE_REGISTRY_SER.md) i pojedinačne README dokumente povezane u gornjoj tabeli.

## Podaci, reproduktivnost i ograničenja

Podrazumevani uzorak `Main` za većinu modula posle pripreme i QC pravila obuhvata 8.023 biračka mesta za predsedničke izbore 2017. i po 7.787 za izbore 2022. Modul `voter_rigging` umesto toga koristi `Master` kako bi uključio i podobna BM sa manje od 100 upisanih birača. Modul `approximate_normality` takođe čita `Master`, ali primarnu analizu zasniva na BM sa `E >= 100`, dok su BM sa manje od 100 upisanih birača izdvojena kao dopunska analiza osetljivosti. Analize drugih izbora zahtevaju kompatibilne pripremljene baze i dodatnu validaciju.

- Korenski [`.gitignore`](.gitignore) izuzima izvorne i pripremljene Excel baze i lokalno generisane rezultate, uključujući `contours_outputs/`, `voter_rigging_outputs/`, `approximate_normality_outputs/` i `shpilkin_outputs/`.
- Uz istraživačke rezultate čuvati kontrolne sume ulaznih fajlova, verzije koda, podešavanja i `sessionInfo()`. Premale ili nedostajuće grupe evidentiraju se kao `SKIP`, umesto da se za njih generiše nepouzdana gustina.
- Konturni dijagrami prikazuju geografski standardizovane raspodele, a strelica opisuje pomeranje maksimuma KDE gustine. Poseban modul `voter_rigging` računa opisno rastojanje `D(p)`, **bez** međunarodno standardizovane statistike `δ(p)` i oblasti statističkog prihvatanja. Modul približne normalnosti koristi empirijske histograme sa fiksnom širinom intervala (bez KDE izglađivanja) i prikazuje asimetriju, spljoštenost i Jarque–Bera test; ne procenjuje parametre posebnog modela izborne manipulacije. Špiljkinov modul ima tri odvojena postupka; nulta uslovna procena viška glasova ne dokazuje odsustvo manipulacije, dok pozitivna procena nije potvrđen broj falsifikovanih glasova. Nijedan nalaz pojedinačno ne dokazuje namernu manipulaciju.
- [MANIFEST.sha256](MANIFEST.sha256) sadrži kontrolne sume objavljenih programskih fajlova. Za proveru je potrebna potpuna verzija repozitorijuma, a ne samo arhiva korenskih dokumenata.

MIT licenca: [LICENSE](LICENSE). Podaci za citiranje: [CITATION.cff](CITATION.cff). © 2026 Zlatko J. Kovačić.
