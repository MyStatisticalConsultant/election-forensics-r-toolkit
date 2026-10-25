# Election Forensics R Toolkit — v1.11.0

Datum izdanja: 26. oktobar 2026.

## Dodato

- **Približna normalnost v0.1.2**, nezavisni modul u `modules/approximate_normality/`, zasnovan na radu Klimek, Yegorov, Hanel i Thurner (2012), *Statistical detection of systematic election irregularities*, PNAS, https://doi.org/10.1073/pnas.1210722109.
- Izvorna logaritamska stopa glasova pobednika `log(W/(E-W))`, za BM sa `0 < W < E`; standardizacija unutar izbora/oblasti na nultu sredinu i jediničnu uzoračku standardnu devijaciju.
- Grafikoni po uzoru na sliku 2, sa **empirijskim verovatnoćama histogramskih intervala fiksne širine povezanim dužima**, bez KDE izglađivanja. Podrazumevana širina standardizovanog intervala je 0,2; širina intervala i vidljivi raspon x-ose mogu se menjati.
- Grafikoni na engleskom i srpskom (latinica) za poređenje izbora i grupa unutar izbora; sve podobne BM i nacionalno definisane grupe Small/Large koriste istu referentnu standardizaciju. Odvojena analiza osetljivosti uključuje BM sa manje od 100 upisanih birača, dok primarna analiza sledi pravilo izvornog rada `E >= 100`.
- Jasno označena crna referentna standardna normalna raspodela `N(0,1)`, odgovarajuće boje u legendi, automatsko prelamanje dužih legendi i dvojezični opisi.
- Numerički CSV izlazi: isključenja BM, transformisane vrednosti, referentne sredine i standardne devijacije, brojevi i verovatnoće po intervalima, očekivane normalne verovatnoće, asimetrija, obična spljoštenost, Jarque–Bera test i p-vrednosti, kao i dijagnostika izvoza.
- Sintetički numerički i grafički testovi, integracija sa stvarnim bazama i provera izvoza; dvojezični metodološki dokumenti i vodiči za rezultate.
- Ažurirani korenski registar, instalacija, tok rada, podaci za citiranje, `.gitignore` i kontrolne sume. Kod ranijih analitičkih modula nije menjan.

## Opseg i tumačenje

Modul opisuje približnu normalnost i odstupanja od normalne referentne raspodele. **Ni nenormalna raspodela niti statistički značajan test normalnosti ne predstavljaju dokaz izborne prevare.** Geografska heterogenost, agregacija podataka i legitimni izborni mehanizmi mogu promeniti oblike raspodela. Modul **ne** procenjuje parametre `f_i` i `f_e` posebnog parametarskog modela izborne manipulacije.

Videti [README modula](modules/approximate_normality/README_SER.md), [metodologiju](modules/approximate_normality/METHODOLOGY_SER.md) i [prethodne napomene](RELEASE_NOTES_SER_v1.10.0.md).
