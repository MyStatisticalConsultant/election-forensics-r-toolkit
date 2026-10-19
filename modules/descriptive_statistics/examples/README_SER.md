# Primeri upotrebe — deskriptivni modul v0.3.1

[English](README.md)

Ovaj folder sadrži **uputstva**, ne originalne RZS baze niti generisane izlaze. Najpre pripremite tri baze prethodnim modulom.

Iz foldera `modules/descriptive_statistics`:

```r
main <- readxl::read_excel(
  "../rzs_data_preparation/RZS_prepared/presidential_2022_RZS_prepared.xlsx",
  sheet="Main"
)
head(main[c("District", "Municipality", "E", "C", "B", "Size", "Size_JHK")])
nrow(main)   # 7787 za proverenu bazu
sum(main$E) # 6467903 za proverenu bazu

# Za sve tabele izvršiti: source("Descriptive_statistics.R")
```

`Main` isključuje BM ispod 100 upisanih. Proširena deskriptivna grupa `All` dodaje samo ona BM ispod 100 koja su prošla QC kriterijume iz `Master`. To **nije** ceo nefiltrirani zvanični skup. Videti [metodologiju](../METHODOLOGY_SER.md) i [opis izlaza](../OUTPUT_GUIDE_SER.md).
