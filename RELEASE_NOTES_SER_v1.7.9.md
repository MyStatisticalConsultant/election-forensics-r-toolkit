# Election Forensics R Toolkit v1.7.9 — čisto objedinjeno izdanje

[English](RELEASE_NOTES_v1.7.9.md)

**Klimek modul:** v0.1.4. **Descriptive Statistics:** v0.3.1. **RZS Data Preparation:** postojeća verzija neizmenjena.

Ovaj kompletan GitHub paket uklanja zastarela korenska uputstva za pojedinačne patch-eve i prethodne razvojne release notes. Sadrži samo aktuelne beleške izdanja, dokumentaciju, kompletna tri modula, testove, primere, licence, referentne fajlove i obnovljene SHA-256 manifeste. Istorija razvoja sačuvana je u prethodnim Git commitima i dnevnicima promena modula.

**Objedinjene Klimek funkcije od v0.1.3.4-dev:** dvojezični naslovi, puni podnaslovi grupa, izgled A/B figura, razdvajanje standardnih/JHK grupa, korak y-ose od 10 p.p., posebni RZS nazivi okruga, prikaz za 0/1/više BM i potpuni teritorijalni redovi za prazne grupe. **Analitički R kod i numeričke formule nisu menjani ovim prepakivanjem.** R kod preostala dva modula takođe je nepromenjen.

**Autor je potvrdio validaciju za sva tri izbora:** svi Klimek testovi i kompletno izvršavanje uspešno su završeni za predsedničke 2017. i 2022. i parlamentarne 2022. Za parlamentarne 2022. dostavljen je detaljan zapis konzole (7.787 Main BM, 480 prihvaćenih BM ispod 100, 436 figura i PASS izvoza). Za oba predsednička izbora autor je potvrdio PASS bez dostavljanja zasebnih konzolnih logova. [Zapisnik validacije](modules/klimek/VALIDATION_RECORD_2026-10-23_SER.md). Sastavljač paketa nije nezavisno ponavljao R testove.

**Javna dokumentacija:** Uputstva namenjena samo održavaocu (postavljanje na GitHub, potpuna zamena sadržaja i kontrolne liste izdavanja) čuvaju se izdvojeno, van javnog repozitorijuma. Korisnička, metodološka i validaciona dokumentacija ostaje javna.

Kumulativne krive su deskriptivne; ne dokazuju izborne nepravilnosti niti predstavljaju potpuni inferencijalni JHK test.
