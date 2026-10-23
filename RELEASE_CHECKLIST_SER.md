# Kontrolna lista za objavljivanje — Election Forensics R Toolkit

[English](RELEASE_CHECKLIST.md) · [Registar](MODULE_REGISTRY_SER.md) · [Tok rada](WORKFLOW_SER.md)

## Repozitorijum i dokumentacija — pri svakom novom modulu

- [ ] Pregledati **sve aktuelne** `.md` datoteke u osnovnom folderu i svim modulima, EN/SR. Ispraviti zastarele tvrdnje o postojećim, planiranim i validiranim modulima.
- [ ] Uskladiti korenske README dokumente, registar, arhitekturu EN/SR, GitHub uputstva, tok rada, instalaciju, linkove, liste izlaza, podatke o citiranju i verzije.
- [ ] Proveriti sve interne linkove, radne direktorijume i relativne `INPUTS` putanje. Razlikovati prvo pripremanje baze od kasnijeg izvršavanja samo izabranog modula.
- [ ] Proveriti `LICENSE`, `CITATION.cff`, `.gitignore`, SHA-256 manifest i dvojezične korisničke/metodološke dokumente i testove novog modula.
- [ ] Sačuvati stare dnevnike promena i beleške o ranijim izdanjima kao istorijske dokaze; dodati beleške o novoj verziji.
- [ ] Potvrditi da dodavanje modula nije slučajno promenilo ranije provereni R kod ili lokalne podatke.

## Provere podataka i analiza

- [ ] Priprema RZS: upoređivanje sa zvaničnim zbirovima, ugovor `Main`/`Master`/`Options` i dokumentovana stavka **REVIEW** za upisane 2017.
- [ ] Deskriptivni modul v0.3.1: sintetički, integracioni i izlazni testovi za tri izbora; `100 or more == Main`, osam delimično preklapajućih grupa, 16 agregatnih korelacionih matrica, izveštaji i ćirilično/latinično kodiranje.
- [ ] Klimek v0.1.4: iz `modules/klimek/` izvršiti svih sedam komandi iz [uputstva za zamenu](GITHUB_REPLACE_KLIMEK_SER.md): `run_tests`, `test_graphics_layout`, `test_single_station_plots`, `test_zero_station_groups`, `integration_real_data`, `Klimek.R`, `check_exports`.
- [ ] Proveriti SR/EN A i B naslove, čitljive legende, korake od 10 procentnih poena na y-osi, razdvajanje standardnih/JHK grupa i posebne RZS šifre 33, 55 i 25–29.
- [ ] Proveriti 0 BM = nema slike uz `Stations=0` / `NA` u tabelama; 1 BM = tačka; 2+ BM = linija; nema zastarelih slika izabrane oblasti.
- [ ] Proveriti krajnje vrednosti obe normalizacije, zbir glasova svih opcija, osam preklapajućih grupa i Unicode.
- [ ] Sačuvati datiran zapis testova, R `sessionInfo()`, hash ulaza i izabrane slike; bez tih provera ne tvrditi da je Klimek nezavisno validiran.
- [ ] Opisne krive ne dokaziju izbornu prevaru.

## Objavljivanje

- [ ] U Git idu samo kod, testovi, dokumentacija i namerno objavljene reference; izvori i generisani izveštaji ostaju lokalno ili se objavljuju posebno sa poreklom.
- [ ] Proveriti Git diff, linkove, oznaku verzije i tačne statuse sva tri modula.
- [ ] Beleške o izdanju moraju razlikovati promene dokumentacije od promena statističkog metoda.
