# Election Forensics R Toolkit — v1.12.0

[Srpski (latinica)](README_SER.md) · [Installation](INSTALLATION.md) · [Module registry](MODULE_REGISTRY.md) · [Workflow](WORKFLOW.md) · [Release notes](RELEASE_NOTES_v1.12.0.md)

An open-source R toolkit for reproducible analysis of official Serbian election returns at polling-station level. It comprises **one upstream data-preparation module and seven independent analytical modules**. Outputs are descriptive or diagnostic: **a statistical anomaly alone is not proof of electoral fraud**.

## Modules

| Module | Version / status | Purpose | Documentation |
|---|---|---|---|
| RZS data preparation | Established, previously validated | Harmonise official workbooks, apply data-quality checks, prepare the `Main`, `Master` and `Options` sheets | [RZS preparation](modules/rzs_data_preparation/README.md) |
| Descriptive statistics | v0.3.1 | National, district and municipality statistics, robust measures and reporting tables | [Descriptive statistics](modules/descriptive_statistics/README.md) |
| Klimek cumulative curves | v0.1.4 | Cumulative turnout–vote curves, including pre-defined Size and JHK groups | [Klimek](modules/klimek/README.md) |
| Election fingerprints | v0.1.4 | Observed two-dimensional turnout–vote-share count histograms and supplementary KDE diagnostics | [Election fingerprints](modules/election_fingerprints/README.md) |
| **Contour diagrams** | **v0.1.4** | Standardised, bilingual two-dimensional KDE contours comparing Small/Large and JHK groups at national, district and municipality levels | [Contours](modules/contours/README.md) |
| **Voter-rigging diagnostics** | **v0.1.1** | Median-based small/large polling-station discrepancy `D(p)` and cumulative winner-share curves, with bilingual Figure 4-style plots and CSV diagnostics | [Voter rigging](modules/voter_rigging/README.md) |
| **Approximate normality** | **v0.1.2** | Standardised logarithmic winner-vote rates, connected empirical histogram probabilities, normal-reference curves and normality statistics (EN/SR-Latin) | [Approximate normality](modules/approximate_normality/README.md) |
| **Shpilkin/Kobak diagnostics** | **v0.1.3** | Descriptive turnout/winner histograms; registered-voter-weighted integer-percentage Monte Carlo tests; conditional high-turnout excess-votes scenario | [Shpilkin](modules/shpilkin/README.md) |

Detailed methodological definitions, numerical and graphical parameters, module-specific tests and limitations are documented **in each module**, rather than reproduced in this root overview. Downstream modules read the prepared RZS data independently; they do not alter the source workbooks or require another analytical module to be executed first.

## Getting started

1. Install [R](https://cran.r-project.org/) and optionally [RStudio](https://posit.co/download/rstudio-desktop/); clone or download this repository. See [installation](INSTALLATION.md).
2. Obtain the official RZS input workbooks and prepare them once, **or reuse compatible, previously validated local workbooks** in `modules/rzs_data_preparation/RZS_prepared/`. The source and prepared Excel data are not distributed with the repository.
3. Choose an analytical module, set the RStudio working directory to the corresponding `modules/<name>/` folder and run the entry-point script. Each module documents its packages, editable parameters and tests. Consult the [workflow guide](WORKFLOW.md), the [module registry](MODULE_REGISTRY.md) and the README linked in the module table above.

## Data, reproducibility and limitations

The default prepared `Main` data used by most methods contain 8,023 polling stations for presidential 2017 and 7,787 for each supported 2022 election after upstream QC and sample restrictions. The voter-rigging module instead uses `Master` to retain QC-eligible polling stations with fewer than 100 registered voters. Approximate normality also reads `Master`, but uses stations with `E >= 100` for the primary analysis, with under-100 stations shown only in a separately labelled sensitivity analysis. Analyses for other elections require compatible prepared workbooks and validation.

- The root [`.gitignore`](.gitignore) excludes official raw data, prepared workbooks and locally generated outputs, including `contours_outputs/`, `voter_rigging_outputs/`, `approximate_normality_outputs/` and `shpilkin_outputs/`.
- Keep source checksums, code versions, configuration and `sessionInfo()` alongside published analyses. A missing or too-small group is logged as `SKIP`; an algorithm should not manufacture a density plot for it.
- Contour diagrams visualise geographically standardised distributions; their arrows show KDE-mode displacement **descriptively**. The separate voter-rigging module calculates the descriptive displacement `D(p)` and **does not** estimate the international reference-standardised `δ(p)` or its significance region. The approximate-normality module uses fixed-width empirical bins (not KDE) and reports skewness, kurtosis and Jarque–Bera diagnostics; it does **not** estimate the separate parametric fraud-model coefficients. The Shpilkin module implements separate descriptive histograms, an integer-percentage binomial Monte Carlo test, and a **conditional** excess-votes scenario: a zero scenario estimate cannot establish the absence of fraud, and a positive estimate is not a verified count of fraudulent ballots. No module's output alone proves intentional manipulation.
- The root [checksum manifest](MANIFEST.sha256) lists source-file hashes. To audit a complete checkout, validate the manifest against the complete published file set, not only a ZIP of root documents.

## License and citation

MIT License: [LICENSE](LICENSE). Citation metadata: [CITATION.cff](CITATION.cff). © 2026 Zlatko J. Kovačić.
