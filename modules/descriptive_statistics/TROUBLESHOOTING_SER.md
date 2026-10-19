# Rešavanje problema — v0.3.1

[English](TROUBLESHOOTING.md)

| Problem | Uzrok i rešenje |
|---|---|
| `cannot open file 'R/descriptive_core.R'` | Pogrešan radni folder. Otvorite `modules/descriptive_statistics`, proverite `getwd()`; ne unosite ličnu putanju `setwd()` u javni kod. |
| `Prepared XLSX not found` | Najpre izvršite `RZS_data_preparation.R`; proverite tri fajla u `../rzs_data_preparation/RZS_prepared/` ili podesite `INPUTS`. |
| `there is no package called ...` | Instalirajte `readxl`, `openxlsx`, `readr`, a za Word i `officer`, `flextable`. Po potrebi ponovo pokrenite RStudio. |
| Word nije generisan | Proverite `WRITE_WORD <- TRUE` i oba opciona Word paketa. Ako nedostaju, skripta nastavlja sa Excel/CSV, ali preskače Word. |
| `check_exports.R` pada pri obradi samo jednih izbora | Test izvoza podrazumeva sva **tri** izbora; izvršite osnovnu konfiguraciju ili dokumentovano prilagodite test. |
| Š, Đ, Ž, Č, Ć nisu dobri u Excel prikazu CSV-a | CSV je UTF-8 sa BOM. U Excel-u koristite **Data > From Text/CSV**, izaberite UTF-8, ili otvorite izvorni `.xlsx`. |
| Nema BM ispod 100 u nekoj opštini | To je moguć ispravan nalaz. Nedostupne korelacije/testovi ostaju prazni (`NA`), a ne nula. |
| Dobijeno 14 umesto 16 matrica | Pomešani su fajlovi prethodne verzije. Proverite da `size_report_order` sadrži `100 or more` i da postoje `Corr_D_08` i `Corr_M_08`. |
| Broj `100 or more` nije jednak listu `Main` | Proverite da li su Excel baze iste verzije i tip/godina izbora odgovarajući; pokrenite testove pripreme. Ne menjati QC da se zbir „popravi”. |
| P-vrednosti se razlikuju od drugog programa | Proverite uzorak, jednake rangove, aproksimaciju `wilcox.test(..., exact=FALSE)`, NA, BH porodice i verzije R/paketa. |
| Buduće RZS kolone se pogrešno čitaju | Zaustavite izvršavanje; položajna šema u modulu pripreme nije univerzalna. Videti `SCHEMA_EVOLUTION_SER.md` prethodnog modula. |

Za prijavu dostaviti **tačnu grešku, izbore, verziju koda, `sessionInfo()` i korake za ponavljanje**. Ne prikačinjati poverljive lozinke ili nepovezane lične fajlove. GitHub Issues ili `Zlatko@MyStatisticalConsultant.com`.
