# Istorija verzija

[English](CHANGELOG.md)

## 0.1.4 — 23. oktobar 2026. (objedinjeno izdanje za GitHub)

- Objedinjene sve razvojne ispravke od v0.1.1 do v0.1.3.4 u jednoj celovitoj strukturi modula. Postojeću javnu verziju v0.1.0-dev treba zameniti u celosti; međuzakrpe nisu potrebne.
- Dvojezični naslovi, lokalizacija oblasti, posebne RZS kategorije, oznake y-ose na svakih 10 procentnih poena, razdvojene B slike i pregledni A podnaslovi i legende.
- Prazne grupe u teritorijalnim tabelama; 0 BM = bez grafikona, 1 BM = tačka, 2+ BM = kriva; selektivno uklanjanje zastarelih slika.
- Usklađene oznake izdanja, vodiči, testovi, manifest i citiranje. Analitički R kod i statističke formule isti su kao u v0.1.3.4-dev.
- Autor je potvrdio PASS za sva tri podržana izbora; detaljni konzolni log postoji za parlamentarne 2022, a predsednički su potvrđeni bez zasebnih logova (VALIDATION_SER.md).

## 0.1.1-dev — 21. oktobar 2026. (samo grafička korekcija)

- Puna imena lista/kandidata u B-grafikonima premeštena su iz glavnog naslova u podnaslov na izabranom jeziku, uz prelamanje teksta.
- Pretrpani B-grafikon sa osam krivih podeljen je na standardne i JHK grupe, uz alternativni prikaz na dva panela.
- Legenda A-grafikona automatski je u dva reda za tri ili više opcija; puna imena se prelamaju.
- Zastarele `B_<opcija>_combined` PNG/PDF datoteke uklanjaju se prilikom ponovnog iscrtavanja.
- Dodati su testovi izgleda i izvoza, kao i dopunjena dvojezična uputstva.
- Nisu menjane formule ni računanje podataka; nove slike treba proveriti u RStudio.

## 0.1.0-dev — 19. oktobar 2026.

- Tri ranija skripta spojena su u **jedan** izvršni R skript sa detaljno komentarisanim korisničkim odeljkom EDITABLE, funkcijama i računskim blokovima.
- Stari nazivi i ad hoc rangiranje BM zamenjeni su standardnim `Main`, `Master`, `Options`, `Size` i `Size_JHK` iz `RZS_data_preparation.R`.
- Ugrađeno je osam grupa BM, numeričko računanje svih opcija, dve normalizacije krivih, dve porodice grafikona (zajednički i panelni), dva jezika, korisnički nazivi i palete, opcioni geografski grafikoni, metapodaci i testovi.
- T90/T95 su zadržani **isključivo kao opisne metrike**, uz izričito definisanje blokova; neodbranjive permutacione p-vrednosti su uklonjene.
- Dodata je dvojezična dokumentacija za GitHub sa detaljnim korisničkim uputstvom.
- **Validacija:** očekuje se kompletno lokalno RStudio testiranje tri pripremljene baze i vizuelni pregled; ovo još nije konačno istraživačko izdanje.

## v0.1.2-dev

- Sve A figure sada prikazuju puni naziv grupe biračkih mesta u drugom redu glavnog naslova.
- Oznake na y-osi za A i B figure sada se prikazuju na svakih 10 procentnih poena.
- B figure sada imaju pune oznake na vertikalnoj osi (0%, 10%, 20%, ...).
- Engleske i srpske oznake na slikama usklađene su sa dogovorenim punim nazivima grupa.

## v0.1.3-dev

- A figure sada prikazuju puni naziv grupe biračkih mesta kao drugi red u subtitle stilu (manji font, bez bold-a).
- Glavni naslovi A i B figura sada koriste lokalizovane nazive izbora i oblasti, npr. "parliamentary 2022 Serbia" i "predsednički 2017 Kolubarski okrug".
- Srpski glavni naslovi više ne koriste sirove interne oznake poput "parliamentary_2022 National".

## v0.1.3.1-dev — usklađivanje funkcije i testa (2026-10-23)

- Test `tests/test_graphics_layout.R` sada poziva važeću funkciju `b_titles()` sa šest argumenata. Stari test je koristio četiri argumenta i davao grešku `subscript out of bounds`.
- Funkcija `pretty_election_label()` sada jasno prijavljuje nepoznat tip izbora.
- Kod engleskih naziva okruga zamenjuje se završno `okrug` sa `district`, bez dupliranja.
- Prošireni testovi SR/EN naslova i podnaslova; statističke formule nisu menjane.


## v0.1.3.2-dev — posebne administrativne kategorije RZS (2026-10-23)

- Naslovi grafikona koriste `District_code` za posebne kategorije: **33** → Inostranstvo/Overseas i **55** → Zavodi za izvršenje krivičnih sankcija/Prisons, bez nastavka okrug/district.
- Za šifre **25–29** zadržava se RZS naziv; postojeći nastavak „okrug” se po potrebi prevodi, ali se novi teritorijalni nastavak ne dodaje automatski. Šifre same po sebi ne dokazuju fizičku lokaciju BM.
- Šifra okruga prosleđuje se i A i B naslovima; prošireni su testovi za obične i posebne kategorije na oba jezika. Numerički rezultati i ulazne baze nisu menjani.

## v0.1.3.3-dev — Prikaz grupa sa jednim opažanjem

- Sprečena ponovljena upozorenja `geom_line()` kada grupa u izabranoj oblasti sadrži samo jedno validno BM.
- Jedino opažanje prikazuje se tačkom, bez veštačkog iscrtavanja kumulativne linije; numerička analiza nije menjana.
- Dodat je parametar `SINGLE_POINT_SIZE` u EDITABLE delu i test `tests/test_single_station_plots.R`.
- Jedna sažeta poruka po oblasti navodi grupe sa jednim BM, uključujući grupu `Large` za Inostranstvo 2022.

## v0.1.3.4-dev — eksplicitna obrada praznih grupa biračkih mesta

- Teritorijalni rezimei obuhvataju svaku prisutnu oblast × svih osam grupa BM × svaku izbornu opciju, čak i kada određena grupa nema nijedno BM.
- Za praznu grupu beleži se `Stations=0`, zbirni brojači su nula, a nedefinisani procenti imaju vrednost `NA`. U teritorijalnim CSV i Excel tabelama `NA` se zapisuje eksplicitno.
- Program jednom po oblasti prijavljuje izabrane grupe sa 0 BM, a ne jednom za svaku sliku i jezik.
- Pre ponovnog crtanja brišu se samo stare Klimek A/B PNG/PDF slike **te oblasti**. Prazna grupa nema grafikon; druge oblasti i datoteke ostaju netaknute.
- Nula BM: nema krive; jedno BM: tačka; dva ili više: linija. Statističke formule i nacionalne grupe se ne menjaju.
- Dodat je `tests/test_zero_station_groups.R` i proširen `tests/check_exports.R`.
