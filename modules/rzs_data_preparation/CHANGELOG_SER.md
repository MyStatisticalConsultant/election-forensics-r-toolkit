# Evidencija izmena

## 1.3.1 — 18. oktobar 2026.

- Ispravljena R sintaksa uslova `if` / `else` na kraju skripta `tests/validate_official_totals.R` (prethodna verzija je prijavljivala grešku u parsiranju na liniji 194).
- `tests/run_tests.R` sada unapred proverava i sintaksu validatora pomoću funkcije `parse()`, bez potrebe za izvornim Excel fajlovima.
- Pravila pripreme podataka, referentni rezultati RIK-a i matematičke provere nisu menjani.


## Verzija 1.1 — 18. oktobar 2026.

Jasno odvojen `EDITABLE` odeljak sa proverom podešavanja i dvojezičnim objašnjenjima; ubačeni englesko-srpski komentari u važne programske celine. Lokalni izvorni fajlovi smeštaju se u `raw_data/`. Nedvosmisleno označeni `Main` kao osnovni analitički ulaz i `Master` kao potpuna revizijska baza. Dodati prateći dvojezični dokumenti, šablon administrativnih odluka, arhitektura i početni testovi. Osnovne formule i struktura 15 izlaznih listova iz verzije 1.0 ostaju neizmenjene.

## Verzija 1.0 — izvorni skript

Priprema podataka RZS za 2017/2022, provere kvaliteta, podela po veličini biračkog mesta, izvođenje promenljivih, metapodaci i izvoz Excela.

## 1.2.0 — 18. 10. 2026.
Uopštavanje za predsedničke i parlamentarne izbore; novi identifikator vrste i godine, neutralne kolone izbornih opcija i zasebni izlazni fajlovi. Dodat zvanični link za parlamentarne izbore 2022. Struktura izvora nije neposredno potvrđena. Promene nisu kompatibilne sa starim nazivima kolona/fajlova.

### 1.2.1 — Usklađivanje strukturnog testa

Razjašnjeni komentari za analitički ulaz `Main` i revizijski skup `Master` u skriptu; usklađen uslov u strukturnom testu. Izračunavanja nisu menjana.


## 1.3 — 18. oktobar 2026.
- Dodata nezavisna provera prema konačnim rezultatima RIK-a za sva tri izbora i svih 38 kandidata/lista.
- Dokumentovana razlika `REVIEW` za broj upisanih birača 2017. (zbir RZS 6.723.177; objavljeni broj RIK-a 6.724.949).
- Dodata dvojezična uputstva, referentni zbirovi i mašinski čitljiv izveštaj. Računska logika pripreme baze nije menjana.
