# Reproducibility

[Srpski (latinica)](REPRODUCIBILITY_SER.md)

The module reads original source-preserving prepared workbooks, not GitHub-hosted official files. Reproducing an analysis requires: (1) identical official RZS raw XLSX and its provenance, (2) the exact `RZS_data_preparation.R` revision and configuration, (3) the same prepared workbook with matching `MD5`, (4) `Klimek.R` Git commit and the full **EDITABLE** settings, (5) R and package versions, and (6) the choice of languages, plotted groups, options, normalisations and fonts.

National curve rows are sorted by reported `Turnout` and then `Station_key`; no random seed is used. T90/T95 are descriptive and deterministic. Relative paths are resolved against `modules/klimek`. Figures may differ in typography/antialiasing across OS and graphics devices, even if their numbers agree. Save `writeLines(capture.output(sessionInfo()), "sessionInfo.txt")` locally with the configuration and result manifest.

Raw RZS workbooks, generated XLSX, CSV curves and images are excluded from normal Git commits via `.gitignore`. If publishing a derived dataset or figures, use a separately versioned archival release with original-source attribution, data-use checks and a reproducibility note. For share calculations, always distinguish the whole original election from the QC-defined analytical groups.
