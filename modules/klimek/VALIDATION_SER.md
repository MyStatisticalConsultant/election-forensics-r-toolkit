# Validacija — Klimek v0.1.4

[English](VALIDATION.md) · [Stvarni autorov zapisnik testiranja](VALIDATION_RECORD_2026-10-23_SER.md)

**Status: autor je lokalno validirao sva tri podržana izbora (`presidential_2017`, `presidential_2022`, `parliamentary_2022`) i proverene numeričke/grafičke funkcije.** Za sva tri izbora potvrdio je PASS. Detaljni završni zapis svih sedam RStudio komandi dostavljen je za parlamentarne 2022; za predsedničke nisu dostavljeni zasebni logovi. Testovi nisu nezavisno izvršeni pri pakovanju.

Potvrđeni su sintetički testovi, obe normalizacije, klasifikacije BM, izjednačenja izlaznosti, dvojezični naslovi, korak y-ose od 10 procentnih poena, grupe sa 0/1/više BM, posebne RZS kategorije, krajevi nacionalnih krivih za `parliamentary_2022` i 436 generisanih figura uz uspešnu proveru izvoza. Detalji su u [zapisniku validacije](VALIDATION_RECORD_2026-10-23_SER.md).

Iz direktorijuma `modules/klimek` ponoviti po potrebi:

```r
source("tests/run_tests.R")
source("tests/test_graphics_layout.R")
source("tests/test_single_station_plots.R")
source("tests/test_zero_station_groups.R")
source("tests/integration_real_data.R")
source("Klimek.R")
source("tests/check_exports.R")
```

**Granice dokaza:** Dostavljeni detaljni završni log obuhvata aktivni `parliamentary_2022`. Autor je zasebno potvrdio PASS za predsedničke 2017. i 2022. To predstavlja potvrđenu validaciju sva tri izbora od strane autora; zasebni logovi bi samo unapredili arhiviranu dokaznu dokumentaciju i **nisu preostali uslov za validaciju**. R testovi nisu nezavisno ponavljani u okruženju za pakovanje.

Za reproduktivnost čuvati Git commit, `sessionInfo()`, hash vrednosti XLSX ulaza, EDITABLE postavke, ceo R log i reprezentativne slike na oba jezika. Klimek krive su opisne i nisu dokaz nepravilnosti niti potpuni inferencijalni JHK test.
