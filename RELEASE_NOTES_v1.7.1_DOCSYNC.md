# v1.7.1-docsync (documentation update; development release)

This is a **documentation synchronisation only** of the v1.7 development repository. All existing `.R` source files, validation logic and statistical formulas are unchanged. The new `klimek` v0.1.0-dev module still requires RStudio execution and visual figure checks before it can be called validated.

Updated root EN/SR READMEs, upload guides, release checklists; added EN/SR workflow and module registry; updated preparation-module EN/SR architecture and README, and Klimek EN/SR user-guide instructions for reusing already prepared workbooks. Historical release notes remain unchanged. `MANIFEST.sha256` was regenerated after the documentation updates.

**Operational change in guidance:** A new module is installed by adding its folder plus synchronizing affected documentation, not by reinstalling or rerunning everything. Reuse existing `RZS_prepared` files if their schema and source content are still valid. Preserve local raw/prepared/generated data.
