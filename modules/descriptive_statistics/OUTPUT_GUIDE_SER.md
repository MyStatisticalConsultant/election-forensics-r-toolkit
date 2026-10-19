# Vodič kroz izlazne fajlove — v0.3.1

[English](OUTPUT_GUIDE.md) · [Tabele za publikacije](JOURNAL_REPORTS_SER.md)

## Fajlovi za svake izbore

U `descriptive_outputs/` nastaju `<tip>_<godina>_descriptive.xlsx`, opcioni `<tip>_<godina>_descriptive_journal_tables.docx` i istoimeni CSV podfolder. Podaci se preuzimaju iz `Main`, `Master` i `Options` bez menjanja ulaznih fajlova. Osam grupa u izlaznim tabelama nisu sve međusobno isključive.

## Listovi u Excel fajlu

| List | Sadržaj |
|---|---|
| `README` | Podaci o izvršavanju, definicije skupova |
| `Nat_counts`, `Dist_counts`, `Mun_counts` | Broj BM, upisani birači, evidentirani izlazak, ubačeni, važeći i nevažeći listići; mere veličine BM |
| `Nat_rates`, `Dist_rates`, `Mun_rates` | Izlaznost, udeli, opcije na prva dva nacionalna mesta, disperzija, efektivan broj opcija |
| `Nat_options`, `Dist_options`, `Mun_options` | Glasovi i udeli **svih** kandidata/izbornih lista |
| `Nat_robust`, `Dis_robust`, `Mun_robust` | Robusne mere i pokazatelji zajedničkog ponašanja izlaznosti i udela opcije |
| `Nat_joint_bins`, `Dis_joint_bins`, `Mun_joint_bins` | Dvodimenzionalni razredi širine 10 procentnih poena, broje se BM |
| `Group_tests` | Izvršeni Kruskal–Volisovi i Vilkoksonovi testovi, N, p i BH q |
| `Options_dictionary` | Identifikatori, nazivi i odgovarajuće kolone kandidata/lista |
| `Correlation_overview` | Pregled 16 matrica |
| `Corr_D_01` … `Corr_D_08` | Korelacije među agregatima okruga |
| `Corr_M_01` … `Corr_M_08` | Korelacije među agregatima opština |

`D` označava okruge, a `M` opštine. Grupe u matricama `01–07` redom su `All`, `Less than 100`, `Small`, `Middle`, `Large`, `JHK Small`, `JHK Large`; **`08` = `100 or more`**. Zvezdice označavaju nominalnu značajnost; detaljne p, BH q i N vrednosti nalaze se u CSV-u.

## CSV i Word

Svaki izborni CSV podfolder sadrži `national_table1_counts.csv`, `national_table2_rates.csv`, njihove okružne i opštinske verzije, tri `*_options.csv`, tri `*_robust_distributions.csv`, tri `*_joint_turnout_winner_bins.csv`, `group_significance_tests.csv`, `correlation_overview.csv` i `correlation_pairs_p_q_n.csv`.

CSV je kodiran kao **UTF-8 sa BOM**, pogodan za Excel Windows, dok `.xlsx` i `.docx` podržavaju Unicode. CSV čuva punu računsku preciznost, a formatirane tabele prikazuju dve decimale za stope i mere, cele brojeve za birače/listiće i po pravilu tri decimale za p/q.

Word fajl za svake izbore počinje sa četiri nacionalne tabele, a zatim slede opširni prilozi za okruge/opštine: A (glasovi i stope), B (disperzija i povezanost), C (sprovedeni testovi). Za glavni deo naučnog rada preporučuje se izbor nekoliko sažetih tabela. U `docs/publication/` nalaze se četiri objašnjavajuća Word dokumenta na engleskom i srpskom.

`NA` ili prazno polje znači da podatak ili pokazatelj nije raspoloživ/odrediv, **ne da je jednak nuli**. Kod nula važećih listića udeo kandidata nije definisan. Prazna BM grupa može izostati iz tabelarnog sažetka, ali njen korelacioni list ostaje. [DATA_DICTIONARY_SER.md](DATA_DICTIONARY_SER.md) · [CORRELATIONS_SER.md](CORRELATIONS_SER.md).
