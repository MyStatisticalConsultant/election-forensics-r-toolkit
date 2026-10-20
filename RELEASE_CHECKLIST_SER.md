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
- [ ] Klimek v0.1.0-dev: iz `modules/klimek/` izvršiti `source("tests/run_tests.R")`, `source("tests/integration_real_data.R")`, `source("Klimek.R")` i `source("tests/check_exports.R")`.
- [ ] Proveriti obe normalizacije kumulativnih krivih, svih osam grupa, krajnje vrednosti za sve opcije, EN/SR grafikone, dijakritike i eventualno izabrane oblasti.
- [ ] Sačuvati datiran zapis testova, `sessionInfo()`, parametre i hash ulaza. Ne proglašavati Klimek validiranim dok provere ne prođu.
- [ ] Jasno navesti da statističke anomalije nisu samostalni dokaz izborne manipulacije.

## Objavljivanje

- [ ] U Git idu samo kod, testovi, dokumentacija i namerno objavljene reference; izvori i generisani izveštaji ostaju lokalno ili se objavljuju posebno sa poreklom.
- [ ] Proveriti Git diff, linkove, oznaku verzije i tačne statuse sva tri modula.
- [ ] Beleške o izdanju moraju razlikovati promene dokumentacije od promena statističkog metoda.
