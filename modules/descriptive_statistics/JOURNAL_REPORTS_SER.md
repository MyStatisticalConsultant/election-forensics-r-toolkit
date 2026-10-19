# Tabele za naučne publikacije — v0.3.1

[English](JOURNAL_REPORTS.md) · [Opširno objašnjenje tabela (Word)](docs/publication/TABLES_SER.docx)

Skripta generiše **jedan Word dokument za svake izbore**. Prve četiri nacionalne tabele mogu poslužiti za glavni deo naučnog rada, a kompletne okružne i opštinske tabele namenjene su **dopunskim prilozima**. Nijedna tabela, zvezdica ili niska p-vrednost sama ne dokazuje izbornu prevaru.

| Tabela | Sadržaj | Uloga |
|---|---|---|
| Tabela 1 | Upisani, ubačeni, važeći i nevažeći listići; udeli grupa u referentnoj grupi `All` | Obim uzorka i računska konzistentnost |
| Tabela 2 | Upisani, broj BM, prosečan broj upisanih po BM | Uticaj veličine BM na uporedivost |
| Tabela 3 | Izlaznost, udeli prve dve nacionalne opcije, efektivan broj opcija, robusne mere | Koncentracija, rasipanje i poređenje |
| Tabela 4 | **Sprovedeni** nacionalni Kruskal–Volisovi i Vilkoksonovi testovi sa p i BH q | Razlike distribucija, bez zaključka o uzroku |
| Prilog A | Za okruge/opštine: upisani, važeći, glasovi i udeli nacionalno prve/druge opcije po grupama | Pregled područja |
| Prilog B | Broj BM, izlaznost, medijana/IQR, udeo pobednika, Spirmanova korelacija i p | Robusni obrazac i lokalna povezanost |
| Prilog C | **Sprovedeni** testovi po području, N, p, BH q i značajnost | Praćenje inferencijalnih signala |

Nacionalno prve dve opcije ostaju iste u svim oblastima. Red `100 or more` je **odmah posle `All`**; označava tačno `Main`. `Size` i `Size_JHK` odvojeno dele `Main`. Glasovi/listići su celi brojevi, stope i deskriptivne mere imaju **dve decimale**, a p/q tri decimale ili `<0.001`. CSV čuva punu numeričku preciznost.

## Šta testovi proveravaju

Kruskal–Volisov test poredi izlaznost i udeo pobednika po BM u **disjunktnim Small/Middle/Large** grupama, a Vilkoksonov test rang-suma u **JHK Small/JHK Large**, pri čemu je Large celokupna dopunska grupa. Test je moguć samo uz odgovarajući broj BM i varijabilnost; `NA` za p znači da nije mogao da se izračuna. BH korekcija primenjuje se unutar `Level × Outcome × Test`, preko oblasti. Korelacije agregata imaju **drugu BH porodicu**, unutar pojedinačne matrice.

Pre predaje časopisu proveriti prelom Word tabela, naslove, brojeve stranica, zaglavlja, srpska slova, širinu tabela i pravila konkretnog časopisa. Raniji nezavisno generisani Word izveštaji služe za poređenje i nisu nužno identični poslednjem R izvozu. Definicije: [METHODOLOGY_SER.md](METHODOLOGY_SER.md), [DATA_DICTIONARY_SER.md](DATA_DICTIONARY_SER.md), [CORRELATIONS_SER.md](CORRELATIONS_SER.md) i četiri Word vodiča iz `docs/publication/`.
