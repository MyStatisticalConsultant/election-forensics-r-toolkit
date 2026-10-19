# Contributing to the descriptive module

[Srpski](CONTRIBUTING_SER.md)

Contributions are welcome for **documented bugs, reproducibility, tests, metadata completeness, translations and new analysis modules**. Please open a GitHub Issue first for a substantive change so that sampling, statistical definitions and output compatibility can be discussed.

1. Describe the intended calculation and unit of analysis, expected input fields, whether it uses `Main` or accepted under-100 stations, and how `Size`/`Size_JHK` are treated.
2. Add a small synthetic fixture with known expected counts or coefficients; where possible add an independent comparison for one of the three existing election workbooks.
3. Keep the prepared RZS data immutable. Never silently drop station records or replace undefined shares with zero.
4. Preserve Serbian characters in UTF-8 and update both EN and `_SER.md` descriptions; maintain stable variable and correlation-matrix identifiers or document a breaking change.
5. Run all seven test/runner commands from the module README and report R version/package versions; do not submit generated data directories as normal source changes.
6. Avoid claims of fraud based only on a statistical flag. Describe alternative explanations, uncertainties and qualitative verification steps.

**Known future extension:** replace positional source templates in the upstream RZS module with a versioned role/heading schema before supporting additional RZS administrative columns or local elections. This belongs upstream, not in the descriptive module.

Code is covered by the repository's [MIT licence](../../LICENSE). Copyright © 2026 Zlatko J. Kovačić.
