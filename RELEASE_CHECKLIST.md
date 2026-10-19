# Release checklist — Election Forensics R Toolkit

[Srpski](RELEASE_CHECKLIST_SER.md)

Use this list before marking the GitHub release stable. Checking one item does **not** imply that unrelated statistical claims have been independently validated.

- [ ] Repository tree contains root README in **EN and SR-Lat**, MIT licence, citation metadata, `.gitignore`, both modules and their paired documentation.
- [ ] Code filenames/version match documentation (`RZS_data_preparation.R` in its existing tested version; descriptive module **v0.3.1**).
- [ ] `raw_data/`, `RZS_prepared/`, `descriptive_outputs/`, `validation_results/` are not accidentally staged for Git.
- [ ] Official RZS files are preserved unmodified; upstream preparation tests and official-total comparison run, with 2017 registered-voter **REVIEW** prominently recorded.
- [ ] All seven descriptive test/run commands succeed against the same three source workbooks and same commit.
- [ ] Preserve a complete, dated RStudio console log and sanitized `sessionInfo()`; archive software/package versions and input file hashes.
- [ ] Check `100 or more` equals `Main` for all three elections; `All` and both size partitions reconcile nationally and geographically.
- [ ] Compare key R-generated vote counts, robust statistics and representative p/q-values with independent implementations/references; document any tolerance/tie differences.
- [ ] Confirm 16 ecological matrices per election, group significance test export, Unicode display of ŠĐŽČĆšđžčć and separate Word for each election.
- [ ] Check Word table headings, wide table pagination, journal appendix labels and p-value formatting.
- [ ] Inspect all relative EN/SR documentation links on GitHub; record release tag and commit SHA in journal citations.
- [ ] Describe scope as **validated for the three tested election datasets**, not universally guaranteed or evidence of election fraud.

A versioned generated workbook/report may be attached separately to a GitHub Release only with provenance, checksum and applicable redistribution review; not as ordinary Git source.
