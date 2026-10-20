# Reproduktivnost

[English](REPRODUCIBILITY.md)

Za ponavljanje analize potrebni su: (1) identični izvorni RZS Excel fajlovi sa podacima o poreklu; (2) ista verzija `RZS_data_preparation.R` i njena konfiguracija; (3) ista pripremljena baza sa odgovarajućim `MD5` otiskom; (4) isti Git commit `Klimek.R` i ceo odeljak **EDITABLE**; (5) verzije R-a i paketa; (6) podešavanja jezika, grupa, opcija, imenitelja i fontova.

Sortiranje ide po `Turnout`, pa po `Station_key`, tako da nema nasumičnog razrešavanja izjednačenja. Nema Monte Carlo koraka i zato nije potreban seed. Repne metrike su opisne i determinističke. Relativne putanje se odnose na `modules/klimek`. PNG/PDF tipografija i zaglađivanje mogu se razlikovati među operativnim sistemima iako su brojevi isti. Pokrenite `writeLines(capture.output(sessionInfo()), "sessionInfo.txt")` i sačuvajte taj lokalni fajl sa postavkama.

Izvorni RZS fajlovi, generisani XLSX, CSV i slike se obično ne objavljuju unutar glavnog Git izvornog repozitorijuma. Eventualne izvedene baze i slike arhivirajte kao zasebno verzionisano izdanje, uz navođenje porekla, prava ponovne upotrebe i postupka reprodukcije. Uvek razlikujte nacionalni izvorni zbir od QC definisanih analitičkih grupa.
