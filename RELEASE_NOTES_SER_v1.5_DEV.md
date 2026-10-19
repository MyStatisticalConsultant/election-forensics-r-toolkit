# Election Forensics R Toolkit v1.5.1-dev

Kod i proračuni prvog modula (`rzs_data_preparation`) **nisu menjani** nakon ranije provere. Modul `descriptive_statistics` nadograđen je na razvojnu **v0.2.1**, dok je ranija v0.1.0 bila uspešno testirana u korisnikovom RStudio okruženju.

Novine: CSV kodiranje UTF-8 sa BOM, republičke tabele, QC-prihvaćena BM ispod 100 birača, dve pregledne tabele za republiku/okrug/opštinu, 14 ekoloških korelacionih matrica po izborima (Pearsonov r, nominalna značajnost 5%, p/N/BH-q), opciona Word dokumenta i novi testovi izvoza.

**Status provere:** Nova v0.2.1 još nije izvršno testirana u R-u u ovom okruženju. Korisnik treba da pokrene sintetičke, integracione i izvozne testove pre objave kao konačne verzije. Izvorni fajlovi nisu menjani.

Fajlovi iz `raw_data`, `RZS_prepared`, novi deskriptivni izlazi i automatski validacioni folderi ostaju van Git-a. Za problem proširivanja RZS tabela pogledati `modules/rzs_data_preparation/SCHEMA_EVOLUTION_SER.md`.


## v1.5.1-dev: ispravka korelacija

Ispravljeno formiranje korelacionih parova kada je grupa prazna; dodati sintetički regresioni testovi. Nema izmena ulaznih fajlova ni pripreme RZS podataka. Pokrenuti testove u lokalnom RStudio okruženju.
