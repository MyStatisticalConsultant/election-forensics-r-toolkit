# Dnevnik izmena — modul Descriptive Statistics

[English](CHANGELOG.md)

## v0.3.1 — 19. oktobar 2026. — osnovni analitički uzorak

- Grupa **`100 or more`** eksplicitno je dodata na nacionalnom, okružnom i opštinskom nivou i jednaka je `Main`.
- Sačuvano je `All = 100 or more + QC-prihvaćena Less than 100`, kao i dva nezavisna rastavljanja po veličini BM.
- Dodate su **osme** korelacione matrice za oba nivoa (`Corr_D_08`, `Corr_M_08`); stare oznake su zadržane.
- Ažurirani su robusni/statistički, Word, Excel i CSV prikazi, referentne vrednosti i testovi izvoza.
- **Naknadno ažuriranje dokumentacije:** usklađeni dvojezični README, metodologija, rečnik, validacija i vodiči za objavljivanje; **numerički algoritmi nisu menjani u ovom dokumentacionom paketu**.

## v0.3.0 — 18. oktobar 2026. — publikacione tabele i robusne mere

- Zaseban Word izveštaj za svake izbore sa sažetim državnim tabelama, potpunim teritorijalnim prilozima i sprovedenim testovima.
- Medijana, IQR, percentili, Tukijevi autlajeri, zajednička raspodela izlaznosti i udela pobednika, Pirsonove/Spirmanove korelacije po BM.
- Kruskal–Volisovi i JHK Vilkoksonovi testovi, sa BH-korekcijama i numeričkim izlazima.

## v0.2.1 — 18. oktobar 2026. — prazne grupe

- Ispravljeno sastavljanje korelacionih parova kada ne postoje BM/oblasti ili kada postoji nula/jedna numerička varijabla; prošireni testovi.

## v0.2.0 — 18. oktobar 2026. — proširene teritorijalne analize

- Dodata QC-prihvaćena grupa ispod 100, nacionalne/okružne/opštinske tabele, oblikovani izlazi i korelacione matrice agregata.

## v0.1.0 — 18. oktobar 2026. — prvi modul

- Standardizovani ulaz iz pripreme podataka, okruzi/opštine, dve klasifikacije i glasovi svih opcija.

**Validacija:** odnosi se na tri proverena izborna skupa, za koje je istraživač potvrdio nezavisno slaganje numeričkih rezultata; ceo RStudio zapis v0.3.1 treba arhivirati. [VALIDATION_SER.md](VALIDATION_SER.md).
