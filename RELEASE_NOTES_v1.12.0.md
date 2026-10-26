# Election Forensics R Toolkit — v1.12.0

Release date: 26 October 2026.

## Added

- **`shpilkin` v0.1.3** (`modules/shpilkin/`), an independent module with three complementary analyses of polling-station results.
- Turnout and winner-vote descriptive histograms, with configurable bin widths and English/Serbian-Latin PNG outputs.
- Kobak–Shpilkin–Pshenichnikov (2016) integer-percentage anomaly diagnostics: registered-electorate-weighted 0.1-percentage-point histograms, near-integer windows of ±0.05 percentage points, binomial Monte Carlo reference distributions, and integer/half-integer controls.
- An explicitly **conditional** Shpilkin-style excess-votes scenario using turnout bins and a reference winner-to-other-valid-votes ratio. Its automatic modal-turnout reference interval is a descriptive choice, not an independently verified fraud-free baseline. Reference-width sensitivity is exported separately.
- CSV files for polling-station eligibility, binned summaries, Monte Carlo replicates and reference envelopes, excess-votes intermediate calculations and sensitivity; bilingual methodology, README and output guides.
- Root documentation, `.gitignore`, citation metadata and checksum manifest updated. Existing analytical modules are unchanged.

## Validation and interpretation

Validation scope: numerical, bilingual-graphics, real-data contract and export test suites passed in RStudio for presidential 2017/2022 and parliamentary 2022. These integration tests did **not** independently reconcile all results against official electoral totals. The default 999 Monte Carlo repetitions are exploratory; 10,000 match the source paper's simulation count more closely.

**Neither a zero conditional excess estimate nor an absence of detected integer-percentage anomalies establishes that an election was free of fraud. A positive conditional estimate is not an identified number of fraudulent ballots.** Interpret the three analyses separately, taking turnout definitions (`C/E` primary; `B/E` sensitivity), election context, model assumptions and data quality into account.

See [Shpilkin README](modules/shpilkin/README.md), [methodology](modules/shpilkin/METHODOLOGY.md), and [previous release notes](RELEASE_NOTES_v1.11.0.md).

**Excess-vote figures:** Curve-following grey polygons mark only positive differences beyond the upper reference boundary. The bottom annotation is deliberately split into two lines (English and Serbian-Latin) so it is fully visible in PNG exports. Numeric excess remains the sum of positive turnout-bin residuals, not the geometric area. The plotting tests check polygon geometry, interpolated crossings and caption layout; run them locally with `source("tests/test_graphics.R")`.
