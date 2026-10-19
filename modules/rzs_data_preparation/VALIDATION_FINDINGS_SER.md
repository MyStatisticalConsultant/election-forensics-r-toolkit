# Početna validacija prema zvaničnim izbornim rezultatima 2017/2022.

**Datum analize:** 18. oktobar 2026. **Status:** 73 provere `PASS`, jedna `REVIEW`, nijedna `FAIL` u zasebnom, početnom poređenju 74 stavke iz tri dostavljene Excel datoteke. Ovo poređenje nije isto što i pokretanje novog R skripta za validaciju, koji još treba izvršiti u lokalnoj R sesiji.

| Pokazatelj | Predsednički 2017 | Predsednički 2022 | Parlamentarni 2022 |
|---|---:|---:|---:|
| Biračka mesta | 8.396 | 8.267 | 8.267 |
| Upisani birači: zbir RZS po biračkim mestima | 6.723.177 | 6.502.307 | 6.502.307 |
| Upisani birači: objavljeni broj RIK-a | 6.724.949 | 6.502.307 | 6.502.307 |
| Birači koji su izašli (`A`) | 3.655.365 | 3.811.585 | 3.810.559 |
| Listići u kutijama (`C`) | 3.654.014 | 3.797.612 | 3.806.050 |
| Nevažeći (`I`) | 60.378 | 89.933 | 112.722 |
| Važeći (`B`) | 3.593.636 | 3.707.679 | 3.693.328 |
| Pojedinačni rezultati koji se poklapaju sa RIK-om | 11/11 | 8/8 | 19/19 |
| Biračka mesta u `Main` | 8.023 | 7.787 | 7.787 |

Za 2017. zbir upisanih birača iz RZS po biračkim mestima manji je od objavljenog nacionalnog broja RIK-a za **1.772**. Ova razlika ima status **REVIEW**; uzrok nije utvrđen. Na osnovu raspoloživih podataka ne može se tvrditi da je razlika nastala zbog greške u pripremi. Ona utiče na imenilac pri izračunavanju izlaznosti, ali ne i na tačno slaganje glasova svih kandidata sa RIK-om.

Za sva tri izbora važi da je zbir broja redova u `Main` i `Excluded` jednak broju u `Master`, da su zbirni glasovi svih kandidata/lista jednaki broju važećih listića i da izveštaji o kontroli kvaliteta ne prijavljuju duplikate, povrede identiteta listića niti nepodudaranje zbira glasova. Ti izveštaji su ipak **rezultat iste obrade**, ne nezavisna provera zapisnika biračkih odbora. Sledeći korak je direktna provera originalnih RZS fajlova, pojedinačnih zapisnika i rezultata po opštinama/okruzima.

**Izvori:** [RIK 2017](https://arhiva.rik.parlament.gov.rs/english/arhiva-sednice-2017.php), [birački spisak 2017](https://arhiva.rik.parlament.gov.rs/latinica/izbori-za-predsednika-republike-2017-broj-biraca.php), [RIK predsednički 2022](https://www.rik.parlament.gov.rs/vest/sr/317359/70-sednica-republicke-izborne-komisije.php), [RIK parlamentarni 2022](https://www.rik.parlament.gov.rs/vest/sr/324925/79-sednica-republicke-izborne-komisije.php). [Arhiva izbora](https://arhivaizbora.rs/teritorija/RS/srbija/izbori) takođe navodi 6.723.177 za 2017.

**Status za GitHub:** razvojna/istraživačka verzija uz jasno saopštenje o ograničenju validacije; još nije opravdana tvrdnja o bezuslovno potvrđenoj tačnosti svih podataka.
