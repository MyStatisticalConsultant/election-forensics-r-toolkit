# Publishing the Election Forensics R Toolkit on GitHub

[Srpski](GITHUB_UPLOAD_GUIDE_SER.md) · [Repository README](README.md)

## Recommended publication choice

Publish **one GitHub repository** called `election-forensics-r-toolkit`, containing both modules in `modules/`. Do **not** create a second stand-alone repository for descriptive statistics unless you deliberately want two separately maintained releases. A single repository preserves the tested data contract between preparation and analysis. The descriptive module has its **own** README, tests, change history and citation metadata within the larger repository.

The **code version** remains descriptive module **v0.3.1** and preparation module **v1.3.1**; this package's edits are documentation-only. Consider a repository tag only after completing the [release checklist](RELEASE_CHECKLIST.md). The repository version shown in prior development archives is `v1.6.1-dev`; do not use an unearned “production validated” badge.

## What to upload (and in which order)

GitHub's web upload is simplest for the first publication:

1. Create an **empty public repository** named `election-forensics-r-toolkit`. Add a short description, such as *Open R toolkit for reproducible Serbian election data preparation and descriptive election forensics*. Choose **not** to auto-add a new README, `.gitignore` or licence because they already exist in this package.
2. **Extract the supplied full toolkit ZIP locally.** Open its `election-forensics-r-toolkit/` folder; upload the **contents of this folder** (not the surrounding distribution ZIP) to the repository root. GitHub's **Add file > Upload files** accepts a directory dropped into the browser in supported browsers; for extensive trees prefer Git command line or GitHub Desktop.
3. Ensure the top-level files appear: `README.md`, `README_SER.md`, `LICENSE`, `CITATION.cff`, `.gitignore`, `GITHUB_UPLOAD_GUIDE*.md`, `RELEASE_CHECKLIST*.md` and the release notes/manifests.
4. Confirm `modules/rzs_data_preparation/` contains `RZS_data_preparation.R`, its original **EN/SR documentation**, `RZS_station_status_overrides_TEMPLATE.csv`, `examples/` and `tests/` including the official reference CSVs and `validate_official_totals.R`.
5. Confirm `modules/descriptive_statistics/` contains `Descriptive_statistics.R`, `R/descriptive_core.R`, `R/descriptive_extended.R`, both README languages, other paired EN/SR `.md` files, `tests/` with seven tests/reference CSV, `examples/`, and `docs/publication/` with four EN/SR Word guides.
6. Commit with a factual message such as `Publish tested preparation and descriptive modules with bilingual documentation`. Check GitHub's rendered README links, file trees, language/diacritic display and licence detection.
7. Run the local release tests against the **same commit** and retain the successful v0.3.1 RStudio console output; update release documentation only if the evidence supports it. Then create the first **GitHub Release** or tag, noting the dataset scope and the 2017 upstream REVIEW item.

For future updates, prefer Git commits/branches or pull requests rather than repeatedly replacing the entire tree. An existing Git repository can use:

```bash
cd election-forensics-r-toolkit
git init
git add .
git status
git commit -m "Add election data preparation and descriptive modules"
git branch -M main
git remote add origin https://github.com/USERNAME/election-forensics-r-toolkit.git
git push -u origin main
```

Replace `USERNAME` with your GitHub username **only after creating the repository**. Never place access tokens or secrets in commands, R source files or commits. If using GitHub Desktop, choose **Add an Existing Repository**, review changed files, commit and publish.

## Do not upload ordinary working/output directories

| Directory or file | Upload to Git repository? | Reason |
|---|---|---|
| `modules/rzs_data_preparation/raw_data/` with three official XLSX files | **No** | Link to source and download locally; preserve source hashes and applicable terms |
| `modules/rzs_data_preparation/RZS_prepared/` with derived XLSX/CSV | **No** | Reproducible generated data; can be distributed as explicit release assets if desired |
| `modules/descriptive_statistics/descriptive_outputs/` | **No** | Generated Excel/CSV/Word; journal supplements or a versioned Release asset are better |
| `**/validation_results/` | **No**, not as automatic working files | Publish a reviewed snapshot under `docs/validation/` *only if* preserving its provenance |
| `tests/` in both modules | **Yes** | Executable checks and fixed reference values are essential |
| `examples/` in both modules | **Yes** | User guidance and usage examples |
| `docs/publication/` | **Yes** | Four educational English/Serbian Word files are part of the documentation |
| `MANIFEST.sha256` | **Yes**, after regenerating | Hashes of tracked files in the documentation release |

The `.gitignore` already protects raw/derived outputs. To avoid accidentally bypassing it, inspect `git status` and **do not use `git add -f`** on excluded data. If you deliberately publish prepared workbooks as separate GitHub Release assets, state the exact RZS source, version, sample definitions and SHA-256 hash, and distinguish them from code.

## No upstream numerical code changes

**Do not change `modules/rzs_data_preparation/RZS_data_preparation.R` for this documentation release.** Both modules already agree on `Main`, `Master`, `Options`, national size groups and QC flags. The future need for heading/role-based imports is documented in `SCHEMA_EVOLUTION.md`; it should be implemented as a **separate tested version** rather than an unvalidated last-minute change.

## Final review

Complete [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md). If a different prepared-data version was used for tests than for the journal tables, repeat the tests and update the records. A public GitHub commit history and exact release tag make citing and reproducing the analysis considerably easier.
