# Korelaciona analiza: 16 matrica i pregled — v0.3.1

[English](CORRELATIONS.md)

## Šta se korelira?

Svaka matrica predstavlja zasebnu **ekološku Pirsonovu korelacionu matricu** (*Pearson correlation matrix*). Tačke posmatranja nisu BM nego **agregati okruga** (`D`) ili **agregati kombinacija okrug–opština** (`M`) unutar izabrane grupe BM. Matrica za 32 okruga ima najviše 32 posmatranja po koeficijentu, a ne hiljade BM. Promenljive uključuju zbirne brojeve birača i listića, glasove svake liste/kandidata, stope, lokalnu razliku, efektivan broj opcija i neke mere disperzije. Veza između upisanih i ubačenih listića može biti visoka samo zato što veći okruzi imaju više birača.

`Joint_Pearson_r` i `Joint_Spearman_rho` u robusnim izlazima koriste **biračka mesta unutar date oblasti/grupe** i mere vezu njihove izlaznosti i udela nacionalno prve opcije. To je druga jedinica analize.

## Oznake matrica

`D_01`/`M_01` = `All`; `_02` = `Less than 100`; `_03` = `Small`; `_04` = `Middle`; `_05` = `Large`; `_06` = `JHK Small`; `_07` = `JHK Large`; `_08` = **`100 or more` (`Main`)**. Prvobitne oznake `01–07` nisu menjane.

## r, p, q i broj posmatranja

Za svaki par numeričkih promenljivih Pirsonov r računa se na raspoloživim agregatima područja za koje obe vrednosti postoje. `N_pairs` je stvarni broj područja za **taj par**, i može biti manji od `Areas`. Kada postoje manje od tri para ili je varijansa nula, r nije odrediv. Dvostrano p računa se iz t-raspodele pod uobičajenim pretpostavkama, a BH korekcija stope lažnih otkrića (*Benjamini–Hochberg*) primenjuje se **unutar svake matrice**. Zvezdica uz r u `Corr_*` označava nominalno p<0,05, **ne** nužno BH značajnost. CSV `correlation_pairs_p_q_n.csv` čuva `R`, `P_value`, `N_pairs` i `BH_q_value`.

## Kako čitati `correlation_overview.csv`

| Kolona | Šta broj znači |
|---|---|
| `Matrix` | Oznaka, npr. `D_08` |
| `Level` | Jedinica posmatranja: okrug ili okrug–opština |
| `Size_group` | Grupa BM izabrana pre agregacije |
| `Areas` | Broj agregiranih područja, **ne broj BM** |
| `Variables` | Broj numeričkih pokazatelja |
| `N_tested` | Broj jedinstvenih **parova promenljivih** za koje je izračunato p |
| `Significant_nominal` | Broj parova sa dvostranim p<0,05 |
| `Significant_BH` | Broj parova sa BH q<0,05 u okviru matrice |

**Izmišljeni primer:** `D_08, District, 100 or more, Areas=32, Variables=50, N_tested=1100, Significant_nominal=85, Significant_BH=43`. Od najviše 50×49/2 = 1.225 parova, proverljivo je 1.100. Brojevi **85 i 43 odnose se na parove promenljivih**, a nikako na broj sumnjivih okruga ili BM. Za stvarne nalaze treba otvoriti generisani CSV; primer ne predstavlja rezultat istraživanja.

## Ograničenja i uloga u izbornoj forenzici

r=0,70 znači izraženiju **linearnu povezanost između agregata**, a ne 70% promene, verovatnoću prevare ili dokaz uzroka. Veze mogu biti posledica broja birača, zajedničkih imenilaca, činjenice da se udeli glasova zbiraju na 100%, geografske strukture, socioekonomskih razlika, pojedinačnih ekstremnih oblasti, prostorne zavisnosti ili grešaka u izveštavanju. BH korekcija umanjuje problem višestrukih poređenja, ali ne otklanja ostale metodološke probleme.

Kod neuobičajenih veza potrebno je navesti hipotezu, pregledati grafikone rasipanja i uticaj pojedinačnih oblasti, porediti slične oblasti, koristiti prostorne/kontekstualne kontrole i uključiti zapisnike BM, izveštaje posmatrača i rezultate ponovnog brojanja. Korelacije agregata nisu direktan dokaz nepravilnosti na pojedinačnim BM. [METHODOLOGY_SER.md](METHODOLOGY_SER.md).
