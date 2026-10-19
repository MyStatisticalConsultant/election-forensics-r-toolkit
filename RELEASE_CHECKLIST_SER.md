# Kontrolna lista za objavljivanje — Election Forensics R Toolkit

[English](RELEASE_CHECKLIST.md)

Ispunjenje jedne provere ne znači automatsku validaciju svih statističkih zaključaka.

- [ ] U osnovnom folderu su README na **engleskom i srpskom latinicom**, MIT licenca, metapodaci citiranja, `.gitignore`, oba modula i dvojezična dokumentacija.
- [ ] Nazivi/verzije koda odgovaraju dokumentaciji (postojeći provereni `RZS_data_preparation.R`; deskriptivni modul **v0.3.1**).
- [ ] `raw_data/`, `RZS_prepared/`, `descriptive_outputs/`, `validation_results/` nisu greškom dodati u Git.
- [ ] RZS izvori su neizmenjeni; izvršeni su testovi prethodnog modula, uz jasno navedenu stavku **REVIEW** za upisane 2017.
- [ ] Uspešno se izvršava svih sedam komandi testiranja i analize deskriptivnog modula za ista tri Excel ulaza i isti commit.
- [ ] Sačuvan je datiran konzolni RStudio zapis i `sessionInfo()` bez ličnih putanja; evidentirane verzije softvera i hash ulaza.
- [ ] `100 or more` je identičan `Main` za sva tri izbora; `All` i obe klasifikacije daju proverene nacionalne i teritorijalne zbirove.
- [ ] Ključni glasovi, robusne mere i reprezentativne p/q-vrednosti poređeni su sa nezavisnim referencama; svaka razlika u zaokruživanju ili vezanim rangovima objašnjena.
- [ ] Postoji 16 matrica po izborima, izlaz sprovedenih testova, tačna slova ŠĐŽČĆšđžčć i zaseban Word izveštaj po izborima.
- [ ] Provereni su naslovi, prelomi širokih Word tabela, oznake priloga i prikaz p-vrednosti.
- [ ] Svi EN/SR linkovi ispravno rade na GitHub-u; u publikaciji se navodi tag/commit.
- [ ] Objavljena tvrdnja ostaje **validirano za tri proverena izborna skupa**, bez garancije za sve buduće podatke i bez tvrdnje o dokazu izborne prevare.

Veliki generisani rezultati mogu se objaviti kao zasebni GitHub Release dodaci uz dokumentovan izvor, hash i proveru uslova daljeg deljenja — ne kao obični Git izvorni fajlovi.
