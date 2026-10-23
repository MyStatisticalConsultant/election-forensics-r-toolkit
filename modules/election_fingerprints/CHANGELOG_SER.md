# Izborni otisci — istorija promena

## v0.1.4 — stabilno izdanje (24. oktobar 2026.)

Prvo izdanje spremno za objavljivanje, objedinjeno od testirane razvojne verzije v0.1.3.1. Uključuje dvodimenzionalne histograme broja BM, dopunski KDE i alternativnu definiciju izlaznosti, dvojezične slike, nacionalne/okružne/opštinske prikaze, obe nacionalno validirane Size/JHK klasifikacije, evidenciju BM, mreže i statusne izveštaje.

KDE mreža 200×200 računa se u središtima ćelija i prikazuje uz `coord_equal`, bez upozorenja o izgubljenim rubnim redovima. Veličina običnog podnaslova može se menjati (14 pt podrazumevano). Nepostojeće geografske šifre eksplicitno se dijagnostikuju uz predlog važeće šifre, kada postoji. **Podrazumevano `INVALID_AREA_POLICY` sada je `"error"`**, umesto ranijeg `"warn"`; korisnik može posebno dozvoliti samo upozorenja. Testovi izvoza pokrivaju sve izabrane oblasti, grupe i vrste fajlova.

Autor je dostavio PASS rezultate numeričkih, grafičkih, geografskih, integracionih i izvoznih testova za tri izborna skupa (nacionalni nivo + četiri okruga + dve opštine po izborima), bez neočekivanih upozorenja. Prelazak na v0.1.4 ne menja numeričke formule, histogram, KDE estimator, funkcije crtanja ili provere u odnosu na v0.1.3.1.
