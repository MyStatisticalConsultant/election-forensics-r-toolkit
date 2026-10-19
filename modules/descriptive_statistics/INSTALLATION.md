# Installation and local execution — v0.3.1

[Srpski](INSTALLATION_SER.md) · [README](README.md)

1. Install R (CRAN), then optionally RStudio Desktop; neither Posit Cloud nor Shiny hosting is needed.
2. Install dependencies in R once: `install.packages(c("readxl","openxlsx","readr"))`; for Word output additionally `install.packages(c("officer","flextable"))`.
3. Download the complete toolkit ZIP or clone the Git repository. Extract it before executing; keep the two folders under `modules/` together.
4. Download the official RZS raw Excel files separately and use `modules/rzs_data_preparation/RZS_data_preparation.R` to produce the three prepared workbooks. Edit its **own** input configuration first; do not copy original workbooks into the Git repository.
5. Confirm these files exist:

   ```text
   modules/rzs_data_preparation/RZS_prepared/presidential_2017_RZS_prepared.xlsx
   modules/rzs_data_preparation/RZS_prepared/presidential_2022_RZS_prepared.xlsx
   modules/rzs_data_preparation/RZS_prepared/parliamentary_2022_RZS_prepared.xlsx
   ```
6. Set your RStudio working directory to `modules/descriptive_statistics`; check with `getwd()` and `file.exists("Descriptive_statistics.R")`.
7. At the top of `Descriptive_statistics.R`, edit only `INPUTS` if sources differ, `OUTPUT_DIR`, `DISPLAY_DECIMALS`, `WRITE_CSV` and `WRITE_WORD`. Use relative paths and never insert machine-specific paths in committed code.
8. Execute the six pre-run steps plus export check in the [README](README.md). Word requires both optional packages and `WRITE_WORD <- TRUE`.

The runner writes `descriptive_outputs/<election>_descriptive.xlsx`, optional Word and supporting CSVs without editing any prepared input workbook. `source("tests/check_exports.R")` is intended **only after** running `source("Descriptive_statistics.R")`.

If running only one election, delete other rows **in the editable `INPUTS` table** without altering function definitions. The export checker currently expects the default **three-election** set, so it should not be used unchanged on a one-election run. See [troubleshooting](TROUBLESHOOTING.md).
