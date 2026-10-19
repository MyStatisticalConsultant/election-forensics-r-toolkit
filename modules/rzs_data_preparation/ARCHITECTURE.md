# Proposed architecture and development plan

## Verdict on step-by-step development

**Yes, gradual implementation is appropriate — but not as one progressively larger script.** Start with this reproducible data-preparation baseline and add separately tested modules behind a common data contract. A method should be independently executable before any user interface is built. This balances incremental delivery with traceable scientific software engineering.

## Benefits and risks

Advantages: early usable results, easier peer review, controlled validation of each forensic method, reusable common source interpretation, lower up-front cost, clean version history, and gradual improvements to public reporting.

Risks of an ever-growing single script: tightly coupled global settings, repeated or divergent data cleaning, hard-to-reproduce method-specific exclusions, fragile updates when RZS schemas change, increased regression risk, and unmaintainable UI integration. Separate but unrelated script folders can also drift apart unless schemas, test data, metadata and interfaces are shared.

## Recommended repository roadmap

```text
election-forensics-r-toolkit/
├── modules/
│   ├── rzs_data_preparation/     # Current self-contained first module
│   ├── descriptive_statistics/           # Future
│   ├── election_fingerprints/            # Future
│   ├── election_contours/                # Future
│   ├── normality_diagnostics/            # Future
│   ├── turnout_vote_regression/          # Future
│   └── mebane_fmm/                       # Future
├── R/                                    # Future shared: import, QC, selection, reporting
├── tests/                                # Future cross-module integration tests
├── inst/                                 # Future schemas/example non-sensitive fixtures
├── docs/                                 # Future method explanations and limitations
└── app/                                  # Future optional Shiny presentation layer
```

**Now:** only `modules/rzs_data_preparation` exists, with real code. Future entries above are illustrative architecture, **not files already implemented**.

## Proposed interface contracts

**Input contract:** consistent station identifiers, year, administrative names, turnout/count fields, candidate-vote columns and provenance. Schema version must be explicit. **Sample contract:** `Master` never loses audit records; `Main` is a default, not universal, eligible sample; each method declares its selection rule and denominators. **Output contract:** method results are structured tables with configuration, warnings, reproducibility metadata and human-readable interpretations. **Reporting contract:** public-facing visuals include units, sample size, uncertainty, alternative explanations and no unjustified fraud claims.

As soon as methods start sharing code, refactor canonical import/validation into `R/` functions and consider an R package (`DESCRIPTION`, `NAMESPACE`, `renv.lock`) with testthat and continuous integration. Avoid moving to a package before the data model and first two method interfaces are stable. For ongoing automation, add an orchestrator that runs import → validation → analyses → reports; attach Shiny only after output contracts are established. Maintain CLI/batch execution so researchers can reproduce results without opening the app.

## Practical phased delivery

**Phase 1 (now):** publish RZS importer, transparent outputs and tests; validate official totals and edge cases. **Phase 2:** centralize schema, provenance, QC, fixtures and reproducible dependency versions. **Phase 3:** implement descriptive summaries and fingerprints/contours as separate validated methods. **Phase 4:** add regression and model-heavy methods with tests of assumptions, simulation/sensitivity and interpretation. **Phase 5:** implement bilingual public-facing report templates and an optional Shiny UI consuming precomputed outputs. **Phase 6:** versioned release and continuous validation on newly published RZS schemas.

A public dashboard must not turn statistical indicators into automated determinations of misconduct. Require method passports documenting assumptions, uncertainty, false positives and scientific validation.


## Election-type coverage and v1.2 data contract

This module processes Serbian **presidential** candidates and **parliamentary** electoral lists as neutral vote **options**. Set `election_type` to `presidential` or `parliamentary`; combined input rows may share a year, but must not share the same type/year pair. The 2022 parliamentary source is [`G202219002.xlsx`](https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx); save it as `raw_data/Parliament 2022 ~ G202219002.xlsx`. The other configured inputs are the 2017 and 2022 presidential results.

**Validation limitation:** the structure of the 2022 parliamentary XLSX could not be directly inspected in this preparation environment. It is provisionally assigned the `2022` column template; **validate its headers, row totals, option columns and QC results** against the official workbook before analytical use. The script does not support local-election source files without a separately validated schema and (where applicable) constituency-specific winner/list logic.

For both supported types, `Main` remains the default analysis worksheet and `Master` the complete audit-preserving dataset. `Option_01_votes`, `Option_01_pct`, etc., have type-neutral meanings; `Options` maps each option to its source heading. `Winner_*` / `Second_*` are the top two **national vote totals** in the input, not automatically the winner of every constituency or an allocation of seats. No parliamentary seat allocation is performed. Election identifiers now include `Election_type`, protecting against same-year collisions. Outputs are `presidential_2017_RZS_prepared.xlsx`, `presidential_2022_RZS_prepared.xlsx` and `parliamentary_2022_RZS_prepared.xlsx`.

Existing downstream scripts that expected `Candidate_*`, `Candidates`, a year-only station key, or `P2022_RZS_prepared.xlsx` must be adapted to the v1.2 contract.
