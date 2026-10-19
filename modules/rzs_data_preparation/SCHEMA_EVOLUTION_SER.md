# Bezbedno proširivanje strukture izvornih RZS tabela

**Trenutno ograničenje:** `RZS_data_preparation.R` koristi pozicione šablone 2017/2022 i pretpostavlja da su **sve kolone posle poslednje osnovne varijable** glasovi kandidata ili lista (2017: od 15. kolone; 2022: od 11.). Ako RZS ubaci dodatne varijable, npr. *glasao uz pomoć*, *glasao van biračkog mesta*, takva kolona može biti **pogrešno protumačena kao izborna opcija**. Mogu se pojaviti lažne povrede zbira glasova ili pogrešni nazivi opcija, iako su izvorne `V1...` kolone sačuvane. Nije bezbedno pretpostaviti kompatibilnost kasnijih datoteka bez pregleda sheme.

## Predloženo rešenje (plan, još nije implementirano)

1. Uvesti tabelu mapiranja po izborima: izvorni naziv/položaj → kanonska promenljiva, tip, jedinica, obaveznost i dozvoljene nedostajuće vrednosti.
2. Eksplicitno navesti kolone glasova **svih** kandidata/izbornih lista; ne prihvatati automatski sve kolone desno od važećih glasova.
3. Dodati opcione administrativne promenljive kao `Assisted_voters`, `Outside_station_voters` i sl., čuvati originalne RZS nazive i razlikovati nedostajuću vrednost (`NA`) od zabeležene nule.
4. Kod nepoznatih ili dvosmislenih kolona zaustaviti uvoz i prikazati objašnjenje, umesto da skript proizvede prividno validne podatke.
5. Posebne provere kombinovanja novih pokazatelja uvoditi samo na osnovu zvaničnih definicija. Na primer, nije nužno da se kategorije glasanja uz pomoć i van BM međusobno isključuju.
6. Verzije sheme i primere testirati na prethodno proverenim izbornim datotekama pre objavljivanja.

Ovo proširenje pripada prvom modulu `RZS_data_preparation.R`. Deskriptivni modul bi zatim koristio nove kanonske promenljive, bez ponovne izgradnje arhitekture.
