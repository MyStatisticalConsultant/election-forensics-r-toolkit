# Metodologija: regresione dijagnostičke analize biračkih mesta

## 1. Intuitivno objašnjenje

Na dijagramu rasipanja (*scatterplot*) svaka tačka predstavlja jedno biračko mesto (BM). Vodoravna osa označava izlaznost ili karakteristiku nevažećih listića; uspravna osa pokazuje deo glasova koji pripada određenoj izbornoj opciji. Regresiona prava sažima prosečnu povezanost između tih veličina. Njen nagib je koristan za poređenje teritorija, izbora i skupina BM, ali sam po sebi ne pokazuje da li su glasovi menjani niti ko bi to mogao da uradi.

Lukinova i saradnici (2011) upoređivali su **glasove kandidata kao udeo u svim upisanim biračima** sa izlaznošću, posebno analizirajući pobednika i drugog kandidata. Mebaneovo razmatranje mogućih nepravilnosti podstiče proveru da li visoku podršku pobedniku prati neobično mali broj nevažećih listića. Ali broj nevažećih listića zavisi i od veličine BM, dizajna glasačkog listića, lokalnih uslova i drugih faktora. Zato posmatramo i apsolutni broj i stopu nevažećih, uz dodatne regresione provere.

## 2. Podaci i definicije

Neka `E_i` označava upisane birače, `B_i` važeće glasačke listiće, `C_i` ubačene listiće (važeće plus nevažeće), `W_i` glasove nacionalnog pobednika, a `R_i` glasove nacionalno drugoplasirane opcije. Primarna izlaznost je `T_i=C_i/E_i`, a alternativna `B_i/E_i`. Broj nevažećih listića iznosi `I_i=C_i-B_i`, stopa `Q_i=I_i/C_i`, a udeo pobednika među važećim glasovima `S_i=W_i/B_i`. Procenti su izraženi množenjem sa 100.

Koristi se radni list `Master`. Za podobnost su neophodni jedinstvena šifra BM, šifre okruga i opštine, celobrojne nenegativne vrednosti i logički uslovi `1 <= B <= C <= E`, `0 <= W`, `0 <= R`, `W+R <= B`. Isključene vrednosti i razlozi nalaze se u `station_qc.csv`. Primarni skup obuhvata `E >= 100`, a manja BM se obrađuju odvojeno.

Na nacionalnom skupu automatski se biraju dve opcije sa najvećim zbirom glasova iz `Option_NN_votes`. Identitet pobednika proverava se preko `Winner_votes`, odnosno eksplicitnog zamenskog polja. Podešavanjem `SELECTION` mogu se zadati kolone, ali prva mora odgovarati nacionalnom pobedniku. Nazivi kandidata/lista preuzimaju se iz šifarnika `Options` po broju izborne opcije (`Option_number`), uz mogućnost ručno proverenog `OPTION_LABELS` mapiranja. Ako identitet nije pouzdano utvrđen, analiza se zaustavlja umesto da nagađa naziv. Isti izbor pobednika i drugoplasiranog važi za sve geografske analize. Delimično mapiranje je dozvoljeno: naziv neobuhvaćene izborne opcije i dalje se čita iz proverenog šifarnika.

## 3. Deo A — metod Lukinove i saradnika

Osnovne regresije procenjuju se metodom običnih najmanjih kvadrata (*ordinary least squares*, OLS):

\[
100\frac{W_i}{E_i}=\alpha_W+\beta_W\left(100\frac{C_i}{E_i}\right)+\epsilon_{Wi},
\qquad
100\frac{R_i}{E_i}=\alpha_R+\beta_R\left(100\frac{C_i}{E_i}\right)+\epsilon_{Ri}.
\]

Posebna analiza zamenjuje `C/E` sa `B/E`. Jedno BM predstavlja jednu opservaciju sa jednakim ponderom. Prikazane prave predstavljaju konkretne OLS modele čiji su koeficijenti upisani u CSV, bez KDE ili lokalnog izglađivanja.

Izvorni rad na stranama 613–620, posebno na slikama 12–29, koristi odgovarajuću formu `V/E = βT + α`. Nalaz velikog koeficijenta za pobednika autori razmatraju u ruskom istorijskom, regionalnom i uporednom kontekstu. Nagib blizu ili iznad jedan nije univerzalni statistički kriterijum za falsifikovanje rezultata.

**Matematička povezanost:** `W/E` je deo ukupne izlaznosti, pa je pozitivna veza sasvim moguća i kada je procenat podrške pobedniku jednak na svim BM. Ako je podrška stalna i iznosi `s`, važi približno `W/E = s(C/E)`. Prema tome, nagib nije čista mera nepravilnosti, nego može zavisiti od političkih i demografskih osobina birača.

## 4. Deo B — regresije inspirisane Mebaneom

Prvi grafikon iz priloženog korisničkog skripta predstavlja **udeo pobednika među važećim glasovima** u odnosu na **broj nevažećih listića**. Taj odnos ne sme se označavati kao `W/E`, što je bila pogrešna oznaka u starom grafikonu. Uz taj pristup implementiramo i normalizovanu alternativu:

\[
\begin{aligned}
\text{B1:}\quad 100\frac{W_i}{B_i}&=a_1+b_1 I_i+u_i,\\
\text{B2:}\quad 100\frac{W_i}{B_i}&=a_2+b_2\left(100\frac{I_i}{C_i}\right)+v_i.
\end{aligned}
\]

Negativan koeficijent može biti kompatibilan s nekim hipotezama o manipulaciji rezultatima, ali nije univerzalno očekivanje za poštene izbore. Ni pozitivan koeficijent ne dokazuje odsustvo nepravilnosti. Udeo pobednika i stopa nevažećih imaju povezane imenioca i brojioce; to može proizvesti sastavne (*compositional*) i aritmetičke artefakte.

Dodatni kontrolni modeli uključuju izlaznost, logaritam broja upisanih birača i, tamo gde je opravdano, fiksne efekte opština:

\[
100\frac{W_i}{B_i}=a+bX_i+\gamma T_i^{(\%)}+\lambda\log E_i+u_i.
\]

`X_i` je ili broj ili procenat nevažećih listića. Reč je o dodatnim analizama osetljivosti u našem Toolkit-u, ne o preuzetoj formalnoj Mebaneovoj jednačini. Kontrole ne uklanjaju svu neopaženu heterogenost i ne omogućavaju uzročne zaključke.

## 5. Statistika i dijagnostika

Za svaki model čuvamo koeficijente, klasične OLS standardne greške, t-testove, intervale poverenja 95%, korigovani `R²`, F-statistiku i p-vrednost, rezidualnu standardnu devijaciju i broj BM. Pored njih računaju se HC3 robusne standardne greške pomoću procene:

\[
\widehat V_{HC3}=(X'X)^{-1}X'\,\operatorname{diag}\!\left[\frac{e_i^2}{(1-h_{ii})^2}\right]X(X'X)^{-1}.
\]

Oznake `e_i` i `h_ii` odnose se na reziduale i dijagonalne elemente matrice uticaja. Robusne p-vrednosti koriste približnu t raspodelu sa rezidualnim stepenima slobode, a **nisu** klasterski robusne. Dodatno čuvamo dijagnostiku heteroskedastičnosti zasnovanu na regresiji kvadriranih reziduala na prilagođene vrednosti, Cookovu udaljenost i *leverage* po BM. Kada nema dovoljnog uzorka ili varijacije, status preskakanja se izričito navodi u CSV dokumentima.

## 6. Podela po veličini i geografiji

Za nacionalnu analizu i izabrane okruge i opštine formiraju se: sva BM sa `E >= 100`, BM manje od 100 kao posebna analiza osetljivosti, zatim `Size` Small/Large i `Size_JHK` Small/Large. Obe podele potiču iz nacionalne pripreme RZS podataka i ne preračunavaju se za pojedine okruge ili opštine. Grupe se mogu preklapati, te njihovi regresioni rezultati nisu međusobno nezavisni.

## 7. Ograničenja i odgovorno tumačenje

OLS veze između agregiranih podataka po BM nisu uzročne. Na njih mogu uticati obrazovanje, starost, geografska struktura, mobilizacija birača, karakteristike kandidata, izborne administracije i greške u evidenciji. HC3 ublažava posledice heteroskedastičnosti za standardne greške, ali ne rešava endogenost, prostornu zavisnost, selekciju niti problem mehaničke povezanosti razlomaka. Veći broj regresija povećava rizik slučajno značajnih nalaza. Neophodno je poređenje sa drugim forenzičkim analizama, izbornim zapisnicima i neposrednim posmatranjem.

## Literatura

Lukinova, E., Myagkov, M., & Ordeshook, P. C. (2011). *Metastasised Fraud in Russia’s 2008 Presidential Election*. *Europe-Asia Studies, 63*(4), 603–621. https://doi.org/10.1080/09668136.2011.566426

Mebane, W. R. Jr. *A Guide to Election Forensics*. U ovom modulu je njegova opšta motivacija za proveru nevažećih listića razdvojena od naših sopstvenih OLS specifikacija, koje **nisu** predstavljene kao preuzete formule iz tog izvora.
