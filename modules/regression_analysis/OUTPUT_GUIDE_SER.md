# Vodič kroz izlazne fajlove — regression_analysis v0.1.8

Modul se pokreće iz `modules/regression_analysis/`. Svi rezultati smeštaju se u `regression_analysis_outputs/` (isključeno iz javnog GitHub repozitorijuma).

Osnovna organizacija je `regression_analysis_outputs/<izbori>/<definicija_izlaznosti>/<geografski_nivo>/<šifra_područja>/`. Za nacionalni nivo putanja je, na primer:

`presidential_2022/turnout_C_over_E/national/national/`.

Okrug i opština koriste `district/<šifra>/` i `municipality/<šifra>/`. Izlazi se čuvaju posebno za `C/E` i `B/E`, kao i na oba jezika.

## Numerički CSV fajlovi

**`run_configuration.csv`** sadrži aktivne parametre, oznake verzija, definicije izlaznosti, geografski obuhvat, podele Size/JHK i kriterijume za izvršavanje. **`export_manifest.csv`** daje pregled kombinacija izbora i područja, broja BM, modela i figura.

**`selected_options.csv`** navodi koji kandidat ili lista predstavlja nacionalnog pobednika i drugoplasiranog: izvorne kolone `Option_NN_votes`, ukupne glasove, način izbora, proverene nazive iz `Options` ili `OPTION_LABELS` i kolonu `label_source` kao dokaz porekla oznaka. Identitet ovih opcija ostaje isti u analizi okruga i opštine.

**`station_qc.csv`** sadrži početne podatke `E`, `B`, `C`, `W`, glasove drugoplasiranog, `Size`, `Size_JHK`, izvedene stope i razloge isključenja. BM sa `valid_counts = FALSE` ne ulaze u regresiju.

**`group_sample_counts.csv`** prikazuje veličinu grupa `All_100plus`, `Under100`, `Size_Small`, `Size_Large`, `JHK_Small` i `JHK_Large`. Grupe nisu međusobno nezavisne; dve klasifikacije su zasebne i mogu se preklapati.

**`lukinova_station_values.csv`** sadrži za svako BM izlaznost i udeo glasova pobednika/drugoplasiranog u broju upisanih birača. **`invalid_station_values.csv`** sadrži udeo pobednika među važećim glasovima, broj i stopu nevažećih, izlaznost i logaritam broja upisanih birača.

**`model_summary.csv`** sadrži oznaku i formulu modela, grupu, status, broj BM, `R²`, korigovani `R²`, F-statistiku, p-vrednost, rezidualnu standardnu devijaciju, dijagnostiku heteroskedastičnosti i broj uticajnih opservacija. Modeli `A`, `B1`, `B2` su osnovne regresije, dok oznake `Controlled` i `Municipality_FE` predstavljaju dodatne provere osetljivosti.

**`model_coefficients.csv`** čuva koeficijente, obične OLS standardne greške, intervale poverenja, t-testove i p-vrednosti, kao i HC3 robusne standardne greške i intervale. **`model_station_residuals.csv`** čuva prilagođene vrednosti, reziduale, dijagonalne vrednosti matrice uticaja (*leverage*) i Cookovu udaljenost po BM. Jedno BM se može pojaviti u više modela i klasifikacija.

## Grafikoni

**`Regression_A_Size_EN.png` / `_SR.png`**: izlaznost i glasovi pobednika i drugoplasiranog izraženi u procentima svih upisanih birača. Verzija `Size_JHK` koristi JHK grupe.

**`Regression_B1_...`**: udeo glasova pobednika među važećim listićima prema apsolutnom broju nevažećih listića.

**`Regression_B2_...`**: isti udeo prema stopi nevažećih, odnosno nevažeći/ubačeni listići × 100.

Za svaki model postoje figure sa oba sistema klasifikacije (`Size` i `Size_JHK`) i oba jezika (`EN`, `SR`, srpski latinica). Figure `Size` imaju četiri panela: sva podobna BM sa E ≥ 100, mala, velika i BM sa E < 100. Figure `Size_JHK` imaju tri panela: All i JHK Small gore, JHK Large centrirano ispod. BM sa manje od 100 birača ostaju dostupna u `Size` grafikonima i CSV rezultatima. Regresione linije odgovaraju koeficijentima osnovnog nekontrolisanog OLS modela u CSV; kontrolni modeli se ne crtaju kao obične prave jer sadrže više prediktora.

## Provera i tumačenje

Redosled: `tests/run_tests.R`, `tests/test_graphics.R`, `tests/integration_real_data.R`, `Regression_analysis.R`, `tests/check_exports.R`. Test sa stvarnim podacima proverava postojanje i logičku doslednost polja, ali nije nezavisno usaglašavanje sa zvaničnim rezultatima. Regresiona povezanost nije dokaz izborne manipulacije.

JHK grafikoni (v0.1.8) imaju format 17,5 × 13 inča, zajedničke nazive horizontalne i vertikalne ose i jednorednu napomenu. Formule modela A raspoređene su na zajedničkoj skali 0–100% kako ne bi dolazilo do preklapanja u grupama sa užim rasponom vrednosti.
