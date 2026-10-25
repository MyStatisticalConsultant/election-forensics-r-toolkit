# Metodologija — približna normalnost logaritamskih stopa glasova

[English](METHODOLOGY.md) · [README](README_SER.md)

**Izvor:** Klimek, P., Yegorov, Y., Hanel, R., & Thurner, S. (2012), *Statistical detection of systematic election irregularities*, *Proceedings of the National Academy of Sciences*, 109(41), 16469–16473; *Supporting Information*, https://doi.org/10.1073/pnas.1210722109. Najvažniji delovi su *Data Collapse* i slika 2 (str. 2), *Approximate Normality* i slika 3 (str. 3), *Discussion* (str. 5), kao i tabele S2–S3 iz dodatka.

## A. Intuitivno objašnjenje

### Zbog čega posmatramo oblik raspodele?

Biračka mesta se razlikuju po podršci pobedničkoj listi ili kandidatu. Udeo upisanih birača koji su glasali za pobednika ograničen je između nule i jedinice. Transformacijom u *logaritamski odnos šansi* dobijamo novu, neograničenu promenljivu, a potom je standardizacijom postavljamo na zajedničku skalu. Time postaje lakše porediti **oblike raspodela** različitih izbora, nezavisno od njihove prosečne podrške pobedniku i različite disperzije.

Ako deluje veliki broj sličnih procesa, ove standardizovane raspodele mogu biti približno zvonaste, odnosno približno normalne. Klimek i saradnici ukazuju da se često javlja **približna**, a ne obavezna normalnost regularnih izbora. Izrazita asimetrija, više vrhova ili debeli repovi mogu predstavljati povod za dodatnu analizu. Međutim, i regionalna koncentracija političkih preferencija, različiti tipovi naselja, mobilizacija birača, posebna biračka mesta ili nivo agregacije mogu proizvesti takav oblik bez izborne manipulacije. Isto tako, neke nepravilnosti neće proizvesti uočljivo odstupanje. **Ni oblik grafikona ni Jarque–Bera p-vrednost ne predstavljaju dokaz manipulacije.**

### Zašto su linije na izvornoj slici uglaste?

Priložena stara skripta koristi `geom_density()`: izglađenu procenu gustine pomoću kernela (KDE). Na slici 2 originalnog rada prikazane su empirijske vrednosti histogramâ povezane dužima, pa je kriva sa vidljivim uglovima. Novi modul računa frekvencije po intervalima, deli ih veličinom grupe i neposredno povezuje sredine intervala. Nema KDE izglađivanja.

U priloženim materijalima nije precizirana tačna širina intervala originalne slike. Zato je **podrazumevana širina 0,2 standardizovane jedinice dokumentovani izbor Toolkit-a**, koji može biti promenjen; nije predstavljena kao potvrđena vrednost izvornog koda autora.

### Zašto posebna analiza za manje od 100 upisanih?

Klimek i saradnici izuzimaju iz glavne analize biračka mesta sa manje od 100 birača kako bi smanjili slučajne ekstremne udele karakteristične za vrlo male uzorke. Modul zadržava tu granicu, ali nudi **odvojenu analizu osetljivosti** za matematički validna BM ispod 100. Ta mesta nikada ne utiču na referentnu sredinu i standardnu devijaciju glavnog uzorka.

## B. Formalni algoritam

### 1. Definicije i podobnost

Za biračko mesto i označimo sa E_i (odgovara N_i u radu) broj upisanih birača, B_i broj važećih listića, C_i broj ubačenih listića i W_i broj glasova za **nacionalno određenog pobednika**. Neophodni su konačni, nenegativni celobrojni podaci, E_i≥1, 0≤W_i≤B_i≤C_i≤E_i i jedinstveni identifikatori biračkih mesta. Za logaritamsku transformaciju dodatno važi 0<W_i<E_i. BM sa W_i=0 ili W_i=E_i izuzimaju se kao matematički nedefinisana; nikakve proizvoljne male konstante se ne dodaju. Razlog izuzimanja beleži se u CSV-u.

**Osnovni uzorak:** sva podobna BM sa E_i≥100. **Uzorak osetljivosti:** podobna BM sa E_i<100. Oba su dostupna na listu `Master` u pripremljenoj bazi RZS.

### 2. Logaritamska stopa glasova iz rada

\[
\nu_i=\log\left(\frac{W_i}{E_i-W_i}\right)
=\operatorname{logit}\left(\frac{W_i}{E_i}\right).
\]

**Imenilac je E_i−W_i**, a ne B_i−W_i, C_i−W_i ili njihov recipročni odnos. Broj upisanih birača koji nisu evidentirani kao glasovi pobednika obuhvata i neizašle i ostale birače. Zato ovo nije običan udeo glasova pobednika među važećim listićima.

### 3. Standardizacija

Za izbore k i geografsko područje g, sredina i **uzoračka** standardna devijacija računaju se preko svih podobnih BM sa E≥100:

\[
\bar\nu_{k,g}=\frac1{n_{k,g}}\sum_{i\in A_{k,g}}\nu_i,\qquad
s_{k,g}=\sqrt{\frac1{n_{k,g}-1}\sum_{i\in A_{k,g}}(\nu_i-\bar\nu_{k,g})^2}.
\]

Svako podobno BM, uključujući BM iz podgrupa, dobija vrednost

\[
z_i=(\nu_i-\bar\nu_{k,g})/s_{k,g}.
\]

Samo raspodela svih BM iz osnovnog uzorka ima sredinu nula i uzoračku SD jedan. Kategorije Small, Large i BM sa E<100 **ne standardizuju se zasebno**, jer bi zasebna standardizacija mogla prikriti razlike između njihovih raspodela. Na nacionalnom nivou ovo odgovara poređenju izbora iz rada; na nivou okruga i opštine predstavlja jasno označenu lokalnu adaptaciju. Za referentnu standardizaciju zahteva se najmanje 30 podobnih BM i pozitivna SD.

### 4. Histogram sa jednakim intervalima

Zadata je širina intervala h>0 (podrazumevano h=0,2). Svakom z_i se pridružuje celobrojni indeks

\[
k_i=\left\lfloor z_i/h+\frac12\right\rfloor.
\]

Sredina intervala je x_k=kh, a granice su [kh−h/2,kh+h/2). Za grupu G empirijska verovatnoća intervala iznosi

\[
\widehat P_G(k)=\#\{i\in G:k_i=k\}/|G|.
\]

U tabelu ulaze i intervali sa frekvencijom nula između minimuma i maksimuma grupa. Na grafikonu se sredine intervala povezuju pravim dužima, bez izglađivanja. Teorijska standardna normalna raspodela prikazuje se na **istoj skali verovatnoće po intervalu**:

\[
P_0(k)=\Phi(kh+h/2)-\Phi(kh-h/2),
\]

pri čemu je Φ funkcija raspodele standardne normalne promenljive. Ne upoređuje se neusklađeno `dnorm(x)` kao gustina po jedinici x sa relativnim frekvencijama po intervalima. Grafikon podrazumevano pokazuje raspon −5 do +5, ali CSV čuva sve ekstremne intervale.

### 5. Vrste poređenja

**Izbori međusobno:** svaki izbor standardizuje se posebno na osnovu svih podobnih BM svog područja, a zatim se porede histogrami iste širine na zajedničkoj skali. Potrebna su najmanje dva izbora za sliku; legenda automatski prelazi u novi red posle tri izbora.

**Grupe u okviru izbora:** sva BM sa E≥100 porede se sa kategorijama Small i Large već utvrđenim u nacionalnoj pripremi (`Size` ili opciono `Size_JHK`). Ostale kategorije ostaju u grupi „Sva BM” i u referentnoj standardizaciji. Za pojedinačnu malu/veliku grupu zahteva se najmanje deset BM. Kategorije veličine nikada se ne preračunavaju zasebno u okrugu ili opštini.

**Analiza osetljivosti ispod 100:** BM sa E<100 porede se zasebno sa svim BM iz osnovnog uzorka uz **iste parametre standardizacije osnovnog uzorka**. Zahteva se najmanje deset takvih BM u odabranom području.

### 6. Asimetrija, spljoštenost i Jarque–Bera test

Za grupu G veličine n neka su m_j=n⁻¹Σ(z_i−z̄)^j centralni momenti. Računaju se:

\[
\text{asimetrija}=m_3/m_2^{3/2},\qquad
\text{spljoštenost}=m_4/m_2^2,\qquad
\text{višak spljoštenosti}=\text{spljoštenost}-3.
\]

Koristi se **Pearsonova spljoštenost** (*ordinary kurtosis*), za koju normalna raspodela ima vrednost **3**, kao u originalnom radu i tabelama S2–S3. Jarque–Bera statistika je

\[
JB=\frac n6\left[\text{asimetrija}^2+\frac{(\text{spljoštenost}-3)^2}{4}\right],
\quad p=P(\chi_2^2\ge JB).
\]

Asimptotska p-vrednost polazi od idealizovanih pretpostavki koje ne moraju važiti za prostorno zavisna biračka mesta. U velikim uzorcima odbacivanje stroge normalnosti može nastati i pri neznatnim odstupanjima. Rezultat predstavlja **dijagnostiku oblika raspodele**, ne meru izbornih nepravilnosti. Izbor nivoa agregacije može promeniti asimetriju i spljoštenost, što autori neposredno pokazuju.

## C. Šta reprodukujemo, a šta prilagođavamo?

Osnov originalnog rada čine poređenja **različitih izbora i država**, dok su poređenja Small/Large, odvojeni grafikoni za BM sa manje od 100 i lokalni prikazi **proširenja Toolkit-a**. Tačan histogram-width i kod za crtanje originalne slike 2 nisu dati u priloženom članku i dodatku; zato nije moguće garantovati identičnost svakog piksela. U implementaciji su javno definisani pravila intervala i svi numerički koraci. Ovaj modul ne računa parametre inkrementalne i ekstremne manipulacije (`f_i`, `f_e`) koji su zaseban deo rada.

## D. Kontrolna lista za interpretaciju

Proveriti nacionalnog pobednika u `Options`; nacionalne zbirne rezultate potvrditi prethodnom validacijom RZS; pregledati BM sa W=0, W=E, E<100; ispitati uticaj izbora širine intervala, veličine grupa i geografske agregacije; uporediti sa nezavisnim posmatračkim i administrativnim dokazima. Ni približna normalnost ni njeno statističko odbacivanje sami ne rešavaju pitanje integriteta izbora.
