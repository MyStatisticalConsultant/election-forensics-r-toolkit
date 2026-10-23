# Opis izlaznih datoteka

[English](OUTPUT_GUIDE.md)

U `fingerprint_outputs/<oznaka_izbora>/` nastaju:

- `fingerprints_status.csv`: oblast, definicija izlaznosti, nacionalna opcija, broj BM, broj prihvaćenih i izostavljenih, status KDE i MD5 ulaznog fajla.
- `<oblast>/audit_valid.csv` i `audit_cast.csv`: svako BM i razlog uključenja ili isključenja.
- `<oblast>/grid_hist_valid.csv` i `grid_hist_cast.csv`: potpuna 2D mreža sa `N_stations` (broj BM u ćeliji); zbir mora biti jednak ukupnom broju uključenih BM.
- `<oblast>/grid_kde_valid.csv` i `grid_kde_cast.csv`: dopunska mreža sa maksimalno normalizovanom KDE gustinom (0–1), ako je moguće izračunati.
- `<oblast>/EN/` i `<oblast>/SR/`: `fingerprint_hist_valid.png/.pdf`, `fingerprint_hist_cast.png/.pdf`, `fingerprint_kde_valid.png/.pdf`, `fingerprint_kde_cast.png/.pdf`, zavisno od podešavanja.

Folderi su označeni prema šiframa (`National`, `District_XX`, `Municipality_XX_YYYYY`), a na slici stoji pun naziv oblasti. Histogram ima brojčanu, a KDE relativnu skalu. Izlazi `cast` jasno su obeleženi kao analiza osetljivosti. Za nula uključenih BM nema slika, a za nedovoljno BM ili nultu varijansu KDE se preskače uz status `insufficient_data`.


## Izlazi po grupama veličine

Osnovne slike svih BM ostaju na dosadašnjim putanjama. Novih pet grupa upisuje izveštaje i slike u `<oblast>/groups/<ŠIFRA>/`; svaka grupa ima audit CSV, ćelijsku tabelu 2D histograma, opcioni KDE raster i slike EN/SR. `fingerprints_status.csv` uključuje kolone `Group`, `Group_classification`, `Group_label_EN`, `Group_label_SR`, `N_area_main`, `N_main` i dosadašnje pokazatelje. Prazne grupe dobijaju red `N_main=0`, `N_included=0` i `KDE_status=empty`, bez slike. Stare slike i mreže ćelija koje je modul generisao uklanjaju se pre novog izvršavanja.

### Geografski ključevi i validacija izvoza

Postavite `AREA_MODE <- "selected"` i `SELECT_MUNICIPALITY_KEYS <- c("26|90239")` za opštinu Peć (u odgovarajućim izborima). Pogrešni ključevi, kao `25|90239`, dobijaju jasnu dijagnostičku poruku sa predlogom ako postoji. `INVALID_AREA_POLICY <- "error"` (podrazumevano) ili `"warn"` određuje nastavak/prekid. Posle generisanja pokrenite `source("tests/check_exports.R")`, koji proverava sve izabrane teritorijalne nivoe, a ne samo Srbiju. Numerički algoritam i grafički prikaz nisu menjani.
