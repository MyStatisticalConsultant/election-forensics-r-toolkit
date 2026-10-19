# Election Forensics R Toolkit

**Reproducible research tools for Serbian election data** · [Srpski (latinica)](README_SER.md)

The Election Forensics R Toolkit is an open-source, **locally run** collection of R modules for preparing official polling-station data, documenting quality-control decisions, and producing transparent descriptive and, in later releases, statistical election-forensics analyses. It is **not** a live Shiny application. Statistical anomalies or significant associations do not, by themselves, prove electoral fraud.

## Available modules

| Module | Status and scope | Documentation |
|---|---|---|
| `rzs_data_preparation` | Established preparation workflow for **2017 and 2022 presidential and 2022 parliamentary** RZS source formats; exports `Master`, `Main`, `Options`, QC and metadata | [English](modules/rzs_data_preparation/README.md) · [Serbian](modules/rzs_data_preparation/README_SER.md) |
| `descriptive_statistics` **v0.3.1** | National, district and municipality summaries; eight overlapping reporting groups; 16 aggregate correlation matrices per election; robust measures, rank tests, CSV, Excel and optional Word | [English](modules/descriptive_statistics/README.md) · [Serbian](modules/descriptive_statistics/README_SER.md) |

**Validation boundary:** descriptive output from the three named elections was checked against independently calculated reference results as reported by the researcher. The repository includes tests to reproduce these checks. This is not blanket certification for other elections, newly inserted source columns or causal/fraud conclusions. The preparation module retains a documented **2017 registered-voter REVIEW** discrepancy; see [validation findings](modules/rzs_data_preparation/VALIDATION_FINDINGS.md) and the [descriptive-module validation guide](modules/descriptive_statistics/VALIDATION.md).

## How modules connect

```text
Official RZS XLSX  (download locally; not committed)
           |
           v
modules/rzs_data_preparation/RZS_data_preparation.R
           |
           v
RZS_prepared/<election>_RZS_prepared.xlsx
    |  Master = all retained source records + QC flags
    |  Main   = default analysis sample (eligible, E >= 100)
    `  Options = candidate/list dictionary
           |
           v
modules/descriptive_statistics/Descriptive_statistics.R
           |
           v
descriptive_outputs/  (XLSX, UTF-8 BOM CSV, optional DOCX)
```

`Main` is the default population for subsequent methods. The descriptive module also includes **QC-accepted** stations with fewer than 100 registered voters in its explicitly defined supplementary `All` and `Less than 100` groups. The eight rows must not be summed together.

## Repository organisation

```text
election-forensics-r-toolkit/
├── README.md / README_SER.md
├── LICENSE
├── CITATION.cff
├── .gitignore
├── GITHUB_UPLOAD_GUIDE.md / GITHUB_UPLOAD_GUIDE_SER.md
├── RELEASE_CHECKLIST.md / RELEASE_CHECKLIST_SER.md
└── modules/
    ├── rzs_data_preparation/
    │   ├── RZS_data_preparation.R
    │   ├── README.md / README_SER.md
    │   ├── tests/
    │   └── ... method, QC and bilingual documentation
    └── descriptive_statistics/
        ├── Descriptive_statistics.R
        ├── R/                 # reusable descriptive functions
        ├── tests/             # synthetic, integration and export checks
        ├── examples/          # usage guidance, no official data
        ├── docs/publication/  # explanatory EN/SR Word guides
        └── ... bilingual .md documentation
```

The folders `raw_data/`, `RZS_prepared/`, `descriptive_outputs/` and automatically generated `validation_results/` are **local working/output folders** and are excluded from ordinary Git commits. Verified validation evidence may be tracked separately under a documentation path, with clear provenance. See the [upload guide](GITHUB_UPLOAD_GUIDE.md).

## First use

1. Install [R](https://cran.r-project.org/) and optionally [RStudio](https://posit.co/download/rstudio-desktop/).
2. Download official RZS XLSX files using links in the [preparation README](modules/rzs_data_preparation/README.md), saving them to the preparation module's `raw_data/` folder with the filenames expected by its editable configuration.
3. Run the preparation module, then run its syntax and official-total validation scripts.
4. Run the descriptive module's tests, runner and export verification from **its own module directory**. [Installation guide](modules/descriptive_statistics/INSTALLATION.md).

## Publication and future development

Current code is restricted to tested presidential/parliamentary RZS templates. New administrative source columns **must not** be silently treated as electoral options: the positional importer needs a versioned schema mapping before such files are accepted. [Schema evolution](modules/rzs_data_preparation/SCHEMA_EVOLUTION.md).

Planned, **not yet implemented**, modules include election fingerprints, turnout–vote contours, normality diagnostics, regression and Mebane FMM. The modular architecture is described in [ARCHITECTURE.md](modules/rzs_data_preparation/ARCHITECTURE.md). Keep interpretation and any future public interface separate from statistical computations.

Copyright © 2026 **Zlatko J. Kovačić**. [MIT licence](LICENSE). Feedback and errors: GitHub Issues or `Zlatko@MyStatisticalConsultant.com`. See [citation metadata](CITATION.cff).
