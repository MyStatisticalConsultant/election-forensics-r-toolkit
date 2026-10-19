# Election Forensics R Toolkit — Module 01: RZS Data Preparation (Presidential and Parliamentary Elections)

**Version 1.1 · R script · English documentation · Serbian-Latin companion files**

This is the first standalone module of a planned open, reproducible **Election Forensics R Toolkit**. It converts official Republic of Serbia Statistical Office (RZS) presidential/parliamentary-election polling-station Excel workbooks into analysis-ready, source-preserving workbooks. The current implementation is designed for the **2017 and 2022 schemas** for presidential and parliamentary elections, not arbitrary election years or unvalidated local formats. It is run **locally**, not on Posit Connect, Shiny or an online service.

**Important distinction:** Data validation flags and election-forensics visualizations are *diagnostics*, not findings of fraud. This module does **not** implement election-fraud tests, the full Jiménez–Hidalgo–Klimek (JHK) significance test, or any causal inference about irregularities.

## Why this module?

Official election spreadsheets vary across years and do not generally arrive with ready-to-use, harmonized variables, documented eligibility decisions, or transparent quality-control (QC) traces. This script creates an auditable upstream data contract for subsequent methods: descriptive analyses by district and municipality, turnout/vote fingerprints, contours, approximate-normality diagnostics, regression models, and, potentially, Mebane finite-mixture models (FMM). Those methods are **planned**, not implemented here.

## What it does

- Imports 2017-style and 2022-style RZS Excel files, preserving raw values as `V1`, `V2`, ... and original row indices.
- Retains district, municipality and polling-station identifiers; derives stable within-source keys (`Year|District_code|Municipality_code|PS_number`).
- Harmonizes registered voters `E`, attendance `A`, ballots cast `C`, invalid ballots `I`, valid ballots `B`, and candidate results.
- Derives turnout (`100*C/E`), vote shares, winner/runner-up fields, logarithmic ratios and other indicators.
- Flags missing/negative/non-integer data, identity violations, duplicated keys and other QC concerns.
- Allows documented, optional administrative station-status overrides; never rewrites official raw votes.
- Defines a primary eligible sample and method-specific eligibility flags; retains excluded records with reasons.
- Implements two **different** station-size groupings: bottom/top 20% of the cumulative electorate (ties included) and a JHK-oriented split at the station-size 20th percentile. Neither constitutes the full JHK test.
- Exports one multi-sheet Excel workbook per election plus `cross_election_QC_summary.csv`.

## Which worksheet should I analyze?

**Use `Main` as the default prepared polling-station dataset for downstream forensic-method scripts.** `Main` contains only `Eligible_primary == TRUE` records. **Use `Master` as the authoritative full prepared/audit dataset**: all records remain there, including observations omitted from the default analytical subset and flags for method-specific suitability. Methods that need another population or denominator must start from `Master` and document their own sample decisions. `Raw_RZS` retains source-imported text; `Excluded` separately displays records not in `Main`.

**Do not** analyze `Raw_RZS` as if it were cleaned; do not assume every record in `Main` is usable for every method. See [OUTPUT_GUIDE.md](OUTPUT_GUIDE.md) and [DATA_DICTIONARY.md](DATA_DICTIONARY.md).

## Repository structure

```text
election-forensics-r-toolkit/
├── README.md                        # Planned ecosystem and module directory
├── LICENSE
├── .gitignore
└── modules/
    └── rzs_data_preparation/
        ├── RZS_data_preparation.R
        ├── README.md
        ├── README_SER.md
        ├── METHODOLOGY.md / METHODOLOGY_SER.md
        ├── DATA_DICTIONARY.md / DATA_DICTIONARY_SER.md
        ├── REPRODUCIBILITY.md / REPRODUCIBILITY_SER.md
        ├── OUTPUT_GUIDE.md / OUTPUT_GUIDE_SER.md
        ├── ARCHITECTURE.md / ARCHITECTURE_SER.md
        ├── CHANGELOG.md / CHANGELOG_SER.md
        ├── CONTRIBUTING.md / CONTRIBUTING_SER.md
        ├── LICENSE / CITATION.cff
        ├── RZS_station_status_overrides_TEMPLATE.csv
        ├── tests/run_tests.R
        └── examples/README.md
```

Local-only directories `raw_data/` and `RZS_prepared/` are created by the user/run; their contents are excluded from Git. Original official XLSX files and derived election workbooks are **not distributed** in this repo.

## Requirements and dependencies

Install [R](https://cran.r-project.org/) and, optionally, [RStudio Desktop](https://posit.co/download/rstudio-desktop/). Required CRAN packages: `readxl`, `openxlsx`. An Internet connection is needed to download R/packages and official source XLSX files, **not** for script execution after those files are present. RStudio and Shiny are not required.

```r
install.packages(c("readxl", "openxlsx"))
```

The script checks that packages exist and exits with an actionable message otherwise. Use a contemporary supported R version; precise versions used should be recorded using `sessionInfo()`.

## Download and local setup

Use GitHub **Code → Download ZIP**, extract it, or clone the eventual repository URL (not assigned in this release). Open the **module folder** (`modules/rzs_data_preparation`) as the working directory. Do not use a personal `setwd("C:/Users/...")` inside the script.

Download the original official workbooks from the RZS publications site:

- Presidential election 2017: <https://publikacije.stat.gov.rs/G2017/Xls/G20176004.xlsx>
- Presidential election 2022: <https://publikacije.stat.gov.rs/G2022/Xls/G202219003.xlsx>
- Parliamentary election 2022: <https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx>

Create `raw_data/` inside the module directory; save the official files there, using the names expected in the EDITABLE section (or edit the `source` paths). Verify schema/version and attribution against the original RZS publication. The supplied paths and templates are examples of supported layouts, **not automatic download logic**.

## EDITABLE settings (edit only this section)

At the very beginning of `RZS_data_preparation.R`, set:

| Setting | Purpose | Default |
|---|---|---|
| `INPUTS$year` | Election year(s), one row per election | 2017, 2022 |
| `INPUTS$source` | Local XLSX paths relative to module working directory or absolute paths | `raw_data/...xlsx` |
| `INPUTS$template` | Schema selection | `2017`, `2022` |
| `OUTPUT_DIR` | Destination for prepared files | `RZS_prepared` |
| `OVERRIDES_FILE` | Optional evidence-based station decisions | `RZS_station_status_overrides.csv` |
| `MIN_ELECTORATE` | Main-sample registered-electorate threshold | `100` |
| `ELECTORATE_FRACTION` | Cumulative electorate allocated to each extreme size group | `0.20` |
| `JHK_PERCENTILE` | Station-size percentile for JHK-oriented split | `0.20` |

To analyze **only 2017**, replace the `INPUTS` table with a single 2017 row (do not change only the `year` column). Later elections require **manual confirmation of schema compatibility** and substantive interpretation; use `template="2022"` only if the source column structure genuinely matches it.

Below the edit block is the clearly marked **DO NOT CHANGE THE CODE BELOW THIS LINE** boundary. Methodology, field definitions and quality checks are not meant to be modified by routine users.

## Run locally

From the module directory in RStudio:

```r
source("RZS_data_preparation.R", encoding = "UTF-8")
```

Or at the command line from the same folder:

```bash
Rscript RZS_data_preparation.R
```

Read any stop/error messages; do not interpret missing inputs as a successful run. The script overwrites **its own generated output workbooks** on repeat runs; original RZS inputs are not changed.

## Exported worksheets and results

For each year, `RZS_prepared/P<YEAR>_RZS_prepared.xlsx` includes **15** worksheets:

| Sheet | Function |
|---|---|
| `Raw_RZS` | Source fields imported as text (`V1`...) |
| `Master` | Complete harmonized records and QC/eligibility flags: **audit source of truth** |
| `Main` | Eligible prepared polling-station records: **default analytical input** |
| `Excluded` | Ineligible observations retained for review |
| `Zero_cases` | Zero cast, zero valid, or zero received ballot observations |
| `QC_summary` | Quality checks and counts |
| `QC_records` | Station-level noteworthy QC records |
| `Gap_distribution` | Absolute differences between attendance `A` and cast `C` |
| `Gap_direction` | Counts by sign of `A−C` |
| `Size_summary` | Size group sample counts and electorate shares |
| `Size_thresholds` | Selected thresholds and percentile |
| `Options` | Names, candidate column mappings, national totals and ranks |
| `Source_dictionary` | RZS columns and Serbian Cyrillic originals |
| `Derived_dictionary` | Selected derived variable definitions/formulas |
| `Metadata` | Year, official URL, MD5, UTC timestamp, assumptions/caveats |

A separate `cross_election_QC_summary.csv` combines summary counts across the processed years. It is a QC output, **not** a combined harmonized cross-election dataset. For detailed field semantics see the dictionary documents.

## Administrative-status override CSV

The optional file has mandatory columns `Year,District_code,Municipality_code,PS_number,Admin_status,Comment`. Allowed statuses: `verified_complete`, `verified_no_ballots_received`, `verified_invalid_record`, `unverified`. The repository includes a *header-only* [`RZS_station_status_overrides_TEMPLATE.csv`](RZS_station_status_overrides_TEMPLATE.csv). Copy it to `RZS_station_status_overrides.csv` and enter only **documented, independently verified decisions**. No fabricated sample decisions are provided. Codes may contain leading zeroes: use text-preserving CSV editing tools. The loader explicitly reads CSV columns as text to preserve leading zeroes in codes; still verify all identifiers against the source.

## Methodological workflow

`RZS XLSX → read as text → schema map → canonical values → source-preserving QC → explicit eligibility → size grouping → derived method flags → Excel outputs`. Primary turnout is `100*C/E` (**not** `100*A/E` or `100*B/E`). Candidate vote percentage uses `B` as denominator; `B=0` produces missing (`NA`) percentages, not a fabricated zero. See [METHODOLOGY.md](METHODOLOGY.md).

## Reproducibility and tests

The source workbook is not changed; original source text columns remain in output; `Source_row`, `Station_key`, original input MD5 and run timestamp support auditing. Record R and package versions:

```r
writeLines(capture.output(sessionInfo()), "sessionInfo.txt")
```

To run the structural tests (and an optional complete run when source inputs are locally available):

```r
source("tests/run_tests.R", encoding="UTF-8")
```

The tests are **not a substitute for empirical verification against published RZS totals**, nor do they establish analytical validity or fraud. See [REPRODUCIBILITY.md](REPRODUCIBILITY.md).

## Limitations and interpretation

- **2017/2022 schemas** only; other election types/year layouts are not automatically supported.
- Winner/runner-up are computed from candidate total votes in the supplied dataset; candidate column-order consistency matters.
- The `2022` schema lacks received/unused ballot fields; zero ballots cast must not be conflated with zero ballots *received*.
- Grouping at a size quantile is *not* the JHK inferential test, geographic standardization, or a fraud conclusion.
- Flagged station counts depend on administrative source quality, choices of thresholds and override documentation; QC flags require human contextual examination.
- Source names and administrative labels are transliterated into Serbian Latin for convenience; `Raw_RZS` and `Source_dictionary` preserve original field text.
- The current script selects columns positionally. A newly published official file can silently change layout without satisfying semantic assumptions; check schemas before relying on results.

## Troubleshooting

**Missing package:** run `install.packages(c("readxl","openxlsx"))`. **Source workbook not found:** check working directory and `INPUTS$source`. **Unsupported schema:** choose `2017` or `2022`, only for actually compatible sources. **Missing station identifiers / candidate header:** confirm you downloaded the correct publication and first worksheet. **No eligible stations / overlapping size thresholds:** inspect `Master`/QC logic or source data and avoid relaxing checks simply to force an output. **Duplicate or unmatched overrides:** validate exact source codes and station keys. **Excel locked:** close the generated output workbook and rerun. For reports, include the exact error, source provenance (not confidential information), R version, `sessionInfo()` and steps to reproduce.

## Planned modules and software architecture

This script is intentionally self-contained. For the future toolkit, use shared tested **R functions**, not a chain of copy-pasted, ever-growing scripts. A recommended project structure, interface contracts, and phased roadmap are in [ARCHITECTURE.md](ARCHITECTURE.md). New modules should consume `Main` by default, expose explicit selection decisions, offer method-specific eligibility checks, and publish their assumptions, uncertainty and interpretive caveats. A Shiny public dashboard is a **separate future layer**.

## Citation, contributions, feedback and copyright

Suggested provisional citation: **Kovačić, Z. J. (2026). *Election Forensics R Toolkit: RZS Presidential and Parliamentary Data Preparation* (v1.2) [R script]. GitHub repository URL to be added after publication.** Prefer a release tag or commit hash for reproducibility. Machine-readable citation: [`CITATION.cff`](CITATION.cff). Contributions: [`CONTRIBUTING.md`](CONTRIBUTING.md). GitHub Issues can be used after the repository is published; feedback: [Zlatko@MyStatisticalConsultant.com](mailto:Zlatko@MyStatisticalConsultant.com).

Copyright © 2026 Zlatko J. Kovačić. MIT licence: [`LICENSE`](LICENSE). Official election data remain attributable to RZS; this software licence does not replace applicable source-data rights or citation requirements.


## Election-type coverage and v1.2 data contract

This module processes Serbian **presidential** candidates and **parliamentary** electoral lists as neutral vote **options**. Set `election_type` to `presidential` or `parliamentary`; combined input rows may share a year, but must not share the same type/year pair. The 2022 parliamentary source is [`G202219002.xlsx`](https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx); save it as `raw_data/Parliament 2022 ~ G202219002.xlsx`. The other configured inputs are the 2017 and 2022 presidential results.

**Validation limitation:** the structure of the 2022 parliamentary XLSX could not be directly inspected in this preparation environment. It is provisionally assigned the `2022` column template; **validate its headers, row totals, option columns and QC results** against the official workbook before analytical use. The script does not support local-election source files without a separately validated schema and (where applicable) constituency-specific winner/list logic.

For both supported types, `Main` remains the default analysis worksheet and `Master` the complete audit-preserving dataset. `Option_01_votes`, `Option_01_pct`, etc., have type-neutral meanings; `Options` maps each option to its source heading. `Winner_*` / `Second_*` are the top two **national vote totals** in the input, not automatically the winner of every constituency or an allocation of seats. No parliamentary seat allocation is performed. Election identifiers now include `Election_type`, protecting against same-year collisions. Outputs are `presidential_2017_RZS_prepared.xlsx`, `presidential_2022_RZS_prepared.xlsx` and `parliamentary_2022_RZS_prepared.xlsx`.

Existing downstream scripts that expected `Candidate_*`, `Candidates`, a year-only station key, or `P2022_RZS_prepared.xlsx` must be adapted to the v1.2 contract.


### Validation against official RIK results (new in v1.3)

After data preparation and the structural test, run `source("tests/validate_official_totals.R")` from this module's root. Reference totals for all three elections and every candidate/list are version-controlled in `tests/official_reference_*.csv`; the validation report is produced under `validation_results/` (not committed). **The 2017 registered-voter comparison remains REVIEW (−1,772); other national totals and all option vote counts reconcile.** See [`tests/VALIDATION_README.md`](tests/VALIDATION_README.md). Do not claim unconditional validation until the 2017 register discrepancy is resolved.
## Downstream descriptive-statistics module

The harmonised `Main`, `Master` and `Options` sheets are the inputs to the independently documented [Descriptive Statistics module v0.3.1](../descriptive_statistics/README.md). This link is documentary only; `RZS_data_preparation.R` calculations and the reported 2017 validation REVIEW are unchanged.
