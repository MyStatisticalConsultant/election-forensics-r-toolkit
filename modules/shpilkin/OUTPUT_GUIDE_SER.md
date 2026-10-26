# Objašnjenje izlaznih fajlova — shpilkin

Svi rezultati nastaju u `shpilkin_outputs/` (isključeno iz Git-a). CSV fajlovi su UTF-8, sa imenima kolona; nedostajuće vrednosti nisu nule.

U korenu izlaza:
- `run_configuration.csv` — parametri, seme, širine intervala, definicije i metodološke pretpostavke.
- `export_manifest.csv` — spisak izbora, definicija izlaznosti i teritorijalnih oblasti, veličine uzorka i status simulacija.
- `national_comparison_histograms.csv` — svi intervali i frekvencije za poređenje izbora (prva zadana definicija izlaznosti).
- `National_comparison_EN.png` i `_SR.png` — dvojezični uporedni dijagrami, najviše tri izbora u redu legende.

Za svaki izbor, definiciju izlaznosti i geografsku oblast:
- `station_level_qc.csv` — svi ulazni brojevi, procenti, kriterijumi podobnosti i razlozi isključenja; **BM sa E<100 ostaju u evidenciji**.
- `quality_summary.csv` — veličina uzoraka po postupku, ne predstavlja nezavisno usklađivanje sa zvaničnim ukupnim rezultatima RZS.
- `descriptive_station_rates.csv` — originalni i eventualno slučajno pomereni procenti **samo za prikaz**.
- `descriptive_turnout_bins.csv`, `descriptive_winner_bins.csv` — granice i centri intervala, broj BM, verovatnoća i gustina.
- `Descriptive_turnout_EN/SR.png`, `Descriptive_winner_EN/SR.png` — opisni histogrami sa podesivom širinom intervala, podrazumevano 0,5 procentnih poena.
- `integer_mc_summary.csv` — broj BM blizu celih procenata, simulaciona srednja vrednost, SD, odstupanje, z, kvantili, Monte Karlo p-vrednost i kontrola polucelobrojnih procenata.
- `integer_mc_replicates.csv` — rezultat svake Monte Karlo iteracije.
- `integer_turnout_mc_histogram.csv`, `integer_winner_mc_histogram.csv` — **ponderi E**, originalni intervali od 0,1 procentni poen, simulaciona srednja vrednost i tačkasti intervali 0,5%–99,5%. Jedinica u CSV-u je broj birača, na slici milioni.
- `Integer_MC_turnout_EN/SR.png`, `Integer_MC_winner_EN/SR.png` — posmatrana kriva, očekivana kriva i simulaciona oblast.
- `excess_turnout_bins.csv` — broj BM, E, B, W, B-W, očekivani W i odstupanja po intervalima izlaznosti.
- `excess_summary.csv` — referentni interval, koeficijent, dijagnostika i uslovna procena pozitivnog viška; **nije dokazan broj falsifikovanih glasova**.
- `excess_sensitivity.csv` — rezultati za referentne poluširine 5; 7,5 i 10 procentnih poena.
- `Excess_scenario_EN/SR.png` — crvena kriva posmatranih glasova pobednika, plava referentna kriva skaliranih ostalih važećih glasova (nije Monte Karlo prosek), tačkaste granice referentnog intervala i **siva oblast pozitivnih odstupanja samo iznad gornje granice**. Podnaslov prikazuje zaokruženi zbir i udeo, a CSV čuva nezaokružene vrednosti. Siva oblast na zasebnim Monte Karlo histogramima predstavlja simulacioni interval, ne višak glasova.

Za okružne/opštinske analize Monte Karlo po početnom podešavanju nije uključen, radi izbegavanja velikog opterećenja i nepouzdanih lokalnih testova. Nedovoljan broj BM se beleži u manifestu. Pri ponovnom pokretanju stari izlazi mogu biti prepisani; sačuvajte zasebne kopije objavljenih rezultata.

Napomena ispod grafikona raspoređena je u tačno dva reda da bi u celosti bila vidljiva u PNG fajlovima. **Grafičko zasenčenje:** Sivi poligoni prate pozitivnu razliku između posmatrane i referentne krive; preseci su linearno interpolirani. Numerička procena je zbir pozitivnih odstupanja po intervalima iz `excess_summary.csv`, a ne geometrijska površina poligona.
