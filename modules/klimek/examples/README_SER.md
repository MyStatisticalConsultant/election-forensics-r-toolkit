# Primeri

Pokrenite modul iz `modules/klimek`. Skript `Klimek.R` već sadrži primere `INPUTS` za tri izbora. Pre pokretanja sačuvajte pripremljene Excel baze u `../rzs_data_preparation/RZS_prepared/`.

Za engleske grafikone koristite `GRAPH_LANGUAGES <- "EN"`, za srpske `"SR"`, a za oba jezika `c("EN", "SR")`. Podešavanja `OPTION_SELECTION_MODE <- "top_n"` i `DISPLAY_TOP_N <- 3L` prikazuju tri nacionalno najbolje rangirane liste/kandidata. `CURVE_NORMALISATIONS <- "both"` izračunava obe vrste krivih. Detaljni primeri za nazive i boje dati su u `USER_GUIDE_SER.md`.

Ne postavljajte izvorne Excel baze, izvezene CSV datoteke tačaka krivih ni grafikone u glavni izvorni GitHub repozitorijum.
