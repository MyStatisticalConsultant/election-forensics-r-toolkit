# Election Forensics R Toolkit — v1.10.0

Release date: 25 October 2026.

## Added

- **Voter-rigging diagnostics v0.1.1**, independent module in `modules/voter_rigging/`, based on Jimenez, Hidalgo and Klimek (2017).
- Polling-station source: QC-eligible observations from the `Master` worksheet, including stations with fewer than 100 registered voters.
- Municipal leave-one-out turnout/winner-share standardisation, 95% covariance-ellipse filtering, coordinate-wise median distances `D(p)` for 0.5%–90% size thresholds and cumulative winner-vote-share curves.
- Turnout specifications A (`B/E`) and B (`C/E`), optional exploratory permutation checks, and national/district/municipality reporting.
- English and Serbian-Latin Figure 4-style PNG visualisations with readable, multi-row election legends; 50% reference line in panel B; intermediate/final CSVs; executable synthetic, graphics, real-data integration and export tests.
- Updated root documentation and Git ignore rules. Previous modules and release notes are unchanged.

## Interpretation

**This module reports descriptive `D(p)` only, not the reference-standardised `δ(p)` or its formal significance/rejection region.** The source article's international comparison depends on comparable reference elections not available in these input workbooks. Exploratory patterns can motivate additional checks but do not establish misconduct. The module README and methodology documents explain this limitation and future reference-data requirements.

See [module documentation](modules/voter_rigging/README.md) and [previous release notes](RELEASE_NOTES_v1.9.0.md).
