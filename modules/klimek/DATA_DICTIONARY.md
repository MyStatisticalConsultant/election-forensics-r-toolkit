# Data dictionary

[Srpski (latinica)](DATA_DICTIONARY_SER.md)

## Required input fields

| Field | Definition | Unit/notes |
|---|---|---|
| `Election_type`, `Year` | Type and year | A presidential and parliamentary election may share a year |
| `Station_key` | Unique station ID | Includes election type, year, district, municipality and polling station |
| `District_code`, `Municipality_code` | Administrative codes | Treated as strings; municipality key combines both |
| `District`, `Municipality` | Human-readable names | Serbian-Latin Unicode retained |
| `E` | Registered electorate | Integer persons |
| `C` | Ballots cast (in box) | Integer ballots |
| `B` | Valid ballots | Integer ballots |
| `I` | Invalid ballots | Integer ballots; `C=B+I` QC identity |
| `Turnout` | `100*C/E` | Percentage points |
| `Option_XX_votes` | Count for candidate/list | From `Options.Votes_field`, NOT guessed from a percentage suffix |
| `Size` | Small/Middle/Large | Upstream cumulative-electorate size grouping |
| `Size_JHK` | Small/Large | Upstream 20th-size-percentile complement |
| `Eligible_primary` | Use in Main | Boolean QC eligibility |
| `Under_100` | `E<100` | Boolean flag; extra QC checks apply |
| `Admin_no_ballots`, `Admin_invalid`, `Invalid_numeric` | QC decisions | Exclude unacceptable under-100 records |

## Key outputs

| Field | Definition |
|---|---|
| `Group` | One of eight `ALL, GE100, LT100, SMALL, MIDDLE, LARGE, JHK_SMALL, JHK_LARGE` |
| `Area_level` | `National`, `District`, or `Municipality` |
| `Area_key` | `ALL`, district code, or `District_code|Municipality_code` |
| `Stations` / `Polling_stations` | Count of stations in selected group/area |
| `Registered`, `Ballots_cast`, `Valid_ballots`, `Invalid_ballots` | Sums of canonical counts |
| `Option_field`, `Option_votes`, `Option_share_pct` | Option reference, vote sum and `100*votes/valid` |
| `Turnout_pct` | `100*sum(C)/sum(E)`; not mean station turnout |
| `Cum_votes` | Cumulative option votes after sorting by turnout |
| `Y_valid` | `100*Cum_votes/total valid ballots` |
| `Y_option` | `100*Cum_votes/total option votes`, undefined if zero |
| `Total_valid`, `Total_option_votes` | Curve denominators |
| `Curve_option_endpoint_pct` | Final `Y_option` (100 or NA) |
| `Tail` | 0.90 or 0.95 turnout percentile when enabled |
| `Turnout_cutoff`, `N_stations` | Threshold and stations in tail |
| `Mean_station_margin_pp` | Unweighted mean station-level percentage-point bloc margin |
| `Pooled_margin_pp` | Pooled valid-ballot-weighted bloc margin |
| `Input MD5` | Hash of the locally prepared Excel workbook, not the original source |

`Options.Total_votes` identifies national ranking from the **complete input source** and is used for selecting displayed options, not as the default group's denominator. Numerators and denominators in reports come from the selected sample. No p-values are defined for the descriptive cumulative curves.
