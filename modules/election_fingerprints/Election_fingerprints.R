#!/usr/bin/env Rscript
# =============================================================================
# ELECTION FORENSICS R TOOLKIT | ELECTION FINGERPRINTS | v0.1.4
# EN: Klimek et al. (2012), Figure 1: observed TWO-DIMENSIONAL HISTOGRAM.
# SR: Klimek i saradnici (2012), slika 1: posmatrani DVODIMENZIONALNI HISTOGRAM.
# EN: KDE and ballots-cast turnout are explicitly labelled supplementary plots.
# SR: KDE i izlaznost po ubačenim listićima su jasno označeni kao dopune.
# EN: Run from modules/election_fingerprints: source("Election_fingerprints.R")
# =============================================================================

# ==================== EDITABLE INPUTS / PODEŠAVANJA ===========================
INPUTS <- data.frame(
  election_type=c("presidential","presidential","parliamentary"),
  year=c(2017L,2022L,2022L),
  prepared_file=c(
    "../rzs_data_preparation/RZS_prepared/presidential_2017_RZS_prepared.xlsx",
    "../rzs_data_preparation/RZS_prepared/presidential_2022_RZS_prepared.xlsx",
    "../rzs_data_preparation/RZS_prepared/parliamentary_2022_RZS_prepared.xlsx"),
  stringsAsFactors=FALSE)
OUTPUT_DIR <- "fingerprint_outputs"
GRAPH_LANGUAGES <- c("EN","SR")  # Both outputs in a single run / oba jezika

# EN: The five polling-station-size groups are ON by default (two national
#     classifications). Size boundaries are read from the validated Main sheet;
#     NEVER re-estimate them within districts or municipalities.
# SR: Pet grupa veličine BM je podrazumevano uključeno; klasifikacije Size i
#     Size_JHK se preuzimaju iz Main, bez ponovnog računanja po oblastima.
PLOT_SIZE_GROUPS <- TRUE
SIZE_GROUPS <- c("SMALL","MIDDLE","LARGE","JHK_SMALL","JHK_LARGE")

# EN: National winner from Options.Total_votes for ALL geographies; or manual.
# SR: Pobednik na nivou Srbije iz Options.Total_votes za SVE oblasti; ili ručno.
OPTION_MODE <- "national_winner"   # national_winner | manual
MANUAL_OPTION_BY_ELECTION <- list(
  # parliamentary_2022="Option_01_votes"
)
# EN: Optional English names by exact option-field code, per election.
# SR: Engleski nazivi (opciono), po tačnoj šifri opcije i izborima.
OPTION_LABELS_EN <- list()
OPTION_LABELS_SR <- list()

# EN: Geographic plots: national / selected / all. Keep subnational groups
#     as subsets of polling stations; do NOT aggregate PS into one observation.
# SR: Oblast: national / selected / all; svako BM ostaje zasebno opažanje.
AREA_MODE <- "national"             # national | selected | all
GENERATE_DISTRICTS <- TRUE
GENERATE_MUNICIPALITIES <- FALSE
SELECT_DISTRICT_CODES <- c("33","55")    # exact District_code, includes special areas
SELECT_MUNICIPALITY_KEYS <- character(0) # e.g. c("26|90239")
# EN/SR: warn (continue with valid keys) or error (stop on invalid selection).
# EN: The diagnostic is produced per election; geographic coverage can differ.
# SR: Dijagnostika je po izborima; dostupnost šifara može se razlikovati.
INVALID_AREA_POLICY <- "error"      # error (default; stop) | warn (continue)

# EN: True Fig. 1 representation: polling-station COUNTS per grid cell.
# SR: Izvorna Slika 1: BROJ biračkih mesta u ćeliji, bez KDE zaglađivanja.
HIST_BINS <- 50L                 # 2 percentage points per cell; adjustable
KDE_GRID <- 200L
MIN_KDE_STATIONS <- 10L         # skip KDE when too little information
PLOT_HISTOGRAM <- TRUE
PLOT_KDE <- TRUE
TURNOUT_MEASURES <- c("valid","cast")  # valid = original definition, cast = sensitivity
MARGINAL_SIZE <- 5
SHOW_LEGEND <- TRUE
PLOT_WIDTH_IN <- 11
PLOT_HEIGHT_IN <- 8.0
# EN/SR: Main title and subtitle fonts (pt); subtitle is not bold.
MAIN_TITLE_FONT_SIZE <- 17
SUBTITLE_FONT_SIZE <- 14
PNG_DPI <- 170
SAVE_PNG <- TRUE
SAVE_PDF <- TRUE
SAVE_GRID_CSV <- TRUE
SAVE_INPUT_AUDIT <- TRUE
SHOW_CAPTION <- TRUE

# ==================== END EDITABLE / KRAJ PODEŠAVANJA ========================

required_packages <- c("readxl","ggplot2","MASS","ggExtra","cowplot","readr")
check_packages <- function() {
  absent <- required_packages[!vapply(required_packages,requireNamespace,logical(1),quietly=TRUE)]
  if(length(absent)) stop("Install missing R packages: ",paste(absent,collapse=", "),call.=FALSE)
}
validate_settings <- function() {
  stopifnot(is.data.frame(INPUTS),nrow(INPUTS)>=1L,
    all(c("election_type","year","prepared_file")%in%names(INPUTS)),
    !anyDuplicated(paste(INPUTS$election_type,INPUTS$year)),
    all(INPUTS$election_type%in%c("presidential","parliamentary")),
    all(GRAPH_LANGUAGES%in%c("EN","SR")),length(GRAPH_LANGUAGES)>0L,
    OPTION_MODE%in%c("national_winner","manual"),
    AREA_MODE%in%c("national","selected","all"),
    INVALID_AREA_POLICY%in%c("warn","error"),
    is.logical(GENERATE_DISTRICTS),is.logical(GENERATE_MUNICIPALITIES),
    HIST_BINS>=2L,HIST_BINS<=500L,KDE_GRID>=20L,MIN_KDE_STATIONS>=3L,
    is.logical(PLOT_SIZE_GROUPS),length(PLOT_SIZE_GROUPS)==1L,!is.na(PLOT_SIZE_GROUPS),
    all(SIZE_GROUPS%in%c("SMALL","MIDDLE","LARGE","JHK_SMALL","JHK_LARGE")),
    !anyDuplicated(SIZE_GROUPS),
    all(TURNOUT_MEASURES%in%c("valid","cast")),
    length(TURNOUT_MEASURES)>0L, PLOT_HISTOGRAM||PLOT_KDE,
    SAVE_PNG||SAVE_PDF,
    is.numeric(MAIN_TITLE_FONT_SIZE),length(MAIN_TITLE_FONT_SIZE)==1L,
    is.finite(MAIN_TITLE_FONT_SIZE),MAIN_TITLE_FONT_SIZE>=8,
    is.numeric(SUBTITLE_FONT_SIZE),length(SUBTITLE_FONT_SIZE)==1L,
    is.finite(SUBTITLE_FONT_SIZE),SUBTITLE_FONT_SIZE>=8)
  invisible(TRUE)
}
election_id <- function(tp,yr) paste0(tp,"_",as.integer(yr))
safe_name <- function(x) gsub("[^A-Za-z0-9_-]","_",as.character(x))
write_csv <- function(x,path) {
  dir.create(dirname(path),showWarnings=FALSE,recursive=TRUE)
  readr::write_excel_csv(as.data.frame(x,stringsAsFactors=FALSE),path,na="")
}

# --------------------------- PREPARED RZS DATA -------------------------------
# EN: Preserve official integer vote counts; never reconstruct from percentages.
# SR: Koriste se originalni brojevi glasova, bez rekonstrukcije iz procenata.
read_prepared <- function(path,tp=NULL,yr=NULL) {
  if(!file.exists(path)) stop("Prepared RZS workbook not found: ",path)
  sn <- readxl::excel_sheets(path)
  if(!all(c("Main","Options")%in%sn)) stop("Prepared workbook needs Main and Options sheets")
  d <- as.data.frame(readxl::read_excel(path,sheet="Main",guess_max=10000),check.names=FALSE)
  opt <- as.data.frame(readxl::read_excel(path,sheet="Options"),check.names=FALSE)
  needed <- c("Election_type","Year","Station_key","District_code","District",
              "Municipality_code","Municipality","E","B","C","Size","Size_JHK","Eligible_primary")
  if(length(setdiff(needed,names(d)))) stop("Missing canonical Main columns: ",paste(setdiff(needed,names(d)),collapse=", "))
  reqopt <- c("Votes_field","Option_name_SR_Lat","Total_votes")
  if(length(setdiff(reqopt,names(opt)))) stop("Missing Options columns: ",paste(setdiff(reqopt,names(opt)),collapse=", "))
  fields <- as.character(opt$Votes_field)
  if(!nrow(d)||!length(fields)||anyNA(fields)||anyDuplicated(fields)||
     any(!grepl("^Option_[0-9]+_votes$",fields))||any(!fields%in%names(d)))
    stop("Invalid option dictionary or missing vote-count fields")
  if(anyDuplicated(d$Station_key)||any(is.na(d$Station_key))) stop("Duplicate/missing polling-station keys")
  if(!is.null(tp)&&any(as.character(d$Election_type)!=tp)) stop("Election type does not match input configuration")
  if(!is.null(yr)&&any(as.integer(d$Year)!=as.integer(yr))) stop("Election year does not match input configuration")
  if(any(is.na(d$Eligible_primary)|!as.logical(d$Eligible_primary)))
    stop("Main has non-eligible polling stations; rebuild/validate upstream")
  for(k in c("E","B","C",fields)) d[[k]] <- suppressWarnings(as.numeric(d[[k]]))
  if(any(!is.finite(d$E)|d$E<100)) stop("Main should contain registered electorate >=100 only")
  d$District_code <- as.character(d$District_code)
  d$Municipality_code <- as.character(d$Municipality_code)
  d$District <- as.character(d$District)
  d$Municipality <- as.character(d$Municipality)
  d$Size <- as.character(d$Size)
  d$Size_JHK <- as.character(d$Size_JHK)
  # EN/SR: Both canonical size partitions must cover Main exactly once.
  if(anyNA(d$Size)||anyNA(d$Size_JHK)||
     any(!d$Size%in%c("Small","Middle","Large"))||
     any(!d$Size_JHK%in%c("Small","Large")))
    stop("Incomplete/invalid Size or Size_JHK classification in prepared Main")
  list(main=d,options=opt,source_md5=unname(tools::md5sum(path)))
}
choose_option <- function(options,id,mode=OPTION_MODE,manual=MANUAL_OPTION_BY_ELECTION) {
  fields <- as.character(options$Votes_field)
  if(mode=="manual") {
    f <- manual[[id]]
    if(is.null(f)||length(f)!=1L||!f%in%fields)
      stop("Manual election option missing/invalid for ",id,"; use an Options.Votes_field")
    return(f)
  }
  votes <- suppressWarnings(as.numeric(options$Total_votes))
  if(!length(votes)||any(!is.finite(votes))||any(votes<0))
    stop("Options.Total_votes is incomplete/invalid: cannot identify national winner")
  fields[which.max(votes)]  # stable: first field in Options if exact tie
}
option_label <- function(opt, field, id, lang) {
  o <- which(as.character(opt$Votes_field)==field)
  if(length(o)!=1L) stop("Unknown option field: ",field)
  raw <- as.character(opt$Option_name_SR_Lat[o])
  override <- if(lang=="EN") OPTION_LABELS_EN[[id]] else OPTION_LABELS_SR[[id]]
  if(!is.null(override) && field%in%names(override)) return(as.character(override[[field]]))
  if(is.na(raw)||!nzchar(raw)) return(field)
  raw
}

# ----------------------- TWO SIZE CLASSIFICATIONS ----------------------------
# EN: Group membership is copied from the national Main workbook, and only
#     then subset geographically. The five groups overlap across classifications
#     by DESIGN; never sum their counts as five mutually exclusive groups.
# SR: Grupe nasleđuju nacionalnu podelu iz Main. Grupa iz jedne klasifikacije
#     preklapa se sa grupama iz druge: njihovi brojevi se ne sabiraju zajedno.
size_group_labels <- function(codes,lang) {
  en <- c(SMALL="Small polling stations",MIDDLE="Medium polling stations",
          LARGE="Large polling stations",JHK_SMALL="JHK small polling stations",
          JHK_LARGE="JHK large polling stations")
  sr <- c(SMALL="Mala biračka mesta",MIDDLE="Srednja biračka mesta",
          LARGE="Velika biračka mesta",JHK_SMALL="JHK mala biračka mesta",
          JHK_LARGE="JHK velika biračka mesta")
  dictionary <- if(lang=="SR") sr else en
  if(any(!codes%in%names(dictionary))) stop("Unknown polling-station size group")
  unname(dictionary[codes])
}
size_classification <- function(group) {
  if(group=="ALL") "All_Main" else if(group%in%c("SMALL","MIDDLE","LARGE"))
    "Size" else if(group%in%c("JHK_SMALL","JHK_LARGE")) "Size_JHK" else
    stop("Unknown size-group code")
}
make_size_groups <- function(d) {
  if(!all(c("Size","Size_JHK")%in%names(d))) stop("Missing Size/Size_JHK columns")
  if(anyNA(d$Size)||anyNA(d$Size_JHK)||
     any(!d$Size%in%c("Small","Middle","Large"))||
     any(!d$Size_JHK%in%c("Small","Large")))
    stop("Invalid size partition; check nationally prepared RZS workbook")
  result <- list(
    SMALL=d[d$Size=="Small",,drop=FALSE],
    MIDDLE=d[d$Size=="Middle",,drop=FALSE],
    LARGE=d[d$Size=="Large",,drop=FALSE],
    JHK_SMALL=d[d$Size_JHK=="Small",,drop=FALSE],
    JHK_LARGE=d[d$Size_JHK=="Large",,drop=FALSE])
  stopifnot(sum(vapply(result[c("SMALL","MIDDLE","LARGE")],nrow,integer(1)))==nrow(d),
            sum(vapply(result[c("JHK_SMALL","JHK_LARGE")],nrow,integer(1)))==nrow(d))
  result
}

# --------------------------- TERRITORIAL LABELS ------------------------------
pretty_election <- function(tp,yr,lang) {
  words <- if(lang=="SR") c(presidential="predsednički",parliamentary="parlamentarni") else
    c(presidential="presidential",parliamentary="parliamentary")
  if(!tp%in%names(words)) stop("Unknown election type: ",tp)
  paste(unname(words[[tp]]),as.integer(yr))
}
area_label <- function(type,name,code,lang) {
  if(type=="National") return(if(lang=="SR") "Srbija" else "Serbia")
  nm <- trimws(as.character(name))
  if(is.na(nm)||!nzchar(nm)) nm <- as.character(code)
  if(type=="District") {
    if(as.character(code)=="33") return(if(lang=="SR") "Inostranstvo" else "Overseas")
    if(as.character(code)=="55") return(if(lang=="SR") "Zavodi za izvršenje krivičnih sankcija" else "Prisons")
    # Special codes 25–29 preserve the official name; no made-up district suffix.
    if(as.character(code)%in%as.character(25:29)) {
      if(lang=="EN") return(sub("(?i)\\s+okrug$"," district",nm,perl=TRUE))
      return(nm)
    }
    if(lang=="EN") {
      nm <- sub("(?i)\\s+okrug$","",nm,perl=TRUE)
      return(if(grepl("(?i)\\s+district$",nm,perl=TRUE)) nm else paste(nm,"district"))
    }
    return(if(grepl("(?i)\\s+okrug$",nm,perl=TRUE)) nm else paste(nm,"okrug"))
  }
  if(type=="Municipality") {
    if(lang=="EN") return(if(grepl("(?i)\\s+municipality$",nm,perl=TRUE)) nm else paste(nm,"municipality"))
    if(grepl("(?i)^(opština|grad)\\s",nm,perl=TRUE)) return(nm)
    return(paste("opština",nm))
  }
  stop("Unrecognized area level: ",type)
}
make_title <- function(lang,tp,yr,area,field,option_name,kind,measure,group="ALL") {
  stem <- if(lang=="SR") "Izborni otisci" else "Election fingerprints"
  election <- pretty_election(tp,yr,lang)
  area_name <- area_label(area$type,area$name,area$code,lang)
  main <- paste0(stem," | ",election," ",area_name)
  is_winner <- identical(field,area$national_winner)
  selected_text <- if(lang=="SR") {
    if(is_winner) "Pobednička opcija: " else "Odabrana opcija: "
  } else {if(is_winner) "National winning option: " else "Selected option: "}
  kind_text <- if(lang=="SR") {
    if(kind=="hist") "2D histogram (broj BM)" else "KDE (zaglađena gustina)"
  } else {if(kind=="hist") "2D histogram (PS counts)" else "KDE (smoothed density)"}
  measure_text <- if(lang=="SR") {
    if(measure=="valid") "važeći glasovi / upisani birači" else "osetljivost: ubačeni listići / upisani birači"
  } else {if(measure=="valid") "valid votes / registered voters" else "sensitivity: ballots cast / registered voters"}
  detail <- paste0(selected_text,option_name," | ",kind_text," | ",measure_text)
  # EN/SR: Size classification is the first subtitle line, smaller and plain.
  if(group!="ALL") detail <- paste(size_group_labels(group,lang),detail,sep="\n")
  list(main=main,subtitle=detail)
}

# ------------------------- NATIONAL / SUBNATIONAL ----------------------------
# EN: Subsets of ORIGINAL polling stations, never district-level aggregation.
# SR: Uvek se analiziraju pojedinačna BM unutar teritorijalne oblasti.
first_name <- function(v,fallback) {
  v <- unique(trimws(as.character(v[!is.na(v)])))
  v <- v[nzchar(v)]
  if(length(v)) v[[1]] else as.character(fallback)
}
# EN: Validate exact RZS identifiers instead of silently dropping unmatched keys.
# SR: Provera zvaničnih RZS šifara; pogrešni ključevi se ne preskaču neprimetno.
validate_area_selection <- function(d,mode=AREA_MODE,
    districts=GENERATE_DISTRICTS,municipalities=GENERATE_MUNICIPALITIES,
    selected_districts=SELECT_DISTRICT_CODES,
    selected_municipalities=SELECT_MUNICIPALITY_KEYS,
    policy=INVALID_AREA_POLICY,context="") {
  if(!policy%in%c("warn","error")) stop("INVALID_AREA_POLICY must be warn or error")
  if(mode!="selected") return(invisible(TRUE))
  report_issue <- function(msg) {
    msg <- paste0("[Fingerprints] ",if(nzchar(context)) paste0(context,": ") else "",msg)
    if(policy=="error") stop(msg,call.=FALSE)
    warning(msg,call.=FALSE)
  }
  known_dist <- sort(unique(as.character(d$District_code)))
  keys <- paste(as.character(d$District_code),as.character(d$Municipality_code),sep="|")
  known_muni <- sort(unique(keys))
  if(districts) {
    requested <- unique(as.character(selected_districts))
    invalid <- setdiff(requested,known_dist)
    if(length(invalid)) report_issue(paste0("unknown District_code(s): ",
      paste(invalid,collapse=", "),"; no output for these codes. ",
      "Check prepared Main$District_code for valid identifiers."))
  }
  if(municipalities) {
    requested <- unique(as.character(selected_municipalities))
    invalid <- setdiff(requested,known_muni)
    if(length(invalid)) for(key in invalid) {
      parts <- strsplit(key,"|",fixed=TRUE)[[1]]
      guess <- if(length(parts)==2L && nzchar(parts[[2]]))
        known_muni[endsWith(known_muni,paste0("|",parts[[2]]))] else character()
      suggestion <- if(length(guess)) paste0(" Possible matching key(s): ",
        paste(guess,collapse=", "),".") else ""
      report_issue(paste0("unknown District_code|Municipality_code key: '",key,
        "'; no output for this key.",suggestion,
        " Check prepared Main for exact district-municipality pairs."))
    }
  }
  invisible(TRUE)
}
make_areas <- function(d,mode=AREA_MODE,districts=GENERATE_DISTRICTS,
                       municipalities=GENERATE_MUNICIPALITIES,
                       selected_districts=SELECT_DISTRICT_CODES,
                       selected_municipalities=SELECT_MUNICIPALITY_KEYS,
                       invalid_policy=INVALID_AREA_POLICY,context="") {
  areas <- list(list(type="National",code="ALL",name="National",data=d,dir="National"))
  if(mode=="national") return(areas)
  validate_area_selection(d,mode,districts,municipalities,
    selected_districts,selected_municipalities,invalid_policy,context)
  if(districts) {
    cs <- sort(unique(as.character(d$District_code)))
    if(mode=="selected") cs <- intersect(cs,as.character(selected_districts))
    for(code in cs) {
      z <- d[d$District_code==code,,drop=FALSE]
      areas[[length(areas)+1L]] <- list(type="District",code=code,
        name=first_name(z$District,code),data=z,
        dir=paste0("District_",safe_name(code)))
    }
  }
  if(municipalities) {
    keys <- paste(d$District_code,d$Municipality_code,sep="|")
    cs <- sort(unique(keys))
    if(mode=="selected") cs <- intersect(cs,as.character(selected_municipalities))
    for(key in cs) {
      z <- d[keys==key,,drop=FALSE]
      areas[[length(areas)+1L]] <- list(type="Municipality",code=key,
        name=first_name(z$Municipality,key),data=z,
        dir=paste0("Municipality_",safe_name(gsub("\\|","_",key))))
    }
  }
  areas
}

# -------------------- EXACT RATE DEFINITIONS AND QC --------------------------
# EN: Paper-consistent primary plot x=valid votes/registered; y=winner/valid.
# SR: Primarni prikaz x=važeći/upisani; y=glasovi izborne opcije/važeći.
# EN: Alternative x=ballots cast/registered changes X ONLY; not share Y.
# SR: U osetljivosti menja se SAMO X; imenilac Y ostaje broj važećih.
prepare_rates <- function(d,field,measure="valid") {
  if(!field%in%names(d)) stop("Missing winner votes column: ",field)
  if(!measure%in%c("valid","cast")) stop("Unknown turnout definition")
  E <- as.numeric(d$E); B <- as.numeric(d$B); C <- as.numeric(d$C)
  W <- as.numeric(d[[field]])
  xnum <- if(measure=="valid") B else C
  reason <- rep("included",length(E))
  reason[!is.finite(E)|E<100] <- "invalid_electorate"
  ix <- reason=="included" & (!is.finite(B)|B<=0|B>E)
  reason[ix] <- "invalid_valid_ballots"
  ix <- reason=="included" & (!is.finite(W)|W<0|W>B)
  reason[ix] <- "invalid_option_votes"
  ix <- reason=="included" & (!is.finite(xnum)|xnum<0|xnum>E)
  reason[ix] <- "invalid_turnout_numerator"
  x <- rep(NA_real_,length(E)); y <- rep(NA_real_,length(E))
  ok <- reason=="included"
  x[ok] <- 100*xnum[ok]/E[ok]
  y[ok] <- 100*W[ok]/B[ok]
  ix <- ok & (!is.finite(x)|!is.finite(y)|x<0|x>100|y<0|y>100)
  reason[ix] <- "out_of_range"
  data.frame(Station_key=as.character(d$Station_key),
    District_code=as.character(d$District_code),
    Municipality_code=as.character(d$Municipality_code),
    E=E,B=B,C=C,Option_votes=W,
    turnout_pct=x,share_pct=y,Status=reason,
    stringsAsFactors=FALSE)
}

# ------------------------ 2-D HISTOGRAM COUNTS -------------------------------
# EN: Each PS contributes exactly ONE observation (unweighted count).
# SR: Svako BM daje tačno JEDNO opažanje (bez ponderisanja biračima).
make_hist_grid <- function(x,y,bins=HIST_BINS) {
  if(length(x)!=length(y)||!length(x)||any(!is.finite(x)|!is.finite(y))||
     any(x<0|x>100|y<0|y>100)||bins<2L)
    stop("Histogram requires finite percentages in [0,100] and bins>=2")
  cutpoints <- seq(0,100,length.out=bins+1L)
  ix <- findInterval(x,cutpoints,rightmost.closed=TRUE,all.inside=TRUE)
  iy <- findInterval(y,cutpoints,rightmost.closed=TRUE,all.inside=TRUE)
  # EN/SR: x fastest, y second: includes ZERO-count cells for true count scale.
  z <- tabulate((iy-1L)*bins+ix,nbins=bins*bins)
  stopifnot(sum(z)==length(x))
  width <- 100/bins
  data.frame(turnout_pct=rep((seq_len(bins)-0.5)*width,times=bins),
    share_pct=rep((seq_len(bins)-0.5)*width,each=bins),
    N_stations=as.integer(z),stringsAsFactors=FALSE)
}
make_kde_grid <- function(x,y,n=KDE_GRID) {
  if(length(x)<MIN_KDE_STATIONS || stats::sd(x)<=0 || stats::sd(y)<=0) return(NULL)
  # EN: Raster coordinates must be cell CENTRES, not the 0/100 outer edges.
  #     Otherwise geom_raster trims all 4*n-4 boundary tiles at scale limits.
  # SR: KDE mreža se računa u SREDIŠTIMA ćelija, ne na granicama 0/100.
  #     Time se izbegava odsecanje 4*n-4 rubnih pločica.
  half_cell <- 50 / as.numeric(n)
  kd <- MASS::kde2d(x,y,n=n,
                     lims=c(half_cell,100-half_cell,half_cell,100-half_cell))
  z <- as.vector(kd$z)
  if(any(!is.finite(z))||max(z)<=0) return(NULL)
  g <- expand.grid(turnout_pct=kd$x,share_pct=kd$y)
  g$density_normalized <- pmax(0,pmin(1,z/max(z)))
  g
}

# ----------------------- BILINGUAL FIGURE LAYOUT -----------------------------
palette_fingerprint <- c("#367fb6","#47a6bf","#8fd2b0","#ecf5a2","#ffc16a","#ee5b52")
make_core_plot <- function(d,grid,kind,measure,lang) {
  # EN: invisible PS points let ggExtra draw marginals from actual PS, not tiles.
  # SR: Nevidljive tačke prenose izvorna BM u marginalne raspodele.
  p <- ggplot2::ggplot(d,ggplot2::aes(x=turnout_pct,y=share_pct)) +
    ggplot2::geom_point(alpha=0,size=0.001,show.legend=FALSE)
  if(kind=="hist") {
    max_n <- max(grid$N_stations)
    p <- p + ggplot2::geom_raster(data=grid,
      ggplot2::aes(x=turnout_pct,y=share_pct,fill=N_stations),inherit.aes=FALSE) +
      ggplot2::scale_fill_gradientn(colours=palette_fingerprint,
        limits=c(0,max(1,max_n)),breaks=sort(unique(as.integer(pretty(c(0,max(1,max_n)),n=5)))),
        name=if(lang=="SR") "Broj biračkih mesta" else "Polling stations")
  } else {
    p <- p + ggplot2::geom_raster(data=grid,
      ggplot2::aes(x=turnout_pct,y=share_pct,fill=density_normalized),inherit.aes=FALSE) +
      ggplot2::scale_fill_gradientn(colours=palette_fingerprint,
        limits=c(0,1),breaks=seq(0,1,0.2),
        name=if(lang=="SR") "Relativna KDE gustina (0–1)" else "Relative KDE density (0–1)")
  }
  xlab <- if(lang=="SR") {
    if(measure=="valid") "Izlaznost – važeći glasovi / upisani (%)" else
      "Izlaznost – ubačeni listići / upisani (%)"
  } else {
    if(measure=="valid") "Turnout – valid votes / registered (%)" else
      "Turnout – ballots cast / registered (%)"
  }
  ylab <- if(lang=="SR") "Udeo glasova izborne opcije (%)" else "Electoral option vote share (%)"
  if(SHOW_CAPTION) {
    p <- p + ggplot2::labs(caption=if(lang=="SR")
      "Opisni izborni otisci; anomalije same po sebi nisu dokaz prevare" else
      "Descriptive fingerprints; anomalies alone are not evidence of fraud")
  }
  # EN: Never impose hard scale limits on raster cell centres: scale limits
  #     can censor whole border rows during geom_raster() / ggMarginal() draws.
  #     Clip the VIEW at 0–100 via the coordinate system instead. This retains
  #     all grid rows and visible axes while avoiding removed-row warnings.
  # SR: Ne ograničavati raster na skali (odsecaju se rubne ćelije); granice
  #     prikaza 0–100 zadati u koordinatnom sistemu, bez gubitka redova.
  p + ggplot2::scale_x_continuous(breaks=seq(0,100,25),
        labels=function(v)paste0(v,"%"),expand=ggplot2::expansion(mult=0)) +
      ggplot2::scale_y_continuous(breaks=seq(0,100,25),
        labels=function(v)paste0(v,"%"),expand=ggplot2::expansion(mult=0)) +
      ggplot2::coord_equal(xlim=c(0,100),ylim=c(0,100),expand=FALSE) +
      ggplot2::labs(x=xlab,y=ylab) +
      ggplot2::theme_bw(base_size=13) +
      ggplot2::theme(legend.position=if(SHOW_LEGEND) "right" else "none",
        legend.title=ggplot2::element_text(face="bold",size=11),
        legend.text=ggplot2::element_text(size=10),
        axis.title=ggplot2::element_text(size=14),
        axis.text=ggplot2::element_text(size=11),
        panel.grid=ggplot2::element_blank(),
        plot.caption=ggplot2::element_text(size=9,hjust=1),
        plot.margin=ggplot2::margin(5,5,5,5))
}
create_fingerprint_plot <- function(d,grid,kind,measure,lang,labels) {
  p <- make_core_plot(d,grid,kind,measure,lang)
  # EN: one PS or constant data cannot yield a marginal kernel density.
  # SR: Pri premalo/konstantnih BM koriste se marginalni histogrami.
  mt <- if(nrow(d)>=MIN_KDE_STATIONS &&
           stats::sd(d$turnout_pct)>0 && stats::sd(d$share_pct)>0) "density" else "histogram"
  marg <- ggExtra::ggMarginal(p,type=mt,margins="both",size=MARGINAL_SIZE,
    colour="black",fill=NA)
  title_line <- paste(strwrap(labels$main,width=83),collapse="\n")
  # EN/SR: Preserve the deliberate newline separating size and method.
  # EN/SR: Use a narrower wrap width for the larger subtitle font.
  subtitle_line <- paste(vapply(strsplit(labels$subtitle,"\n",fixed=TRUE)[[1]],
    function(t) paste(strwrap(t,width=83),collapse="\n"),character(1)),collapse="\n")
  # EN/SR: ggplot title/subtitle blocks prevent overlap if a name wraps.
  header <- ggplot2::ggplot() + ggplot2::theme_void() +
    ggplot2::labs(title=title_line,subtitle=subtitle_line) +
    ggplot2::theme(
      plot.title.position="plot",
      plot.title=ggplot2::element_text(face="bold",size=MAIN_TITLE_FONT_SIZE,margin=ggplot2::margin(b=6)),
      plot.subtitle=ggplot2::element_text(face="plain",size=SUBTITLE_FONT_SIZE,margin=ggplot2::margin(t=3)),
      plot.margin=ggplot2::margin(t=3,r=8,b=1,l=12))
  header_lines <- length(strsplit(title_line,"\n",fixed=TRUE)[[1]]) +
    length(strsplit(subtitle_line,"\n",fixed=TRUE)[[1]])
  # EN/SR: Reserve extra space for the enlarged subtitle, especially the
  #     long size-group names in EN/SR and the method/turnout description.
  header_share <- min(0.42,0.14+0.046*max(0,header_lines-2L))
  cowplot::plot_grid(header,marg,ncol=1,rel_heights=c(header_share,1-header_share))
}
save_plot <- function(plot,prefix) {
  dir.create(dirname(prefix),recursive=TRUE,showWarnings=FALSE)
  if(SAVE_PNG) ggplot2::ggsave(paste0(prefix,".png"),plot=plot,
        width=PLOT_WIDTH_IN,height=PLOT_HEIGHT_IN,dpi=PNG_DPI,bg="white")
  if(SAVE_PDF) ggplot2::ggsave(paste0(prefix,".pdf"),plot=plot,
        width=PLOT_WIDTH_IN,height=PLOT_HEIGHT_IN,device="pdf",bg="white")
}

# --------------------------- PROCESS ELECTION --------------------------------
run_one_election <- function(tp,yr,path) {
  id <- election_id(tp,yr)
  message("[Fingerprints] Reading ",id,": ",path)
  src <- read_prepared(path,tp,yr)
  opt <- src$options
  national_winner <- choose_option(opt,id)
  selected_label_en <- option_label(opt,national_winner,id,"EN")
  selected_label_sr <- option_label(opt,national_winner,id,"SR")
  areas <- make_areas(src$main,context=id)
  root <- file.path(OUTPUT_DIR,id)
  dir.create(root,recursive=TRUE,showWarnings=FALSE)
  report <- list()
  for(a in areas) {
    a$national_winner <- as.character(opt$Votes_field[which.max(as.numeric(opt$Total_votes))])
    area_dir <- file.path(root,a$dir)
    dir.create(area_dir,recursive=TRUE,showWarnings=FALSE)
    # EN/SR: Clear ONLY our figure names, including group output directories.
    # Removed/disabled subgroups cannot leave obsolete charts masquerading as new.
    if(dir.exists(area_dir)) {
      old_figures <- list.files(area_dir,pattern="^fingerprint_(hist|kde)_(valid|cast)\\.(png|pdf)$",
                                recursive=TRUE,full.names=TRUE)
      if(length(old_figures)) unlink(old_figures)
      # EN/SR: stale count/KDE grids cannot remain for empty groups or disabled modes.
      old_grids <- list.files(area_dir,pattern="^grid_(hist|kde)_(valid|cast)\\.csv$",
                              recursive=TRUE,full.names=TRUE)
      if(length(old_grids)) unlink(old_grids)
    }
    subgroups <- if(PLOT_SIZE_GROUPS) make_size_groups(a$data)[SIZE_GROUPS] else list()
    datasets <- c(list(ALL=a$data),subgroups)
    for(gr in names(datasets)) {
      group_data <- datasets[[gr]]
      group_dir <- if(gr=="ALL") area_dir else file.path(area_dir,"groups",gr)
      dir.create(group_dir,recursive=TRUE,showWarnings=FALSE)
      if(!nrow(group_data))
        message("[Fingerprints] ",id," / ",a$dir," / ",gr,
                ": zero polling stations; no figures, status recorded")
      for(measure in TURNOUT_MEASURES) {
        raw <- prepare_rates(group_data,national_winner,measure)
        good <- raw[raw$Status=="included",,drop=FALSE]
        bad <- raw[raw$Status!="included",,drop=FALSE]
        if(SAVE_INPUT_AUDIT) write_csv(raw,file.path(group_dir,paste0("audit_",measure,".csv")))
        report[[length(report)+1L]] <- data.frame(Election=id,
          Area_level=a$type,Area_code=a$code,Area_name=a$name,
          Group=gr,Group_classification=size_classification(gr),
          Group_label_EN=if(gr=="ALL") "All polling stations (E >= 100)" else size_group_labels(gr,"EN"),
          Group_label_SR=if(gr=="ALL") "Sva biračka mesta (E >= 100)" else size_group_labels(gr,"SR"),
          N_area_main=nrow(a$data),
          Option_field=national_winner,Option_selection=OPTION_MODE,
          Turnout_definition=measure,N_main=nrow(group_data),N_included=nrow(good),
          N_excluded=nrow(bad),N_histogram_figures=if(nrow(good)&&PLOT_HISTOGRAM)length(GRAPH_LANGUAGES) else 0L,
          KDE_status=if(!PLOT_KDE) "disabled" else if(!nrow(good)) "empty" else "pending",
          Source_workbook_MD5=src$source_md5,stringsAsFactors=FALSE)
        j <- length(report)
        if(!nrow(good)) {
          report[[j]]$KDE_status <- "empty"
          next
        }
        hist_grid <- make_hist_grid(good$turnout_pct,good$share_pct,HIST_BINS)
        if(SAVE_GRID_CSV) write_csv(hist_grid,file.path(group_dir,paste0("grid_hist_",measure,".csv")))
        kde_grid <- if(PLOT_KDE) make_kde_grid(good$turnout_pct,good$share_pct,KDE_GRID) else NULL
        report[[j]]$KDE_status <- if(!PLOT_KDE) "disabled" else if(is.null(kde_grid)) "insufficient_data" else "generated"
        if(!is.null(kde_grid) && SAVE_GRID_CSV)
          write_csv(kde_grid,file.path(group_dir,paste0("grid_kde_",measure,".csv")))
        if(is.null(kde_grid) && PLOT_KDE)
          message("[Fingerprints] ",id," / ",a$dir," / ",gr," / ",measure,
                  ": KDE omitted (too few stations or zero variance); histogram retained")
        for(lang in GRAPH_LANGUAGES) {
          out <- file.path(group_dir,lang)
          optlab <- if(lang=="EN") selected_label_en else selected_label_sr
          if(PLOT_HISTOGRAM) {
            lbl <- make_title(lang,tp,yr,a,national_winner,optlab,"hist",measure,group=gr)
            p <- create_fingerprint_plot(good,hist_grid,"hist",measure,lang,lbl)
            save_plot(p,file.path(out,paste0("fingerprint_hist_",measure)))
          }
          if(PLOT_KDE&&!is.null(kde_grid)) {
            lbl <- make_title(lang,tp,yr,a,national_winner,optlab,"kde",measure,group=gr)
            p <- create_fingerprint_plot(good,kde_grid,"kde",measure,lang,lbl)
            save_plot(p,file.path(out,paste0("fingerprint_kde_",measure)))
          }
        }
      }
    }
  }
  status <- do.call(rbind,report)
  write_csv(status,file.path(root,"fingerprints_status.csv"))
  message("[Fingerprints] Completed ",id,": ",nrow(src$main)," Main stations; ",
          length(areas)," areas; ",length(datasets)," group outputs per area (including ALL)")
  invisible(status)
}
run_fingerprints <- function() {
  validate_settings()
  check_packages()
  x <- lapply(seq_len(nrow(INPUTS)),function(i)
    run_one_election(INPUTS$election_type[i],INPUTS$year[i],INPUTS$prepared_file[i]))
  names(x) <- paste(INPUTS$election_type,INPUTS$year,sep="_")
  message("[Fingerprints] All configured elections completed; upstream files unchanged.")
  invisible(x)
}
if(!identical(Sys.getenv("EF_FINGERPRINT_TEST_MODE"),"1")) run_fingerprints()
