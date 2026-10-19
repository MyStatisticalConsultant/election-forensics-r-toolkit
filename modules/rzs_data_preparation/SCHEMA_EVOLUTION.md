# Extending RZS election source schemas safely

**Current limitation:** `RZS_data_preparation.R` uses positional templates (`2017`/`2022`) and currently treats **all columns after** the last required ballot field as presidential candidates or parliamentary electoral lists (2017: columns 15 onward; 2022: columns 11 onward). Thus a new future RZS field such as “voted with assistance” or “voted outside the polling station”, when inserted before, between or after option-vote columns, **will not be interpreted safely**. Even if the raw `V1`, `V2`, … data survive, the added field may be mistaken for an electoral option and cause false vote-sum violations, rejected stations or an incorrect option dictionary. Never assume later source files remain compatible merely because the number of columns is larger.

## Recommended future schema contract (planned, not implemented)

1. Introduce per-election schema metadata mapping **source header/column** → canonical variable name, expected type, unit, required/optional, and permitted missingness; include the official URL and source checksum.
2. Identify candidate/list vote columns explicitly by **header patterns plus human-reviewed option map**, never by “all columns to the right of B”. Keep a documented `Options` dictionary.
3. Add a separate extensible group of optional administrative fields, e.g. `Assisted_voters`, `Outside_station_voters`, `Mobile_voters`, `Complaints_count`; retain original raw headings and distinguish unavailable (`NA`) from observed zero.
4. Use a **fail-closed** validation policy: unidentified/ambiguous column names or changes in mandatory columns must stop import with a precise message, not quietly produce results.
5. Add cross-field checks only where justified by official definitions: e.g. assisted/outside station counts may overlap, so **do not sum them into turnout** or assume categories are mutually exclusive without source documentation.
6. Version each schema, add a per-election mapping test fixture and regression tests, and publish a new data-dictionary version before enabling it for production.

This change belongs upstream in `RZS_data_preparation.R`; the descriptive module can then be extended by selecting additional canonical fields and incorporating them into aggregate and correlation outputs, without changing the rest of the pipeline.
