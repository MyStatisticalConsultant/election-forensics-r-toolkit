# Publishing and updating the Election Forensics R Toolkit on GitHub

[Srpski (latinica)](GITHUB_UPLOAD_GUIDE_SER.md) · [Workflow](WORKFLOW.md) · [Release checklist](RELEASE_CHECKLIST.md)

## Current repository (v1.7.9 consolidated release)

Maintain **one** GitHub repository, `election-forensics-r-toolkit`, containing three modules:

| Module | Code status | Function |
|---|---|---|
| [`rzs_data_preparation`](modules/rzs_data_preparation/README.md) | Previously tested, one 2017 registered-voter REVIEW | Creates `Master`, `Main`, `Options`, QC and metadata |
| [`descriptive_statistics`](modules/descriptive_statistics/README.md) v0.3.1 | Tested against the three supported elections, within documented scope | National/district/municipality descriptives, correlations and reports |
| [`klimek`](modules/klimek/README.md) v0.1.4 | **Pending local RStudio validation** | Cumulative vote–turnout curves and EN/SR figures |

The original data and generated workbooks stay on the user's machine. **Do not describe Klimek as validated until its tests and figure inspection have passed.**

## A. First publication of the complete repository

1. Create a public GitHub repository named `election-forensics-r-toolkit`, initially empty (do not ask GitHub to add a README, licence or `.gitignore`).
2. Extract the **full toolkit ZIP** locally. Upload/commit the **contents** of its `election-forensics-r-toolkit/` directory, keeping relative paths unchanged. Prefer GitHub Desktop or Git for multi-folder updates.
3. Check root `README.md`, `README_SER.md`, `.gitignore`, `LICENSE`, `CITATION.cff`, `MODULE_REGISTRY*.md`, `WORKFLOW*.md`, the upload guides, release checklists and the checksum manifest.
4. Check all three subdirectories under `modules/`: `rzs_data_preparation/`, `descriptive_statistics/`, and `klimek/`. Include source code, `tests/`, `examples/`, English/Serbian documentation, and the descriptive module's four publication Word guides.
5. Run the applicable tests against the **same local source files and code revision**; see [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md). Record results and limitations. Do not imply that Klimek passed before it has actually run.
6. Check Markdown links, Unicode diacritics, and relative paths on GitHub before tagging a release.

## B. Adding a module to an existing repository (recommended routine)

**Do not delete or reinstall the repository.** With the existing working copy:

1. Keep a backup/commit of the validated state. From the new toolkit archive, copy only `modules/<new_module>/` into your existing `modules/` directory. Do not place the full new repository **inside** the old one.
2. From the new release, merge the explicitly changed *root* documentation and configuration files (`README*.md`, `MODULE_REGISTRY*.md`, `WORKFLOW*.md`, `GITHUB_UPLOAD_GUIDE*.md`, `RELEASE_CHECKLIST*.md`, and other specifically changed files). Use GitHub Desktop's **Changes** view or `git diff` to review replacements.
3. Update previous-module documentation **only where its current statements have become outdated** (for example architecture maps, upstream/downstream links or installation guidance). Do not overwrite locally modified working scripts, parameter settings or prepared datasets without reviewing differences.
4. Verify `.gitignore` covers the new module's generated outputs. Run the new module's synthetic, real-data and export tests; inspect its published graphical outputs.
5. Commit a coherent update such as `Add Klimek module and synchronize EN/SR documentation`, then push. Tag/release only after distinguishing validated and development components.

For subsequent incremental changes, prefer commits or pull requests. Git is not required to *run* modules; it is strongly recommended for preserving working code and documentation history.

## C. Generated datasets and products are not repository source files

Do **not** commit `modules/rzs_data_preparation/raw_data/`, `modules/rzs_data_preparation/RZS_prepared/`, `modules/descriptive_statistics/descriptive_outputs/`, `modules/klimek/klimek_outputs/`, or automatically generated `validation_results/`. The `.gitignore` excludes these paths. You may publish explicitly reviewed results as separately documented GitHub Release assets, subject to source-data conditions and provenance.

Do commit `tests/`, documented official reference values, `examples/`, method documentation, and any deliberately tracked validation evidence with source hashes. Review `git status` before a push; never force-add excluded private/local data.

## D. Preserve separate analyses

You can execute **only Klimek** from `modules/klimek/` when the three prepared XLSX workbooks already exist at `../rzs_data_preparation/RZS_prepared/`. You need not rerun `RZS_data_preparation.R` or `Descriptive_statistics.R`. See the [step-by-step workflow](WORKFLOW.md).

## E. Documentation maintenance rule

Every module addition requires a full inventory check of **all current `.md` documentation** in the repository and **both languages**. Update module lists, availability statements, architecture diagrams, sample contracts, paths, status/validation claims, user guides, release checklists and root navigation. Historical changelogs and prior release notes remain historical records and should not be silently rewritten. Include a link/consistency audit and a regenerated `MANIFEST.sha256` in each new archive.

Copyright © 2026 Zlatko J. Kovačić. [MIT licence](LICENSE).

**Current Klimek replacement (v0.1.4):** [GITHUB_REPLACE_KLIMEK.md](GITHUB_REPLACE_KLIMEK.md).
