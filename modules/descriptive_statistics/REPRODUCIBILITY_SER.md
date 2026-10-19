# Protokol reproduktivnosti — v0.3.1

[English](REPRODUCIBILITY.md)

Za reprodukovanje su potrebni **tačni R izvorni fajlovi, isti zvanični RZS ulazi (ili provereni pripremljeni Excel fajlovi), konfiguracija, softverske verzije i pravila definisanja uzorka**. Samo slaganje konačne tabele nije dovoljno za naučnu proverljivost bez izvornog traga.

## Šta evidentirati pri svakom izvršavanju

1. Zvanični URL, datum preuzimanja, originalni naziv i MD5 izvorne datoteke (beleži pripremni modul), tip/godinu/šablon izbora i administrativna izuzeća.
2. Verziju/commit modula pripreme i listove `Master`, `Main`, `Options`, `Metadata`, `QC_summary`/`QC_records`; posebno navesti pregled stavke REVIEW za upisane 2017.
3. Verziju/commit deskriptivnog modula 0.3.1 i sva EDITABLE podešavanja: `INPUTS`, `OUTPUT_DIR`, `DISPLAY_DECIMALS`, `WRITE_CSV`, `WRITE_WORD`.
4. Rezultat `sessionInfo()` (R, operativni sistem, R paketi); `renv` zaključavanje paketa je moguća buduća dopuna, ali **nije implementirano** u ovom izdanju.
5. Konzolni zapis svih testova iz [VALIDATION_SER.md](VALIDATION_SER.md), uz reprezentativna nezavisna poređenja.
6. Po potrebi SHA-256 distribuisanih izlaza i pravila zaokruživanja (CSV puna preciznost, u prikazu dve decimale).

## Postupanje sa fajlovima

Modul čita tri pripremljena radna lista, ali ih ne menja. Ne menjati izlazne tabele ručno i potom ih predstavljati kao potpuno reprodukovane. `raw_data/`, `RZS_prepared/` i `descriptive_outputs/` isključeni su iz Git-a; korisnici ih generišu lokalno. Ako se kao praktična pomoć objavljuju veliki izlazni fajlovi, treba koristiti posebno verzionisani **GitHub Release dodatak** nakon provere uslova ponovnog korišćenja i hash vrednosti.

Za reprodukciju koristiti nacionalne pragove klasifikacije, ne nove lokalne pragove. `All` znači samo QC-prihvaćena BM, ne ceo `Master`. Za precizno poređenje koristiti numeričke CSV vrednosti ili R objekte, a ne zaokruženi Word. Ponoviti testove pri promeni R-a, paketa, RZS šeme ili pravila sortiranja.

**Budući izvori:** položajno mapiranje kolona RZS može pogrešno prepoznati novu administrativnu kolonu kao izborni rezultat. Potrebna je verzionisana šema prema nazivima i ulogama kolona pre prihvatanja novih formata ili lokalnih izbora. [SCHEMA_EVOLUTION_SER.md](../rzs_data_preparation/SCHEMA_EVOLUTION_SER.md).
