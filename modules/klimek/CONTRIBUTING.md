# Contributing

[Srpski (latinica)](CONTRIBUTING_SER.md)

Contributions and corrections are welcome via GitHub Issues or pull requests. Before changing calculations, document the target election type/schema, affected input/output fields, statistical rationale, and any implications for station inclusion. Include synthetic tests for all nontrivial helpers and real-data reconciliation tests against supported prepared workbooks. Never modify the `RZS_data_preparation.R` or original source records silently. Any proposed significance test must state a defensible null hypothesis and account for geographical confounding and multiplicity as appropriate. Contributions to graph translations, accessible colours and documentation should be bilingual when practical. Keep raw official XLSX and generated outputs out of regular source commits.
