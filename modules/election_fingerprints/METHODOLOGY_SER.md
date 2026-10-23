# Metodologija: posmatrani izborni otisci

[English](METHODOLOGY.md) · [Modul](README_SER.md)

**Izvorni algoritam.** U slici 1 rada Klimek i saradnika (2012) prikazani su dvodimenzionalni **histogrami broja izbornih jedinica** prema izlaznosti (x) i udelu glasova pobednika (y). Autori isključuju jedinice sa manje od 100 upisanih birača. Modul zato koristi već pripremljeni `Main` uzorak i prebrojava jedno BM u jednoj ćeliji. Primarni histogram nije KDE, nema ponderisanja brojem birača, niti rekonstrukcije glasova iz procenata.

Uz `E` (upisani), `B` (važeći), `C` (ubačeni listići) i `W` (glasovi izabrane opcije), primarno računamo `x=100B/E`, `y=100W/B`. Posebno obeležena analiza osetljivosti koristi `x=100C/E`, a `y` ostaje nepromenjeno. Uslovi su `E>=100`, `B>0`, `B<=E`, `0<=W<=B`; za osetljivost dodatno `0<=C<=E`. Neispravne ili nedostajuće vrednosti se evidentiraju, bez zaokruživanja ili „popravljanja” na 100%.

Pobednik se određuje na **nacionalnom nivou** iz `Options.Total_votes` i ostaje isti na svim nižim nivoima. Moguće je ručno odabrati drugu izbornu opciju, uz jasno označavanje na grafikonu.

Dvodimenzionalna mreža obuhvata 0–100% na obe ose; podrazumevano `HIST_BINS=50` znači širinu ćelije 2 procentna poena. Tačno 100% ide u poslednju ćeliju. Zbir ćelija mora biti jednak broju BM uključenih u prikaz. **Veličina ćelija nije potpuna specifikacija preneta iz rada**, već transparentna implementaciona odluka.

**Dopunski prikazi.** KDE (`MASS::kde2d`) predstavlja zaglađenu gustinu, normalizovanu na sopstveni maksimum; legenda 0–1 ne iskazuje ni broj BM ni verovatnoću prevare. KDE uz granice 0% i 100% može biti pristrasan. Marginalne gustine i histogrami sa strane preuzeti su iz vizuelnog primera korisnika, ne iz originalne slike 1. Izlaznost po ubačenim listićima označena je kao analiza osetljivosti.

**Šta nije implementirano:** parametarski model procene `f_i` i `f_e`, simulacija poštenog scenarija, logaritamske raspodele i formalni testovi. Tri klastera iz starog `Mclust` skripta nisu ekvivalentni mehanizmima prevare u radu Klimek i saradnika.

**Okruzi i opštine:** analiziraju se pojedinačna BM unutar oblasti, a ne zbirni redovi. Heterogenost stanovništva i političkih preferencija može menjati oblike otisaka i bez izborne manipulacije. Oblik otiska nije samostalan dokaz prevare.

Audit izostavljanja, tačne mreže, MD5 izvorne baze i konfiguracija omogućavaju ponovljivost. Izvor: Klimek, P., Yegorov, Y., Hanel, R., & Thurner, S. (2012). *Statistical detection of systematic election irregularities*. PNAS 109(41), 16469–16473. https://doi.org/10.1073/pnas.1210722109


## Unapred definisane grupe prema veličini BM

Pored neizmenjenog izbornog otiska uzorka `Main`, podrazumevano se generišu zasebne slike za tri grupe `Size` (Mala/Srednja/Velika) i dve grupe `Size_JHK` (JHK mala/velika). Grupe su definisane i proverene u modulu za pripremu RZS podataka; pragovi veličine se **ne izračunavaju ponovo po okruzima ili opštinama**. Svaka klasifikacija zasebno obuhvata sve prihvaćene BM date oblasti, dok se dve klasifikacije međusobno preklapaju. Ovo je opisna stratifikacija, a ne novi test ni parametarski model prevare. Za sve otiske važi uslov najmanje 100 upisanih birača.

### Središta rubnih ćelija dopunske KDE mreže

Interval 0–100% podeljen je na `KDE_GRID` jednakih raster ćelija po osi. KDE se ocenjuje u **središtima** ćelija (za mrežu 200×200: 0,25%, 0,75%, …, 99,75%). Izvorna opažanja, Gausov KDE, izbor širine jezgra i primarni dvodimenzionalni histogram ostaju nepromenjeni. Time `geom_raster()` više ne odbacuje 796 rubnih ćelija čija su središta ranije bila na krajnjim granicama. Rubna pristrasnost uobičajene Gausove KDE i dalje postoji: ovo je ispravka prikaza, a ne statistička korekcija rubne pristrasnosti.

### Ispravka granica samo u grafičkom prikazu

KDE se i dalje računa funkcijom `MASS::kde2d` u središtima ćelija mreže 200×200. Ose 0–100% se sada postavljaju pomoću `coord_equal(xlim=c(0,100), ylim=c(0,100), expand=FALSE)`, **bez čvrstih granica u `scale_x/y_continuous`**, kako ggplot ne bi odbacivao rubne raster redove. Estimator i numeričke KDE vrednosti ostaju isti. Test je proširen sa 50×50 na podrazumevanu mrežu 200×200 jer je raniji manji test prolazio uprkos upozorenjima pri punom izvršavanju.
