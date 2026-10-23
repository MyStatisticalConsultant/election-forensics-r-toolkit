# Rečnik ulaznih i izvedenih podataka

[English](DATA_DICTIONARY.md)

Iz prethodno validiranog Excel fajla koriste se listovi `Main` i `Options`. `Station_key` je stabilan identifikator BM; `Election_type` i `Year` su tip i godina izbora; `District_code` / `District` predstavljaju šifru i naziv okruga; `Municipality_code` / `Municipality` šifru i naziv opštine; `Eligible_primary` potvrđuje pripadnost uzorku `Main`.

`E` su upisani birači (`E>=100`), `B` važeći glasovi, `C` ubačeni listići, a `Option_XX_votes` originalni broj glasova izborne opcije. Primarna izlaznost = `100B/E`, dodatna izlaznost = `100C/E`, udeo glasova = `100W/B`. `Options.Votes_field` označava odgovarajuću kolonu, `Option_name_SR_Lat` sadrži naziv, a `Total_votes` nacionalni zbir za utvrđivanje pobednika.

`audit_<measure>.csv` čuva šifre BM/okruga/opštine, brojeve glasova, procente i status. Status može biti `included`, `invalid_electorate`, `invalid_valid_ballots`, `invalid_option_votes`, `invalid_turnout_numerator` ili `out_of_range`. Bez imputacije, rekonstrukcije ili prisilnog ograničavanja na 100%.


## Polja klasifikacija veličine

`Main.Size`: `Small`, `Middle`, `Large`; `Main.Size_JHK`: `Small`, `Large`. Svako BM pripada tačno jednoj grupi u svakoj od dve klasifikacije. Izvorni glasovi i identifikatori se ne menjaju. Statusna tabela sadrži šifru i puni naziv grupe na oba jezika; `N_main` je broj BM u grupi, a `N_area_main` broj BM u celoj oblasti.
