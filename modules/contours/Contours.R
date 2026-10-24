###############################################################################
# ELECTION FORENSICS R TOOLKIT — CONTOUR DIAGRAMS (v0.1.4 — GitHub release)
# Izborna forenzika — Konturni dijagrami
#
# Descriptive 2D isodensity contours ONLY. No voter-rigging hypothesis test,
# no displacement delta(p), no inference about fraud.
# Requires: readxl, ggplot2, MASS (MASS ships with standard R distributions).
# Run from modules/contours/: source("Contours.R")
###############################################################################

# =========================== EDITABLE SECTION ================================
INPUTS <- data.frame(
  election = c("presidential_2017", "presidential_2022", "parliamentary_2022"),
  prepared_file = file.path("..", "rzs_data_preparation", "RZS_prepared",
    c("presidential_2017_RZS_prepared.xlsx",
      "presidential_2022_RZS_prepared.xlsx",
      "parliamentary_2022_RZS_prepared.xlsx")),
  stringsAsFactors = FALSE
)
DATA_SHEET <- "Main"               # Standard validated sample, E >= 100
WINNER_VOTES_FIELD <- "Winner_votes" # Nationally selected winner from preparation
GRAPH_LANGUAGES <- c("EN", "SR")
TURNOUT_DEFINITIONS <- c("A", "B")  # A = B/E; B = C/E; y = winner/B
COMPARISONS <- c("Size", "Size_JHK")
GEOGRAPHIC_LEVELS <- c("national", "district", "municipality")
# NULL means all districts or municipalities; otherwise use official IDs
DISTRICT_CODES <- NULL
MUNICIPALITY_CODES <- NULL
OUTPUT_DIR <- "contours_outputs"
MIN_REFERENCE_NEIGHBORS <- 5L    # municipal leave-one-out baseline needs >= 5 peers
MIN_GROUP_STATIONS <- 15L       # minimum plotted group size after standardisation
KDE_GRID <- 180L                # resolution for common-grid 2D KDE
# Relative density levels: identical for both group-specific normalised KDEs.
CONTOUR_FRACTIONS <- c(.22, .32, .42, .52, .63, .74, .85)
# MASS::kde2d() divides supplied h by FOUR. Below we specify effective kernel
# SD in z-score units then multiply by 4 before giving h to ggplot2.
KDE_EFFECTIVE_SD_FLOOR <- 0.40  # prevents undersmoothing at large N
KDE_SMOOTH_MULTIPLIER <- 1.25   # effective Gaussian SD >= 0.50
KDE_VIEW_QUANTILES <- c(.005, .995) # display only; ALL observations enter KDE
KDE_VIEW_MARGIN <- 0.06
CONTOUR_ALPHA_RANGE <- c(0.18, 0.95) # outer contours paler; inner contours stronger
SHOW_MODE_ARROW <- TRUE             # arrow KDE mode Large -> KDE mode Small
SHOW_MODE_MARKERS <- TRUE           # small circle at each modal centre
MODE_ARROW_MIN_DISTANCE <- 0.08     # if the modes overlap, omit the arrow
MODE_ARROW_LINEWIDTH <- 0.55
IMAGE_WIDTH_IN <- 7.0
IMAGE_HEIGHT_IN <- 5.25
IMAGE_DPI <- 300L
EXPORT_STANDARDIZED_ROWS <- TRUE
RUN_NOW <- TRUE
# ============================================================================

need_packages <- function(names) {
  absent <- names[!vapply(names, requireNamespace, logical(1), quietly = TRUE)]
  if (length(absent)) stop("Install these R packages: ", paste(absent, collapse=", "), call.=FALSE)
}
need_packages(c("readxl", "ggplot2", "MASS"))

clean_id <- function(x) {
  z <- trimws(as.character(x)); z[is.na(x) | z == ""] <- NA_character_; z
}
slug <- function(x) {
  x <- gsub("[^A-Za-z0-9_-]", "_", as.character(x), perl=TRUE)
  x <- gsub("_+", "_", x)
  ifelse(nchar(x) == 0, "unknown", substr(x, 1L, 90L))
}
num <- function(x) suppressWarnings(as.numeric(x))
truth <- function(x) {
  if (is.logical(x)) return(!is.na(x) & x)
  toupper(trimws(as.character(x))) %in% c("TRUE","T","1","YES")
}
required_fields <- c("Station_key", "District_code", "District", "Municipality_code",
                     "Municipality", "E", "B", "C", "Size", "Size_JHK")
assert_fields <- function(d, fields, file) {
  missing <- setdiff(fields, names(d))
  if(length(missing)) stop(file, " missing fields: ", paste(missing, collapse=", "), call.=FALSE)
}

# Percentage units: the original article calculates in proportions; the z score
# is unchanged if all rates are multiplied by 100. Keep proportions internally.
# Case A: x = B/E (valid votes / registered; paper-consistent specification)
# Case B: x = C/E (ballots in box / registered; Toolkit specification)
# Both:   y = winner_votes/B (winner votes / valid votes)
prepare_rates <- function(d, winner_field, definition) {
  if (!definition %in% c("A", "B")) stop("Definition must be A or B.")
  assert_fields(d, c(required_fields, winner_field), "Prepared data")
  d$E <- num(d$E); d$B <- num(d$B); d$C <- num(d$C)
  d$Winner_selected <- num(d[[winner_field]])
  d$District_code <- clean_id(d$District_code)
  d$Municipality_code <- clean_id(d$Municipality_code)
  d$District <- clean_id(d$District)
  d$Municipality <- clean_id(d$Municipality)
  d$Station_key <- clean_id(d$Station_key)
  d$Size <- as.character(d$Size); d$Size_JHK <- as.character(d$Size_JHK)
  d$turnout_raw <- if(definition == "A") d$B / d$E else d$C / d$E
  d$winner_raw <- d$Winner_selected / d$B
  d$raw_ok <- !is.na(d$Station_key) & !is.na(d$District_code) &
    !is.na(d$Municipality_code) & is.finite(d$E) & is.finite(d$B) &
    is.finite(d$C) & is.finite(d$Winner_selected) &
    d$E >= 100 & d$B > 0 & d$C >= d$B & d$C <= d$E &
    d$Winner_selected >= 0 & d$Winner_selected <= d$B &
    is.finite(d$turnout_raw) & is.finite(d$winner_raw) &
    d$turnout_raw >= 0 & d$turnout_raw <= 1 &
    d$winner_raw >= 0 & d$winner_raw <= 1
  if("Eligible_contour" %in% names(d))
    d$raw_ok <- d$raw_ok & truth(d$Eligible_contour)
  if(anyDuplicated(d$Station_key[!is.na(d$Station_key)]))
    stop("Duplicate Station_key values found; inspect the input workbook.")
  d
}

# Paper: neighborhood Nb(i) consists of *other* polling stations in the SAME
# local geographic unit. For a municipality, compute mean and sample SD using
# ALL eligible other stations (not only stations in a comparison category).
# Algebraic leave-one-out formulas, identical to explicit setdiff(i).
leave_one_out_z <- function(values, municipality, min_neighbours=5L) {
  n <- length(values); out <- rep(NA_real_, n)
  nneighbors <- integer(n)
  valid <- is.finite(values) & !is.na(municipality) & nzchar(municipality)
  if(!any(valid)) return(list(z=out, neighbors=nneighbors))
  groups <- split(which(valid), municipality[valid], drop=TRUE)
  for(idx in groups) {
    m <- length(idx)
    nneighbors[idx] <- max(0L, m-1L)
    if(m-1L < min_neighbours || m < 3L) next
    v <- values[idx]
    others_n <- m-1L
    others_sum <- sum(v)-v
    others_mean <- others_sum/others_n
    # Sample variance over neighbors: (sum squares - n*mean^2)/(n-1)
    others_var <- (sum(v*v)-v*v - others_sum^2/others_n)/(others_n-1L)
    others_var[others_var < 0 & others_var > -1e-11] <- 0
    good <- is.finite(others_var) & others_var > 1e-12
    tmp <- rep(NA_real_, m)
    tmp[good] <- (v[good]-others_mean[good])/sqrt(others_var[good])
    out[idx] <- tmp
  }
  list(z=out, neighbors=nneighbors)
}

standardize_municipality <- function(d, min_neighbours=5L) {
  # Only QC-eligible stations contribute to geographic references; compute
  # BEFORE splitting by Size / Size_JHK or selecting plotted areas.
  d$z_turnout <- NA_real_; d$z_winner <- NA_real_
  d$reference_neighbors <- 0L
  valid <- which(d$raw_ok)
  if(!length(valid)) return(d)
  # Municipal codes are unique nationally; combine district and municipality
  # defensively for sources that reuse local codes.
  local_id <- paste(d$District_code[valid], d$Municipality_code[valid], sep="|")
  a <- leave_one_out_z(d$turnout_raw[valid], local_id, min_neighbours)
  b <- leave_one_out_z(d$winner_raw[valid], local_id, min_neighbours)
  d$z_turnout[valid] <- a$z
  d$z_winner[valid] <- b$z
  d$reference_neighbors[valid] <- pmin(a$neighbors, b$neighbors)
  d$standardized_ok <- d$raw_ok & is.finite(d$z_turnout) & is.finite(d$z_winner)
  d
}

# v0.1.3: TWO group-specific 2-D KDEs drawn by geom_density_2d().
# The earlier implementation fed bw.nrd0 directly to MASS::kde2d(),
# forgetting its h/4 internal conversion. That made the actual kernels four
# times narrower than intended, creating large numbers of tiny contours.
# We explicitly calculate the EFFECTIVE Gaussian kernel SD on pooled z scores.
# Both groups receive exactly the same h, while contours compare fractions
# of the peak density WITHIN each group (contour_var="ndensity").
contour_geometry <- function(area, class_field, min_group=15L, grid=180L,
                             contour_fractions=CONTOUR_FRACTIONS) {
  if(!class_field %in% names(area))
    stop("Missing grouping column: ", class_field)
  keep <- !is.na(area$standardized_ok) & area$standardized_ok &
    !is.na(area[[class_field]]) & area[[class_field]] %in% c("Small", "Large") &
    is.finite(area$z_turnout) & is.finite(area$z_winner)
  g <- area[keep, , drop=FALSE]
  g$class <- factor(as.character(g[[class_field]]), levels=c("Large","Small"))
  counts <- table(factor(g$class, levels=c("Small","Large")))
  if(any(counts < min_group)) return(list(ok=FALSE,
    reason=paste0("Insufficient standardized stations: Small=",counts[[1]],
                  ", Large=",counts[[2]]), counts=counts))
  x <- g$z_turnout; y <- g$z_winner
  if(!all(is.finite(c(x,y))) ||
     !is.finite(stats::sd(x)) || !is.finite(stats::sd(y)) ||
     stats::sd(x) < 1e-9 || stats::sd(y) < 1e-9)
    return(list(ok=FALSE,reason="Pooled zero variance / invalid z scores",counts=counts))

  if(!is.numeric(KDE_EFFECTIVE_SD_FLOOR) ||
     length(KDE_EFFECTIVE_SD_FLOOR)!=1L ||
     !is.finite(KDE_EFFECTIVE_SD_FLOOR) || KDE_EFFECTIVE_SD_FLOOR<=0)
    stop("KDE_EFFECTIVE_SD_FLOOR must be a positive finite scalar")
  if(!is.numeric(KDE_SMOOTH_MULTIPLIER) ||
     length(KDE_SMOOTH_MULTIPLIER)!=1L ||
     !is.finite(KDE_SMOOTH_MULTIPLIER) || KDE_SMOOTH_MULTIPLIER<=0)
    stop("KDE_SMOOTH_MULTIPLIER must be a positive finite scalar")
  if(length(contour_fractions)<2L || any(!is.finite(contour_fractions)) ||
     any(contour_fractions <= 0 | contour_fractions >= 1) ||
     is.unsorted(contour_fractions, strictly=TRUE))
    stop("CONTOUR_FRACTIONS must be strictly ascending within (0,1)")

  sigma <- pmax(c(stats::bw.nrd0(x),stats::bw.nrd0(y)),
                 KDE_EFFECTIVE_SD_FLOOR) * KDE_SMOOTH_MULTIPLIER
  h <- 4 * sigma # MASS::kde2d divides h by 4 internally: critical correction
  if(any(!is.finite(h)) || any(h<=0))
    return(list(ok=FALSE,reason="Invalid pooled KDE bandwidth",counts=counts))

  # Coordinate cropping occurs after density estimation (coord_cartesian).
  # Extremes still contribute to the KDE: they are NEVER removed from g.
  xr <- as.numeric(stats::quantile(x, KDE_VIEW_QUANTILES, type=8, na.rm=TRUE))
  yr <- as.numeric(stats::quantile(y, KDE_VIEW_QUANTILES, type=8, na.rm=TRUE))
  if(any(!is.finite(c(xr,yr))) || diff(xr)<=0 || diff(yr)<=0) {
    xr <- range(x); yr <- range(y)
  }
  xr <- xr + c(-1,1)*max(diff(xr),.001)*KDE_VIEW_MARGIN
  yr <- yr + c(-1,1)*max(diff(yr),.001)*KDE_VIEW_MARGIN
  # The KDE mode is a descriptive density peak, NOT the inferential
  # displacement statistic delta(p) from the separate voter-rigging test.
  # Use the identical h and the same pooled evaluation grid for both groups;
  # x/y extremes are retained (view clipping is ONLY at the plotting stage).
  mode_grid_limits <- c(min(x), max(x), min(y), max(y))
  kde_modes <- group_kde_modes(g, h, grid, mode_grid_limits)
  list(ok=TRUE, data=g, counts=counts, h=h, effective_sd=sigma,
       limits=c(xr,yr), levels=contour_fractions, grid=as.integer(grid),
       kde_modes=kde_modes)
}

# Estimate one 2D KDE density peak per group on the SAME grid and bandwidth.
# Distinguish density modes (visual centres) from means, centroids, or the
# published inferential displacement test. These are used only for an arrow.
group_kde_modes <- function(data, h, grid, limits) {
  required <- c("class", "z_turnout", "z_winner")
  if(!all(required %in% names(data))) stop("KDE modes: missing plot fields")
  out <- vector("list", 2L)
  for(i in seq_along(c("Large", "Small"))) {
    group_name <- c("Large", "Small")[[i]]
    d <- data[!is.na(data$class) & as.character(data$class)==group_name,,drop=FALSE]
    if(nrow(d) < 2L) return(NULL)
    kd <- tryCatch(MASS::kde2d(d$z_turnout, d$z_winner,
                h=h, n=as.integer(grid), lims=limits), error=function(e) NULL)
    if(is.null(kd) || !any(is.finite(kd$z))) return(NULL)
    z <- kd$z
    z[!is.finite(z)] <- -Inf
    idx <- arrayInd(which.max(z), dim(z))
    out[[i]] <- data.frame(class=group_name,
      x=kd$x[idx[1L]], y=kd$y[idx[2L]], stringsAsFactors=FALSE)
  }
  do.call(rbind, out)
}

# Construct the directed visual annotation only when both modes are finite,
# distinct, and actually visible in the cropped figure. Never move a modal
# centre merely to make an arrow appear.
mode_arrow_data <- function(geom, minimum_distance=MODE_ARROW_MIN_DISTANCE) {
  centers <- geom$kde_modes
  if(is.null(centers) || nrow(centers)!=2L ||
     !all(c("class","x","y") %in% names(centers))) return(NULL)
  start <- centers[centers$class=="Large",,drop=FALSE]
  end <- centers[centers$class=="Small",,drop=FALSE]
  if(nrow(start)!=1L || nrow(end)!=1L ||
     !all(is.finite(c(start$x,start$y,end$x,end$y)))) return(NULL)
  lim <- geom$limits
  visible <- function(cx, cy)
    cx >= lim[1] && cx <= lim[2] && cy >= lim[3] && cy <= lim[4]
  if(!visible(start$x, start$y) || !visible(end$x, end$y)) return(NULL)
  distance <- sqrt((end$x-start$x)^2 + (end$y-start$y)^2)
  if(!is.finite(distance) || distance < minimum_distance) return(NULL)
  data.frame(x=start$x,y=start$y,xend=end$x,yend=end$y)
}

area_subsets <- function(d, levels=c("national","district","municipality"),
                         district_codes=NULL, municipality_codes=NULL) {
  chosen <- list()
  if("national" %in% levels) chosen[[length(chosen)+1L]] <-
    list(level="national", code="national", display_EN="Serbia", display_SR="Srbija", rows=rep(TRUE,nrow(d)))
  districts <- unique(d[!is.na(d$District_code), c("District_code","District"),drop=FALSE])
  districts <- districts[!duplicated(districts$District_code),,drop=FALSE]
  if(!is.null(district_codes)) {
    invalid <- setdiff(as.character(district_codes),districts$District_code)
    if(length(invalid)) stop("Unknown DISTRICT_CODES: ",paste(invalid,collapse=", "))
    districts <- districts[districts$District_code %in% as.character(district_codes),,drop=FALSE]
  }
  if("district" %in% levels) for(j in seq_len(nrow(districts))) {
    code <- districts$District_code[[j]]; name <- districts$District[[j]]
    chosen[[length(chosen)+1L]] <- list(level="district",code=code,
      display_EN=paste0("District: ",name),display_SR=paste0("Okrug: ",name),
      rows=!is.na(d$District_code) & d$District_code == code)
  }
  municipalities <- unique(d[!is.na(d$Municipality_code),
                  c("District_code","Municipality_code","Municipality"),drop=FALSE])
  municipalities <- municipalities[!duplicated(paste(municipalities$District_code,
     municipalities$Municipality_code)),,drop=FALSE]
  if(!is.null(municipality_codes)) {
    invalid <- setdiff(as.character(municipality_codes),municipalities$Municipality_code)
    if(length(invalid)) stop("Unknown MUNICIPALITY_CODES: ", paste(invalid,collapse=", "))
    municipalities <- municipalities[municipalities$Municipality_code %in% as.character(municipality_codes),,drop=FALSE]
  }
  if(!is.null(district_codes)) municipalities <- municipalities[
       municipalities$District_code %in% as.character(district_codes),,drop=FALSE]
  if("municipality" %in% levels) for(j in seq_len(nrow(municipalities))) {
    code <- municipalities$Municipality_code[[j]]
    dcode <- municipalities$District_code[[j]]
    name <- municipalities$Municipality[[j]]
    chosen[[length(chosen)+1L]] <- list(level="municipality",code=paste(dcode,code,sep="_"),
      display_EN=paste0("Municipality: ",name),display_SR=paste0("Opština: ",name),
      rows=!is.na(d$District_code) & !is.na(d$Municipality_code) &
        d$District_code == dcode & d$Municipality_code == code)
  }
  chosen
}

election_name <- function(tag, lang) {
  year <- sub(".*_", "", tag)
  if(grepl("^presidential",tag)) {
    if(lang == "EN") paste("Presidential election", year) else paste("Predsednički izbori",year)
  } else if(grepl("^parliamentary",tag)) {
    if(lang == "EN") paste("Parliamentary election",year) else paste("Parlamentarni izbori",year)
  } else tag
}

make_figure <- function(geom, election, area, comparison, definition, lang="EN", winner_name="Winner") {
  if(!lang %in% c("EN","SR")) stop("Languages: EN or SR")
  if(comparison == "Size") {
    group_label <- if(lang=="EN") "Size: Small vs Large" else "Veličina: Mala i velika biračka mesta"
  } else {
    group_label <- if(lang=="EN") "JHK: bottom 20% vs remainder" else "JHK: donjih 20% i preostala mesta"
  }
  definition_label <- if(definition == "A") "A: valid/registered (B/E)" else "B: cast/registered (C/E)"
  definition_label <- if(lang=="SR") {
    if(definition=="A") "A: važeći/upisani (B/E)" else "B: listići u kutiji/upisani (C/E)"
  } else definition_label
  loc <- if(lang=="EN") area$display_EN else area$display_SR
  subtitle <- paste0(loc, "  |  ", group_label, "  |  ", definition_label,
                     "\n", if(lang=="EN") "National winner: " else "Nacionalni pobednik: ", winner_name)
  t <- if(lang=="EN") "Standardized election contours" else "Standardizovani izborni konturni dijagrami"
  label <- if(lang=="EN") c("Large stations","Small stations")
           else c("Velika biračka mesta","Mala biračka mesta")
  directed <- if(isTRUE(SHOW_MODE_ARROW)) mode_arrow_data(geom) else NULL
  caption <- if(lang=="EN") {
    if(!is.null(directed)) "Arrow: Large -> Small KDE density peaks; descriptive only, not a fraud test."
    else "Descriptive KDE contours only; not a test of electoral fraud."
  } else {
    if(!is.null(directed)) "Strelica: od maksimuma KDE gustine velikih ka malim BM; bez testa prevare."
    else "Samo opisne KDE konture; nisu test izborne prevare."
  }

  p <- ggplot2::ggplot(geom$data,
       ggplot2::aes(x=z_turnout, y=z_winner, colour=class, group=class)) +
    # One KDE for EACH group; common pooled h (corrected for MASS h/4),
    # common relative contour levels via ndensity; no contour per station.
    ggplot2::geom_density_2d(
      ggplot2::aes(alpha=ggplot2::after_stat(level)),
      h=geom$h, n=geom$grid, contour_var="ndensity", breaks=geom$levels,
      linewidth=.8, lineend="round", show.legend=TRUE) +
    ggplot2::scale_colour_manual(
      values=c(Large="#F8766D",Small="#00BFC4"),
      breaks=c("Large","Small"), labels=label, drop=FALSE, name=NULL) +
    ggplot2::scale_alpha(range=CONTOUR_ALPHA_RANGE, guide="none") +
    ggplot2::guides(colour=ggplot2::guide_legend(override.aes=list(alpha=1,linewidth=1.2))) +
    ggplot2::geom_hline(yintercept=0,colour="grey87",linewidth=.25) +
    ggplot2::geom_vline(xintercept=0,colour="grey87",linewidth=.25) +
    ggplot2::coord_cartesian(xlim=geom$limits[1:2],ylim=geom$limits[3:4],expand=FALSE) +
    ggplot2::labs(title=paste(election_name(election,lang),"—",t),
      subtitle=subtitle,
      x=if(lang=="EN") "Standardized turnout" else "Standardizovana izlaznost",
      y=if(lang=="EN") "Standardized winner vote share" else "Standardizovani udeo glasova pobednika",
      caption=caption) +
    ggplot2::theme_bw(base_size=11) +
    ggplot2::theme(plot.title=ggplot2::element_text(size=14,face="bold"),
      plot.subtitle=ggplot2::element_text(size=11,margin=ggplot2::margin(b=9)),
      plot.caption=ggplot2::element_text(size=8,colour="grey45"),
      legend.position=c(.975,.035),legend.justification=c("right","bottom"),
      legend.background=ggplot2::element_rect(fill="white",colour="grey55"),
      legend.key=ggplot2::element_rect(fill="white",colour=NA),
      panel.grid.minor=ggplot2::element_line(colour="grey93"))

  if(!is.null(directed)) {
    # Draw markers below the black arrow so the arrowhead remains visible.
    if(isTRUE(SHOW_MODE_MARKERS)) {
      p <- p + ggplot2::geom_point(data=geom$kde_modes,
        ggplot2::aes(x=x,y=y),inherit.aes=FALSE,
        shape=21,size=2.3,stroke=.55,fill="white",colour="black",
        show.legend=FALSE)
    }
    p <- p + ggplot2::geom_segment(data=directed,
      ggplot2::aes(x=x,y=y,xend=xend,yend=yend),inherit.aes=FALSE,
      colour="black",linewidth=MODE_ARROW_LINEWIDTH,
      arrow=grid::arrow(type="closed",length=grid::unit(.17,"cm")),
      show.legend=FALSE)
  }
  p
}

read_election <- function(path, sheet=DATA_SHEET) {
  if(!file.exists(path)) stop("Missing prepared file: ",path)
  sheets <- readxl::excel_sheets(path)
  if(!sheet %in% sheets) stop("Workbook ",path," has no sheet ",sheet)
  as.data.frame(readxl::read_excel(path,sheet=sheet))
}

log_record <- function(election,definition,area,comparison,n_all,n_small,n_large,status,reason="") {
  data.frame(election=election,definition=definition,level=area$level,
    area=area$code,comparison=comparison, eligible_area=n_all,
    small=n_small,large=n_large,status=status,reason=reason,stringsAsFactors=FALSE)
}

run_contours <- function(inputs=INPUTS, out_dir=OUTPUT_DIR) {
  stopifnot(is.data.frame(inputs),all(c("election","prepared_file") %in% names(inputs)))
  if(!length(inputs$election)) stop("No INPUTS set")
  if(!all(GRAPH_LANGUAGES %in% c("EN","SR"))) stop("Invalid GRAPH_LANGUAGES")
  if(!all(TURNOUT_DEFINITIONS %in% c("A","B"))) stop("Invalid TURNOUT_DEFINITIONS")
  if(!all(COMPARISONS %in% c("Size","Size_JHK"))) stop("Invalid COMPARISONS")
  if(!all(GEOGRAPHIC_LEVELS %in% c("national","district","municipality"))) stop("Invalid GEOGRAPHIC_LEVELS")
  dir.create(out_dir,recursive=TRUE,showWarnings=FALSE)
  qc <- list(); no <- 0L
  for(ii in seq_len(nrow(inputs))) {
    tag <- inputs$election[[ii]]; path <- inputs$prepared_file[[ii]]
    message("[Contours] Reading ",tag,": ",path)
    input <- read_election(path)
    for(def in TURNOUT_DEFINITIONS) {
      d <- standardize_municipality(prepare_rates(input,WINNER_VOTES_FIELD,def),
                                    MIN_REFERENCE_NEIGHBORS)
      root <- file.path(out_dir,tag,if(def=="A") "A_valid" else "B_cast")
      dir.create(root,recursive=TRUE,showWarnings=FALSE)
      if(EXPORT_STANDARDIZED_ROWS) {
        dat <- d[,c("Station_key","District_code","District","Municipality_code",
                     "Municipality","E","B","C","Winner_selected","Size","Size_JHK",
                     "turnout_raw","winner_raw","raw_ok","reference_neighbors",
                     "z_turnout","z_winner","standardized_ok"),drop=FALSE]
        utils::write.csv(dat,file.path(root,"standardized_rows.csv"),row.names=FALSE,na="")
      }
      areas <- area_subsets(d,GEOGRAPHIC_LEVELS,DISTRICT_CODES,MUNICIPALITY_CODES)
      for(area in areas) {
        a <- d[area$rows,,drop=FALSE]
        eligible <- sum(a$standardized_ok,na.rm=TRUE)
        winner <- if(WINNER_VOTES_FIELD != "Winner_votes") WINNER_VOTES_FIELD else if("Winner_name" %in% names(a)) {
          w <- unique(as.character(stats::na.omit(a$Winner_name)))
          if(length(w)) w[[1]] else "Winner"
        } else "Winner"
        for(comp in COMPARISONS) {
          geom <- contour_geometry(a,comp,MIN_GROUP_STATIONS,KDE_GRID,CONTOUR_FRACTIONS)
          ns <- as.integer(geom$counts[["Small"]]); nl <- as.integer(geom$counts[["Large"]])
          no <- no+1L
          if(!geom$ok) {
            qc[[no]] <- log_record(tag,def,area,comp,eligible,ns,nl,"SKIP",geom$reason)
            message("[Contours] SKIP ",tag," / ",area$level,"_",area$code," / ",comp,
                    " / ",def,": ",geom$reason)
            next
          }
          dest <- file.path(root,area$level,slug(area$code))
          dir.create(dest,recursive=TRUE,showWarnings=FALSE)
          for(lang in GRAPH_LANGUAGES) {
            file <- file.path(dest,paste0(tag,"_",slug(area$code),"_",comp,"_",def,"_",lang,".png"))
            p <- make_figure(geom,tag,area,comp,def,lang,winner)
            ggplot2::ggsave(file,p,width=IMAGE_WIDTH_IN,height=IMAGE_HEIGHT_IN,
                            units="in",dpi=IMAGE_DPI,bg="white",limitsize=TRUE)
          }
          qc[[no]] <- log_record(tag,def,area,comp,eligible,ns,nl,"PASS","")
        }
      }
      utils::write.csv(data.frame(election=tag,definition=def,
        source_rows=nrow(d),eligible_raw=sum(d$raw_ok),
        eligible_standardized=sum(d$standardized_ok),
        excluded_preprocessing=sum(!d$raw_ok),
        excluded_reference=sum(d$raw_ok & !d$standardized_ok)),
        file.path(root,"standardization_qc.csv"),row.names=FALSE)
    }
  }
  if(length(qc)) {
    m <- do.call(rbind,qc)
    utils::write.csv(m,file.path(out_dir,"contour_export_manifest.csv"),row.names=FALSE)
    message("[Contours] PASS figuresets: ",sum(m$status=="PASS"),
            "; SKIP figuresets: ",sum(m$status=="SKIP"),
            " (each successful figureset produces EN/SR PNGs as configured).")
  }
  invisible(if(length(qc)) do.call(rbind,qc) else data.frame())
}

if (isTRUE(RUN_NOW) && Sys.getenv("EF_CONTOUR_TEST_MODE") != "1") {
  run_contours()
}
