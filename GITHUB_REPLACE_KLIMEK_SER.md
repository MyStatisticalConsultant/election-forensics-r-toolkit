# Zamena objavljenog Klimek foldera — v0.1.4 (23. oktobar 2026)

[English](GITHUB_REPLACE_KLIMEK.md) · [README modula](modules/klimek/README_SER.md) · [Validacija](modules/klimek/VALIDATION_SER.md)

Na GitHub-u je trenutno Klimek **0.1.0-dev**. Preporučuje se **potpuna zamena** foldera `modules/klimek/`, a ne primena svih ranijih zakrpa. Nije potrebno ponovo pokretati prva dva modula ako pripremljene baze ostaju iste.

1. Preuzmite najnovije promene (`git pull`) i sačuvajte rezervnu kopiju eventualnih lokalnih izmena. Ne brišite ceo repozitorijum niti druga dva modula.
2. Otpakujte `Klimek_v0.1.4_GitHub_Module.zip` u privremeni folder. ZIP sadrži putanju `modules/klimek/`.
3. U lokalnoj kopiji repozitorijuma izbrišite samo stari `modules/klimek/`, pa na isto mesto prekopirajte novi folder. Ne stavljajte novi `klimek` *unutar* starog foldera.
4. Iz kompletnog paketa `Election_Forensics_R_Toolkit_v1.7.9_GitHub.zip` prenesite i ažuriranu korensku dokumentaciju (`README*`, `MODULE_REGISTRY*`, `WORKFLOW*`, `GITHUB_UPLOAD_GUIDE*`, `RELEASE_CHECKLIST*`, `CITATION.cff`, `GITHUB_REPLACE_KLIMEK*`, `RELEASE_NOTES_v1.7.9.md`), a korenski `MANIFEST.sha256` prekopirajte **samo ako** ostatak repozitorijuma tačno odgovara kompletnom ZIP paketu; inače manifest regenerišite iz stvarno objavljenih datoteka. Kod prva dva modula ne treba zamenjivati.
5. U GitHub Desktop proverite listu Changes, ili u Git-u izvršite `git status`. Ne objavljujte ulazne RZS baze ni generisane rezultate. Sačuvajte jedan commit i pošaljite ga na GitHub.

Ako koristite Git komandnu liniju, iz korena repozitorijuma (nakon čuvanja rezervne kopije) možete koristiti `git rm -r modules/klimek`, kopirati novi folder na isto mesto, zatim `git add -A`, `git commit` i `git push`. GitHub Desktop je jednostavniji kada treba uskladiti veliki broj izbrisanih, novih i izmenjenih datoteka.

**Provera u RStudio** — iz foldera `modules/klimek`:

```r
source("tests/run_tests.R")
source("tests/test_graphics_layout.R")
source("tests/test_single_station_plots.R")
source("tests/test_zero_station_groups.R")
source("tests/integration_real_data.R")
source("Klimek.R")
source("tests/check_exports.R")
```

Pregledajte A i B grafikone na oba jezika, posebne RZS kategorije 33/55 i grupe sa 0, 1 i više BM. Autor je potvrdio da slike izgledaju kako je očekivano, ali još nemamo kompletan zapisnik uspešnog izvršavanja svih sedam komandi. Tek posle provera objavite oznake izdanja `klimek-v0.1.4` i `v1.7.9`.
