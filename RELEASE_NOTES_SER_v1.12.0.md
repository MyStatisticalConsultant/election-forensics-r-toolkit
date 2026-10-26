# Election Forensics R Toolkit — v1.12.0

Datum izdanja: 26. oktobar 2026.

## Dodato

- **`shpilkin` v0.1.3** (`modules/shpilkin/`), nezavisan modul sa tri međusobno povezana, ali metodološki različita postupka.
- Opisni histogrami izlaznosti i udela glasova pobednika, sa podesivom širinom intervala i dvojezičnim PNG grafikonima (engleski/srpski latinica).
- Kobak–Špiljkin–Pšeničnikov (2016) analiza koncentracije oko celobrojnih procenata: histogrami širine 0,1 procentni poen ponderisani brojem upisanih birača, prozor ±0,05 procentnih poena, binomijalna Monte Karlo referenca i provere polucelobrojnih vrednosti.
- **Uslovna** Špiljkinova procena viška glasova po intervalima izlaznosti, uz referentni odnos glasova pobednika i ostalih važećih glasova. Automatski izabran interval oko najčešće izlaznosti nije nezavisno potvrđena oblast bez nepravilnosti. Analize osetljivosti čuvaju se zasebno.
- CSV fajlovi sa podobnošću BM, frekvencijama po intervalima, Monte Karlo iteracijama i referentnim oblastima, međukoracima procene viška glasova i analizama osetljivosti; metodologija, README i vodiči kroz izlaze na oba jezika.
- Ažurirani korenski dokumenti, `.gitignore`, podaci za citiranje i manifest kontrolnih suma. Postojeći analitički moduli nisu menjani.

## Validacija i tumačenje

Obim validacije: u RStudio-u su prošli numerički, grafički, integracioni i izvozni testovi za predsedničke izbore 2017/2022. i parlamentarne izbore 2022. Integracioni testovi **ne predstavljaju** nezavisno usaglašavanje svih rezultata sa zvaničnim ukupnim vrednostima. Podrazumevanih 999 Monte Karlo iteracija služi preliminarnoj analizi; 10.000 je bliže izvornoj studiji.

**Nulta uslovna procena viška glasova, kao ni odsustvo anomalije celobrojnih procenata, ne dokazuje da nije bilo izborne prevare. Pozitivna uslovna procena nije utvrđen broj falsifikovanih glasova.** Tri postupka tumače se odvojeno, uz definicije izlaznosti (`C/E` primarna, `B/E` analiza osetljivosti), pretpostavke, podatke i izborni kontekst.

Videti [README modula](modules/shpilkin/README_SER.md), [metodologiju](modules/shpilkin/METHODOLOGY_SER.md) i [prethodne napomene o izdanju](RELEASE_NOTES_SER_v1.11.0.md).

**Grafikoni viška glasova:** Sivi poligoni prate samo pozitivnu razliku iznad gornje referentne granice. Napomena ispod grafikona ima tačno dva reda (engleski i srpski, latinica), kako ne bi bila odsečena u PNG izvozu. Numerički višak ostaje zbir pozitivnih odstupanja po intervalima, a ne geometrijska površina. Grafički test proverava granice poligona, interpolirane preseke i raspored teksta; pokrenite ga lokalno preko `source("tests/test_graphics.R")`.
