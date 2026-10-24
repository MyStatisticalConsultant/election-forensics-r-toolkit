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

Numerički, grafički, geografski, integracioni i izvozni testovi zabeleženi su sa statusom PASS za predsedničke 2017/2022. i parlamentarne 2022. Provera izvoza obuhvatila je nacionalni nivo, četiri odabrana okruga i dve odabrane opštine po izborima, uključujući obe Size klasifikacije. To dokumentuje provereni obim, a ne sve moguće oblasti ili buduće baze. Otisci su eksploratorna dijagnostika, a ne dokaz prevare.

Izvorni i testni R fajlovi prethodna tri modula ostali su neizmenjeni u odnosu na izdanje v1.7.9. Numerički i grafički algoritmi izbornih otisaka sačuvani su iz testirane implementacije; stabilno izdanje dodalo je oznake verzije i podrazumevano strogu proveru geografskih šifara.
