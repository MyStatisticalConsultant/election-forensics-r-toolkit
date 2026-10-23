# Replace the published Klimek folder — v0.1.4 (23 October 2026)

[Srpski (latinica)](GITHUB_REPLACE_KLIMEK_SER.md) · [Module README](modules/klimek/README.md) · [Validation](modules/klimek/VALIDATION.md)

The GitHub repository currently contains Klimek **0.1.0-dev**. Publish **one complete replacement** of `modules/klimek/`, not a chain of patches. Only the code and documentation change; there is no need to rerun RZS preparation or descriptive statistics when the prepared inputs are unchanged.

## Preferred method: GitHub Desktop / Git + local file manager

1. **Preserve the repository history.** Pull the latest `main` branch and make a backup of local edits. Do *not* delete the repository or `modules/rzs_data_preparation/` or `modules/descriptive_statistics/`.
2. From the release ZIP `Klimek_v0.1.4_GitHub_Module.zip`, extract `modules/klimek/` into a temporary location. **The ZIP's top-level `modules/` is a folder structure, not a second nested `modules/` directory to put inside the existing module.**
3. In the locally cloned repository, delete the existing **`modules/klimek/` directory only**, and replace it with the extracted new `modules/klimek/`. This removes obsolete files from the old version and makes additions/deletions visible to Git.
4. Also copy the modified **root documentation** from `Election_Forensics_R_Toolkit_v1.7.9_GitHub.zip`, particularly `README*.md`, `MODULE_REGISTRY*.md`, `WORKFLOW*.md`, `GITHUB_UPLOAD_GUIDE*.md`, `RELEASE_CHECKLIST*.md`, `CITATION.cff`, `GITHUB_REPLACE_KLIMEK*.md`, and `RELEASE_NOTES_v1.7.9.md`. **The supplied root `MANIFEST.sha256` is valid for the complete v1.7.9 snapshot only.** If you merge selectively into an older GitHub tree, regenerate the root manifest from the exact final tracked files rather than copying a checksum list that describes files you did not upload. Do not overwrite user-customized R code in the other two modules.
5. Review changed files using `git status`; ensure generated datasets, raw workbooks and `klimek_outputs/` are not included. Commit and push.

Example command-line steps **after** extracting the module archive to a temporary directory, from the repository root (adapt the source path):

```bash
git pull --ff-only
# Back up any uncommitted edits to modules/klimek before removing it.
git rm -r modules/klimek
cp -R /path/to/extracted/modules/klimek modules/klimek
git add modules/klimek
git status
# Copy updated root documentation, check the diff, then:
git add -A
git commit -m "Release Klimek v0.1.4 and synchronize toolkit documentation"
git push
```

On Windows, use GitHub Desktop with File Explorer to replace the folder; avoid copying the new `klimek/` directory **inside** the old `klimek/` directory. A browser-only GitHub upload is poor for multi-file deletions; use Desktop or Git to guarantee that obsolete files are removed.

## Quality gate

From `modules/klimek/` in RStudio, run all **seven commands** below (five test scripts + generator + export check):

```r
source("tests/run_tests.R")
source("tests/test_graphics_layout.R")
source("tests/test_single_station_plots.R")
source("tests/test_zero_station_groups.R")
source("tests/integration_real_data.R")
source("Klimek.R")
source("tests/check_exports.R")
```

Review an A and B graph in each language, the special RZS reporting categories 33/55, an ordinary district, and the 0/1/2+ station cases. Save the console transcript, `sessionInfo()`, source workbook hashes and relevant figures. The researcher reported that these plots look correct; a full seven-command test log has not yet been provided. Tag `klimek-v0.1.4` / `v1.7.9` **after** the tests pass. Do not claim independent runtime verification before that point.

The consolidated module includes `Klimek.R`, six files under `tests/`, `examples/`, bilingual methodology, guides, changelogs and SHA-256 manifest. No source data or generated output images are included.
