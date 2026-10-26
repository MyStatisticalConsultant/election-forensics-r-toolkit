# Metodologija — Špiljkin i Kobak–Špiljkin–Pšeničnikov

## 1. Intuitivno objašnjenje

Modul obuhvata **tri povezana, ali različita postupka**. Prvi prikazuje raspodele izlaznosti i procenta glasova pobednika po biračkim mestima (BM). Oblik krive može ukazati na neuobičajene vrhove ili dugačke repove, ali ni odstupanje od pravilnog oblika ni njegova odsutnost sami po sebi nisu dokaz izbornih manipulacija. Politička geografija, selektivna mobilizacija i druge legitimne okolnosti mogu promeniti raspodelu.

Drugi postupak proverava da li se rezultati **neobično često nalaze veoma blizu celih procenata**, recimo 65%, 70% ili 91%. Pošto su izborni rezultati količnici celih brojeva, takvi vrhovi mogu nastati i sasvim slučajno. Zato Kobak, Špiljkin i Pšeničnikov (2016) porede posmatrani broj BM sa celobrojnim procentima sa hiljadama simulacija binomnog glasanja, uz očuvanje stvarne veličine svakog BM.

Treći postupak je **uslovna procena viška glasova**. Ako je odnos glasova pobednika i ostalih važećih glasova približno stabilan u izabranom referentnom delu raspodele izlaznosti, kriva ostalih glasova može se prilagoditi tom odnosu i ekstrapolirati ka većoj izlaznosti. Pozitivna razlika između stvarnih i očekivanih glasova pobednika predstavlja **modelsku procenu anomalnog viška**, a ne utvrđen broj falsifikovanih glasova. Pretpostavka može pasti zbog geografskih razlika, različite mobilizacije ili promena političkih preferencija.

## 2. Literatura i status reprodukcije

- **Opisne krive:** Kobak, Shpilkin i Pshenichnikov (2016), *Statistical fingerprints of electoral fraud?*, Significance 13(4), 20–23, DOI:10.1111/j.1740-9713.2016.00936.x. Originalne slike koriste intervale od 0,25 procentnih poena, površinu histograma jedan i nasumično pomeranje brojioca U(-0,5;0,5). Za manji broj BM u Srbiji podrazumevana širina 0,5 predstavlja **dokumentovano prilagođavanje**.
- **Test celobrojnih procenata:** Kobak, Shpilkin i Pshenichnikov (2016), *Integer percentages as electoral falsification fingerprints*, Annals of Applied Statistics 10(1), 54–73, DOI:10.1214/16-AOAS904. Originalni postupak koristi 0,1 procentni poen, histograme ponderisane **brojem upisanih birača**, i 10.000 Monte Karlo simulacija.
- **Procena viška glasova:** Špiljkinov neparametarski pristup uslovljen izlaznošću, uz dodatna javna objašnjenja procedure i funkcije `NonparamElectionForensics()` u EFToolkit-u. Dokumentacija: `https://cedarus.io/research/evolution-of-russian-elections`. **Dostavljeni PDF ne propisuje jedinstveni algoritam za treći postupak.** Zato su izbor referentnog raspona, način skaliranja, intervali izlaznosti i sabiranje pozitivnih odstupanja precizno definisani kao **implementacija scenarija u našem Toolkit-u**, a ne doslovno preuzeti estimator.

## 3. Podaci, izlaznost i kriterijumi podobnosti

Iz lista `Master` koriste se: E — upisani birači; B — važeći glasovi; C — svi ubačeni listići; W — glasovi pobednika izbora; identifikatori BM i teritorijalne jedinice. Nacionalni pobednik proverava se u listu `Options`. Osnovne kontrole zahtevaju cele, neprotivrečne vrednosti: 0 ≤ W ≤ B ≤ C ≤ E, E > 0, B > 0.

Primarna izlaznost je **100 C/E**, a dopunska analiza koristi **100 B/E**. Udeo glasova pobednika je **100 W/B** u oba slučaja. U originalnoj ruskoj studiji brojilac izlaznosti predstavljao je izdate listiće, a imenilac za procenat pobednika drugačije definisane ubačene listiće. Zato podaci iz Srbije ne predstavljaju numerički potpuno identičan ugovor izvornog članka; to ograničenje mora ostati vidljivo u rezultatu.

BM sa E < 100 isključena su iz tri glavna postupka, ali ostaju u CSV evidenciji kvaliteta. Opisni histogrami i scenario viška glasova isključuju BM sa izlaznošću ili rezultatom pobednika od 100%. Celobrojni test isključuje BM sa **posmatranim** procentima većim od 99% (tačno 99% je dozvoljeno). Opcioni nivoi su nacionalni, okružni i opštinski; mali lokalni uzorci daju nestabilne procene. Početna Monte Karlo analiza izvodi se samo na nacionalnom nivou.

## 4. Opisni histogrami

Za svako BM definiše se X_i kao izlaznost ili rezultat pobednika. Opcionalno se samo za sliku brojiocu dodaje ε_i ~ U(-0,5;0,5), što ublažava artefakte deljenja celih brojeva. **Izvorni celobrojni podaci ostaju neizmenjeni za Monte Karlo test i procenu viška.**

Centralne tačke intervala širine h su b_k=kh. Ako u intervalu k leži n_k od ukupno N podobnih BM, gustina je

    f_hat(b_k) = n_k / (N*h).

Zbir površina je jedan. Za srpske podatke podrazumevano je h=0,5 procentnih poena; originalna slika koristi h=0,25. Izbor grafičkog h **ne utiče** na zasebno definisane intervale testiranja celobrojnih anomalija.

## 5. Test celobrojnih procenata i Monte Karlo

Za BM i posmatramo izlaznost T_i i procenat pobednika R_i. BM ulazi u statistiku q kada je bar jedna od ove dve vrednosti udaljena najviše ω = 0,05 procentnih poena od najbližeg celog broja. Računaju se i odvojeni rezultati za izlaznost i pobednika, kao i kontrola udaljenosti od polovine procenta.

U svakoj Monte Karlo replici simuliraju se **nezavisno**:

    G_i^(r) ~ Binom(E_i, G_i/E_i),
    W_i^(r) ~ Binom(B_i, W_i/B_i).

Zatim se izračunaju simulirani procenti i isti kriterijum blizine celog broja. Ugovor o nazivima G, E, B i W odgovara našim RZS podacima; ne simuliraju se celi novi zapisnici već odvojene marginalne promenljive, kao u radu. Simulacije imaju fiksno polazno seme. Izvoz sadrži posmatrani q, srednju vrednost, SD, odstupanje, z-vrednost, Monte Karlo p-vrednost i simulacione kvantile 0,5% i 99,5%. P-vrednost sa R simulacija ima donju granicu 1/(R+1).

Histogrami testa imaju širinu **0,1 procentnih poena**; visina intervala je **zbir upisanih birača E_i**, ne broj BM. Siva oblast na grafikonu predstavlja tačkaste simulacione kvantile po intervalima, a ne simultani interval pouzdanosti cele krive. Podrazumevano za eksplorativnu analizu koristi se R=999, a za završno računanje preporučuje se R=10.000, kao u izvornoj studiji. Posmatrani i simulirani procenti veći od 99% ne računaju se u broj celobrojnih BM.

## 6. Uslovni model viška glasova

Za svaki interval izlaznosti k saberu se glasovi pobednika W_k i ostali važeći glasovi O_k. U unapred određenom referentnom području C=[a,b] izračunava se

    alpha = suma(W_k, k u C) / suma(O_k, k u C).

Očekivana kriva pobednika je alpha * O_k, a razlika d_k = W_k − alpha*O_k. U ovoj verziji sabiraju se **pozitivni delovi** razlike samo iznad gornje granice referentnog područja:

    A_+ = suma[max(d_k,0), za t_k>b].

To je scenarijska procena pod pretpostavkom stabilnog odnosa glasova, a ne utvrđen obim nezakonitih glasova.

**Usklađenost grafikona sa procenom.** Sivi **poligoni koji prate obe krive** prikazuju samo pozitivne razlike desno od gornje granice referentnog područja. Između centara susednih intervala crvena i plava kriva linearno se interpoliraju, a njihove presečne tačke umeću se u granice poligona. Tako nema delova zasenčenja izvan krivih niti praznina uz njihove pozitivne razlike. Vrednost `positive_residual_votes` u CSV fajlu predstavlja **zbir pozitivnih odstupanja u diskretnim intervalima izlaznosti**, a **ne geometrijski integral** zasenčenih poligona. Osa Y prikazuje hiljade glasova, a podnaslov zaokruženi zbir. Plava kriva **nije** Monte Karlo očekivanje: ona predstavlja ostale važeće glasove skalirane koeficijentom `alpha` iz referentnog opsega. Nasuprot tome, siva oblast na odvojenim Monte Karlo histogramima označava simulacione kvantile. Slikovni prikaz ne dokazuje uzrok odstupanja niti broj nezakonito dodatih glasova. Automatski referentni raspon centriran je oko najčešćeg intervala izlaznosti između 20% i 80%. Ova automatska opcija ima oznaku `AUTO_MODAL_DESCRIPTIVE`: **nema garancije da je taj deo raspodele neizmenjen i pouzdan**. Poželjno je unapred odabrati teorijski opravdan raspon i proveriti alternativne poluširine od 5; 7,5 i 10 procentnih poena. Nedovoljan broj BM ili glasova u referentnom delu onemogućava procenu. Visok koeficijent varijacije odnosa W_k/O_k označava upozorenje, ne formalni test.

## 7. Reproduktivnost i ograničenja

CSV fajlovi sadrže sve kriterijume uključivanja, originalne i eventualno pomerene procente za grafikon, frekvencije i pondere intervala, simulacione rezultate po iteraciji, kvantile i statistike testa, izbor referentnog raspona, pojedinačna odstupanja i analizu osetljivosti. Uporedni grafici prikazuju **pobednike pojedinačnih izbora**, što ne znači nužno da se poredi jedna ista lista.

Ovaj modul ne odlučuje da li je došlo do prevare, ne određuje krivicu pojedinačnih BM i ne izvodi pravno važeću procenu nelegalnih glasova. Pre interpretacije potrebni su provera zvaničnih ukupnih rezultata, lokalne heterogenosti, izvornih zapisnika i drugi nezavisni izvori dokaza.
