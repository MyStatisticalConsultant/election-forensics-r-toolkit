# Rečnik izlaznih promenljivih i statističkih mera — v0.3.1

[English](DATA_DICTIONARY.md) · [Opširni Word vodič](docs/publication/VARIABLES_SER.docx)

Ovaj rečnik opisuje izlaze deskriptivnog modula; izvorne i izvedene promenljive `Master/Main` dokumentovane su u [modulu pripreme](../rzs_data_preparation/DATA_DICTIONARY_SER.md). Brojevi birača i glasova ostaju celi brojevi, a stope su izražene u **procentima 0–100**, ne kao razmere 0–1.

## Identifikatori i zbirne veličine

| Promenljiva | Značenje |
|---|---|
| `Election_type`, `Year`, `Level` | Tip izbora, godina i nivo: država (`National`), okrug (`District`), opština (`Municipality`) |
| `Area_key` | `RS`, šifra okruga ili spoj `okrug|opština`, čime se sprečava zamena istih šifara |
| `Area_name` | Izvorni naziv područja, uključujući specijalne administrativne kategorije |
| `Classification`, `Size_group` | Sistem klasifikacije i jedna od osam oznaka grupa; među sistemima postoji preklapanje |
| `Polling_stations` | Broj QC-prihvaćenih biračkih mesta u posmatranoj grupi i oblasti |
| `Registered` | Zbir E — upisani birači |
| `Attendance` | Zbir A — evidencija izlaska birača |
| `Ballots_cast` | Zbir C — ubačeni listići |
| `Valid`, `Invalid` | Zbir B — važeći i zbir I — nevažeći listići; C=B+I |
| `Winner_votes`, `Runnerup_votes` | Glasovi **nacionalno** prve i druge opcije, istih u svim područjima |
| `Local_leader`, `Local_leader_votes`, `Local_second_votes` | Lokalno prva i druga opcija; redosled može biti drugačiji od nacionalnog |

## Stope i koncentracija

| Promenljiva | Definicija |
|---|---|
| `Turnout_pct` | `100×Ballots_cast/Registered` — zbirna izlaznost |
| `Attendance_pct` | `100×Attendance/Registered` — evidentirani izlazak |
| `Valid_per_registered_pct` | `100×Valid/Registered` |
| `Invalid_per_cast_pct` | `100×Invalid/Ballots_cast` |
| `Invalid_per_registered_pct` | `100×Invalid/Registered` |
| `Winner_per_valid_pct`, `Runnerup_per_valid_pct` | Udeo nacionalno prve/druge opcije među važećim |
| `Winner_per_registered_pct` | Udeo nacionalnog pobednika među upisanim |
| `Local_margin_pct` | Razlika glasova lokalno prve i druge opcije, kao procenat važećih |
| `Effective_number_options` | `1/Σ(udeo opcije u važećim)^2` — efektivan broj izbornih opcija |
| `Share_valid_pct`, `Share_registered_pct` | U tabelama svih kandidata/lista: `100×Votes/Valid` i `100×Votes/Registered` |

Kada je imenilac nula, rezultat je nedefinisan (`NA`), a ne nula. Za udele 50%, 30%, 20% efektivan broj opcija je **2,63**. To opisuje koncentraciju glasova, a nije procena verovatnoće prevare.

## Statistika po biračkim mestima

Osnovne kolone obuhvataju `Mean_E`, `Median_E`, `SD_E`, `Min_E`, `Max_E`, `N_turnout`, `Mean_turnout_pct`, `Median_turnout_pct`, `SD_turnout_pct`, `P20_turnout_pct`, `P80_turnout_pct`, `N_winner_share`, kao i analogne mere udela pobednika i nevažećih. Prošireni modul računa četiri porodice:

- `Electorate_*` — raspodela upisanih po BM (`E`).
- `Turnout_*` — raspodela izlaznosti po BM (`100×C/E`).
- `Winner_share_*` — raspodela udela nacionalnog pobednika (`100×Winner_votes/B`).
- `Invalid_share_*` — raspodela nevažećih (`100×I/C`).

Za svaku su dostupne oznake `_N` (broj raspoloživih BM), `_Mean` (aritmetička sredina), `_Median` (medijana), `_SD` (standardna devijacija uzorka), `_Q1`/`_Q3` (prvi i treći kvartil), `_IQR=Q3−Q1`, `_P10`/`_P90` (10. i 90. percentil), `_Outlier_count` (broj autlajera van `[Q1−1,5×IQR; Q3+1,5×IQR]`) i `_Outlier_pct` (procenat autlajera). Primer: `Turnout_Median=57,20` i `Turnout_IQR=12,40` znači da srednja polovina BM ima raspon izlaznosti od 12,40 procentnih poena — **ne** nužno simetričan oko medijane.

`Mean_ballots_cast`, `SD_ballots_cast`, `Mean_valid`, `SD_valid`, `Mean_invalid`, `SD_invalid` jesu mere prosečnog broja listića po BM, gde svako BM ima jednak ponder.

## Povezanost izlaznosti i podrške

`Joint_N` je broj BM sa obe određene stope; `Joint_Pearson_r`, `Joint_Pearson_p`, `Joint_Spearman_rho`, `Joint_Spearman_p` su koeficijenti i nominalne dvostrane p-vrednosti **među BM unutar oblasti/grupe**. Pripadajuće `Joint_*_BH_q` kolone, ako su prisutne, sadrže BH-korekcije. Ovo **nisu** korelacije između okruga/opština.

U `*_joint_turnout_winner_bins.csv`, `Turnout_bin` i `Winner_share_bin` označavaju intervale od 10 procentnih poena; `Stations` broji BM u ćeliji, `N_complete` sva BM sa obe stope, a `Share_in_area_group_pct=100×Stations/N_complete`. Četiri BM u ćeliji ne znače četiri glasa.

## Statistički testovi i pregled korelacija

`group_significance_tests.csv` sadrži `Outcome`, `Test` (`Size_Kruskal_Wallis` ili `JHK_Wilcoxon`), `Level`, `Area_key`, `N_used`, `N_Small`, `N_Middle`, `N_Large`, medijane grupa, test-statistiku `Statistic`, `P_value` (dvostrano p), `BH_q_value` i oznake `Significant_nominal`/`Significant_BH`. `NA` označava da test nije bilo moguće izračunati, a **nije p=0**.

`correlation_overview.csv` sadrži `Matrix` (`D_01`–`D_08`, `M_01`–`M_08`), `Level`, `Size_group`, `Areas` (broj agregata oblasti), `Variables` (broj numeričkih pokazatelja), `N_tested` (broj **parova promenljivih** za koje je računato p), `Significant_nominal` (broj parova sa p<0,05), `Significant_BH` (broj parova sa BH q<0,05, unutar matrice). **Ove vrednosti nisu broj sumnjivih BM ili opština.** Pojedinačni `R`, `P_value`, `N_pairs`, `BH_q_value` i `Significant_5pct` nalaze se u `correlation_pairs_p_q_n.csv`. Videti [CORRELATIONS_SER.md](CORRELATIONS_SER.md) i [JOURNAL_REPORTS_SER.md](JOURNAL_REPORTS_SER.md).

Dodatna intuitivna objašnjenja i primeri nalaze se u četiri Word dokumenta u `docs/publication/`.
