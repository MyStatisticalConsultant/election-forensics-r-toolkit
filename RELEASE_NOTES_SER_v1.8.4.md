# Election Forensics R Toolkit — v1.8.4 (stabilno izdanje)

Datum izdanja: 24. oktobar 2026. Uključuje **Izborne otiske v0.1.4 (stabilno izdanje)**.

## Sadržaj izdanja

- Dodati dvodimenzionalni **histogrami broja biračkih mesta** prema pristupu iz slike 1 rada Klimek i saradnika (2012), sa zasebno obeleženim dopunskim KDE prikazom i alternativnom definicijom izlaznosti po ubačenim listićima.
- Dvojezični PNG/PDF rezultati na nacionalnom, okružnom i opštinskom nivou i po obe ranije definisane klasifikacije veličine BM: `Size` (mala/srednja/velika) i `Size_JHK` (JHK mala/velika), uz osnovne ALL prikaze.
- Nacionalni pobednik ostaje ista lista/kandidat na svim teritorijalnim nivoima; čuvaju se status BM, izostavljanja, 2D mreže i zvanične šifre.
- Ispravljena granica prikaza dopunske KDE mreže 200×200 bez lažnih upozorenja o odbačenim rubnim ćelijama; podnaslov je podesiv i podrazumevano ima 14 pt.
- Izričita provera izabranih okružnih i opštinskih šifara uz **podrazumevano strogo pravilo** `INVALID_AREA_POLICY <- "error"`. Alternativa `"warn"` zahteva korisnički izbor.
- Prošireni testovi geografskih šifara, zaustavljanja i potpunosti izvoza svih oblasti, veličina BM, definicija izlaznosti i fajlova.
- Ažurirani svi osnovni dokumenti repozitorijuma, verzija citiranja, dvojezična instalacija i tok rada. Iz javne arhive izostavljeni su razvojni paketi, privatna uputstva, izvorni RZS Excel fajlovi i generisani grafikoni.

## Validacija i ograničenja

Autor je dostavio PASS rezultate numeričkih, grafičkih, geografskih, integracionih i izvoznih testova za predsedničke 2017/2022. i parlamentarne 2022. Provereno je po 1 nacionalno područje, 4 okruga i 2 opštine po izborima, uključujući obe Size klasifikacije, bez neočekivanih upozorenja. To je potvrda navedenog opsega, ne svih budućih teritorijalnih izbora ili novih baza. Otisci su eksploratorna dijagnostika, a ne dokaz prevare.

Devetnaest R izvornih/testnih fajlova prethodna tri modula ostalo je identično prethodnoj javnoj verziji v1.7.9. Prelaz na stabilni modul ne menja numeričke/statističke formule niti grafičke algoritme u odnosu na lokalno potvrđenu razvojnu verziju v0.1.3.1; izmene su oznake izdanja i podrazumevano stroga provera šifara.
