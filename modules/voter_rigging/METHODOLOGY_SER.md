# Metodologija — Poređenje malih i velikih biračkih mesta i test izbornih anomalija

**Izvor:** Jimenez, Hidalgo i Klimek (2017), *Testing for voter rigging in small polling stations*, Science Advances, 3, e1602363, tekst str. 3–6 i Supplementary Materials str. 2–4.

## 1. Intuitivno objašnjenje

Polazna hipoteza je da na malim biračkim mestima može biti lakše vršiti pritisak na birače ili kontrolisati njihovo ponašanje. Ipak, mala biračka mesta često se nalaze u seoskim sredinama, u kojima političke preferencije, struktura stanovništva i izlaznost mogu prirodno biti drugačiji nego u gradovima. Zato **nije dovoljno uporediti procente podrške pobedniku na malim i velikim biračkim mestima na nivou države**.

Autori najpre porede svako biračko mesto sa **drugim biračkim mestima iste lokalne geografske jedinice**. Na taj način dobijaju standardizovane pokazatelje koliko se izlaznost i udeo glasova pobednika nekog mesta razlikuju od lokalnog okruženja. Kada se zatim analiziraju male i velike grupe, moguće je proceniti da li njihove distribucije imaju različite centre.

Zamislimo dve grupe tačaka na ravni. Horizontalna osa pokazuje standardizovanu izlaznost, vertikalna standardizovani udeo glasova pobednika. Za obe grupe računaju se **medijane** po koordinatama. Njihovo rastojanje je `D(p)`, gde je `p` prag kojim definišemo šta su mala BM. Analiza se ponavlja za pragove od 0,5% do 90%, tako da zaključak ne zavisi samo od jednog proizvoljnog praga veličine.

**Ali velika vrednost `D(p)` nije automatski statistički značajna.** Autori za formalni zaključak upoređuju tu vrednost sa referentnim vrednostima iz drugih izbora. Naš Toolkit trenutno nema takvu međunarodnu referentnu bazu, pa ova prva verzija prikazuje samo opisno rastojanje `D(p)`, bez statističkog zaključka koji zahteva dodatnu referencu.

Drugi prikaz, po uzoru na sliku 4B, prati kako se kumulativni procenat glasova pobednika menja kada se u zbir postepeno uključuju sve manja biračka mesta. To je dodatna opisna provera osetljivosti rezultata na veličinu BM.

## 2. Promenljive i podobnost

Za biračko mesto `i` koristimo: `E_i` broj upisanih birača; `B_i` broj važećih glasova; `C_i` broj listića u kutiji / broj glasalih prema definiciji pripremljene baze; `W_i` glasove iste, nacionalno izabrane pobedničke liste ili kandidata.

Ulaz je list **`Master`** iz RZS pripremljenih radnih svezaka. `Main` standardno ima uslov E≥100, koji je nepogodan ako želimo ispitivati i najmanja BM. Ovaj modul zato prihvata i mesta sa `E<100` ako prođu zasebnu kontrolu: jedinstveni ID i geografski ključevi, celobrojni podaci, `E≥1`, `B>0`, `B≤C≤E`, `0≤W≤B`. Ne preuzimaju se filteri drugih modula koji unapred isključuju veoma mala BM.

Računamo dve varijante izlaznosti radi robusnosti:

- **A:** `t_i=B_i/E_i`, uz `v_i=W_i/B_i`;
- **B:** `t_i=C_i/E_i`, uz `v_i=W_i/B_i`.

Množenje stope sa 100 ne menja Z rezultat, jer se standardizacija vrši istovremeno i u brojniku i u imeniocu. A predstavlja varijantu bližu originalnom radu, dok je B jasno označena dopunska varijanta Toolkit-a.

## 3. Lokalna standardizacija (*leave-one-out*)

Neka je `N(i)` skup **ostalih** podobnih BM u istoj opštini. Računamo:

`Z_t(i)=[t_i-prosek(t_j, j∈N(i))]/sd(t_j, j∈N(i))`

`Z_v(i)=[v_i-prosek(v_j, j∈N(i))]/sd(v_j, j∈N(i))`.

U referentnoj opštini mora biti najmanje **deset podobnih BM**, odnosno najmanje devet *drugih* mesta za konkretno BM. To pravilo sledi minimalnu veličinu susedstva iz Supplementary Materials i princip da se posmatrano BM ne koristi u sopstvenoj referenci. To je strože od podrazumevanog uslova u modulu `contours`. Kada nema dovoljnog broja BM ili je referentna standardna devijacija nula, Z vrednost nije podobna za dalju analizu. U CSV fajlu čuvaju se lokalna sredina, standardna devijacija, broj referentnih BM i Z vrednosti za svako mesto.

## 4. Uklanjanje ekstremnih vrednosti elipsom

Na nivou **celog izbornog ciklusa**, za svaku definiciju A/B posebno, izračunavaju se sredina `m` i kovarijaciona matrica `S` za sve podobne parove `(Z_t,Z_v)`. Kvadrat Mahalanobisovog rastojanja je:

`Q_i=(Z_i-m)'S^(-1)(Z_i-m)`.

U analizu `D(p)` ulaze BM za koja je `Q_i ≤ qchisq(0.95,2)` (približno 5,99146). Izvor koristi 95% elipsu određenu uzoračkom kovarijacijom. **Mesto izvan elipse nije proglašeno neregularnim**; to je samo transparentno pravilo uzorkovanja za ovaj konkretni statistički postupak. Broj tako isključenih mesta može se razlikovati od približno 5% prijavljenih u originalnom istraživanju. Parametri elipse i odluka za svako BM čuvaju se u CSV fajlovima.

## 5. Rastojanje medijana D(p)

Za prag `p∈{0,5;1;1,5;…;90}` i posle filtera 95% elipse, u izabranoj geografskoj jedinici računamo p-ti percentil broja upisanih birača `q_p`. Definišemo male BM kao `E_i<q_p`, a velika kao `E_i≥q_p`. Vezane vrednosti na samom pragu ostaju u velikoj grupi. To znači da broj malih BM ne mora biti tačno `p%`. **Svaka grupa mora imati najmanje deset BM.**

U maloj grupi računamo medijane `(m_t^S,m_v^S)`, a u velikoj `(m_t^L,m_v^L)`. Razlika iznosi:

`D(p)=sqrt((m_t^S-m_t^L)^2+(m_v^S-m_v^L)^2)`.

Pored samog rastojanja čuvamo i usmerene komponente `dx=m_t^S-m_t^L` i `dy=m_v^S-m_v^L`. Na primer, **oba pozitivna pomeranja** ukazuju da mala BM imaju veću standardizovanu izlaznost i veći standardizovani udeo pobednika u odnosu na velika BM. Međutim, `D(p)` je nenegativna mera bilo kog dvodimenzionalnog pomeranja, a ne samo pomeranja u gornji desni kvadrant. Pomeranje može biti povezano sa pritiscima, ali i sa demografskim, administrativnim i drugim okolnostima koje nisu izborne prevare.

Medijane su metodološki važne: **one nisu KDE maksimumi** koji se koriste za opisnu strelicu na konturnim dijagramima u drugom modulu.

## 6. Zašto ne računamo δ(p) i oblast prihvatanja?

U originalnom radu `D_k(p)` je izračunat za **21 izborni ciklus u deset država**. Autori su za svaki prag `p` primenili modifikovani Thompson tau postupak identifikovanja izdvojenih izbora, a zatim formirali referentni skup `R` na osnovu više pragova. Standardizovana mera je:

`delta_k(p)=[D_k(p)-prosek(D_l(p),l∈R)]/sd(D_l(p),l∈R)`.

Siva referentna oblast u originalnoj slici 4A zasniva se na takvom međunarodnom poređenju. **Tri srpska izbora nisu dovoljno uporediva nezavisna međunarodna baza**; u dodatku radu nema pune serije `D_k(p)` za referentnih 21 izbora. Zato u ovoj fazi B ne prikazujemo `δ(p)`, ne crtamo sivu oblast i ne donosimo formalni sud o značajnosti prema izvornom testu. U CSV se nalazi `delta_reference=NA` i `reference_status=NOT_AVAILABLE`, nikada proizvoljna nula.

Funkcija `vr_thompson_tau()` pripremljena je i testirana kao metodološka osnova za buduću fazu A, ali **ne koristi se nad samo tri srpska izbora**. Pre pune primene treba pribaviti uporedive strane podatke, rekonstruisati njihove lokalne standardizacije i distance za isti prag `p`, proveriti izbor referentnih ciklusa i odgovarajuće granice odbacivanja.

## 7. Kumulativne krive — slika 4B

Sva aritmetički podobna BM sortiraju se prema `E` od najvećeg ka najmanjem. Za rang `r` računa se:

`cumi(r)=[zbir W_i do r]/[zbir B_i do r]`.

Računaju se **zbirni glasovi**, a ne neponderisani prosek procenata BM. Horizontalna osa koristi logaritamski rang. Za ovaj prikaz koriste se sva aritmetički podobna BM, a ne samo ona unutar elipse namenjene statistici `D(p)`. Rast ili pad krive nakon dodavanja najmanjih BM pokazuje njihov doprinos zbirnom udelu, ali ne dokazuje motiv, pritisak ili nezakonitost.

Generisani prikaz „Fig. 4 style” sadrži oba panela: **A = D(p), ne originalna δ(p)**; **B = kumulativni udeo**. Nacionalni grafikoni više izbora upoređuju se samo ako je uključen nacionalni nivo. Okružni i opštinski prikazi predstavljaju dodatnu eksplorativnu primenu: percentile veličine računamo lokalno, ali standardizaciju i filter 95% elipse određujemo pre lokalnog izdvajanja, na nivou izbora.

## 8. Opciono permutiranje oznaka veličine BM

Dopunski postupak nasumično razmešta veličine BM `E`, ostavljajući već izračunate Z koordinate nepromenjenim. Podrazumevano se to radi u okviru iste opštine, kako bi se sačuvala lokalna struktura veličina, uz mogućnost globalnog mešanja. Za svaki izabrani prag `p` nastaje raspodela `D_random`, a empirijski pokazatelj računa se kao:

`p_eksplorativno=(1+broj(D_random>=D_posmatrano))/(1+broj_validnih_permutacija)`.

**Ovo nije originalni međunarodni statistički test.** Pošto izlaznost u imeniocu sadrži `E`, permutovanje veličina uz fiksne Z koordinate nije potpuno generativni nulti model izbora. Drugačija ograničenja permutovanja takođe menjaju referentnu raspodelu. Zato ni mali dobijeni broj ne treba predstavljati kao potvrdu pritiska na birače. Dopunska provera može se isključiti.

## 9. Reproducibilnost, obuhvat i ograničenja

U CSV se čuva sled od svake ulazne stavke `Master`, preko razloga isključivanja, lokalnih sredina i SD, Z koordinata, parametara elipse, percentila i medijana, do `D(p)` i kumulativnih procenata. Podrazumevani izvorni uslovi za referentne nacionalne izborne cikluse obuhvatali su **više od 1.000 BM, više od 100 lokalnih geografski definisanih grupa i najmanje deset BM po lokalnoj grupi**. Lokalni prikazi ne zadovoljavaju automatski te uslove i zato nisu potvrda izvorne međunarodne značajnosti.

Statistički signali mogu upućivati na mesta koja je opravdano dalje proveriti. Njih treba povezati sa izvornim zapisnicima, nalazima posmatrača, geografskim i demografskim razlikama i postupcima zaštite izbornog prava. Odsustvo pomeranja malih BM ne isključuje pritiske koji se javljaju podjednako na svim vrstama biračkih mesta.

### Natpisi na grafikonima i robusnost prema definiciji izlaznosti

U objedinjenim prikazima po uzoru na sliku 4, samo panel sa rastojanjem medijana zavisi od definicije A (`B/E`) ili B (`C/E`). Kumulativni udeo glasova pobednika računa se nezavisno od imenitelja izlaznosti, pa je panel 4B identičan u oba prikaza. Isprekidana linija označava 50% važećih glasova. Vertikalna osa panela 4A nosi naslov *Veličina efekta, D(p)*: ova mera predstavlja **nestandardizovano rastojanje medijana**, a ne međunarodno standardizovanu statistiku `δ(p)` iz rada Jimenez i saradnika (2017).
