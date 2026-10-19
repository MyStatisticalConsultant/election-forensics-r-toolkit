# Evidencija i domet validacije — deskriptivni modul v0.3.1

[English](VALIDATION.md)

## Šta je validirano?

**Modul je proveren za tri konkretna izborna skupa, uz uslov uspešnog lokalnog izvršavanja testova i potvrđenih nezavisnih poređenja.** Istraživač je potvrdio slaganje dobijenih rezultata sa nezavisno sastavljenim referentnim rezultatima za **predsedničke izbore 2017. i 2022. i parlamentarne izbore 2022.** To podržava ispravnost obrade u tim uslovima, ali nije garancija za sve buduće RZS formate ili izbore.

**Dokazi uključeni u repozitorijum:** sintetički testovi, testovi na stvarnim bazama, robusni/prošireni testovi, kontrola izvezenih fajlova i `tests/reference_100_or_more_totals.csv`. Referentni CSV proverava identitet `100 or more = Main` i glavne zbirne vrednosti za sva tri izbora; **ne proverava nezavisno svaku p/q-vrednost, svaku korelaciju, izgled Word-a ili nepoznate nove šeme podataka**. Potpun zapis jednog uspešnog izvršavanja svih komandi za **v0.3.1 nije priložen ovom dokumentacionom paketu**. Pre konačnog izdanja treba ga sačuvati.

## Referentni podaci za `Main`

| Izbori | BM | Upisani birači |
|---|---:|---:|
| Predsednički 2017. | 8.023 | 6.680.494 |
| Predsednički 2022. | 7.787 | 6.467.903 |
| Parlamentarni 2022. | 7.787 | 6.467.903 |

CSV referenci sadrži i vrednosti za grupu ispod 100 i proširenu `All` grupu. U validaciji **prethodnog** modula ostala je jedna stavka **REVIEW**: za predsedničke izbore 2017. zbir upisanih iz RZS podataka po BM je 6.723.177, dok je objavljen RIK broj 6.724.949; glasovi kandidata i relevantni zbirovi listića su se slagali. Uzrok odstupanja nije utvrđen i ne treba menjati izvorne brojeve da bi se izjednačili. Videti [VALIDATION_FINDINGS_SER.md](../rzs_data_preparation/VALIDATION_FINDINGS_SER.md).

## Ponavljanje testova

Iz foldera `modules/descriptive_statistics`, nakon pripreme tri baze:

```r
source("tests/run_tests.R", encoding="UTF-8")
source("tests/run_tests_extended.R", encoding="UTF-8")
source("tests/run_tests_robust.R", encoding="UTF-8")
source("tests/integration_real_data.R", encoding="UTF-8")
source("tests/integration_extended.R", encoding="UTF-8")
source("Descriptive_statistics.R", encoding="UTF-8")
source("tests/check_exports.R", encoding="UTF-8")
writeLines(capture.output(sessionInfo()), "sessionInfo.txt")
```

Zabeležite poruke konzole, verziju R i paketa. Pre javnog objavljivanja uklonite lične putanje iz loga. Izvozni test podrazumeva **tri** izborne baze i proverava strukturu listova, nacionalne referentne brojeve, 16 matrica, testove i UTF-8 BOM. To **nije** nezavisna provera svih statističkih p/q-vrednosti. Za objavljivanje u časopisu dobro je nezavisno proveriti reprezentativne testove, posebno tretman vezanih rangova, porodice BH-korekcije i verzije softvera.

## Obavezne rekonstrukcije

1. `Main` reprodukuje očekivana podobna BM (8.023 / 7.787 / 7.787).
2. `All = 100 or more + Less than 100` za sve sabirljive brojeve na nivou države i područja.
3. `100 or more = Small + Middle + Large = JHK Small + JHK Large` kao dve zasebne podele.
4. Zbirovi okruga i opština daju odgovarajuće državne ukupne brojeve.
5. Glasovi za sve opcije zbirno daju broj važećih listića.
6. Prazne grupe ne proizvode lažnu značajnost; konačne p/q vrednosti su u [0,1].
7. Izvorni Excel fajlovi se ne menjaju i srpski dijakritici ostaju pravilni u izlazu.

Svaku buduću izmenu strukture RZS fajla, uključujući nove administrativne kolone, potrebno je **zasebno validirati**. Ova verzija ne podrazumeva takvu kompatibilnost.

**Predložena javna formulacija:** „Deskriptivni modul v0.3.1 proveren je poređenjem sa nezavisnim rezultatima za predsedničke izbore 2017. i 2022. i parlamentarne izbore 2022. i uz uključene skripte za automatsku kontrolu. Validacija se odnosi na proverene ulazne formate i podatke. U prethodnom modulu ostaje dokumentovana razlika u broju upisanih za 2017. godinu koja zahteva dodatnu proveru.”

Validacija računanja **nije** dokaz izborne prevare.
