# Examples — descriptive module v0.3.1

[Srpski](README_SER.md)

This directory contains **usage guidance only**, not reconstructed RZS raw workbooks or generated output. For reproducibility, generate the three prepared datasets with the upstream module before running the examples.

From `modules/descriptive_statistics`:

```r
# Read just a preview of the primary analytical sample
main <- readxl::read_excel(
  "../rzs_data_preparation/RZS_prepared/presidential_2022_RZS_prepared.xlsx",
  sheet="Main"
)
head(main[c("District", "Municipality", "E", "C", "B", "Size", "Size_JHK")])

# Check the national canonical population
nrow(main)               # 7787, under the tested configuration
sum(main$E)             # 6467903, under the tested configuration

# Run the entire descriptive workflow via Descriptive_statistics.R
# (see README; this creates outputs for all configured elections)
```

The `Main` dataset intentionally excludes under-100 polling stations; the descriptive `All` group adds back **only QC-accepted** under-100 records from `Master`. Do not confuse `All` with the complete original official population. For interpretation, see [methodology](../METHODOLOGY.md) and [output guide](../OUTPUT_GUIDE.md).
