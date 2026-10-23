# Output guide

[Srpski (latinica)](OUTPUT_GUIDE_SER.md)

The script creates a separate `klimek_outputs/<election_type>_<year>/` for each election. The exact paths are relative to the `modules/klimek` directory unless `OUTPUT_DIR` is changed.

| Location | Content |
|---|---|
| `<id>_klimek_summary.xlsx` | Styled compact workbook: `Metadata`, `Coverage`, `Options`, `National`, `District`, `Municipality`, `Areas`, `Tail_metrics` |
| `<id>_curve_endpoints.xlsx` | Compact group × option curve endpoints, including options not plotted |
| `tables/metadata.csv` | Configuration, input MD5 and limitations |
| `tables/coverage.csv` | Counts by all eight groups; primary reconciliation file |
| `tables/options.csv` | National ranking, source field and EN/SR label mapping |
| `tables/national.csv` | Eight groups × all options, pooled turnout and option vote shares |
| `tables/district.csv`, `tables/municipality.csv` | Every district/municipality × group × electoral option |
| `tables/areas.csv` | Administrative dictionary, including compound municipality keys |
| `tables/tail_metrics.csv` | Descriptive T90/T95 metrics when enabled; header-only otherwise |
| `tables/curve_endpoints.csv` | All national group × option curve endpoints and valid/option denominators |
| `curves/national/<group>_<option>.csv` | Every national curve's ordered polling-station points when enabled |
| `curves/<selected-area>_...csv` | Curve data for selected optional area plots |
| `figures/<EN|SR>/<valid|option>/<area>/A_<group>_<combined|faceted>.<png|pdf>` | Option comparison within station-size group |
| `figures/<EN|SR>/<valid|option>/<area>/B_<option>_combined_standard.<png|pdf>` | One option, up to six **standard** station groups (separate overlay) |
| `figures/<EN|SR>/<valid|option>/<area>/B_<option>_combined_jhk.<png|pdf>` | One option, two **JHK** station groups (separate overlay) |
| `figures/<EN|SR>/<valid|option>/<area>/B_<option>_faceted.<png|pdf>` | One option, **two panels**: standard and JHK classifications |

CSV uses UTF-8 with BOM; Excel XLSX preserves Unicode. Long point CSV is intentionally not placed inside XLSX (could exceed Excel's row limit). Generated files are ignored by Git. A missing figure can be legitimate for a group with zero valid ballots or an option-normalisation curve whose option has zero votes. Inspect `coverage.csv` and `curve_endpoints.csv` rather than assigning it a fabricated zero curve.

**v0.1.1:** The obsolete eight-curve `B_<option>_combined` figure is deleted on rerun. Numeric tables and CSV curve points are unchanged. A legends have two rows when three or more candidates/lists are displayed.


### Empty territorial group rows (v0.1.4)

District and Municipality sheets / `tables/district.csv` / `tables/municipality.csv` contain every eligible area × reporting group × electoral option. `Stations=0` means there are no eligible stations in that group for that area. Counts are zero; turnout and option share are undefined and exported as `NA` (literal text in these two territorial files/sheets). Such a row is not an observation and must never be treated as 0% turnout or 0% share. A missing territorial area is not created when no stations from the eligible `ALL` population belong to it.
