# Metodologija i statističko tumačenje

[English](METHODOLOGY.md)

## Ulaz i sortiranje

Koriste se standardne promenljive iz `RZS_data_preparation.R`: `E` (upisani birači), `C` (listići u kutiji), `B` (važeći listići) i `Option_XX_votes` (glasovi kandidata ili izborne liste). Izlaznost BM je `100*C/E`. BM se ređaju rastuće po izlaznosti, a u slučaju jednakih vrednosti po `Station_key`. Izvorne vrednosti se ne menjaju i izlaznost se ne ograničava na 100%. Kriva je **kumulativni zbir glasova kroz BM sortirana po izlaznosti**, a ne vremenska serija niti funkcija raspodele izlaznosti.

## Dve normalizacije

Za sortirana BM `i=1,...,n`, broj važećih listića `B_i` i glasove opcije `v_ij`, neka je `S_j(k)=Σ(i≤k) v_ij`.

- **U odnosu na sve važeće listiće:** `Y_j^valid(k)=100*S_j(k)/Σ_i B_i`. Krajnja vrednost je udeo glasova opcije u datoj grupi. Ako opcija ima 400 od ukupno 1.000 važećih glasova, završetak krive iznosi 40%.
- **U odnosu na glasove same opcije:** `Y_j^option(k)=100*S_j(k)/Σ_i v_ij`. Kriva sa pozitivnim brojem glasova završava se na 100%. U prethodnom primeru na 100%. Ako opcija nema glasova, odnos je nedefinisan (`NA`).

Druga normalizacija uklanja razlike u ukupnom nivou podrške i prikazuje *na kojem delu skale izlaznosti opcija prikuplja svoje glasove*. Visina krivih normalizovanih po opciji ne predstavlja odnos ukupne podrške između opcija. Razlike između krivih nisu automatski statistički značajne. BM sa nula važećih glasova ne doprinose zbiru glasova, ali, ako su inače prihvaćena, ostaju u broju BM.

## Osam grupa i odnos prema Main

`GE100` je tačno `Main` (E≥100 i ispunjeni drugi QC uslovi); `LT100` su BM sa `Under_100=TRUE` iz `Master` koja ispunjavaju sve ostale QC uslove; `ALL` je zbir ova dva međusobno isključiva dela. `SMALL/MIDDLE/LARGE` predstavljaju podelu `Main` prema promenljivoj `Size` na osnovu kumulativnog udela upisanih birača, uz zajednički tretman jednakih veličina BM. `JHK_SMALL/JHK_LARGE` su druga, dvodelna podela prema `Size_JHK`, ispod 20. percentila veličine BM i ostatak. Sama oznaka JHK **nije potpuni JHK statistički test**, niti uključuje njegovu prostornu standardizaciju. Osam prikazanih grupa nisu osam međusobno nezavisnih uzoraka.

## Geografski rezimei

Brojevi upisanih, listića i glasova sabiraju se **pre** izračunavanja procenata. Okruzi se razlikuju šifrom `District_code`, a opštine složenim ključem `District_code|Municipality_code`. Granice veličina BM ostaju nacionalne, a ne računaju se ponovo po opštinama. Poređenje između geografskih jedinica i dalje može biti opterećeno različitom strukturom stanovništva i ekološkom zabludom.

## Opcione metrike T90/T95

Istraživač unapred određuje dva **nepreklapajuća skupa** kolona glasova. Za svaki uzorak izračunava se kvantil izlaznosti 0,90 ili 0,95 (R tip 7). Zadržavaju se BM sa izlaznošću većom ili jednakom pragu (uključujući izjednačenja) i `B>0`. Ako su `A_i` i `D_i` zbir glasova dva bloka, izračunavaju se `Mean_station_margin_pp=mean_i[100*(A_i−D_i)/B_i]` i `Pooled_margin_pp=100*(Σ A_i−Σ D_i)/(Σ B_i)`, uz broj BM i prag izlaznosti. Različito ponderisanje po veličini BM daje različite procene. Zbog izjednačenja rep može obuhvatiti nešto više od deklarisanih 5%/10%. Ne prikazuje se permutaciona p-vrednost jer odvojeno mešanje udela blokova, kao u starom skriptu, ne čuva zavisnost kompozicionih podataka i nema obrazloženu nultu hipotezu.

## Tumačenje i ograničenja

Koncentracija glasova na BM sa visokom izlaznošću može poticati od regionalne i demografske strukture, kampanje, mobilizacije, razlika u veličini BM, legitimnih posebnih kategorija ili greške zapisnika. Kriva je eksploratorni grafikon, **ne dokaz izborne prevare**. Dalja provera obuhvata uporedive opštine/okruge, kontrolu kontekstualnih faktora, izveštaje posmatrača, zvanične zapisnike i, kada je primereno, reviziju ili ponovno brojanje. Modul ne sprovodi Benfordov test, FMM model, formalni JHK test, kauzalnu analizu niti pravno utvrđivanje nepravilnosti.

**Poreklo:** preuzeta je ideja dve porodice grafikona i opisnih repnih metrika iz tri ranija korisnikova skripta; standardizovani ulaz, osam grupa, obe normalizacije, dva jezika i uklanjanje neosnovane permutacione inferencije predstavljaju novu specifikaciju modula.
