# Election Forensics R Toolkit — v1.10.0

Datum izdanja: 25. oktobar 2026.

## Dodato

- **Voter rigging v0.1.1**, nezavisni modul u `modules/voter_rigging/`, prema radu Jimenez, Hidalgo i Klimek (2017).
- Izvor: QC-podobna biračka mesta iz lista `Master`, uključujući mesta sa manje od 100 upisanih birača.
- Opštinska leave-one-out standardizacija izlaznosti i udela glasova pobednika, filtriranje pomoću elipse 95% zasnovane na kovarijansi, medijanska rastojanja `D(p)` za pragove 0,5%–90% i kumulativni udeo glasova pobednika.
- Definicije izlaznosti A (`B/E`) i B (`C/E`), dopunske eksplorativne permutacione provere i nacionalni, okružni i opštinski prikazi.
- PNG grafikoni na engleskom i srpskom (latinica) po uzoru na Fig. 4; čitljive legende sa više redova; referentna linija 50% u panelu B; međurezultati i završni CSV; sintetički, grafički, integracioni i izvozni testovi.
- Ažurirani korenski dokumenti i `.gitignore`. Ostali moduli i ranije napomene o izdanjima nisu menjani.

## Tumačenje

**Modul prikazuje opisnu meru `D(p)`, a ne međunarodno referentno standardizovanu `δ(p)` ili formalnu oblast statističkog odbacivanja.** Upoređivanje sa izvornim međunarodnim referentnim izborima nije moguće na osnovu sada dostupnih pripremljenih baza. Neuobičajeni obrasci mogu biti razlog za dodatne provere, ali nisu dokaz nepravilnosti. Potrebni podaci za buduće proširenje objašnjeni su u README-u i metodologiji.

Videti [dokumentaciju modula](modules/voter_rigging/README_SER.md) i [prethodne napomene](RELEASE_NOTES_SER_v1.9.0.md).
