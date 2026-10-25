# Vodič kroz numeričke i grafičke rezultate

[English](OUTPUT_GUIDE.md) · [README](README_SER.md) · [Metodologija](METHODOLOGY_SER.md)

Izlazi su u lokalnom folderu `approximate_normality_outputs/` i izuzeti su iz Git repozitorijuma.

| Putanja | Sadržaj |
|---|---|
| `run_configuration.csv` | Parametri izvršavanja i metodološka podešavanja. |
| `cross_election_manifest.csv` | Status poređenja na istom području, broj izbora i broj uporednih grafikona. |
| `run_manifest.csv` | Jedan zapis za izbore × područje: PASS/SKIP i razlog, broj osnovnih/ispod-100 BM, broj slika. |
| `normality_statistics.csv` | Za svaku grupu: n, sredina z, SD z, asimetrija, Pearsonova spljoštenost, višak spljoštenosti, Jarque–Bera statistika i asimptotska p-vrednost. |
| `<election>/station_qc.csv` | Sva BM iz lista Master, glasovi i ν, podobnost, naziv izvorne kolone pobednika i razlozi isključenja. |
| `<election>/source_qc_summary.csv` | Ukupni brojevi podobnih BM, BM sa E<100 i isključenih. |
| `<election>/<level>/<area>/standardization_parameters.csv` | Sredina i uzoračka SD promenljive ν nad svim BM sa E≥100 u datom području. |
| `<election>/<level>/<area>/station_level_log_rates.csv` | Vrednosti ν i z za sva BM u području, pripadnost grupama i QC oznake. |
| `<election>/<level>/<area>/within_election_histogram_bins.csv` | Grupe All/Small/Large: indeks i granice intervala, broj BM, n, empirijska i teorijska normalna verovatnoća. |
| `<election>/<level>/<area>/under100_sensitivity_histogram_bins.csv` | Ista struktura za odvojeno poređenje osnovnog uzorka i BM sa E<100. |
| `cross_election/<level>/<area>/cross_election_histogram_bins.csv` | Zajednički intervali i frekvencije svakog izbora za isto područje. |
| `<election>/<level>/<area>/Figure2_style_within_EN.png` i `_SR.png` | Poređenje grupa u okviru jednih izbora. |
| `<election>/<level>/<area>/Figure2_style_under100_EN.png` i `_SR.png` | Posebna analiza osetljivosti za E<100. |
| `cross_election/<level>/<area>/Figure2_style_cross_elections_EN.png` i `_SR.png` | Poređenje izbora, kada postoje najmanje dva izbora na području. |

`<election>` je stabilna interna oznaka, npr. `presidential_2017`; na javnim slikama podvlake se izostavljaju, a oznake na srpskom se prevode. `<level>` može biti `national`, `district` ili `municipality`; `<area>` je kod ili `national`.

Svi grafikoni na oba jezika imaju posebnu oznaku u legendi **Standardna normalna raspodela, N(0,1)** za crnu liniju. Ona predstavlja očekivanu **verovatnoću po intervalu**, a ne neprekidnu teorijsku funkciju gustine. Boje oznaka u legendi podudaraju se sa empirijskim krivama; referentna oznaka je crna. Boje oznaka u legendi podudaraju se sa empirijskim krivama; referentna oznaka je crna.

### Važne kolone

`nu` = `log(W/(E-W))`. `z` = `(nu-mean_nu)/sd_nu`; sredina i SD računaju se za sva osnovno podobna BM sa E≥100 u okviru istih izbora i područja. `bin_index` = `floor(z/BIN_WIDTH + 0.5)`; `x` = sredina intervala; `left` i `right` = granice; `count` = broj BM; `n` = broj BM u toj **grupi**; `probability` = `count/n`; `normal_probability` = `pnorm(right)-pnorm(left)` za N(0,1). CSV čuva i ekstremne intervale van raspona prikazane slike. Normalna referenca je **verovatnoća intervala**, a ne gustina `dnorm()`.

`kurtosis` je Pearsonova spljoštenost (referentna vrednost normalne raspodele = 3). `jb_p_value` koristi asimptotsku hi-kvadrat(2) raspodelu i **nije p-vrednost testa izborne manipulacije**. Intervali bez BM eksplicitno su sačuvani sa brojem nula.

### Provera

Prvo pregledati `run_manifest.csv`, zatim `source_qc_summary.csv` i `standardization_parameters.csv`. Za svaku grupu mora da važi `sum(count)=n` i `sum(probability)=1`, do numeričke preciznosti. Proveriti razloge izuzimanja i ko je nacionalni pobednik prema listu `Options`. Posle promene pripremljenih baza ponoviti analizu.

Napomena: fajlovi iz prethodnih izvršavanja mogu ostati u izlaznom folderu ako ih naredno podešavanje preskoči. Merodavni su poslednji manifesti; pre bitno drugačije analize arhivirati ili očistiti raniji izlazni folder. Modul automatski ne briše stare fajlove.
