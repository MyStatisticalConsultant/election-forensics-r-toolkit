# Rečnik promenljivih

[English](DATA_DICTIONARY.md)

## Ulazne promenljive

| Promenljiva | Značenje | Napomena |
|---|---|---|
| `Election_type`, `Year` | Vrsta i godina izbora | Dve vrste izbora mogu biti iste godine |
| `Station_key` | Jedinstveni ključ BM | Uključuje vrstu izbora, godinu i administrativne šifre |
| `District_code`, `Municipality_code` | Šifre okruga i opštine | Tekstualne šifre; opštine se razlikuju po složenom ključu |
| `District`, `Municipality` | Nazivi područja | Čuvaju se slova srpske latinice |
| `E` | Broj upisanih birača | Lica, ceo broj |
| `C` | Broj listića u kutiji | Celi broj |
| `B` | Broj važećih listića | Celi broj |
| `I` | Broj nevažećih listića | `C=B+I` je osnovni QC identitet |
| `Turnout` | `100*C/E` | Procenat izlaznosti |
| `Option_XX_votes` | Glasovi kandidata/liste | Tačna kolona iz `Options.Votes_field` |
| `Size` | Mala/Srednja/Velika BM | Podela po kumulativnom broju upisanih birača |
| `Size_JHK` | JHK mala/velika BM | Podela prema 20. percentilu veličine BM |
| `Eligible_primary` | Status prihvaćenosti u Main | Logička oznaka |
| `Under_100` | `E<100` | Potrebna i ostala QC ispravnost |
| `Admin_no_ballots`, `Admin_invalid`, `Invalid_numeric` | Statusi kontrole kvaliteta | Isključuju sporna BM ispod 100 birača |

## Izlazne promenljive

| Promenljiva | Značenje |
|---|---|
| `Group` | Jedna od osam grupa: `ALL, GE100, LT100, SMALL, MIDDLE, LARGE, JHK_SMALL, JHK_LARGE` |
| `Area_level`, `Area_key` | Nivo i šifra područja (`ALL`, okrug ili složena šifra opštine) |
| `Stations`, `Polling_stations` | Broj BM u odabranoj grupi/području |
| `Registered`, `Ballots_cast`, `Valid_ballots`, `Invalid_ballots` | Zbirovi upisanih i listića |
| `Option_field`, `Option_votes`, `Option_share_pct` | Šifra opcije, glasovi i `100*glasovi/važeći` |
| `Turnout_pct` | `100*zbir C/zbir E`, a ne aritmetička sredina izlaznosti BM |
| `Cum_votes` | Kumulativni zbir glasova kroz sortirana BM |
| `Y_valid` | `100*Cum_votes/ukupno važećih listića` |
| `Y_option` | `100*Cum_votes/ukupno glasova te opcije`; nedefinisano za nulu |
| `Total_valid`, `Total_option_votes` | Imenitelji obe krive |
| `Curve_option_endpoint_pct` | Poslednje `Y_option`, odnosno 100 ili NA |
| `Tail`, `Turnout_cutoff`, `N_stations` | Percentil izlaznosti, prag i broj BM u repu |
| `Mean_station_margin_pp` | Nepovoljan ili povoljan prosečni zbir razlika procenata po BM između dva bloka |
| `Pooled_margin_pp` | Razlika ukupnih glasova blokova / ukupno važećih u repu |
| `Input MD5` | Sažetak pripremljene Excel baze, ne izvornog RZS fajla |

`Options.Total_votes` služi za nacionalno rangiranje **iz svih izvornih zapisa** radi izbora opcija prikazanih na slici. Za imenitelje krivih koriste se podaci odabranog uzorka. Opisne krive nemaju p-vrednost.
