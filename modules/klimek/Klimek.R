#!/usr/bin/env Rscript
# =============================================================================
# ELECTION FORENSICS R TOOLKIT | KLIMEK-STYLE CUMULATIVE CURVES | v0.1.4
# EN: Reproducible cumulative vote-versus-turnout curves, not a fraud test.
# SR: Reproduktivne kumulativne krive glasovi–izlaznost; nisu test prevare.
# EN: Run from modules/klimek with source("Klimek.R").
# SR: Pokrenuti iz modules/klimek komandom source("Klimek.R").
# =============================================================================

# ==================== EDITABLE / KORISNIČKA PODEŠAVANJA ======================
# EN: Change only this section. One row per prepared election workbook.
# SR: Menjajte samo ovaj odeljak. Jedan red za svaku pripremljenu bazu izbora.
# EN: Workbook MUST contain Master, Main and Options from RZS_data_preparation.R.
# SR: Excel mora imati Master, Main i Options iz RZS_data_preparation.R.
INPUTS <- data.frame(
  election_type = c("presidential", "presidential", "parliamentary"),
  year = c(2017L, 2022L, 2022L),
  prepared_file = c(
    "../rzs_data_preparation/RZS_prepared/presidential_2017_RZS_prepared.xlsx",
    "../rzs_data_preparation/RZS_prepared/presidential_2022_RZS_prepared.xlsx",
    "../rzs_data_preparation/RZS_prepared/parliamentary_2022_RZS_prepared.xlsx"),
  stringsAsFactors = FALSE
)
# EN: Results are saved under a separate directory per election. Inputs unchanged.
# SR: Rezultati se čuvaju po izborima. Ulazne Excel datoteke se ne menjaju.
OUTPUT_DIR <- "klimek_outputs"

# EN: "EN" = English, "SR" = Serbian Latin, c("EN","SR") = both in ONE run.
# SR: "EN" = engleski, "SR" = srpski (latinica), oba = obe verzije u istom prolazu.
GRAPH_LANGUAGES <- c("EN", "SR")

# EN: "top_n" shows the N nationally highest-ranked options; "all" shows all;
#     "selected" uses SELECT_OPTION_FIELDS (e.g., c("Option_01_votes")).
#     Only DISPLAY choices change, not the computations for other options.
# SR: "top_n" prikazuje N najjačih opcija; "all" sve; "selected" odabrane.
#     Izbor utiče na grafikone, a ne na računanje svih izbornih opcija.
OPTION_SELECTION_MODE <- "top_n"
DISPLAY_TOP_N <- 3L
SELECT_OPTION_FIELDS <- character(0)
# EN/SR: Option selection per election may override the global selection above.
# e.g. OPTION_FIELDS_BY_ELECTION <- list(parliamentary_2022=c("Option_01_votes","Option_03_votes"))
OPTION_FIELDS_BY_ELECTION <- list()

# EN: Supply complete option/candidate labels for each election and language.
#     Keys are votes-column IDs from the Options worksheet; unlisted names
#     default to RZS Serbian-Latin names. Use this to translate English labels.
# SR: Unesite pune nazive kandidata/lista po izborima i jeziku. Ključevi su
#     nazivi kolona iz Options, npr. "Option_01_votes". Neuneti se čitaju iz RZS.
# Example / Primer:
# OPTION_LABELS_EN <- list(parliamentary_2022=c(Option_01_votes="Full English list name"))
# OPTION_LABELS_SR <- list(parliamentary_2022=c(Option_01_votes="Puni naziv liste"))
OPTION_LABELS_EN <- list()
OPTION_LABELS_SR <- list()

# EN: Main groups. All = Main + QC-accepted E<100; GE100 = Main.
#     Size (Small/Middle/Large) and Size_JHK (Small/Large) are the TWO
#     established national classifications; never re-estimate by district.
# SR: All = Main + QC prihvaćena BM sa E<100; GE100 = Main.
#     Size i Size_JHK ostaju nacionalne podele, bez lokalnog preračunavanja.
PLOT_GROUPS <- c("ALL", "GE100", "LT100", "SMALL", "MIDDLE", "LARGE",
                 "JHK_SMALL", "JHK_LARGE")

# EN: "both" saves two denominators for each curve: "valid" (total valid
#     ballots, final ordinate = option's vote share) and "option" (total votes
#     for that option, final ordinate = 100%). Set "valid"/"option" to limit.
# SR: "both" daje obe normalizacije: "valid" = zbir važećih listića (kriva
#     se završava udelom opcije), "option" = zbir glasova opcije (završava se na 100%).
CURVE_NORMALISATIONS <- "both"    # "both", "valid", "option"

# EN: All district/municipality NUMERIC summaries are produced automatically.
#     Charts are national by default. "selected" also plots named areas.
# SR: Numerički rezimei se računaju za sve okruge/opštine; grafikoni nacionalno,
#     ili i za izabrane oblasti ako je režim "selected".
GEOGRAPHIC_PLOTS <- "national"   # "national" or "selected"
# EN: District codes are the exact District_code values from Main.
# SR: Šifre okruga moraju odgovarati koloni District_code.
SELECT_DISTRICT_CODES <- character(0)    # e.g., c("01", "02")
# EN: Municipality keys must be "District_code|Municipality_code" to avoid
#     ambiguity across districts (copy values from the exported area dictionary).
# SR: Šifre opština su "Šifra_okruga|Šifra_opštine".
SELECT_MUNICIPALITY_KEYS <- character(0) # e.g., c("01|001")

# EN: Plot families A = selected options within one station-size group;
#     B = one selected option compared across station-size groups.
#     Each can produce overlay (combined) and faceted plots.
# SR: Tip A = više opcija u jednoj grupi BM; tip B = jedna opcija među grupama.
#     Kombinovani i panelni prikaz mogu se uključiti nezavisno.
PLOT_FAMILY_A <- TRUE
PLOT_FAMILY_B <- TRUE
WRITE_COMBINED <- TRUE
WRITE_FACETED <- TRUE
FACET_FREE_Y <- FALSE              # EN/SR: TRUE = independent vertical scales / posebne Y skale

# EN: Family B (one option across groups) is easier to read as two comparisons:
#     standard groups (ALL, GE100, LT100, SMALL, MIDDLE, LARGE), and the
#     separate JHK_SMALL/JHK_LARGE comparison. Combined plots are SPLIT by default.
# SR: Porodica B (jedna opcija kroz grupe) razdvaja standardne grupe od dve
#     JHK grupe. Kombinovani prikaz podrazumevano pravi DVE odvojene slike.
B_SPLIT_COMBINED <- TRUE
# EN: Family B "faceted" is now ONE TWO-PANEL figure: standard groups above,
#     JHK groups below. Set FALSE to skip it when WRITE_FACETED is TRUE.
# SR: Panelni B grafikon ima DVA panela: standardne grupe gore, JHK dole.
B_TWO_PANEL_FACET <- TRUE
B_PANEL_COLUMNS <- 1L           # EN/SR: 1 = vertical panels / paneli jedan ispod drugog
B_PANEL_HEIGHT_MULTIPLIER <- 1.45  # EN/SR: Extra room for two panels / dodatna visina

# EN: At least three options in Family A => legend automatically uses two rows.
#     Long full candidate/list names wrap without being abbreviated.
# SR: Kod tri ili više izbornih opcija legenda A-grafikona ima dva reda,
#     a duga puna imena prelamaju se bez skraćivanja.
A_LEGEND_ROWS_3PLUS <- 2L
B_LEGEND_ROWS_3PLUS <- 2L
LEGEND_WRAP_CHARS <- 31L        # EN/SR: Approx. characters per legend line / znakova po redu
LEGEND_FONT_SIZE <- 9.5         # EN/SR: Legend text size / veličina legende
TITLE_WRAP_CHARS <- 76L         # EN/SR: Approx. title wrap width / širina naslova
SUBTITLE_WRAP_CHARS <- 86L      # EN/SR: Approx. subtitle width / širina podnaslova

# EN: Output files and graphic appearance / SR: Izlazni formati i izgled.
SAVE_PNG <- TRUE
SAVE_PDF <- TRUE
WRITE_EXCEL <- TRUE
WRITE_CSV <- TRUE
SAVE_CURVE_POINTS <- TRUE           # EN/SR: Can produce large CSV files / veliki CSV fajlovi
PNG_DPI <- 240
PLOT_WIDTH_IN <- 9.5
PLOT_HEIGHT_IN <- 6.0
FACET_COLUMNS <- 2L
BASE_FONT_SIZE <- 12
BASE_FONT_FAMILY <- "sans"          # EN/SR: Choose Unicode-capable font if needed.
LINE_WIDTH <- 0.9
ADD_POINTS <- FALSE
POINT_SIZE <- 0.35
SINGLE_POINT_SIZE <- 2.3          # EN/SR: Visible isolated point / vidljiva usamljena tačka
POINT_ALPHA <- 0.40
LEGEND_POSITION <- "bottom"       # "bottom", "top", "right", "left", "none"
PLOT_THEME <- "bw"                # EN/SR: "bw", "minimal" or "classic"
SHOW_MAJOR_GRID <- TRUE           # EN/SR: Main grid lines / glavna mreža
X_TICK_STEP <- 10                 # EN/SR: X-axis percentage-point tick gap
Y_TICK_STEP <- 10                 # EN/SR: Y-axis percentage-point tick gap
X_LABEL_ANGLE <- 0               # EN/SR: Rotation in degrees / ugao oznaka
COLOR_SCHEME <- "OkabeIto"        # "OkabeIto", "Dark2", "Viridis", "Custom"
# EN: Custom HEX colour per option field or group code; names must match keys.
# SR: Opcione HEX boje za opcije/grupe; imenovani vektori sa šiframa.
OPTION_COLORS <- c()               # e.g., c(Option_01_votes="#0072B2")
GROUP_COLORS <- c()                # e.g., c(ALL="#333333",GE100="#009E73")

# EN: Custom title fragments and graph labels, independent by language.
#     Empty titles use generated titles; override axes if desired.
# SR: Naslovi i oznake osa za svaki jezik (prazan tekst = automatski naslov).
CUSTOM_MAIN_TITLE_EN <- ""
CUSTOM_MAIN_TITLE_SR <- ""
CUSTOM_SUBTITLE_EN <- ""
CUSTOM_SUBTITLE_SR <- ""
CUSTOM_X_LABEL_EN <- "Polling-station turnout (%)"
CUSTOM_X_LABEL_SR <- "Izlaznost na biračkom mestu (%)"
CUSTOM_Y_VALID_EN <- "Cumulative option votes / all valid ballots (%)"
CUSTOM_Y_VALID_SR <- "Kumulativni glasovi opcije / svi važeći listići (%)"
CUSTOM_Y_OPTION_EN <- "Cumulative option votes / option votes (%)"
CUSTOM_Y_OPTION_SR <- "Kumulativni glasovi opcije / glasovi opcije (%)"
# EN: FALSE never truncates valid turnout observations above 100 silently.
# SR: FALSE ne sakriva vrednosti izlaznosti veće od 100, ako postoje.
LIMIT_X_TO_100 <- FALSE

# EN: Optional descriptive T90/T95 comparisons. There is NO automatic
#     designation of "government" or "opposition", and NO permutation test.
# SR: Opciona opisna poređenja T90/T95. Skript NE pretpostavlja vlast/opoziciju
#     i NE primenjuje neobrazložen permutacioni test.
ENABLE_BLOC_TAIL_METRICS <- FALSE
# EN/SR: Map to option vote fields; can sum MULTIPLE nonoverlapping options.
# Example: BLOC_A_BY_ELECTION <- list(parliamentary_2022=c("Option_01_votes"))
BLOC_A_BY_ELECTION <- list()
BLOC_B_BY_ELECTION <- list()
TAIL_PERCENTILES <- c(0.90, 0.95)

# *****************************************************************************
# *************** DO NOT CHANGE THE CODE BELOW THIS LINE **********************
# *************** NE MENJAJTE KOD ISPOD OVE LINIJE ****************************
# *****************************************************************************

# ---------------- BLOCK 1: CONFIGURATION AND PACKAGES -------------------------
# EN: Validate settings early; tests can source helpers without executing runs.
# SR: Proveriti parametre; testovi mogu učitati funkcije bez pokretanja analize.
validate_settings <- function() {
  stopifnot(is.data.frame(INPUTS), nrow(INPUTS)>0,
    all(c("election_type","year","prepared_file") %in% names(INPUTS)),
    all(INPUTS$election_type %in% c("presidential","parliamentary")),
    !anyNA(INPUTS), !anyDuplicated(paste(INPUTS$election_type, INPUTS$year)),
    is.character(OUTPUT_DIR), length(OUTPUT_DIR)==1L, nzchar(OUTPUT_DIR),
    length(GRAPH_LANGUAGES)>0L, all(GRAPH_LANGUAGES %in% c("EN","SR")),
    OPTION_SELECTION_MODE %in% c("top_n","all","selected"),
    length(DISPLAY_TOP_N)==1L, is.finite(DISPLAY_TOP_N), DISPLAY_TOP_N>=1,
    CURVE_NORMALISATIONS %in% c("both","valid","option"),
    GEOGRAPHIC_PLOTS %in% c("national","selected"),
    length(PLOT_GROUPS)>0L,
    all(PLOT_GROUPS %in% c("ALL","GE100","LT100","SMALL","MIDDLE","LARGE",
                          "JHK_SMALL","JHK_LARGE")),
    COLOR_SCHEME %in% c("OkabeIto","Dark2","Viridis","Custom"),
    LEGEND_POSITION %in% c("bottom","top","right","left","none"),
    PLOT_THEME %in% c("bw","minimal","classic"),
    X_TICK_STEP>0,Y_TICK_STEP>0,SINGLE_POINT_SIZE>0,is.finite(X_LABEL_ANGLE),
    all(TAIL_PERCENTILES>0 & TAIL_PERCENTILES<1),
    length(PNG_DPI)==1L, PNG_DPI>=72,
    PLOT_WIDTH_IN>0, PLOT_HEIGHT_IN>0, FACET_COLUMNS>=1,
    B_PANEL_COLUMNS>=1L, B_PANEL_HEIGHT_MULTIPLIER>=1,
    A_LEGEND_ROWS_3PLUS>=1L, B_LEGEND_ROWS_3PLUS>=1L,
    LEGEND_WRAP_CHARS>=10L, LEGEND_FONT_SIZE>0,
    TITLE_WRAP_CHARS>=20L, SUBTITLE_WRAP_CHARS>=20L,
    is.logical(B_SPLIT_COMBINED),length(B_SPLIT_COMBINED)==1L,!is.na(B_SPLIT_COMBINED),
    is.logical(B_TWO_PANEL_FACET),length(B_TWO_PANEL_FACET)==1L,!is.na(B_TWO_PANEL_FACET),
    all(vapply(list(OPTION_LABELS_EN,OPTION_LABELS_SR,
                    OPTION_FIELDS_BY_ELECTION,BLOC_A_BY_ELECTION,BLOC_B_BY_ELECTION),
               is.list,logical(1))))
  if (OPTION_SELECTION_MODE=="selected" && !length(SELECT_OPTION_FIELDS) &&
      !length(OPTION_FIELDS_BY_ELECTION)) stop("Select options in SELECT_OPTION_FIELDS or OPTION_FIELDS_BY_ELECTION.")
  if (!any(c(SAVE_PNG,SAVE_PDF))) warning("All graphics disabled. Numeric output will still be saved.")
  if (COLOR_SCHEME == "Custom" && !length(OPTION_COLORS) && !length(GROUP_COLORS))
    stop("Custom palette requires OPTION_COLORS and/or GROUP_COLORS.")
  invisible(TRUE)
}
required_pkgs <- c("readxl", "openxlsx", "ggplot2", "readr")
check_packages <- function() {
  missing <- required_pkgs[!vapply(required_pkgs, requireNamespace, logical(1), quietly=TRUE)]
  if (length(missing)) stop("Missing R packages: ",paste(missing,collapse=", "),
                            ". Install with install.packages(c('readxl','openxlsx','ggplot2','readr')).")
}

# ---------------- BLOCK 2: GENERAL HELPERS / POMOĆNE FUNKCIJE -----------------
# EN: Canonical names, safe joins, stable sorting and reproducible paths.
# SR: Standardni nazivi, bezbedni ključevi, stabilno sortiranje i putanje.
election_id <- function(tp, yr) paste0(tp,"_",as.integer(yr))
all_group_ids <- c("ALL","GE100","LT100","SMALL","MIDDLE","LARGE","JHK_SMALL","JHK_LARGE")
size_friendly <- function(gr, lang) {
  en <- c(ALL="All",GE100="100 or more",LT100="Less than 100",SMALL="Small",
          MIDDLE="Middle",LARGE="Large",JHK_SMALL="JHK Small",JHK_LARGE="JHK Large")
  sr <- c(ALL="Sva BM",GE100="100 ili više",LT100="Manje od 100",SMALL="Mala",
          MIDDLE="Srednja",LARGE="Velika",JHK_SMALL="JHK mala",JHK_LARGE="JHK velika")
  map <- if (lang=="SR") sr else en
  unname(map[gr])
}
size_friendly_full <- function(gr, lang) {
  en <- c(
    ALL="All polling stations",
    GE100="Polling stations with 100 or more registered voters",
    LT100="Polling stations with less than 100 registered voters",
    SMALL="Small polling stations",
    MIDDLE="Medium polling stations",
    LARGE="Large polling stations",
    JHK_SMALL="JHK small polling stations",
    JHK_LARGE="JHK large polling stations"
  )
  sr <- c(
    ALL="Sva biračka mesta",
    GE100="Biračka mesta sa 100 ili više registrovanih birača",
    LT100="Biračka mesta sa manje od 100 registrovanih birača",
    SMALL="Mala biračka mesta",
    MIDDLE="Srednja biračka mesta",
    LARGE="Velika biračka mesta",
    JHK_SMALL="JHK mala biračka mesta",
    JHK_LARGE="JHK velika biračka mesta"
  )
  map <- if (lang=="SR") sr else en
  unname(map[gr])
}
normalisations <- function() if (CURVE_NORMALISATIONS=="both") c("valid","option") else CURVE_NORMALISATIONS
safe_name <- function(s) gsub("[^a-zA-Z0-9_-]","_",as.character(s))
write_csv <- function(dat,path,na_string="") {
  dir.create(dirname(path),recursive=TRUE,showWarnings=FALSE)
  readr::write_excel_csv(as.data.frame(dat,stringsAsFactors=FALSE),path,na=na_string)
}
empty_curve <- function() data.frame(
  Station_key=character(), Turnout=numeric(), Cum_votes=numeric(),
  Y_valid=numeric(),Y_option=numeric(),
  Vote_share_final=numeric(), Total_valid=numeric(),Total_option_votes=numeric(),
  stringsAsFactors=FALSE)

# ---------------- BLOCK 3: DATA IMPORT AND CONTRACT / ULAZ I UGOVOR ----------
# EN: Read canonical Main, Master and Options; never guess options from _pct.
# SR: Učitavanje Main/Master/Options; opcije se nikada ne nagađaju po _pct.
read_prepared <- function(path, election_type_expected=NULL, year_expected=NULL) {
  if (!file.exists(path)) stop("Prepared workbook not found: ", path)
  ss <- readxl::excel_sheets(path)
  if (!all(c("Main","Master","Options") %in% ss))
    stop("Workbook requires Main, Master and Options worksheets: ", path)
  main <- as.data.frame(readxl::read_excel(path,sheet="Main",guess_max=10000),
                        stringsAsFactors=FALSE,check.names=FALSE)
  master <- as.data.frame(readxl::read_excel(path,sheet="Master",guess_max=10000),
                          stringsAsFactors=FALSE,check.names=FALSE)
  opts <- as.data.frame(readxl::read_excel(path,sheet="Options"),
                        stringsAsFactors=FALSE,check.names=FALSE)
  needed <- c("Election_type","Year","Station_key","District_code",
              "Municipality_code","District","Municipality","E","C","B","I",
              "Turnout","Size","Size_JHK","Eligible_primary","Under_100",
              "Admin_no_ballots","Admin_invalid","Invalid_numeric")
  if (length(setdiff(needed,names(master))))
    stop("Missing required Master fields: ",paste(setdiff(needed,names(master)),collapse=", "))
  if (length(setdiff(needed,names(main))))
    stop("Missing required Main fields: ",paste(setdiff(needed,names(main)),collapse=", "))
  option_req <- c("Votes_field","Option_name_SR_Lat","Option_number","Total_votes")
  if (length(setdiff(option_req,names(opts))))
    stop("Missing Options fields: ",paste(setdiff(option_req,names(opts)),collapse=", "))
  if (!nrow(opts) || anyNA(opts$Votes_field) || anyDuplicated(opts$Votes_field))
    stop("Options worksheet has missing or repeated vote fields.")
  vf <- as.character(opts$Votes_field)
  if (!all(grepl("^Option_[0-9]+_votes$",vf)) ||
      any(!vf %in% names(main)) || any(!vf %in% names(master)))
    stop("Options vote fields do not match canonical Option_XX_votes columns.")
  if (!nrow(main) || anyDuplicated(master$Station_key) || anyDuplicated(main$Station_key))
    stop("Empty Main or duplicate Station_key values.")
  if (!setequal(main$Station_key,master$Station_key[!is.na(master$Eligible_primary) & master$Eligible_primary]))
    stop("Main station identifiers do not match eligible Master records.")
  matched <- match(main$Station_key,master$Station_key)
  shared_counts <- c("E","C","B","I",vf)
  for (field in shared_counts) {
    if (any(as.character(main[[field]])!=as.character(master[[field]][matched]),na.rm=TRUE))
      stop("Main/Master numeric mismatch in: ",field)
  }
  if (!all(main$Eligible_primary %in% TRUE) || any(main$E<100,na.rm=TRUE))
    stop("Main must contain only eligible records E >= 100.")
  if (!is.null(election_type_expected) && any(master$Election_type!=election_type_expected))
    stop("Election type mismatch: ",path)
  if (!is.null(year_expected) && any(master$Year!=as.integer(year_expected)))
    stop("Election year mismatch: ",path)
  # EN/SR: Missing or conflicting numeric values must not be silently repaired.
  numcols <- c("E","C","B","I","Turnout",vf)
  for (nm in numcols) {
    master[[nm]] <- suppressWarnings(as.numeric(master[[nm]]))
    main[[nm]] <- suppressWarnings(as.numeric(main[[nm]]))
  }
  master$District_code <- as.character(master$District_code)
  master$Municipality_code <- as.character(master$Municipality_code)
  main$District_code <- as.character(main$District_code)
  main$Municipality_code <- as.character(main$Municipality_code)
  # EN: Check identities before any subgroup computation.
  for (d in list(main,master)) {
    ok <- !is.na(d$Eligible_primary) & d$Eligible_primary
    if (any(!is.finite(d$E[ok]) | d$E[ok]<=0 | !is.finite(d$C[ok]) |
            !is.finite(d$B[ok]) | !is.finite(d$I[ok])))
      stop("Non-finite eligible official counts.")
    if (any(abs(d$C[ok]-d$B[ok]-d$I[ok])>1e-8) ||
        any(abs(rowSums(d[ok,vf,drop=FALSE])-d$B[ok])>1e-8))
      stop("Ballot or option identities violated in eligible records.")
    if (any(!is.finite(d$Turnout[ok])) ||
        any(abs(d$Turnout[ok]-100*d$C[ok]/d$E[ok])>1e-7))
      stop("Turnout is missing or does not equal 100*C/E in eligible records.")
  }
  totals <- colSums(master[,vf,drop=FALSE],na.rm=TRUE)
  if(any(abs(as.numeric(totals)-as.numeric(opts$Total_votes))>1e-8))
    stop("Master national option totals differ from Options dictionary.")
  names(opts) <- trimws(names(opts))
  list(main=main,master=master,options=opts,
       source_md5=unname(as.character(tools::md5sum(path))))
}

# ---------------- BLOCK 4: EIGHT GROUPS / OSAM GRUPA BM ---------------------
# EN: Supplementary E<100 group must pass every other primary QC criterion.
# SR: Dopunska BM sa E<100 moraju zadovoljiti ostale QC uslove.
make_groups <- function(main,master) {
  small <- master[!is.na(master$Under_100) & master$Under_100 &
                  !is.na(master$Invalid_numeric) & !master$Invalid_numeric &
                  !is.na(master$Admin_no_ballots) & !master$Admin_no_ballots &
                  !is.na(master$Admin_invalid) & !master$Admin_invalid,,drop=FALSE]
  if (any(small$Station_key %in% main$Station_key)) stop("Under-100 group overlaps Main.")
  all_data <- rbind(main,small)
  groups <- list(ALL=all_data, GE100=main, LT100=small,
    SMALL=main[!is.na(main$Size)&main$Size=="Small",,drop=FALSE],
    MIDDLE=main[!is.na(main$Size)&main$Size=="Middle",,drop=FALSE],
    LARGE=main[!is.na(main$Size)&main$Size=="Large",,drop=FALSE],
    JHK_SMALL=main[!is.na(main$Size_JHK)&main$Size_JHK=="Small",,drop=FALSE],
    JHK_LARGE=main[!is.na(main$Size_JHK)&main$Size_JHK=="Large",,drop=FALSE])
  check_partition <- function(g) {
    identical(sort(c(groups[[g[1]]]$Station_key,groups[[g[2]]]$Station_key,
                     if(length(g)>2) groups[[g[3]]]$Station_key else character())),
              sort(main$Station_key))
  }
  if (nrow(all_data)!=nrow(main)+nrow(small) ||
      !check_partition(c("SMALL","MIDDLE","LARGE")) ||
      !check_partition(c("JHK_SMALL","JHK_LARGE")))
    stop("Polling-station size partitions do not reconcile to Main.")
  groups
}

# ---------------- BLOCK 5: OPTIONS AND USER LABELS / IZBORNE OPCIJE ----------
# EN: Compute all option curves; draw selected options only, with optional
#     user-supplied translations keyed by EXACT Options.Votes_field names.
# SR: Računaju se sve opcije; prikazuju se odabrane sa korisničkim prevodom.
option_fields <- function(opt) as.character(opt$Votes_field)
selected_fields <- function(opts,id) {
  allf <- option_fields(opts)
  chosen <- OPTION_FIELDS_BY_ELECTION[[id]]
  if (is.null(chosen)) {
    rank <- order(-as.numeric(opts$Total_votes),as.numeric(opts$Option_number))
    chosen <- switch(OPTION_SELECTION_MODE,
      all=allf,
      selected=SELECT_OPTION_FIELDS,
      top_n=as.character(opts$Votes_field[head(rank,DISPLAY_TOP_N)]))
  }
  if (!length(chosen) || any(!chosen %in% allf))
    stop("Selected graph fields not found in Options for ",id,": ",paste(chosen,collapse=", "))
  unique(as.character(chosen))
}
option_labels <- function(opts,id,lang) {
  f <- option_fields(opts)
  lab <- as.character(opts$Option_name_SR_Lat)
  lab[is.na(lab)|!nzchar(lab)] <- f[is.na(lab)|!nzchar(lab)]
  names(lab) <- f
  overrides <- if(lang=="SR") OPTION_LABELS_SR[[id]] else OPTION_LABELS_EN[[id]]
  if (length(overrides)) {
    if (is.null(names(overrides)) || any(!names(overrides)%in%f))
      stop("Invalid option label override in ",lang," for ",id)
    lab[names(overrides)] <- as.character(overrides)
  }
  lab
}

# ---------------- BLOCK 6: NUMERICAL CURVES / KUMULATIVNE KRIVE --------------
# EN: x=turnout sorted increasing, tie-broken by Station_key; station vote
#     counts are exact integers; no turnout truncation and no share reconstruction.
# SR: Sortiranje izlaznosti rastuće pa Station_key; koriste se stvarni glasovi,
#     bez ograničavanja izlaznosti ili rekonstruisanja iz procenata.
cumulative_curve <- function(dat, votes_field) {
  needed <- c("Station_key","Turnout","B",votes_field)
  if (!all(needed%in%names(dat))) stop("Missing curve input fields.")
  d <- dat[is.finite(dat$Turnout) & is.finite(dat$B) & is.finite(dat[[votes_field]]) &
           dat$B>=0 & dat[[votes_field]]>=0,,drop=FALSE]
  if (!nrow(d)) return(empty_curve())
  d <- d[order(d$Turnout,as.character(d$Station_key)),,drop=FALSE]
  tv <- sum(d$B)
  to <- sum(d[[votes_field]])
  if (tv<=0) return(empty_curve())
  if (any(d[[votes_field]]>d$B+1e-8) || to>tv+1e-8)
    stop("Option votes exceed valid ballots for ",votes_field)
  cv <- cumsum(d[[votes_field]])
  data.frame(Station_key=as.character(d$Station_key),Turnout=d$Turnout,
    Cum_votes=cv,Y_valid=100*cv/tv,
    Y_option=if(to>0)100*cv/to else rep(NA_real_,length(cv)),
    Vote_share_final=rep(100*to/tv,length(cv)),
    Total_valid=rep(tv,length(cv)),Total_option_votes=rep(to,length(cv)),
    stringsAsFactors=FALSE)
}
curve_metrics <- function(curve,id,area_type,area_key,group,field) {
  data.frame(Election=id,Area_level=area_type,Area_key=area_key,
    Group=group,Option_field=field,Stations_used=nrow(curve),
    Valid_ballots=if(nrow(curve))curve$Total_valid[1] else 0,
    Option_votes=if(nrow(curve))curve$Total_option_votes[1] else 0,
    Option_share_pct=if(nrow(curve))tail(curve$Y_valid,1) else NA_real_,
    Curve_option_endpoint_pct=if(nrow(curve))tail(curve$Y_option,1) else NA_real_,
    stringsAsFactors=FALSE)
}

# ---------------- BLOCK 7: OPTIONAL TAIL CONTRASTS / REPNE RAZLIKE -----------
# EN: T90 and T95 describe the mean PS-level vote-share margin among stations
#     at/above the selected TURNOUT quantile. Pooled margin is also reported.
#     No permutation p-value is assigned: no exchangeability null is assumed.
# SR: T90/T95 su srednje razlike udela glasova po BM iznad kvantila izlaznosti.
#     Daje se i agregatni ponderisani udeo; nema permutacionog p-testa.
tail_metric <- function(dat,a_fields,b_fields,p) {
  if (!length(a_fields) || !length(b_fields) ||
      any(!c(a_fields,b_fields)%in%names(dat))) stop("Bloc fields undefined.")
  if (length(intersect(a_fields,b_fields))) stop("Bloc A and B overlap.")
  d <- dat[is.finite(dat$Turnout) & is.finite(dat$B) & dat$B>0,,drop=FALSE]
  if (!nrow(d)) return(data.frame(Tail=p,N_stations=0,Turnout_cutoff=NA_real_,
    Mean_station_margin_pp=NA_real_,Pooled_margin_pp=NA_real_))
  thr <- as.numeric(stats::quantile(d$Turnout,p,na.rm=TRUE,type=7))
  d <- d[d$Turnout>=thr,,drop=FALSE]
  av <- rowSums(d[,a_fields,drop=FALSE])
  bv <- rowSums(d[,b_fields,drop=FALSE])
  data.frame(Tail=p,N_stations=nrow(d),Turnout_cutoff=thr,
    Mean_station_margin_pp=mean(100*(av-bv)/d$B),
    Pooled_margin_pp=100*sum(av-bv)/sum(d$B))
}

# ---------------- BLOCK 8: COLOURS AND BILINGUAL PLOTS / GRAFIKONI -----------
# EN: Combined/faceted plots; customizable captions, colours, sizes, languages.
# SR: Kombinovani/panelni grafikoni uz boje, nazive, veličine i jezik.
plot_colors <- function(keys,kind="option") {
  key_n <- length(keys)
  if (!key_n) return(character())
  if (COLOR_SCHEME=="OkabeIto") {
    base <- c("#0072B2","#D55E00","#009E73","#CC79A7","#E69F00",
              "#56B4E9","#F0E442","#000000")
    if (key_n>length(base)) base <- c(base,grDevices::hcl.colors(key_n-length(base),"Dark 3"))
  } else if (COLOR_SCHEME=="Dark2") {
    base <- grDevices::hcl.colors(key_n,"Dark 3")
  } else if (COLOR_SCHEME=="Viridis") {
    base <- grDevices::hcl.colors(key_n,"viridis")
  } else {
    base <- grDevices::hcl.colors(key_n,"Dark 3")
  }
  out <- stats::setNames(base[seq_len(key_n)],keys)
  overrides <- if(kind=="group") GROUP_COLORS else OPTION_COLORS
  if(length(overrides)) {
    if(is.null(names(overrides)) || any(!grepl("^#[0-9A-Fa-f]{6}$",as.character(overrides))))
      stop("Custom colours require named #RRGGBB values.")
    matchkeys <- intersect(names(overrides),names(out))
    out[matchkeys] <- as.character(overrides[matchkeys])
  }
  out
}
# EN/SR: Wrap titles and full legend names instead of clipping or shortening.
# EN: The source option names and data are unchanged; only chart labels wrap.
# SR: Originalna imena i podaci ostaju nepromenjeni; prelama se samo tekst slike.
wrap_plot_text <- function(x, width) {
  if (is.null(x) || length(x)!=1L || is.na(x) || !nzchar(x)) return("")
  paste(strwrap(as.character(x),width=as.integer(width)),collapse="\n")
}

chart_title <- function(lang, family, id, extra) {
  custom <- if(lang=="EN") CUSTOM_MAIN_TITLE_EN else CUSTOM_MAIN_TITLE_SR
  if(nzchar(custom)) return(paste(custom,extra,sep=" | "))
  stem <- if(lang=="EN") "Cumulative turnout–vote curves" else "Kumulativne krive izlaznost–glasovi"
  paste(stem,extra,sep=" | ")
}
pretty_election_label <- function(lang, election_type, year) {
  if (lang=="EN") {
    type_map <- c(presidential="presidential", parliamentary="parliamentary", local="local")
  } else {
    type_map <- c(presidential="predsednički", parliamentary="parlamentarni", local="lokalni")
  }
  # EN: Validate the exact input contract; invalid labels must not produce
  #     obscure 'subscript out of bounds' errors or misleading graph titles.
  # SR: Jasna provera tipa izbora; nepoznata oznaka daje razumljivu grešku.
  election_type <- as.character(election_type)
  if(length(election_type)!=1L || is.na(election_type) ||
     !election_type %in% names(type_map))
    stop("Unknown election type: ",paste(election_type,collapse=", "),
         ". Expected: ",paste(names(type_map),collapse=", "),call.=FALSE)
  if(length(year)!=1L || is.na(suppressWarnings(as.integer(year))))
    stop("Year must be a single integer.",call.=FALSE)
  paste(unname(type_map[[election_type]]), as.integer(year))
}
# EN: District_code — not a translated name — identifies special RZS categories.
# SR: Posebne kategorije RZS prepoznaju se po šifri, ne po prevedenom nazivu.
normalise_district_code <- function(code) {
  if(length(code)!=1L || is.na(code)) return(NA_character_)
  code <- trimws(as.character(code))
  if(!nzchar(code)) return(NA_character_)
  if(grepl("^[0-9]+$",code)) {
    code <- sub("^0+","",code)
    if(!nzchar(code)) code <- "0"
  }
  code
}
district_reporting_category <- function(district_code=NA_character_) {
  code <- normalise_district_code(district_code)
  if(is.na(code)) return("ordinary")
  if(code=="33") return("overseas")
  if(code=="55") return("prisons")
  if(code %in% as.character(25:29)) return("kosovo_associated")
  "ordinary"
}
# EN: A Kosovo-associated code denotes an official RZS reporting category;
#     it does NOT establish that stations are physically within Kosovo.
#     Preserve that category's source label; translate an EXISTING suffix
#     'okrug'/'district' but never invent one for codes 25–29.
# SR: Šifre 25–29 označavaju RZS kategorije, a ne nužno fizičku lokaciju BM.
#     Sačuvati naziv iz RZS; prevesti postojeći nastavak, ne dodavati novi.
pretty_area_label <- function(lang, area_level, area_name, district_code=NA_character_) {
  if(identical(area_level,"National")) return(if(lang=="EN") "Serbia" else "Srbija")
  nm <- if(length(area_name)==1L && !is.na(area_name)) trimws(as.character(area_name)) else ""
  if(identical(area_level,"District")) {
    category <- district_reporting_category(district_code)
    if(category=="overseas") return(if(lang=="EN") "Overseas" else "Inostranstvo")
    if(category=="prisons") return(if(lang=="EN") "Prisons" else "Zavodi za izvršenje krivičnih sankcija")
    # EN/SR: For nonstandard source labels, no silent geographical assumption.
    if(!nzchar(nm)) nm <- paste0("RZS ",normalise_district_code(district_code))
    if(lang=="EN") {
      if(grepl("[[:space:]]+okrug$",nm,ignore.case=TRUE))
        return(sub("[[:space:]]+okrug$"," district",nm,ignore.case=TRUE))
      if(grepl("[[:space:]]+district$",nm,ignore.case=TRUE)) return(nm)
      if(category=="kosovo_associated") return(nm)
      nm <- sub("[[:space:]]+oblast$","",nm,ignore.case=TRUE)
      return(paste(nm,"district"))
    }
    if(grepl("[[:space:]]+district$",nm,ignore.case=TRUE))
      return(sub("[[:space:]]+district$"," okrug",nm,ignore.case=TRUE))
    if(grepl("[[:space:]]+okrug$",nm,ignore.case=TRUE)) return(nm)
    if(category=="kosovo_associated") return(nm)
    return(paste(nm,"okrug"))
  }
  if(identical(area_level,"Municipality")) {
    if(lang=="EN") {
      if(grepl("municipality$",nm,ignore.case=TRUE)) return(nm)
      return(paste(nm,"municipality"))
    }
    return(nm)
  }
  nm
}
context_label <- function(lang, election_type, year, area_level, area_name,
                          district_code=NA_character_) {
  paste(pretty_election_label(lang,election_type,year),
        pretty_area_label(lang,area_level,area_name,district_code))
}
# EN: B title contains the election and area ONLY. The complete option name
#     belongs in the subtitle (optionally followed by the custom subtitle).
# SR: Naslov B slike sadrži SAMO izbore i oblast; puno ime opcije ide ispod.
b_titles <- function(lang, election_type, year, area_level, area_name, option_label,
                     district_code=NA_character_) {
  main <- chart_title(lang,"B",paste(election_type,year,sep="_"),
                      context_label(lang,election_type,year,area_level,area_name,district_code))
  lead <- if (lang=="EN") "Electoral option: " else "Izborna opcija: "
  extra <- if(lang=="EN") CUSTOM_SUBTITLE_EN else CUSTOM_SUBTITLE_SR
  sub <- paste0(lead,option_label)
  if(nzchar(extra)) sub <- paste(sub,extra,sep=" | ")
  list(title=main,subtitle=sub)
}
# EN/SR: Standard and JHK curves are different size classifications.
b_group_sets <- function(available) {
  list(standard=intersect(c("ALL","GE100","LT100","SMALL","MIDDLE","LARGE"),available),
       jhk=intersect(c("JHK_SMALL","JHK_LARGE"),available))
}
chart_y <- function(lang,norm) {
  if (lang=="EN") {
    if (norm=="valid") CUSTOM_Y_VALID_EN else CUSTOM_Y_OPTION_EN
  } else {
    if (norm=="valid") CUSTOM_Y_VALID_SR else CUSTOM_Y_OPTION_SR
  }
}
# EN: `axis_map` is named by option fields (family A) or group codes (B).
# SR: `axis_map` povezuje šifre opcija (A) ili grupa BM (B) sa natpisima.
plot_curves <- function(curve_long, lang, norm, title, axis_map, color_map,
                        facet=FALSE, subtitle=NULL, legend_rows=1L,
                        facet_variable="Series", facet_columns=FACET_COLUMNS) {
  if(!nrow(curve_long)) return(NULL)
  yy <- if(norm=="valid") "Y_valid" else "Y_option"
  d <- curve_long[is.finite(curve_long[[yy]]),,drop=FALSE]
  if(!nrow(d)) return(NULL)
  d$Series <- factor(as.character(d$Series),levels=unique(as.character(d$Series)))
  if (facet && !facet_variable %in% names(d)) stop("Facet variable not found: ",facet_variable)
  # EN: ggplot cannot draw a line for a series with only one observation.
  #     Keep that station as a visible point; draw lines only for series with
  #     two or more observations, separately within each facet panel.
  # SR: Za jednu tačku ne postoji linija. Takvo BM prikazati kao tačku,
  #     a linije crtati samo za serije sa najmanje dva opažanja po panelu.
  panel_key <- if (facet && facet_variable != "Series") {
    interaction(d$Series, d[[facet_variable]], drop=TRUE)
  } else d$Series
  n_per_series_panel <- as.integer(ave(rep.int(1L,nrow(d)), panel_key, FUN=length))
  line_data <- d[n_per_series_panel>=2L,,drop=FALSE]
  isolated_data <- d[n_per_series_panel==1L,,drop=FALSE]
  if(is.null(subtitle)) subtitle <- if(lang=="EN") CUSTOM_SUBTITLE_EN else CUSTOM_SUBTITLE_SR
  label_text <- vapply(unname(axis_map),wrap_plot_text,character(1),width=LEGEND_WRAP_CHARS)
  theme_base <- switch(PLOT_THEME,
    bw=ggplot2::theme_bw(base_size=BASE_FONT_SIZE,base_family=BASE_FONT_FAMILY),
    minimal=ggplot2::theme_minimal(base_size=BASE_FONT_SIZE,base_family=BASE_FONT_FAMILY),
    classic=ggplot2::theme_classic(base_size=BASE_FONT_SIZE,base_family=BASE_FONT_FAMILY))
  p <- ggplot2::ggplot(d,ggplot2::aes(x=Turnout,y=.data[[yy]],colour=Series,group=Series)) +
    ggplot2::scale_colour_manual(
      values=stats::setNames(unname(color_map[names(axis_map)]),unname(axis_map)),
      breaks=unname(axis_map),labels=label_text,drop=FALSE) +
    ggplot2::scale_y_continuous(
      limits=c(0,max(Y_TICK_STEP,ceiling(max(d[[yy]],na.rm=TRUE)/Y_TICK_STEP)*Y_TICK_STEP)),
      labels=function(x)paste0(format(x,trim=TRUE),"%"),
      breaks=function(limits)seq(0,max(limits),by=Y_TICK_STEP)) +
    ggplot2::scale_x_continuous(
      breaks=function(limits)seq(0,max(0,ceiling(max(limits)/X_TICK_STEP)*X_TICK_STEP),by=X_TICK_STEP)) +
    ggplot2::labs(title=wrap_plot_text(title,TITLE_WRAP_CHARS),
      subtitle=wrap_plot_text(subtitle,SUBTITLE_WRAP_CHARS),
      x=if(lang=="EN") CUSTOM_X_LABEL_EN else CUSTOM_X_LABEL_SR,
      y=chart_y(lang,norm),colour=NULL,
      caption=if(lang=="EN") "Descriptive curves; not a test of fraud" else
        "Opisne krive; nisu dokaz izborne prevare") +
    theme_base +
    ggplot2::guides(colour=ggplot2::guide_legend(nrow=as.integer(legend_rows),byrow=TRUE)) +
    ggplot2::theme(legend.position=LEGEND_POSITION,
      legend.text=ggplot2::element_text(size=LEGEND_FONT_SIZE),
      legend.box="vertical",
      plot.title=ggplot2::element_text(face="bold",margin=ggplot2::margin(b=5)),
      plot.subtitle=ggplot2::element_text(margin=ggplot2::margin(b=9)),
      plot.margin=ggplot2::margin(t=12,r=18,b=12,l=15),
      axis.text.x=ggplot2::element_text(angle=X_LABEL_ANGLE),
      panel.grid.major=if(SHOW_MAJOR_GRID) {
        ggplot2::element_line(colour="#E5E5E5",linewidth=0.3)
      } else {ggplot2::element_blank()},
      panel.grid.minor=ggplot2::element_blank())
  # EN/SR: Separate layers avoid geom_line() warnings for singleton series.
  # The isolated dot is compulsory even when ADD_POINTS is FALSE.
  if (nrow(line_data)) p <- p + ggplot2::geom_line(data=line_data,linewidth=LINE_WIDTH)
  if (nrow(isolated_data)) p <- p + ggplot2::geom_point(
    data=isolated_data, size=SINGLE_POINT_SIZE, shape=16)
  if(ADD_POINTS) p <- p + ggplot2::geom_point(size=POINT_SIZE,alpha=POINT_ALPHA)
  if(facet) {
    fml <- stats::as.formula(paste0("~",facet_variable))
    p <- p + ggplot2::facet_wrap(fml,ncol=as.integer(facet_columns),
                                scales=if(FACET_FREE_Y)"free_y" else "fixed")
  }
  if(LIMIT_X_TO_100) p <- p + ggplot2::coord_cartesian(xlim=c(0,100))
  p
}
save_plot <- function(p,folder,stem,height_multiplier=1) {
  if(is.null(p)) return(invisible(FALSE))
  dir.create(folder,recursive=TRUE,showWarnings=FALSE)
  hh <- PLOT_HEIGHT_IN*height_multiplier
  if(SAVE_PNG) ggplot2::ggsave(file.path(folder,paste0(stem,".png")),plot=p,
    width=PLOT_WIDTH_IN,height=hh,dpi=PNG_DPI,bg="white",limitsize=TRUE)
  if(SAVE_PDF) {
    pdf_device <- if (capabilities("cairo")) grDevices::cairo_pdf else grDevices::pdf
    ggplot2::ggsave(file.path(folder,paste0(stem,".pdf")),plot=p,
      width=PLOT_WIDTH_IN,height=hh,device=pdf_device,bg="white",limitsize=TRUE)
  }
  invisible(TRUE)
}

# EN: Remove only OLD Klimek A/B PNG/PDF for THIS area before the rerun.
#     This includes figures for groups that are now empty, and options/families
#     that are no longer selected. Other areas and input files are untouched.
# SR: Pre svakog prolaza obrisati samo prethodne Klimek A/B slike za OVU oblast,
#     uključujući sada prazne grupe. Ostale oblasti/podaci nisu obuhvaćeni.
clean_area_figures <- function(outdir, area_key) {
  removed <- character()
  for(lang in c("EN","SR")) for(norm in c("valid","option")) {
    dir <- file.path(outdir,"figures",lang,norm,safe_name(area_key))
    if(!dir.exists(dir)) next
    imgs <- list.files(dir,pattern="\\.(png|pdf)$",full.names=TRUE,
                       ignore.case=TRUE)
    old_names <- basename(imgs)
    a_fig <- grepl("^A_(ALL|GE100|LT100|SMALL|MIDDLE|LARGE|JHK_SMALL|JHK_LARGE)_(combined|faceted)\\.(png|pdf)$",old_names)
    b_fig <- grepl("^B_Option_[0-9]+_votes_(combined(_(standard|jhk))?|faceted)\\.(png|pdf)$",old_names)
    imgs <- imgs[a_fig | b_fig]
    if(length(imgs)) {
      unlink(imgs)
      removed <- c(removed,imgs)
    }
  }
  invisible(removed)
}

# ---------------- BLOCK 9: GEOGRAPHIC AGGREGATION / TERITORIJALNI REZIME ----
# EN: District key and compound municipality key avoid same-name collisions.
# SR: Šifre okruga i složeni ključ opštine čuvaju tačnu geografsku strukturu.
# EN: With include_empty=TRUE, return EVERY area x reporting-group combination,
#     including zero-station groups. Areas are drawn from the eligible ALL pool:
#     an unknown/nonexistent code does not become a fabricated reporting area.
# SR: include_empty=TRUE daje sve kombinacije oblast × grupa, uključujući
#     grupe sa nula BM. Oblasti potiču iz prihvaćene grupe ALL.
area_slices <- function(groups,level,include_empty=FALSE) {
  stopifnot(level %in% c("District","Municipality"),
            is.logical(include_empty),length(include_empty)==1L,!is.na(include_empty))
  get_keys <- function(d) {
    if(level=="District") as.character(d$District_code) else
      paste(as.character(d$District_code),as.character(d$Municipality_code),sep="|")
  }
  all_keys <- if(include_empty) sort(unique(get_keys(groups[["ALL"]]))) else character()
  all_keys <- all_keys[!is.na(all_keys) & nzchar(all_keys)]
  out <- list()
  for(g in names(groups)) {
    d <- groups[[g]]
    keys <- get_keys(d)
    area_keys <- if(include_empty) all_keys else sort(unique(keys))
    area_keys <- area_keys[!is.na(area_keys) & nzchar(area_keys)]
    for(nm in area_keys) {
      rows <- which(!is.na(keys) & keys==nm)
      out[[paste(g,nm,sep="::")]] <- list(group=g,key=nm,
                                         data=d[rows,,drop=FALSE])
    }
  }
  out
}
area_dictionary <- function(d) {
  a <- unique(data.frame(District_code=as.character(d$District_code),District=as.character(d$District),
     Municipality_code=as.character(d$Municipality_code),Municipality=as.character(d$Municipality),
     stringsAsFactors=FALSE))
  a$Municipality_key <- paste(a$District_code,a$Municipality_code,sep="|")
  a
}
area_metric_rows <- function(group_data,gname,area_level,area_key,opts,id) {
  out <- lapply(option_fields(opts),function(f) {
    d <- group_data
    # EN/SR: Outputs remain meaningful for empty/zero-valid group.
    eligible <- is.finite(d$Turnout) & is.finite(d$B) & d$B>=0 &
      is.finite(d[[f]]) & d[[f]]>=0
    d <- d[eligible,,drop=FALSE]
    votes <- sum(d[[f]])
    valid <- sum(d$B)
    data.frame(Election=id,Area_level=area_level,Area_key=area_key,Group=gname,
      Option_field=f,Stations=nrow(d),Registered=sum(d$E),Ballots_cast=sum(d$C),
      Valid_ballots=valid,Invalid_ballots=sum(d$I),Option_votes=votes,
      Turnout_pct=if(sum(d$E)>0)100*sum(d$C)/sum(d$E) else NA_real_,
      Option_share_pct=if(valid>0)100*votes/valid else NA_real_,stringsAsFactors=FALSE)
  })
  do.call(rbind,out)
}

# ---------------- BLOCK 10: WRITE EXCEL AND AUDIT / EXCEL I REVIZIJA ---------
# EN: Compact results go to styled Excel and UTF-8-BOM CSV; full long-format
#     curve points are CSV only (could exceed Excel's row limit).
# SR: Zbirni rezultati idu u XLSX i CSV; tačke krivih samo u CSV (mnogo redova).
write_workbook <- function(path,tables) {
  wb <- openxlsx::createWorkbook(creator="Election Forensics R Toolkit")
  for (sheet in names(tables)) {
    d <- as.data.frame(tables[[sheet]],stringsAsFactors=FALSE,check.names=FALSE)
    if(ncol(d)==0L) next
    openxlsx::addWorksheet(wb,sheet,gridLines=FALSE)
    openxlsx::writeData(wb,sheet,d,keepNA=sheet %in% c("District","Municipality"),
                        na.string="NA",withFilter=nrow(d)>0)
    openxlsx::freezePane(wb,sheet,firstRow=TRUE,firstCol=TRUE)
    h <- openxlsx::createStyle(fgFill="#17324D",fontColour="#FFFFFF",textDecoration="bold",wrapText=TRUE)
    openxlsx::addStyle(wb,sheet,h,rows=1,cols=seq_len(ncol(d)),gridExpand=TRUE)
    openxlsx::setRowHeights(wb,sheet,rows=1,heights=32)
    openxlsx::setColWidths(wb,sheet,cols=seq_len(ncol(d)),widths=19)
    nr <- which(grepl("name|Area_key|Option_field|Group",names(d),ignore.case=TRUE))
    if(length(nr)) openxlsx::setColWidths(wb,sheet,cols=nr,widths=27)
  }
  openxlsx::saveWorkbook(wb,path,overwrite=TRUE)
}

# ---------------- BLOCK 11: PER-ELECTION RUN / JEDNI IZBORI -------------------
# EN: Numeric analysis all options/groups; plot filtering affects images only.
# SR: Numerička analiza svih opcija/grupa; izbor opcija utiče samo na slike.
run_one_election <- function(tp,yr,path) {
  id <- election_id(tp,yr)
  message("[Klimek] Reading ",id,": ",path)
  src <- read_prepared(path,tp,yr)
  groups <- make_groups(src$main,src$master)
  opt <- src$options
  plotopts <- selected_fields(opt,id)
  outdir <- file.path(OUTPUT_DIR,id)
  dir.create(file.path(outdir,"tables"),showWarnings=FALSE,recursive=TRUE)
  dir.create(file.path(outdir,"figures"),showWarnings=FALSE,recursive=TRUE)
  if(SAVE_CURVE_POINTS) dir.create(file.path(outdir,"curves","national"),showWarnings=FALSE,recursive=TRUE)
  coverage <- do.call(rbind,lapply(names(groups),function(g) data.frame(
     Election=id,Group=g,Polling_stations=nrow(groups[[g]]),
     Registered=sum(groups[[g]]$E,na.rm=TRUE),
     Ballots_cast=sum(groups[[g]]$C,na.rm=TRUE),
     Valid_ballots=sum(groups[[g]]$B,na.rm=TRUE),
     Invalid_ballots=sum(groups[[g]]$I,na.rm=TRUE))))
  opts_info <- opt
  opts_info$Displayed_in_plots <- as.character(opt$Votes_field)%in%plotopts
  opts_info$Label_EN <- unname(option_labels(opt,id,"EN")[as.character(opt$Votes_field)])
  opts_info$Label_SR <- unname(option_labels(opt,id,"SR")[as.character(opt$Votes_field)])
  # EN/SR: National and territorial tables for ALL options and ALL 8 groups.
  nat <- do.call(rbind,lapply(names(groups),function(g)
     area_metric_rows(groups[[g]],g,"National","ALL",opt,id)))
  level_result <- function(lvl) {
    a <- area_slices(groups,lvl,include_empty=TRUE)
    if(!length(a)) return(nat[FALSE,,drop=FALSE])
    do.call(rbind,lapply(a,function(z) area_metric_rows(z$data,z$group,lvl,z$key,opt,id)))
  }
  dist <- level_result("District")
  muni <- level_result("Municipality")
  geo <- area_dictionary(groups$ALL)
  # EN/SR: Optional tail contrasts at all 3 geographic levels.
  tm <- data.frame()
  a_fields <- BLOC_A_BY_ELECTION[[id]]
  b_fields <- BLOC_B_BY_ELECTION[[id]]
  if(ENABLE_BLOC_TAIL_METRICS) {
    if(is.null(a_fields) || is.null(b_fields) || !length(a_fields) || !length(b_fields))
      stop("Set both bloc definitions for ",id," or disable ENABLE_BLOC_TAIL_METRICS.")
    if(any(!c(a_fields,b_fields)%in%option_fields(opt))) stop("Unknown bloc field for ",id)
    for(g in names(groups)) {
      for(p in TAIL_PERCENTILES) {
        t <- tail_metric(groups[[g]],a_fields,b_fields,p)
        tm <- rbind(tm,cbind(data.frame(Election=id,Area_level="National",Area_key="ALL",Group=g),t))
      }
    }
    for(lvl in c("District","Municipality")) {
      sl <- area_slices(groups,lvl,include_empty=TRUE)
      for(z in sl)for(p in TAIL_PERCENTILES) {
        t <- tail_metric(z$data,a_fields,b_fields,p)
        tm <- rbind(tm,cbind(data.frame(Election=id,Area_level=lvl,Area_key=z$key,Group=z$group),t))
      }
    }
  }
  if(!nrow(tm)) tm <- data.frame(Election=character(),Area_level=character(),Area_key=character(),
      Group=character(),Tail=numeric(),N_stations=integer(),Turnout_cutoff=numeric(),
      Mean_station_margin_pp=numeric(),Pooled_margin_pp=numeric())
  meta <- data.frame(Item=c("Module","Version","Election","Input file","Input MD5",
    "Normalisations","Languages","Curve sort","Source workbook mutation",
    "Groups","P-value"),Value=c("Klimek cumulative curves","0.1.4",id,
    basename(path),src$source_md5,paste(normalisations(),collapse=", "),
    paste(GRAPH_LANGUAGES,collapse=", "),"Turnout then Station_key","Never",
    "8 nationally defined reporting groups","None (descriptive only)"))
  tabs <- list(Metadata=meta,Coverage=coverage,Options=opts_info,
    National=nat,District=dist,Municipality=muni,Areas=geo,Tail_metrics=tm)
  if(WRITE_EXCEL) write_workbook(file.path(outdir,paste0(id,"_klimek_summary.xlsx")),tabs)
  if(WRITE_CSV) for(nm in names(tabs))
    write_csv(tabs[[nm]],file.path(outdir,"tables",paste0(tolower(nm),".csv")),
              na_string=if(nm %in% c("District","Municipality")) "NA" else "")
  # EN: Build national cumulative curves for EVERY candidate/list. By default,
  #     plots only display TOP_N; numeric endpoints and optional point CSV exist
  #     for ALL options, including those not selected for display.
  # SR: Nacionalne krive se računaju za SVE opcije; na grafikonima je samo
  #     odabrani podskup. Numerički završeci i opcioni CSV postoje za sve.
  curve_endpoints <- do.call(rbind,lapply(names(groups),function(g)
    do.call(rbind,lapply(option_fields(opt),function(f) {
      cr <- cumulative_curve(groups[[g]],f)
      if (SAVE_CURVE_POINTS && WRITE_CSV && nrow(cr))
        write_csv(cr,file.path(outdir,"curves","national",
             paste0(g,"_",f,".csv")))
      curve_metrics(cr,id,"National","ALL",g,f)
    }))))
  tabs$Curve_endpoints <- curve_endpoints
  if(WRITE_CSV) write_csv(curve_endpoints,file.path(outdir,"tables","curve_endpoints.csv"))
  # EN/SR: Endpoint tables do not include all curve rows due to XLSX row limit.
  if (WRITE_EXCEL) {
    # EN/SR: Save the compact additional table into a separate small workbook.
    write_workbook(file.path(outdir,paste0(id,"_curve_endpoints.xlsx")),
                   list(Curve_endpoints=curve_endpoints))
  }
  # EN: Only selected curves are drawn and saved for optional geographic areas.
  plot_groups <- groups[PLOT_GROUPS]
  # EN/SR: Print selected district/municipality graphs only (all numeric summaries are saved).
  geo_lookup <- area_dictionary(src$master)
  first_nonempty <- function(x, fallback="") {
    x <- unique(as.character(x[!is.na(x) & nzchar(as.character(x))]))
    if(length(x)) x[[1]] else fallback
  }
  plotting_areas <- list(National=list(groups=groups, area_level="National",
                                      area_name="National", district_code=NA_character_))
  if(GEOGRAPHIC_PLOTS=="selected") {
    for(code in SELECT_DISTRICT_CODES) {
      spl <- lapply(groups,function(d)d[as.character(d$District_code)==code,,drop=FALSE])
      dname <- first_nonempty(geo_lookup$District[geo_lookup$District_code==code], code)
      plotting_areas[[paste0("District_",safe_name(code))]] <- list(
        groups=spl,area_level="District",area_name=dname,district_code=code)
    }
    for(key in SELECT_MUNICIPALITY_KEYS) {
      spl <- lapply(groups,function(d) d[paste(d$District_code,d$Municipality_code,sep="|")==key,,drop=FALSE])
      mname <- first_nonempty(geo_lookup$Municipality[geo_lookup$Municipality_key==key], key)
      plotting_areas[[paste0("Municipality_",safe_name(key))]] <- list(
        groups=spl,area_level="Municipality",area_name=mname,
        district_code=strsplit(key,"|",fixed=TRUE)[[1]][1])
    }
  }
  nfig <- 0L
  for(an in names(plotting_areas)) {
    area_info <- plotting_areas[[an]]
    local_groups <- area_info$groups[PLOT_GROUPS]
    # EN/SR: Remove old area figures BEFORE deciding which groups can be drawn.
    #     This also handles a selected area with NO drawable observations.
    clean_area_figures(outdir,an)
    empty_groups <- names(local_groups)[vapply(local_groups,nrow,integer(1))==0L]
    if(length(empty_groups)) message("[Klimek] ",id," / ",an,
      ": zero-station group(s) ",paste(empty_groups,collapse=", "),
      "; figures omitted; territorial summaries record Stations=0, percentages=NA.")
    # EN: Inform once per area (not once per output figure) about singleton PS
    #     groups. A single observation will appear as a dot, never a line.
    # SR: Jedna poruka po oblasti za grupe sa samo jednim BM; prikaz je tačka.
    singleton_groups <- names(local_groups)[vapply(local_groups,nrow,integer(1))==1L]
    if (length(singleton_groups)) message("[Klimek] ",id," / ",an,
      ": single-station group(s) ",paste(singleton_groups,collapse=", "),
      "; shown as points rather than lines.")
    curves <- list()
    # EN/SR: Reuse exact cumulative curves for both normalisations and languages.
    for(g in names(local_groups)) for(f in plotopts) {
      cr <- cumulative_curve(local_groups[[g]],f)
      if(!nrow(cr)) next
      cr$Group <- g
      cr$Option_field <- f
      curves[[paste(g,f,sep="::")]] <- cr
      if(SAVE_CURVE_POINTS && WRITE_CSV && area_info$area_level!="National")
        write_csv(cr,file.path(outdir,"curves",paste0(safe_name(an),"_",g,"_",f,".csv")))
    }
    if(!length(curves)) {
      message("[Klimek] No drawable observations: ",id," / ",an)
      next
    }
    long <- do.call(rbind,curves)
    for(lang in GRAPH_LANGUAGES) {
      op_lab <- option_labels(opt,id,lang)
      grp_lab <- stats::setNames(size_friendly(names(local_groups),lang),names(local_groups))
      grp_title_lab <- stats::setNames(size_friendly_full(names(local_groups),lang),names(local_groups))
      oc <- plot_colors(plotopts,"option")
      gc <- plot_colors(names(local_groups),"group")
      for(norm in normalisations()) {
        figdir <- file.path(outdir,"figures",lang,norm,safe_name(an))
        # EN/SR: Clean old eight-line combined B files even for options no longer
        # selected in the EDITABLE section; do not touch source data or CSV.
        if(PLOT_FAMILY_B && dir.exists(figdir)) {
          obsolete <- list.files(figdir,
            pattern="^B_Option_[0-9]+_votes_combined\\.(png|pdf)$",full.names=TRUE)
          if(length(obsolete)) unlink(obsolete)
        }
        if(PLOT_FAMILY_A)for(g in names(local_groups)) {
          d <- long[long$Group==g,,drop=FALSE]
          if(!nrow(d)) next
          present <- plotopts[plotopts%in%unique(d$Option_field)]
          a <- op_lab[present]
          d$Series <- unname(op_lab[d$Option_field])
          ttl <- chart_title(lang,"A",id,context_label(
            lang,tp,yr,area_info$area_level,area_info$area_name,area_info$district_code))
          # EN/SR: Three+ options require TWO legend rows; full names may wrap.
          nrows <- if(length(present)>2L) A_LEGEND_ROWS_3PLUS else 1L
          if(WRITE_COMBINED) {
            p <- plot_curves(d,lang,norm,ttl,a,oc,FALSE,subtitle=grp_title_lab[[g]],legend_rows=nrows)
            if(!is.null(p)) {save_plot(p,figdir,paste0("A_",g,"_combined"));nfig<-nfig+1L}
          }
          if(WRITE_FACETED) {
            p <- plot_curves(d,lang,norm,ttl,a,oc,TRUE,subtitle=grp_title_lab[[g]],legend_rows=nrows)
            if(!is.null(p)) {save_plot(p,figdir,paste0("A_",g,"_faceted"));nfig<-nfig+1L}
          }
        }
        if(PLOT_FAMILY_B)for(f in plotopts) {
          d <- long[long$Option_field==f,,drop=FALSE]
          if(!nrow(d)) next
          present <- names(local_groups)[names(local_groups)%in%unique(d$Group)]
          d$Series <- unname(grp_lab[d$Group])
          titles <- b_titles(lang,tp,yr,area_info$area_level,area_info$area_name,
                             op_lab[[f]],area_info$district_code)
          partitions <- b_group_sets(present)
          # EN: Remove pre-v0.1.1 eight-line combined figures from an old run,
          #     otherwise stale PNG/PDF files could be mistaken for new output.
          # SR: Ukloniti zastarele kombinovane B slike sa osam krivih.
          for(ext in c("png","pdf")) {
            stale <- file.path(figdir,paste0("B_",f,"_combined.",ext))
            if(file.exists(stale)) unlink(stale)
          }
          # EN: Two separate overlays: at most six standard curves / two JHK.
          # SR: Dva odvojena grafikona: standardne grupe i JHK par.
          if(WRITE_COMBINED && B_SPLIT_COMBINED)for(part in names(partitions)) {
            subgroups <- partitions[[part]]
            if(!length(subgroups)) next
            ds <- d[d$Group%in%subgroups,,drop=FALSE]
            keys <- subgroups[subgroups%in%unique(ds$Group)]
            if(!length(keys)) next
            a <- grp_lab[keys]
            nrows <- if(length(keys)>2L) B_LEGEND_ROWS_3PLUS else 1L
            p <- plot_curves(ds,lang,norm,titles$title,a,gc,FALSE,
                             subtitle=titles$subtitle,legend_rows=nrows)
            if(!is.null(p)) {
              save_plot(p,figdir,paste0("B_",f,"_combined_",part))
              nfig<-nfig+1L
            }
          }
          # EN: Optional single B figure, TWO panels, each retaining the
          #     grouping logic and the same axes. Not eight overlaid curves.
          # SR: Opciono JEDNA B slika sa DVA panela i uporedivim osama.
          if(WRITE_FACETED && B_TWO_PANEL_FACET) {
            labels <- if(lang=="EN") c(standard="Standard polling-station groups",
                                            jhk="JHK size classification") else
              c(standard="Standardne grupe biračkih mesta",
                jhk="JHK klasifikacija veličine BM")
            d$Panel <- ifelse(d$Group%in%partitions$jhk,
                              labels[["jhk"]],labels[["standard"]])
            d$Panel <- factor(d$Panel,levels=unname(labels))
            a <- grp_lab[present]
            nrows <- if(length(present)>2L) B_LEGEND_ROWS_3PLUS else 1L
            p <- plot_curves(d,lang,norm,titles$title,a,gc,TRUE,
                             subtitle=titles$subtitle,legend_rows=nrows,
                             facet_variable="Panel",facet_columns=B_PANEL_COLUMNS)
            if(!is.null(p)) {
              save_plot(p,figdir,paste0("B_",f,"_faceted"),
                        height_multiplier=B_PANEL_HEIGHT_MULTIPLIER)
              nfig<-nfig+1L
            }
          }
        }
      }
    }
  }
  message("[Klimek] Completed ",id,": ",nrow(src$main),
      " Main stations; ",nfig," figures; output: ",outdir)
  invisible(list(election=id,coverage=coverage,national=nat,district=dist,
                 municipality=muni,options=opts_info,tail=tm))
}

# ---------------- BLOCK 12: RUN ALL / POKRETANJE SVIH IZBORA ----------------
# EN: For RStudio tests set EF_KLIMEK_TEST_MODE=1 before sourcing; ordinary
#     source("Klimek.R") processes every configured election.
# SR: Za testove postaviti EF_KLIMEK_TEST_MODE=1; obično source pokreće analizu.
run_klimek_all <- function() {
  validate_settings()
  check_packages()
  if(!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR,recursive=TRUE)
  result <- vector("list",nrow(INPUTS))
  for(i in seq_len(nrow(INPUTS)))
    result[[i]] <- run_one_election(INPUTS$election_type[i],INPUTS$year[i],
                                    INPUTS$prepared_file[i])
  names(result) <- paste(INPUTS$election_type,INPUTS$year,sep="_")
  message("[Klimek] All elections completed. Prepared source workbooks unchanged.")
  invisible(result)
}
if (!identical(Sys.getenv("EF_KLIMEK_TEST_MODE"),"1")) run_klimek_all()
