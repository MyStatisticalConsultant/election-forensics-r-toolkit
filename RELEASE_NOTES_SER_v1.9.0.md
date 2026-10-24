# Election Forensics R Toolkit — v1.9.0

Datum izdanja: 25. oktobar 2026.

## Novo u ovom izdanju

- **Konturni dijagrami v0.1.4**, novi nezavisni analitički modul u folderu `modules/contours/`.
- Opisni dvodimenzionalni KDE konturni prikazi geografski standardizovane izlaznosti i udela glasova nacionalno određenog pobednika.
- Dve definicije izlaznosti za proveru robusnosti: A = važeći listići/upisani (`B/E`), B = listići u kutiji/upisani (`C/E`); udeo pobednika je `Winner_votes/B` u obe.
- Opštinska leave-one-out standardizacija prema svim ostalim QC-podobnim biračkim mestima iste opštine, pre podele na Size/JHK grupe ili izdvajanja prikazanih oblasti.
- Poređenja Small/Large i JHK; dvojezični PNG grafikoni na nacionalnom, okružnom i opštinskom nivou.
- Uglađene konture, bleđe linije niže gustine, legenda i opisna strelica od KDE maksimuma velikih ka maksimumu malih biračkih mesta.
- `standardized_rows.csv`, `standardization_qc.csv`, `contour_export_manifest.csv` i numerički/grafički testovi.
- Ažurirani korenski pregled modula, instalacija i tok rada, `.gitignore` i podaci za citiranje, uz jednak način predstavljanja svih modula.

## Opseg i tumačenje

Konturni dijagrami su **opisni prikazi**; ne uključuju test *voter rigging* niti statistiku `delta(p)`. Vidljivo pomeranje distribucija samo po sebi ne dokazuje prevaru. `SKIP` slučajevi evidentiraju premale grupe, nedovoljno referentnih podataka ili nemogućnost procene KDE, bez ublažavanja geografskih QC pravila samo radi grafikona. Podržani pripremljeni izbori su predsednički 2017/2022. i parlamentarni 2022.

Programski kod postojećih analitičkih modula i istorijske napomene o prethodnom izdanju nisu predmet ovih izmena. Videti [dokumentaciju modula](modules/contours/README_SER.md) i [istorijske napomene v1.8.4](RELEASE_NOTES_SER_v1.8.4.md).
