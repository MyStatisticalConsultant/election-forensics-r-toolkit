# Objavljivanje i ažuriranje Election Forensics R Toolkit na GitHub-u

[English](GITHUB_UPLOAD_GUIDE.md) · [Tok rada](WORKFLOW_SER.md) · [Kontrolna lista](RELEASE_CHECKLIST_SER.md)

## Trenutni repozitorijum (razvojna verzija v1.7)

Koristite **jedan** GitHub repozitorijum `election-forensics-r-toolkit` sa tri modula:

| Modul | Status koda | Namena |
|---|---|---|
| [`rzs_data_preparation`](modules/rzs_data_preparation/README_SER.md) | Ranije proveren; jedna stavka REVIEW za upisane birače 2017. | Priprema `Master`, `Main`, `Options`, QC i metapodatke |
| [`descriptive_statistics`](modules/descriptive_statistics/README_SER.md) v0.3.1 | Proveren za tri navedena izbora u dokumentovanim granicama | Deskriptivne analize, korelacije i izveštaji |
| [`klimek`](modules/klimek/README_SER.md) v0.1.0-dev | **Još čeka testiranje u RStudio-u** | Kumulativne krive glasova i dvojezični grafikoni |

Originalni i izvedeni Excel fajlovi ostaju lokalno. **Ne označavati Klimek kao validiran dok testovi i vizuelna provera nisu završeni.**

## A. Prvo objavljivanje celog repozitorijuma

1. Na GitHub-u napravite prazan javni repozitorijum `election-forensics-r-toolkit`, bez automatski kreiranih README, licence i `.gitignore`.
2. Otpakujte **kompletan ZIP**. Prenesite sadržaj unutrašnjeg foldera `election-forensics-r-toolkit/`, čuvajući podfoldere. Za veću strukturu preporučuje se GitHub Desktop ili Git.
3. Proverite korenske datoteke `README*.md`, `.gitignore`, `LICENSE`, `CITATION.cff`, `MODULE_REGISTRY*.md`, `WORKFLOW*.md`, uputstva, liste provera i manifest.
4. Proverite da u `modules/` postoje **sva tri** modula sa R skriptovima, testovima, primerima i EN/SR dokumentima; u deskriptivnom modulu uključiti i četiri Word vodiča.
5. Izvršite odgovarajuće testove na istoj verziji koda i istim izvorima; evidentirajte domet i preostale provere. Klimek ostaje razvojna verzija do stvarne potvrde.
6. Proverite linkove, srpska slova i relativne putanje; tek zatim razmotrite GitHub Release/tag.

## B. Dodavanje modula postojećem repozitorijumu

**Nije potrebno brisati niti ponovo instalirati ceo Toolkit.**

1. Sačuvajte prethodno provereno stanje (backup ili Git commit). Iz novog paketa prekopirajte samo `modules/<novi_modul>/` u postojeći `modules/`; nemojte ceo novi repozitorijum ubaciti kao podfolder starog.
2. Usaglasite promenjene korenske datoteke: `README*.md`, `MODULE_REGISTRY*.md`, `WORKFLOW*.md`, `GITHUB_UPLOAD_GUIDE*.md`, `RELEASE_CHECKLIST*.md` i eventualne druge označene izmene. Pregledajte razlike pre zamene.
3. U prethodnim modulima uredite aktuelna dokumenta koja su zastarela, naročito arhitekturu, spisak modula i uputstva. Ne prepisujte lično podešen R kod ili lokalne Excel rezultate bez poređenja.
4. Proverite `.gitignore` i izvršite testove novog modula, proveru izvoza i pregled grafikona.
5. Sačuvajte Git commit, npr. `Add Klimek module and synchronize EN/SR documentation`, i postavite promene na GitHub. Ne izjednačavajte status razvojnih i validiranih modula.

Git nije potreban za izvršavanje analize, ali je koristan za kontrolu verzija i praćenje razlika.

## C. Šta se ne postavlja u osnovni Git repozitorijum

Ne postavljati `raw_data/`, `RZS_prepared/`, `descriptive_outputs/`, `klimek_outputs/` ni automatski generisane `validation_results/`. One su obuhvaćene `.gitignore`. Provereni, verzionisani rezultati mogu se zasebno objaviti kao GitHub Release prilozi uz uslove korišćenja i dokumentovano poreklo.

Postaviti `tests/`, javne referentne vrednosti, `examples/`, metodološka objašnjenja i namerno arhivirane validacione dokaze sa hash vrednostima. Proverite `git status`; ne koristite prisilno dodavanje isključenih podataka.

## D. Izvršavanje samo izabranog modula

Ako tri pripremljena Excel fajla već postoje u `../rzs_data_preparation/RZS_prepared/`, možete neposredno pokrenuti **samo Klimek** iz foldera `modules/klimek/`. Nije potrebno ponovno pokretanje pripreme RZS podataka ili deskriptivne statistike. Detalji: [tok rada](WORKFLOW_SER.md).

## E. Pravilo ažuriranja dokumentacije

Pri **svakom dodavanju modula** proveriti **sve aktuelne `.md` dokumente**, na engleskom i srpskom latinicom. Uskladiti spiskove modula, opise funkcionalnosti, dijagrame arhitekture, putanje, status validacije, korisnička uputstva, navigaciju i kontrolne liste. Istorijske dnevnike promena i beleške o prethodnim izdanjima zadržati kao istorijske izvore. Proveriti linkove i obnoviti `MANIFEST.sha256`.

Autorsko pravo © 2026 Zlatko J. Kovačić. [MIT licenca](LICENSE).
