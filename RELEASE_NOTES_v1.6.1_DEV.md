# Election Forensics R Toolkit v1.6.1-dev — 100-or-more analytic population

The descriptive-statistics module v0.3.1 adds an explicit **100 or more** group equivalent to `RZS_data_preparation.R` workbook `Main` in all reporting levels and Word tables. The `All` group remains `Main` plus QC-approved under-100 stations. Both Size and Size_JHK partitions independently reconstruct Main.

Two new aggregate correlation matrices (`D_08` and `M_08`) give **16 matrices per election**; 01–07 identifiers are retained for backward compatibility. Automated tests cover the group reconciliations. No change to the preparation script, actual voter counts, class thresholds or inferential-test definitions.

**Development status:** source files updated and archive inspected; run RStudio tests and exports locally before tagging as stable.
