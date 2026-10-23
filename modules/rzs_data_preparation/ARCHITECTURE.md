# Toolkit architecture and modular development plan

[Srpski (latinica)](ARCHITECTURE_SER.md) · [Current module registry](../../MODULE_REGISTRY.md) · [Execution workflow](../../WORKFLOW.md)

## Why modular development is appropriate

Developing one method at a time is appropriate when each module is independently testable, consumes a stable data contract and emits documented numerical results. The alternative—a single script continually expanded with many unrelated models—would increase coupling, make failures harder to trace, encourage repeated imports and risk inconsistent definitions of eligible polling stations.

## Implemented structure (Toolkit v1.7.9)

```text
election-forensics-r-toolkit/
├── README.md / README_SER.md
├── MODULE_REGISTRY.md / MODULE_REGISTRY_SER.md
├── WORKFLOW.md / WORKFLOW_SER.md
└── modules/
    ├── rzs_data_preparation/      # implemented; tested for three elections
    │   └── RZS_data_preparation.R
    ├── descriptive_statistics/    # implemented v0.3.1; validated within scope
    │   ├── Descriptive_statistics.R
    │   └── R/                     # reusable descriptive functions
    └── klimek/                    # v0.1.4; researcher-validated for parliamentary 2022
        └── Klimek.R
```

**Planned, not implemented:** fingerprints, contours, normality diagnostics, turnout–vote regressions, Mebane finite-mixture models, shared orchestration, full R package metadata and a public Shiny interface. Never describe these as existing code.

## Data contract and execution independence

The data-preparation module reads official RZS source XLSX files and writes election-specific workbooks with `Master`, `Main`, `Options` and QC/metadata. The descriptive and Klimek modules each read those outputs **directly and independently**. Neither downstream module needs the other to be run; upstream preparation is not rerun unless input workbooks are missing, changed or incompatible with the code/assumptions. See [workflow](../../WORKFLOW.md).

`Master` retains QC context, `Main` is the standard eligible analysis set (E >= 100), and the `Options` worksheet maps all candidates/electoral lists into neutral `Option_*` fields. Method-specific definitions must describe sample selection and denominators. The descriptive and Klimek modules can separately report QC-accepted polling stations with fewer than 100 voters; neither silently promotes them into `Main`.

Each method must declare its output tables, configuration, diagnostic warnings, numerical assumptions, validation evidence and interpretation limits. Figure appearance and public-facing narrative are distinct from inference; no curve or significant correlation proves manipulation without corroboration.

## Evolution without breaking existing modules

1. Freeze/document a working input schema and versioned output contract; record source hash, run parameters and software environment.
2. Develop a new method as a separate `modules/<name>/` folder, starting with synthetic tests and then three-election integration tests, where applicable.
3. Ensure the new module reads prepared datasets in place; it should not rewrite the source or other module outputs.
4. Add bilingual documentation, update the repository root and *all affected existing modules' current documents*, and run the release checklist.
5. Only later consider shared library extraction (`R/`), `testthat`, `renv`, GitHub Actions, orchestrated execution and a Shiny reporting interface once data contracts are stable. Preserve simple stand-alone execution.

## Scope restrictions

The current preparation importer handles validated 2017/2022 presidential/parliamentary positional templates. New RZS columns can change option positions; add a **versioned, heading/role-based schema mapping** before claiming compatibility with an extended source. Local elections require separately tested source schemas and electoral-unit rules.

The 2017 RZS/RIK registered-electorate difference remains documented as **REVIEW**, not silently corrected. See [validation findings](VALIDATION_FINDINGS.md).
