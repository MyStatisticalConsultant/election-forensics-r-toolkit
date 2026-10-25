# Approximate normality — Election Forensics R Toolkit

[Srpski (latinica)](README_SER.md) · [Methodology](METHODOLOGY.md) · [Output guide](OUTPUT_GUIDE.md)

**Module:** `approximate_normality` · **Version:** `0.1.2` · **Entry point:** `Approximate_normality.R`

This R module implements the **rescaled logarithmic vote-rate** construction described by Klimek, Yegorov, Hanel and Thurner (2012), *Statistical detection of systematic election irregularities*, *PNAS* 109(41), 16469–16473, https://doi.org/10.1073/pnas.1210722109. Its primary graphics follow the empirical, **binned-and-connected** presentation of their Figure 2. They are **not kernel-density estimates (KDE)**.

## Scope and scientific interpretation

The primary comparison places the election-wide distributions on a common zero-mean, unit-SD scale and compares each election with the expected bin probabilities of a standard normal distribution. An additional, explicitly designated Toolkit extension contrasts all eligible stations with the pre-existing `Size`-defined Small and Large groups, **using the same election/area standardization for all groups**. Polling stations with fewer than 100 registered voters are excluded from the primary sample, in line with the original paper, but may be plotted as a **separate sensitivity analysis** against the main reference distribution.

These distributions are **descriptive diagnostics** of electoral-result heterogeneity. Approximate normality is not a sufficient condition for fair elections; departures from normality do not prove ballot stuffing or any other manipulation. The paper expressly notes aggregation sensitivity and legitimate sources of heterogeneity. The module does **not** implement the paper's separate parametric fraud model (`f_i`, `f_e`), and does not label elections or polling stations as fraudulent.

## Requirements and data contract

Install R and the CRAN packages **`readxl`**, **`ggplot2`** and **`scales`**:

```r
install.packages(c("readxl", "ggplot2", "scales"))
```

Run from `election-forensics-r-toolkit/modules/approximate_normality/`. The default `INPUTS` expects the existing, **local** prepared RZS workbooks in `../rzs_data_preparation/RZS_prepared/`, namely:

```text
presidential_2017_RZS_prepared.xlsx
presidential_2022_RZS_prepared.xlsx
parliamentary_2022_RZS_prepared.xlsx
```

The module reads the `Master` worksheet, which preserves polling stations below the primary 100-elector threshold. Required fields: `Station_key`, `District_code`, `Municipality_code`, `E` (registered voters), `B` (valid ballots), `C` (ballots cast), `Size` (or `Size_JHK`, when selected), and `Winner_votes` (national winner's vote count). `District` and `Municipality` descriptions are optional; the `Options` sheet should be checked to verify winner selection. If `Winner_votes` is absent, the explicitly configured `WINNER_FIELD_FALLBACKS` fields are used **only if present**; users must confirm their mapping against `Options`. The module does not try to guess a winner.

Prepared workbooks, raw data and generated figures are not shipped in the GitHub module; source data are not modified.

## Editable configuration and run

At the top of `Approximate_normality.R`, review:

- `INPUTS`: election ID and relative prepared workbook path (add future elections here).
- `GRAPH_LANGUAGES <- c("EN", "SR")`: English and Serbian-Latin output.
- `GEOGRAPHIC_LEVELS <- c("national")`: add `"district"` / `"municipality"` for local diagnostics; use `DISTRICT_CODES` / `MUNICIPALITY_CODES` to select areas.
- `SIZE_FIELD <- "Size"`: use the nationally prepared Small/Large categories; optional `"Size_JHK"` where available.
- `BIN_WIDTH <- 0.2`: fixed bin width in *standardized* units, deliberately configurable. The original publication does **not** specify a reproducible exact Figure 2 bin width.
- `PLOT_X_LIMITS <- c(-5, 5)`: visible figure range only; all tail bins remain in CSV exports.
- `MIN_PRIMARY_STATIONS <- 30L`, `MIN_PLOTTED_GROUP <- 10L`: explicit implementation limits, not significance thresholds from the paper.
- `INCLUDE_UNDER100_SENSITIVITY <- TRUE`, `INCLUDE_CROSS_ELECTION <- TRUE`, `INCLUDE_WITHIN_ELECTION <- TRUE`.

Then execute:

```r
Sys.unsetenv("EF_APPROX_NORMALITY_TEST_MODE")
source("Approximate_normality.R", encoding="UTF-8")
```

Outputs are written under `approximate_normality_outputs/` (Git-ignored).

## Figures and CSV outputs

Each eligible election and geography generates `Figure2_style_within_EN.png` and `Figure2_style_within_SR.png`. If at least ten eligible stations under 100 are present, separate `Figure2_style_under100_EN.png` / `_SR.png` sensitivity figures are generated. Each geography with at least two elections yields `Figure2_style_cross_elections_EN.png` / `_SR.png` in `cross_election/`.

All figures are based on **histogram bin probabilities**, not `geom_density()` smoothing. Coloured points/segments are empirical probabilities per fixed-width bin; the black line represents the integrated `N(0,1)` probability for each such bin and appears explicitly in the legend as **Standard normal reference, N(0,1)**. The empirical curves and their legend keys use matching colours, while the standard-normal reference is always black; all entries share one colour legend. With more than three elections the legend wraps into multiple rows. Both languages use corresponding axis names and election labels without underscores.

Numerical files include station-level eligibility and rates, mean/SD used for standardization, **bin centres, bin boundaries, observed counts and proportions, expected normal-bin probabilities**, group-specific skewness, ordinary kurtosis (normal = 3), Jarque–Bera statistics and asymptotic p-values, plus run configuration and a PASS/SKIP manifest. See the [Output guide](OUTPUT_GUIDE.md) for paths and definitions.

## Testing and local validation

```r
source("tests/run_tests.R", encoding="UTF-8")
source("tests/test_graphics.R", encoding="UTF-8")
source("tests/integration_real_data.R", encoding="UTF-8")
Sys.unsetenv("EF_APPROX_NORMALITY_TEST_MODE")
source("Approximate_normality.R", encoding="UTF-8")
source("tests/check_exports.R", encoding="UTF-8")
```

The first two tests use controlled synthetic data. The integration test requires the existing real RZS workbooks on the user's PC. These scripts do not validate the correctness of independent official election totals; retain the upstream RZS preparation module's official-source validations. Re-execute output generation after changing data or bin width.

## Citation

Klimek, P., Yegorov, Y., Hanel, R., & Thurner, S. (2012). Statistical detection of systematic election irregularities. *Proceedings of the National Academy of Sciences*, *109*(41), 16469–16473. https://doi.org/10.1073/pnas.1210722109

Methodological reproduction is limited to the published vote-rate equation and the histogram-based Figure 2 concept. Geographic group comparisons, sample thresholds for plotting, fixed bin width 0.2 and the under-100 extension are transparently documented **Toolkit adaptations**, not an assertion that original plotting code or original foreign-election data were recovered.
