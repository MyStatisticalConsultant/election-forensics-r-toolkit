# Release checklist — Election Forensics R Toolkit

[Srpski (latinica)](RELEASE_CHECKLIST_SER.md) · [Registry](MODULE_REGISTRY.md) · [Workflow](WORKFLOW.md)

## Repository and documentation — required on every new module

- [ ] Inventory **all current** `.md` files in the root and every module, EN/SR: no obsolete claims about which modules exist, are planned, or are validated.
- [ ] Check root README/README_SER, module registry, architecture EN/SR, upload guide, workflow EN/SR, installation sections, method links, output lists, citations and version information.
- [ ] Verify all documentation navigation links, working-directory commands and relative `INPUTS` paths; distinguish new module prerequisites from the first-time preparation workflow.
- [ ] Check `LICENSE`, `CITATION.cff`, `.gitignore`, SHA-256 manifest, new module tests and bilingual method/user guides.
- [ ] Keep historical changelogs and prior release notes intact as evidence of earlier states; publish new release notes for the current release.
- [ ] Confirm new-module changes do not accidentally alter previously validated R source files or existing local data.

## Data and analytical checks

- [ ] RZS preparation: source/official-total checks, `Main`/`Master`/`Options` data contract, and documented 2017 registered-voter **REVIEW**.
- [ ] Descriptive v0.3.1: synthetic + integration + export tests for three named elections; `100 or more == Main`; eight overlapping groups, 16 aggregate correlation matrices, publication outputs and Unicode.
- [ ] Klimek v0.1.4: from `modules/klimek/` run all seven commands in [the upload guide](GITHUB_REPLACE_KLIMEK.md): `run_tests`, `test_graphics_layout`, `test_single_station_plots`, `test_zero_station_groups`, `integration_real_data`, `Klimek.R`, `check_exports`.
- [ ] Confirm SR/EN A and B titles, readable legends, 10%-point y-axis ticks, standard/JHK separation and RZS district categories 33, 55 and 25–29.
- [ ] Check 0 BM = no plot and `Stations=0` / `NA` in territory tables; 1 BM = point; 2+ BM = line; no stale selected-area images.
- [ ] Verify curve endpoints for both normalisations, all option totals, eight overlapping groups and colour/Unicode output.
- [ ] Save dated test logs, R `sessionInfo()`, input hashes and representative screenshots; do not claim independent Klimek validation without those checks.
- [ ] Do not interpret descriptive curves as proof of fraud.

## Publishing

- [ ] Only source, tests, documentation and intentional reference results are committed; raw XLSX, prepared XLSX and generated reports remain excluded unless separately published with provenance.
- [ ] Check Git status/diff, README link rendering, release tag and accurate statuses for all three modules.
- [ ] Provide honest release notes distinguishing documentation-only changes from methodological/code changes.
