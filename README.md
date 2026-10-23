# Election Forensics R Toolkit

**Reproducible research tools for Serbian election data** · [Srpski (latinica)](README_SER.md)

The Election Forensics R Toolkit is an open-source, **locally run** collection of R modules for preparing official polling-station data, documenting quality-control decisions, and producing transparent descriptive and, in later releases, statistical election-forensics analyses. It is **not** a live Shiny application. Statistical anomalies or significant associations do not, by themselves, prove electoral fraud.

## Available modules

| Module | Status and scope | Documentation |
|---|---|---|
| `rzs_data_preparation` | Established preparation workflow for **2017 and 2022 presidential and 2022 parliamentary** RZS source formats; exports `Master`, `Main`, `Options`, QC and metadata | [English](modules/rzs_data_preparation/README.md) · [Serbian](modules/rzs_data_preparation/README_SER.md) |
| `descriptive_statistics` **v0.3.1** | National, district and municipality summaries; eight overlapping reporting groups; 16 aggregate correlation matrices per election; robust measures, rank tests, CSV, Excel and optional Word | [English](modules/descriptive_statistics/README.md) · [Serbian](modules/descriptive_statistics/README_SER.md) |
| `klimek` **v0.1.4** | Klimek-style cumulative vote-versus-turnout curves for eight station groups; both normalisations, two figure families, EN/SR figures, optional area plots and explicit descriptive T90/T95 | [English](modules/klimek/README.md) · [Serbian](modules/klimek/README_SER.md) |


**Validation status:** Klimek v0.1.4 was successfully tested in RStudio by the researcher for **all three supported elections: presidential 2017, presidential 2022 and parliamentary 2022**. All regression, integration, execution and export checks are reported PASS. The detailed console transcript provided for parliamentary 2022 records 7,787 Main polling stations and 436 figures; successful presidential tests are additionally confirmed by the researcher, without separate console transcripts. See the [validation record](modules/klimek/VALIDATION_RECORD_2026-10-23.md). Testing was not independently rerun when packaging this release. Results should not be generalized automatically to new RZS schemas or treated as evidence of election fraud. The upstream preparation module retains a documented **2017 registered-voter REVIEW** discrepancy; see [findings](modules/rzs_data_preparation/VALIDATION_FINDINGS.md).

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
  +--------+----------------------------------+
  |                                           |
  v                                           v
modules/descriptive_statistics/             modules/klimek/
Descriptive_statistics.R                     Klimek.R
  |                                           |
  v                                           v
descriptive_outputs/                         klimek_outputs/
(XLSX, CSV, optional DOCX)                   (CSV, XLSX, EN/SR PNG/PDF)
```

`Main` is the default population for subsequent methods. The descriptive module also includes **QC-accepted** stations with fewer than 100 registered voters in its explicitly defined supplementary `All` and `Less than 100` groups. The eight rows must not be summed together.


**[Current Klimek release and validation](modules/klimek/README.md)**.

**Klimek validation:** v0.1.4 preserves code-aware special RZS area titles (33 Overseas, 55 Prisons, 25–29 source labels); the researcher confirms passing RStudio tests for all three supported elections; the detailed shared console transcript covers parliamentary 2022. Its cumulative curves are exploratory and are not the complete formal JHK statistical test.

## Repository organisation

```text
election-forensics-r-toolkit/
├── README.md / README_SER.md
├── LICENSE
├── CITATION.cff
├── .gitignore
├── WORKFLOW.md / WORKFLOW_SER.md
├── MODULE_REGISTRY.md / MODULE_REGISTRY_SER.md
├── RELEASE_NOTES_v1.7.9.md / RELEASE_NOTES_SER_v1.7.9.md
└── modules/
    ├── rzs_data_preparation/
    │   ├── RZS_data_preparation.R
    │   ├── README.md / README_SER.md
    │   ├── tests/
    │   └── ... method, QC and bilingual documentation
    ├── descriptive_statistics/
        ├── Descriptive_statistics.R
        ├── R/                 # reusable descriptive functions
        ├── tests/             # synthetic, integration and export checks
        ├── examples/          # usage guidance, no official data
        ├── docs/publication/  # explanatory EN/SR Word guides
        └── ... bilingual .md documentation
    └── klimek/
        ├── Klimek.R                 # one self-documented script
        ├── tests/                 # synthetic, real-data, export checks
        ├── USER_GUIDE.md / USER_GUIDE_SER.md
        └── ... bilingual methods, outputs and reproducibility docs
```

The folders `raw_data/`, `RZS_prepared/`, `descriptive_outputs/`, `klimek_outputs/` and automatically generated `validation_results/` are **local working/output folders** and are excluded from ordinary Git commits. Verified validation evidence may be tracked separately under a documentation path, with clear provenance.

## Reusing prepared data — no full restart required

When `modules/rzs_data_preparation/RZS_prepared/*.xlsx` already exists, run only the desired downstream module. Descriptive and Klimek are independent consumers; their results are stored in separate local output directories. See the [step-by-step workflow](WORKFLOW.md), the [current module registry](MODULE_REGISTRY.md). Adding a module does not require re-running all prior modules.

## First use

1. Install [R](https://cran.r-project.org/) and optionally [RStudio](https://posit.co/download/rstudio-desktop/).
2. **Only for first-time setup or changed source data:** download official RZS XLSX files using links in the [preparation README](modules/rzs_data_preparation/README.md), saving them to the preparation module's `raw_data/` folder with the filenames expected by its editable configuration.
3. If the prepared workbooks are missing, run the preparation module and its validation; otherwise reuse the existing workbooks.
4. Run the descriptive module's tests, runner and export verification from **its own module directory**. [Installation guide](modules/descriptive_statistics/INSTALLATION.md).
5. From `modules/klimek/`, run its synthetic, plot-layout, singleton, integration and export tests and its runner; see the bilingual [user guide](modules/klimek/USER_GUIDE.md). Klimek v0.1.4 includes the consolidated visual fixes; the author-reported successful RStudio test log is documented in the [validation record](modules/klimek/VALIDATION_RECORD_2026-10-23.md).

## Publication and future development

Current code is restricted to tested presidential/parliamentary RZS templates. New administrative source columns **must not** be silently treated as electoral options: the positional importer needs a versioned schema mapping before such files are accepted. [Schema evolution](modules/rzs_data_preparation/SCHEMA_EVOLUTION.md).

Planned, **not yet implemented**, modules include election fingerprints, turnout–vote contours, normality diagnostics, regression and Mebane FMM. The modular architecture is described in [ARCHITECTURE.md](modules/rzs_data_preparation/ARCHITECTURE.md). Keep interpretation and any future public interface separate from statistical computations.

Copyright © 2026 **Zlatko J. Kovačić**. [MIT licence](LICENSE). Feedback and errors: GitHub Issues or `Zlatko@MyStatisticalConsultant.com`. See [citation metadata](CITATION.cff).

**Small-area graph handling (v0.1.4):** See [Klimek user guide](modules/klimek/USER_GUIDE.md) for zero-, one- and multi-station behaviour.

