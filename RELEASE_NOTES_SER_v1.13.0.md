# Election Forensics R Toolkit — v1.13.0

Datum izdanja: 27. oktobar 2026.

## Novi analitički modul

- Dodat je **`regression_analysis` v0.1.8** (`modules/regression_analysis/`) kao osmi nezavisni analitički modul, pored postojećeg modula za pripremu RZS podataka. Ostali analitički moduli i ulazne baze nisu menjani.
- **A — Izlaznost i glasovi po upisanom biraču.** Regresija metodom običnih najmanjih kvadrata (OLS) na nivou BM, za nacionalnog pobednika i drugoplasiranog, u skladu sa opisnim specifikacijama koje koriste Lukinova, Myagkov i Ordeshook (2011, str. 613–620). Ovaj postupak nije njihov izum, niti se nalazi za Rusiju automatski prenose na Srbiju.
- **B1 — Broj nevažećih listića.** Regresija udela glasova pobednika u važećim glasovima na *apsolutni broj* nevažećih listića.
- **B2 — Stopa nevažećih listića.** Regresija udela pobednika u važećim glasovima na stopu nevažećih listića u ubačenim listićima; posebni kontrolni modeli osetljivosti uključuju izlaznost, veličinu biračkog tela i opcione fiksne efekte opštine.
- Obe definicije izlaznosti: `C/E` (osnovna) i `B/E` (osetljivost); obe prethodno pripremljene klasifikacije (`Size`, `Size_JHK`) bez lokalnog ponovnog klasifikovanja; BM sa manje od 100 upisanih birača kao posebno označena analiza osetljivosti. JHK grafikoni imaju panele **All, JHK Small i JHK Large**.
- PNG grafikoni na engleskom i srpskom (latinica), sa proverljivim imenima kandidata/lista iz šifarnika `Options`; CSV izvoz parametara, odabira kandidata, kvaliteta podataka, veličine uzoraka, OLS/HC3 koeficijenata, modelskih dijagnostika, procena, reziduala i uticajnih vrednosti.
- Ažurirani su korenski README, registri modula, uputstva za instalaciju i tok rada, `.gitignore`, citiranje i manifest kontrolnih suma; istorijska izdanja i licenca nisu menjani.

## Validacija i ograničenja

Tokom razvoja prijavljeno je uspešno izvršavanje sintetičkih numeričkih testova, provera dvojezičnih grafikona, integracionih testova za tri pripremljene izborne baze i provera nacionalnih CSV izlaza u RStudio-u; završni grafikoni v0.1.8 su vizuelno pregledani. Ove provere **nisu** nezavisno usaglašavanje sa zvaničnim zbirnim rezultatima, ne utvrđuju uzročnost niti dokazuju manipulaciju. Nakon instalacije ponoviti testove prema [README-u modula](modules/regression_analysis/README_SER.md) i sačuvati parametre i numeričke rezultate uz analizu.

Regresija izlaznosti i glasova po upisanom biraču delimično sadrži **mehaničku povezanost** dve promenljive. Broj nevažećih listića zavisi i od veličine BM: ni negativna veza ni statistička značajnost nisu dokaz namere. Kontrolni modeli B1/B2 služe proveri osetljivosti, a ne formalnoj klasifikaciji prevara; odsustvo povezanosti ne potvrđuje da nepravilnosti nisu postojale.

Videti [metodologiju](modules/regression_analysis/METHODOLOGY_SER.md), [vodič kroz izlaze](modules/regression_analysis/OUTPUT_GUIDE_SER.md) i [prethodno izdanje](RELEASE_NOTES_SER_v1.12.0.md).
