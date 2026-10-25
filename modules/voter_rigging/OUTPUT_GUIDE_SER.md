# Numerički rezultati i tumačenje — voter_rigging

[English](OUTPUT_GUIDE.md) · [README](README_SER.md) · [Metodologija](METHODOLOGY_SER.md)

Svi numerički rezultati upisuju se u UTF-8 CSV fajlove ispod lokalnog foldera `voter_rigging_outputs/`, koji se ne otprema na GitHub. Izvorne pripremljene Excel baze ostaju neizmenjene.

- **run_configuration.csv:** izbor radnog lista i metodološki parametri. Međunarodna referentna baza je jasno označena kao nedostupna.
- **export_manifest.csv:** izbori, definicija izlaznosti, geografski nivo, broj redova, broj standardizovanih i zadržanih BM, broj podobnih pragova `p` i broj slika. `SKIP_D` znači da nijedan prag nije mogao biti izračunat.
- **station_level_qc.csv:** originalni brojevi `E,B,C,W`, izvor glasova pobednika, izlaznost, udeo glasova, podobnost, sredine i SD susednih BM, `z_t`, `z_v`, broj suseda, Mahalanobisovo rastojanje, pripadnost 95% elipsi i razlog isključenja. **Razlozi isključenja nisu optužbe za neregularnosti.**
- **quality_summary.csv:** broj redova, podobnih i uključenih BM sa E<100, broj uspešno standardizovanih i unutar elipse, broj opština i opština koje ispunjavaju minimum, kao i ispunjenost osnovnog brojčanog obuhvata iz međunarodnog rada. To samo po sebi ne predstavlja osnov za izvođenje testa značajnosti.
- **ellipse_parameters.csv:** sredine, komponente kovarijacione matrice i granična vrednost 95% elipse.
- **D_by_size_threshold.csv:** pragovi `p=0,5,...,90`, veličinski prag, broj BM, četiri medijane, usmerena pomeranja `dx`,`dy`, rastojanje `D` i status. `delta_reference=NA` i `reference_status=NOT_AVAILABLE` znače da međunarodna standardizacija nije izvršena.
- **cumulative_vote_share.csv:** rang BM od najvećih ka najmanjim, identifikator, broj upisanih, kumulativni važeći glasovi, kumulativni glasovi pobednika i njihov ponderisani udeo.
- **permutation_summary.csv / permutation_draws.csv:** opcione permutacije oznaka veličine i empirijske repne verovatnoće — samo eksplorativno, **ne** originalni međunarodni Thompson tau test.

**Slike:** `Figure4A_D` predstavlja opisno `D(p)` bez oblasti statističkog prihvatanja/odbacivanja; `Figure4B_cumulative` pokazuje kumulativni udeo glasova pobednika; `Figure4_style` prikazuje oba panela. Sufiks `EN` / `SR` označava jezik. Nacionalni prikazi više srpskih ciklusa ne predstavljaju zamenu za međunarodni referentni skup iz rada.

Ako je broj BM nedovoljan, rezultati imaju status `INSUFFICIENT_GROUP`, uz nedostajuću vrednost D. **Nedostajuća vrednost nije nula.** Opštinska standardizacija i 95% elipsa računaju se pre izdvajanja lokalnih područja za prikaz.

**Natpisi i definicije A/B (v0.1.1):** Na osi panela 4A piše `Veličina efekta, D(p)` sa kurzivnim `p`; statistika `δ(p)` nije dostupna bez proverene međunarodne reference. Isprekidana horizontalna linija u panelu 4B označava 50%. Kumulativne krive su identične pod definicijama A (`B/E`) i B (`C/E`), jer zavise samo od glasova. Dakle, u `Figure4_style_comparison_<A/B>_<jezik>.png` **samo panel 4A** zavisi od definicije izlaznosti. U legendi se podvlake zamenjuju razmacima, a svake tri stavke počinje novi red. Nazivi izlaznih fajlova nisu menjani.
