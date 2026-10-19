# Uzorak i osam prikazanih grupa biračkih mesta — v0.3.1

[English](MAIN_SAMPLE_GUIDE.md)

U okviru RZS pripreme, `Master` čuva sve izvorne zapise i oznake kontrole kvaliteta, a `Main` sadrži BM sa `E >= 100` koja ispunjavaju uslove podobnosti. **Grupa `100 or more` je potpuno identična listu `Main`**, a ne svim izvornim BM sa najmanje 100 birača bez obzira na kvalitet podataka.

`Less than 100` sadrži samo BM iz `Master` sa `0 < E < 100` koja nemaju numeričku/računsku grešku, utvrđen nevažeći administrativni status ili primenjivo isključenje zbog nula primljenih listića. `All` je unija `Main` i tako prihvaćenih malih BM; može imati manje zapisa nego nefiltrirani `Master`.

| Oznaka | Kako nastaje | Uloga |
|---|---|---|
| `All` | `Main` + prihvaćena BM ispod 100 | Prošireni deskriptivni skup |
| `100 or more` | Tačno `Main` | Osnovni uzorak za forenzičke metode |
| `Less than 100` | Prihvaćeni zapisi iz `Master` sa E ispod 100 | Dopunska analiza |
| `Small` / `Middle` / `Large` | Nacionalna klasifikacija `Size` | Tri disjunktne grupe prema kumulativnom udelu upisanih |
| `JHK Small` / `JHK Large` | Nacionalna klasifikacija `Size_JHK` | Dve disjunktne grupe; `JHK Large` obuhvata sve ostale |

Pragovi veličina utvrđuju se **posebno za svake izbore, na nivou države**, ne za svaki okrug ili opštinu. Zato u manjim opštinama pojedine grupe mogu imati vrlo malo BM ili nijedno.

Za sve sabirljive brojeve (BM, upisani, glasovi, listići) važi:

```text
All = 100 or more + Less than 100
100 or more = Small + Middle + Large
100 or more = JHK Small + JHK Large
```

To su **tri različita rastavljanja**, a ne osam nezavisnih kategorija. Ne sabirati osam redova! Procenti se ponovo izračunavaju iz odgovarajućih zbirnih imenilaca i brojilaca. Za testove upoređivati samo međusobno isključive grupe istog sistema klasifikacije; `All` i `100 or more` nisu nezavisni uzorci.

Brojevi BM u `Main` za proverene izbore su 8.023 (predsednički 2017), 7.787 (predsednički 2022) i 7.787 (parlamentarni 2022). Referentne vrednosti: `tests/reference_100_or_more_totals.csv`. [VALIDATION_SER.md](VALIDATION_SER.md) · [METHODOLOGY_SER.md](METHODOLOGY_SER.md).
