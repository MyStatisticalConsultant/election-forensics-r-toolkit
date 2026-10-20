# Examples

Run the module from `modules/klimek`. `Klimek.R` already contains a working three-election `INPUTS` example. Before running, place your locally generated workbooks in `../rzs_data_preparation/RZS_prepared/`.

For English-only figures set `GRAPH_LANGUAGES <- "EN"`; for Serbian only set `"SR"`; for both set `c("EN", "SR")`. Set `OPTION_SELECTION_MODE <- "top_n"` and `DISPLAY_TOP_N <- 3L` to plot the leading three nationally ranked candidates/lists. Set `CURVE_NORMALISATIONS <- "both"` for both curve definitions. Examples for labels and colours are in `USER_GUIDE.md`.

Do not upload official input workbooks, generated curve-point CSV files or figure folders to the source repository.
