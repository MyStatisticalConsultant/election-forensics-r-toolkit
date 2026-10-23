# Rešavanje problema

[English](TROUBLESHOOTING.md)

**Ulazni Excel nije pronađen.** Otvorite RStudio sa radnim direktorijumom `modules/klimek`, proverite `INPUTS$prepared_file` i najpre pokrenite pripremni modul. Ne unosite lične apsolutne putanje u blok ispod EDITABLE.

**Nedostaje kolona ili je lista `Options` pogrešna.** Excel nije kanonska pripremljena baza ili je menjan. Ponovo kreirajte bazu koristeći podržani RZS format. Novi izvorni RZS atributi zahtevaju verzionisano mapiranje kolona u *pripremnom* modulu, ne nagađanje po sufiksu `_pct`.

**Š Đ Ž Č Ć nisu ispravno prikazani.** Otvorite CSV kao UTF-8 sa BOM i koristite XLSX nativno. U `BASE_FONT_FAMILY` odaberite font koji podržava latinicu sa dijakriticima (`Arial` u Windows sistemu) i proverite odvojeno PNG i PDF. Ako sistem nema Cairo, PDF fontovi mogu biti ograničeni.

**Nedostaje kriva.** Grupa može biti prazna, broj važećih glasova nula, ili opcija nema glasove uz normalizaciju `option`. Proverite `coverage.csv`, `curve_endpoints.csv` i tačne nazive iz `Options.Votes_field`.

**Izlaznost iznad 100%.** Pregledajte izvorni QC. Skript je ne skraćuje; `LIMIT_X_TO_100=TRUE` samo zumira grafikon i to treba dokumentovati.

**Previše grafikona ili sporo izvođenje.** Podesite jedan jezik, jednu normalizaciju, isključite panelne ili PDF grafikone i `SAVE_CURVE_POINTS`, a birajte nekoliko najboljih opcija. Svi numerički agregati ostaju dostupni.

**Greška T90/T95.** Za svake izbore definišite dva nepreklapajuća skupa opcija, ili isključite `ENABLE_BLOC_TAIL_METRICS`. Nema automatske p-vrednosti.

Pri prijavi greške navedite ceo R tekst greške, vrednosti postavki bez privatnih putanja, `sessionInfo()`, MD5, izbore/grupu i korake reprodukcije.


### `subscript out of bounds` u `tests/test_graphics_layout.R`

Verzija v0.1.3 uvela je funkciju naslova sa šest argumenata, a prethodni test ju je pozivao sa četiri. Zamenite **obe** datoteke, `Klimek.R` i `tests/test_graphics_layout.R`, verzijom v0.1.3.1-dev, pa ponovo pokrenite testove. Pripremljene Excel baze ne menjajte.


### `geom_line(): Each group consists of only one observation`

Verzije pre v0.1.3.3 mogle su da ponavljaju upozorenje za teritorijalno izabrane grupe sa jednim BM. To nije fatalna greška. Verzija v0.1.3.3 prikazuje opažanje kao tačku i čuva numerički rezultat. Posle ažuriranja pokrenite `source("tests/test_single_station_plots.R")`.


### Zašto nedostaje A-grafikon za izabrani okrug? (v0.1.3.4)

Ako okrug nema nijedno prihvaćeno BM u toj grupi, to je očekivano. Program jednom po oblasti prijavljuje `zero-station group(s)` i ne izmišlja krivu niti tačku. Odgovarajući red u teritorijalnoj tabeli ima `Stations=0` i procente `NA`. Stare A/B slike te oblasti brišu se pre novog generisanja; ostali okruzi nisu pogođeni.
