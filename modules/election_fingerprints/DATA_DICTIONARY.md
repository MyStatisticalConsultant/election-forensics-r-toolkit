# Input and derived data dictionary

[Serbian](DATA_DICTIONARY_SER.md)

The upstream canonical RZS workbook (one per election) must include `Main` and `Options`.

| Field | Definition | Role |
|---|---|---|
| `Station_key` | Stable prepared polling-station identifier | Duplicate and audit control |
| `Election_type`, `Year` | Election metadata | Validate input selection |
| `District_code`, `District` | RZS district ID and name | Localized district figures |
| `Municipality_code`, `Municipality` | RZS municipality ID and name | Composite municipality ID and figures |
| `Eligible_primary` | Approved Main inclusion flag | Must be `TRUE` |
| `E` | Registered voters | Denominator of both turnout definitions; `E>=100` |
| `B` | Valid ballots | Primary turnout numerator and **vote-share denominator** |
| `C` | Ballots cast | Sensitivity turnout numerator |
| `Option_XX_votes` | Official votes for option XX | Vote-share numerator |

The `Options` sheet provides `Votes_field`, `Option_name_SR_Lat`, `Total_votes`; `Total_votes` selects the **national** winner, never a district winner. The `Main` sample is not enlarged with stations below 100.

Each exported audit row includes identifiers, `E`, `B`, `C`, `Option_votes`, `turnout_pct`, `share_pct` and `Status` (`included`, `invalid_electorate`, `invalid_valid_ballots`, `invalid_option_votes`, `invalid_turnout_numerator`, `out_of_range`). Reasons are assigned in the named priority order. No missing values are silently reconstructed or replaced.


## Size-group source fields

`Main.Size` must contain `Small`, `Middle`, or `Large`, while `Main.Size_JHK` must contain `Small` or `Large`. Each canonical polling-station record is assigned to exactly one group in each classification. The size-group outputs preserve all original `Station_key`, vote counts, geography and QC conditions. Status output adds size-group code and bilingual full descriptions; `N_main` refers to the selected subgroup, with `N_area_main` the entire region's Main sample.
