#!/usr/bin/env Rscript
# ============================================================================
# REPUBLIC OF SERBIA – ELECTION POLLING-STATION DATA PREPARATION
# Version: 1.3 | Reproducible source-preserving preparation for 2017, 2022,
#              and later elections supplied in a compatible RZS Excel format.
#
# OUTPUT: one Excel workbook per election; no existing input workbook altered.
# Important: this prepares forensic inputs. It does NOT conduct the formal
# Jimenez–Hidalgo–Klimek (2017) statistical test, assess electoral fraud, or
# repair reported votes. Any exceptional exclusions appear in the audit.
# ============================================================================

# ============================================================================
# EDITABLE USER CONFIGURATION / PODESAVANJA KOJA KORISNIK MOZE DA MENJA
# EN: Edit ONLY this section. Run from this module's directory.
# SR: Menjajte SAMO ovaj odeljak. Pokrenite iz direktorijuma ovog modula.
# ============================================================================
# EN: Each row identifies ONE election by type + year, and its local RZS XLSX.
# SR: Svaki red identifikuje JEDNE izbore po vrsti + godini i lokalnom RZS XLSX.
# EN: Keep/change/remove rows together across all columns.
# SR: Redove menjajte/uklanjajte istovremeno u svim kolonama.
# EN: The 2022 parliamentary file is expected to match the 2022-style template;
#     verify against the official workbook before relying on results.
# SR: Za parlamentarne izbore 2022. predviđen je šablon 2022;
#     proveriti strukturu originalnog fajla pre upotrebe rezultata.
INPUTS <- data.frame(
  election_type = c("presidential", "presidential", "parliamentary"),
  year = c(2017L, 2022L, 2022L),
  source = c("raw_data/P2017 RZS ~ G20176004.xlsx",
             "raw_data/P2022 RZS ~ G202219003.xlsx",
             "raw_data/Parliament 2022 ~ G202219002.xlsx"),
  template = c("2017", "2022", "2022"),
  source_url = c("https://publikacije.stat.gov.rs/G2017/Xls/G20176004.xlsx",
                 "https://publikacije.stat.gov.rs/G2022/Xls/G202219003.xlsx",
                 "https://publikacije.stat.gov.rs/G2022/Xls/G202219002.xlsx"),
  stringsAsFactors = FALSE
)
# EN: The script supports presidential/parliamentary results with a compatible schema.
#     Local election files require schema and electoral-unit validation before use.
# SR: Skript podržava predsedničke/parlamentarne izbore kompatibilnog formata.
#     Lokalni izbori zahtevaju proveru strukture i izbornih jedinica.
# EN: Output directory; generated files are not committed to GitHub.
# SR: Direktorijum rezultata; izlazni fajlovi se ne postavljaju na GitHub.
OUTPUT_DIR <- "RZS_prepared"
# EN: Optional evidence-based administrative decisions CSV; missing file is OK.
# SR: Opcioni CSV za proverene administrativne odluke; može da ne postoji.
OVERRIDES_FILE <- "RZS_station_status_overrides.csv"
# EN: Minimum number of registered voters for primary eligibility.
# SR: Najmanji broj upisanih birača za uključivanje u glavni uzorak.
MIN_ELECTORATE <- 100L
# EN: Target cumulative-electorate fraction in each extreme station-size group.
# SR: Ciljni udeo upisanih birača po ekstremnoj grupi veličine biračkih mesta.
ELECTORATE_FRACTION <- 0.20
# EN: Station-size quantile for the JHK-oriented complementary split.
# SR: Kvantil veličine biračkog mesta za JHK podelu na komplementarne grupe.
JHK_PERCENTILE <- 0.20

# *****************************************************************************
# ******** DO NOT CHANGE THE CODE BELOW THIS LINE ****************************
# ******** NE MENJAJTE KOD ISPOD OVE LINIJE ***********************************
# *****************************************************************************

# EN: Validate editable inputs before reading or writing any files.
# SR: Proveriti podešavanja pre čitanja ili pisanja datoteka.
if (!is.data.frame(INPUTS) ||
    !identical(names(INPUTS), c("election_type", "year", "source", "template", "source_url")) ||
    nrow(INPUTS) < 1L || anyNA(INPUTS) ||
    any(!INPUTS$election_type %in% c("presidential", "parliamentary")) ||
    anyDuplicated(paste(INPUTS$election_type, INPUTS$year, sep="|")) ||
    any(!INPUTS$template %in% c("2017", "2022")) ||
    any(!grepl("^[0-9]{4}$", as.character(INPUTS$year))) ||
    any(!nzchar(trimws(INPUTS$source))) ||
    any(!grepl("^https://", INPUTS$source_url))) {
  stop("Invalid INPUTS: each election_type/year combination must be unique with source, template, source_url.")
}
if (!is.character(OUTPUT_DIR) || length(OUTPUT_DIR) != 1L ||
    is.na(OUTPUT_DIR) || !nzchar(trimws(OUTPUT_DIR))) stop("Invalid OUTPUT_DIR.")
if (!is.character(OVERRIDES_FILE) || length(OVERRIDES_FILE) != 1L ||
    is.na(OVERRIDES_FILE)) stop("Invalid OVERRIDES_FILE.")
if (length(MIN_ELECTORATE) != 1L || !is.finite(MIN_ELECTORATE) || MIN_ELECTORATE < 1 ||
    MIN_ELECTORATE != as.integer(MIN_ELECTORATE)) stop("Invalid MIN_ELECTORATE.")
if (length(ELECTORATE_FRACTION) != 1L || !is.finite(ELECTORATE_FRACTION) ||
    ELECTORATE_FRACTION <= 0 || ELECTORATE_FRACTION >= 0.5) stop("Invalid ELECTORATE_FRACTION.")
if (length(JHK_PERCENTILE) != 1L || !is.finite(JHK_PERCENTILE) ||
    JHK_PERCENTILE <= 0 || JHK_PERCENTILE >= 1) stop("Invalid JHK_PERCENTILE.")

# --- REQUIRED PACKAGES / OBAVEZNI R PAKETI -----------------------------------
# EN: Check dependencies, then create the output folder if necessary.
# SR: Proveriti pakete i napraviti izlazni direktorijum po potrebi.
needed <- c("readxl", "openxlsx")
missing_pkgs <- needed[!vapply(needed, requireNamespace, logical(1), quietly=TRUE)]
if (length(missing_pkgs)) {
  stop("Missing R packages: ", paste(missing_pkgs, collapse=", "),
       ". Install once with install.packages(c('readxl','openxlsx')).")
}
if (!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR, recursive=TRUE)

# --- HELPER FUNCTIONS / POMOCNE FUNKCIJE ------------------------------------
# EN: Text normalization, Cyrillic transliteration, safe ratios and group cutoffs.
# SR: Normalizacija teksta, transliteracija, bezbedni odnosi i granice grupa.
clean_text <- function(x) {
  x <- as.character(x)
  x <- gsub("[[:space:]]+", " ", x)
  trimws(x)
}

# Transliteration is for explanatory labels only; originals are retained.
serbian_latin <- function(x) {
  cyr <- strsplit(
    "АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШабвгдђежзијклљмнњопрстћуфхцчџш", "")[[1]]
  lat <- c("A","B","V","G","D","Đ","E","Ž","Z","I","J","K","L","Lj",
           "M","N","Nj","O","P","R","S","T","Ć","U","F","H","C","Č","Dž","Š",
           "a","b","v","g","d","đ","e","ž","z","i","j","k","l","lj",
           "m","n","nj","o","p","r","s","t","ć","u","f","h","c","č","dž","š")
  lookup <- stats::setNames(lat, cyr)
  vapply(as.character(x), function(s) {
    if (is.na(s)) return(NA_character_)
    ch <- strsplit(s, "")[[1]]
    paste0(ifelse(ch %in% names(lookup), lookup[ch], ch), collapse="")
  }, character(1), USE.NAMES=FALSE)
}

read_number <- function(x) {
  z <- clean_text(x)
  z[z %in% c("", "NA", "N/A", "-", "#DIV/0!")] <- NA_character_
  z <- gsub(" ", "", z, fixed=TRUE)
  suppressWarnings(as.numeric(z))
}
rate <- function(num, den) {
  out <- rep(NA_real_, length(den))
  ok <- !is.na(num) & !is.na(den) & den > 0
  out[ok] <- 100 * num[ok] / den[ok]
  out
}
log_rate <- function(num, den) {
  out <- rep(NA_real_, length(den))
  ok <- !is.na(num) & !is.na(den) & num > 0 & den > 0
  out[ok] <- log(num[ok] / den[ok])
  out
}

# TRUE on a row when at least one of the listed columns is missing.
any_missing <- function(dat, cols) {
  v <- rep(FALSE, nrow(dat))
  for (nm in cols) v <- v | is.na(dat[[nm]])
  v
}

# Select inclusive threshold closest to the targeted share, preserving all
# equal-sized stations as one group. This is the ORIGINAL AUTHORS' DESIGN.
cumulative_cutoff <- function(e, fraction, descending=FALSE) {
  sizes <- sort(unique(e), decreasing=descending)
  counts <- tabulate(match(e, sizes), nbins=length(sizes))
  cumulative <- cumsum(sizes * counts)
  target <- sum(e) * fraction
  candidates <- order(abs(cumulative - target), cumulative)
  idx <- candidates[1]
  list(threshold=sizes[idx], n=sum(counts[seq_len(idx)]),
       electorate=cumulative[idx], share=100*cumulative[idx]/sum(e),
       target=target, difference=cumulative[idx]-target,
       boundary_ties=counts[idx])
}

# EN: Label size groups using two distinct definitions; do not conflate them.
# SR: Obeležiti veličine BM po dve različite definicije; ne izjednačavati ih.
assign_sizes <- function(dat, fraction, percentile) {
  eligible <- which(dat$Eligible_primary)
  dat$Size <- NA_character_
  dat$Size_JHK <- NA_character_
  if (length(eligible) == 0L) stop("No eligible stations available for size grouping.")
  electorate <- dat$E[eligible]
  small <- cumulative_cutoff(electorate, fraction, FALSE)
  large <- cumulative_cutoff(electorate, fraction, TRUE)
  if (small$threshold >= large$threshold)
    stop("Small and Large cumulative-electorate thresholds overlap; review settings.")
  dat$Size[eligible] <- "Middle"
  dat$Size[eligible[which(electorate <= small$threshold)]] <- "Small"
  dat$Size[eligible[which(electorate >= large$threshold)]] <- "Large"
  q <- as.numeric(stats::quantile(electorate, probs=percentile,
                                  na.rm=TRUE, type=7, names=FALSE))
  dat$Size_JHK[eligible] <- ifelse(electorate < q, "Small", "Large")
  # JHK "Large" is the whole complement, and includes the middle sizes.
  assert_that <- function(x, message) if (!isTRUE(x)) stop(message)
  assert_that(sum(dat$Size=="Small", na.rm=TRUE)==small$n,
              "Small group assignment did not match the inclusive boundary count.")
  assert_that(sum(dat$Size=="Large", na.rm=TRUE)==large$n,
              "Large group assignment did not match the inclusive boundary count.")
  rows <- function(group, variable="Size") {
    ii <- which(dat$Eligible_primary & !is.na(dat[[variable]]) & dat[[variable]]==group)
    data.frame(Method=variable, Group=group, Stations=length(ii),
               Registered_voters=sum(dat$E[ii]),
               Electorate_share_pct=100*sum(dat$E[ii])/sum(electorate))
  }
  table <- do.call(rbind, c(lapply(c("Small","Middle","Large"), rows),
                            lapply(c("Small","Large"), function(x) rows(x,"Size_JHK"))))
  list(data=dat, summary=table, small=small, large=large, q=q)
}

# EN: Map the different 2017 and 2022 official XLSX column layouts.
# SR: Povezati različite rasporede kolona zvaničnih XLSX fajlova.
source_schema <- function(template, total_columns) {
  if (template=="2017") {
    if (total_columns < 16L) stop("The 2017 source requires at least 16 columns.")
    list(header=5L, district=1L, district_name=2L, municipality=3L,
         municipality_name=4L, station=5L, station_name=6L, address=7L,
         E=8L, received=9L, unused=10L, A=11L, C=12L, I=13L, B=14L,
         candidates=seq.int(15L,total_columns))
  } else if (template=="2022") {
    if (total_columns < 11L) stop("The 2022-style source requires at least 11 columns.")
    list(header=1L, district=1L, district_name=2L, municipality=3L,
         municipality_name=4L, station=5L, station_name=NA_integer_,
         address=NA_integer_, E=6L, received=NA_integer_, unused=NA_integer_,
         A=7L, C=8L, I=9L, B=10L,
         candidates=seq.int(11L,total_columns))
  } else stop("Unsupported template: ", template, ". Use '2017' or '2022'.")
}

# EN: Import official station-level records and retain source-row traceability.
# SR: Uvesti podatke po biračkim mestima uz trag do izvornog reda.
import_rzs <- function(path, template) {
  if (!file.exists(path)) stop("Source workbook not found: ", path)
  header_line <- if (template=="2017") 5L else 1L
  # EN: Preserve original text, including leading zeroes in administrative codes.
  # SR: Sačuvati izvorni tekst i početne nule u administrativnim šiframa.
  raw <- as.data.frame(readxl::read_excel(path, sheet=1,
                       skip=header_line-1L, col_types="text",
                       .name_repair="minimal"), stringsAsFactors=FALSE,
                       check.names=FALSE)
  src_headers <- names(raw)
  names(raw) <- paste0("V", seq_len(ncol(raw)))
  sch <- source_schema(template, ncol(raw))
  if (length(sch$candidates)<2L) stop("No adequate vote-option columns found.")
  # EN: Ignore rows with incomplete station identifiers (typically blank rows).
  # SR: Preskočiti redove bez potpunih identifikatora biračkog mesta.
  code <- clean_text(raw[[sch$district]])
  municipality <- clean_text(raw[[sch$municipality]])
  ps <- clean_text(raw[[sch$station]])
  valid_record <- !is.na(code) & nzchar(code) &
                  !is.na(municipality) & nzchar(municipality) &
                  !is.na(ps) & nzchar(ps)
  if (any(!valid_record)) {
    message("Skipping ",sum(!valid_record),
            " rows without complete station identifiers (blank formatted rows / headers).")
  }
  src_row <- header_line + which(valid_record)
  raw <- raw[valid_record,,drop=FALSE]
  rownames(raw) <- NULL
  headers <- clean_text(src_headers)
  candidate_names <- clean_text(serbian_latin(headers[sch$candidates]))
  if (any(!nzchar(candidate_names))) stop("One or more vote-option columns has no heading.")
  list(raw=raw, headers=headers, schema=sch, source_row=src_row,
       candidate_names=candidate_names)
}

# EN: Read optional documented station-status decisions; reject duplicates.
# SR: Učitati dokumentovane odluke o statusu BM; odbaciti duplikate.
load_overrides <- function(filename) {
  if (!file.exists(filename)) return(NULL)
  # EN: Read override IDs as text so leading zeroes are never lost.
  # SR: Ucitati sve oznake kao tekst kako se ne bi izgubile pocetne nule.
  x <- utils::read.csv(filename, stringsAsFactors=FALSE, fileEncoding="UTF-8",
                       colClasses="character")
  required <- c("Election_type","Year","District_code","Municipality_code","PS_number",
                "Admin_status","Comment")
  if (!all(required %in% names(x))) stop("Override CSV must have: ",
                                        paste(required,collapse=", "))
  allowed <- c("verified_complete", "verified_no_ballots_received",
               "verified_invalid_record", "unverified")
  if (any(!x$Admin_status %in% allowed))
    stop("Invalid Admin_status in override CSV. Allowed: ",paste(allowed,collapse=", "))
  x$Station_key <- paste(x$Election_type, x$Year, clean_text(x$District_code),
                         clean_text(x$Municipality_code),clean_text(x$PS_number),sep="|")
  if (anyDuplicated(x$Station_key)) stop("Duplicate IDs found in override CSV.")
  x
}
OVERRIDES <- load_overrides(OVERRIDES_FILE)

# EN: Harmonize fields, apply QC, define analytical eligibility, write workbook.
# SR: Standardizovati polja, proveriti kvalitet, odrediti uzorak i izvesti Excel.
process_election <- function(election_type, year, path, template, source_url) {
  imp <- import_rzs(path, template)
  raw <- imp$raw; s <- imp$schema; n <- nrow(raw)
  cat_cols <- paste0("V", s$candidates)
  x <- raw
  x$Election_type <- rep(election_type, n)
  x$Year <- rep(as.integer(year), n)
  x$Source_row <- imp$source_row
  x$District_code <- clean_text(raw[[s$district]])
  x$District <- clean_text(serbian_latin(raw[[s$district_name]]))
  x$Municipality_code <- clean_text(raw[[s$municipality]])
  x$Municipality <- clean_text(serbian_latin(raw[[s$municipality_name]]))
  x$PS_number <- clean_text(raw[[s$station]])
  x$Station_name <- if(is.na(s$station_name)) NA_character_ else
                        clean_text(serbian_latin(raw[[s$station_name]]))
  x$Station_address <- if(is.na(s$address)) NA_character_ else
                           clean_text(serbian_latin(raw[[s$address]]))
  x$Station_key <- paste(x$Election_type, x$Year, x$District_code, x$Municipality_code,
                         x$PS_number, sep="|")
  # EN: Build canonical numeric fields, preserving original source columns.
  # SR: Izvesti standardizovana numerička polja uz očuvanje izvornih kolona.
  # Numeric source values are converted to new canonical columns. Original
  # source columns V1, V2, ... remain unmodified in the output.
  readcol <- function(index) if (is.na(index)) rep(NA_real_,n) else
                         read_number(raw[[index]])
  x$E <- readcol(s$E)
  x$Ballots_received <- readcol(s$received)
  x$Unused_ballots <- readcol(s$unused)
  x$A <- readcol(s$A)  # attendance (izashli na izbore)
  x$C <- readcol(s$C)  # ballots cast / in ballot boxes (glasali)
  x$I <- readcol(s$I)  # invalid
  x$B <- readcol(s$B)  # valid
  cand <- sapply(s$candidates, function(i) read_number(raw[[i]]))
  if (!is.matrix(cand)) cand <- matrix(cand,ncol=length(s$candidates))
  colnames(cand) <- sprintf("Option_%02d_votes",seq_along(s$candidates))
  x <- cbind(x,as.data.frame(cand, check.names=FALSE))
  x$Options_sum <- ifelse(rowSums(is.na(cand))>0, NA_real_, rowSums(cand))
  option_totals <- colSums(cand, na.rm=TRUE)
  order_candidates <- order(-option_totals, seq_along(option_totals))
  w <- order_candidates[1]; r <- order_candidates[2]
  x$Winner_name <- imp$candidate_names[w]
  x$Second_name <- imp$candidate_names[r]
  x$Winner_votes <- cand[,w]
  x$Second_votes <- cand[,r]
  x$Turnout <- rate(x$C,x$E)                     # PRIMARY: C / E * 100
  x$Attendance_pct <- rate(x$A,x$E)              # SECONDARY: A / E * 100
  x$Valid_participation_pct <- rate(x$B,x$E)     # LEGACY: B / E * 100
  x$Invalid_pct_cast <- rate(x$I,x$C)
  x$Invalid_pct_registered <- rate(x$I,x$E)
  x$Winner_pct <- rate(x$Winner_votes,x$B)
  x$Second_pct <- rate(x$Second_votes,x$B)
  x$Winner_per_registered_pct <- rate(x$Winner_votes,x$E)
  x$Second_per_registered_pct <- rate(x$Second_votes,x$E)
  x$Log_winner_per_registered <- log_rate(x$Winner_votes,x$E)
  for (j in seq_len(ncol(cand))) {
    nm <- sprintf("Option_%02d_pct",j)
    x[[nm]] <- rate(cand[,j],x$B)
  }
  # EN: Tag special RZS administrative categories without inferring geography.
  # SR: Obeležiti posebne RZS kategorije bez pretpostavki o lokaciji.
  # Category refers to the official RZS district-level designation, and does
  # not imply a physical polling station's location within Kosovo.
  x$Special_category <- ifelse(x$District_code=="33", "Overseas",
                         ifelse(x$District_code=="55","Prison",
                         ifelse(x$District_code %in% sprintf("%02d",25:29),
                                "Kosovo-associated", "Ordinary")))
  # Do not equate a zero ballot count with a zero ballot *receipt* in 2022,
  # since the 2022 RZS file contains no received/unused ballot columns.
  x$Receipt_information <- ifelse(is.na(x$Ballots_received),
                              "Not supplied by RZS file", "Observed")
  x$No_ballots_received <- !is.na(x$Ballots_received) & x$Ballots_received==0
  x$Zero_cast <- !is.na(x$C) & x$C==0
  x$Zero_valid <- !is.na(x$B) & x$B==0
  x$All_cast_invalid <- x$C > 0 & x$B==0 & !is.na(x$C) & !is.na(x$B)
  x$Duplicate_station_id <- duplicated(x$Station_key) |
                           duplicated(x$Station_key, fromLast=TRUE)
  core_cols <- c("E","A","C","I","B")
  x$Missing_core <- any_missing(x,core_cols)
  all_counts <- cbind(x[,c(core_cols,"Ballots_received","Unused_ballots"),drop=FALSE],cand)
  x$Negative_count <- apply(all_counts,1,function(z) any(z<0,na.rm=TRUE))
  x$Noninteger_count <- apply(all_counts,1,function(z)
                                 any(abs(z-round(z))>1e-8,na.rm=TRUE))
  x$Ballot_identity_violation <- !is.na(x$C)&!is.na(x$I)&!is.na(x$B)&
                                     abs(x$C - x$I - x$B)>1e-8
  x$Option_identity_violation <- !is.na(x$Options_sum)&!is.na(x$B)&
                                       abs(x$Options_sum-x$B)>1e-8
  x$Ballots_exceed_registered <- !is.na(x$C)&!is.na(x$E)&x$C>x$E
  x$Attendance_exceed_registered <- !is.na(x$A)&!is.na(x$E)&x$A>x$E
  x$Attendance_cast_difference <- x$A-x$C  # signed difference, can be negative
  x$Receipt_cast_violation <- !is.na(x$Ballots_received) &
                               !is.na(x$C) & x$C > x$Ballots_received
  x$Administrative_status <- "unverified"
  x$Administrative_comment <- ""
  if(!is.null(OVERRIDES)) {
    ov <- OVERRIDES[OVERRIDES$Election_type == election_type &
                     as.integer(OVERRIDES$Year)==as.integer(year),,drop=FALSE]
    if(nrow(ov)) {
      unmatched <- setdiff(ov$Station_key,x$Station_key)
      if(length(unmatched)) stop("Unmatched override keys: ",paste(unmatched,collapse=", "))
      idx <- match(x$Station_key, ov$Station_key)
      has <- !is.na(idx)
      x$Administrative_status[has] <- ov$Admin_status[idx[has]]
      x$Administrative_comment[has] <- ov$Comment[idx[has]]
    }
  }
  x$Admin_no_ballots <- x$No_ballots_received |
                         x$Administrative_status=="verified_no_ballots_received"
  # Explicit confirmation of completed zero-vote records can override the
  # generic "no ballots received" flag; original counts are NOT rewritten.
  x$Admin_no_ballots[x$Administrative_status=="verified_complete"] <- FALSE
  x$Admin_invalid <- x$Administrative_status=="verified_invalid_record"
  x$Under_100 <- !is.na(x$E)&x$E < MIN_ELECTORATE
  x$Invalid_numeric <- x$Missing_core | is.na(x$E) | x$E<=0 |
       x$Negative_count | x$Noninteger_count |
       x$Ballot_identity_violation | x$Option_identity_violation |
       x$Ballots_exceed_registered | x$Attendance_exceed_registered |
       x$Receipt_cast_violation | x$Duplicate_station_id |
       apply(is.na(cand),1,any)
  x$Eligible_primary <- !x$Under_100 & !x$Admin_no_ballots &
                         !x$Admin_invalid & !x$Invalid_numeric
  x$Eligible_primary[is.na(x$Eligible_primary)] <- FALSE
  # EN: Explicit eligibility and exclusion audit; do not silently drop records.
  # SR: Eksplicitna revizija uključivanja/isključivanja bez brisanja zapisa.
  # Explain ALL reasons rather than hiding observations by row deletion.
  x$Exclusion_reason <- vapply(seq_len(n),function(i) {
    z <- character()
    if(x$Under_100[i]) z <- c(z,"E_below_100")
    if(x$Admin_no_ballots[i]) z <- c(z,"no_ballots_received")
    if(x$Admin_invalid[i]) z <- c(z,"administratively_invalid")
    if(x$Invalid_numeric[i]) z <- c(z,"numeric_or_identity_problem")
    if(!length(z)) "Included" else paste(z, collapse="; ")
  }, character(1))
  x$Audit_action <- ifelse(x$Eligible_primary,
    ifelse(x$Zero_valid,
           "Retained unchanged; option shares undefined",
           "Retained unchanged"),
    "Excluded from main analysis only; original retained unchanged")
  grouping <- assign_sizes(x,ELECTORATE_FRACTION,JHK_PERCENTILE)
  x <- grouping$data
  x$Eligible_turnout <- x$Eligible_primary & !is.na(x$Turnout)
  x$Eligible_cumulative <- x$Eligible_primary & !is.na(x$Turnout) &
                            !is.na(x$Winner_votes)
  x$Eligible_fingerprint <- x$Eligible_primary & !is.na(x$Turnout) &
                             !is.na(x$Winner_pct)
  x$Eligible_contour <- x$Eligible_fingerprint
  x$Eligible_regression <- x$Eligible_primary &
                             !is.na(x$Winner_per_registered_pct) & !is.na(x$Turnout)
  x$Eligible_normality <- x$Eligible_primary & !is.na(x$Log_winner_per_registered)
  x$Eligible_invalid_share <- x$Eligible_primary & !is.na(x$Winner_pct) & !is.na(x$I)
  # No zero-valid denominator is ever forced to 0: it stays numeric NA.
  if(any(x$B==0 & !is.na(x$Winner_pct), na.rm=TRUE))
    stop("Zero-valid-ballot station unexpectedly has a defined winner share.")
  summary_counts <- function(flag, name) data.frame(Check=name,
                  Count=sum(flag,na.rm=TRUE))
  audit <- do.call(rbind,list(
    summary_counts(rep(TRUE,n),"RZS input records"),
    summary_counts(x$Under_100,"E < 100"),
    summary_counts(x$No_ballots_received,"Source reports zero ballots received"),
    summary_counts(x$Zero_cast,"Zero ballots cast"),
    summary_counts(x$Zero_valid,"Zero valid ballots"),
    summary_counts(x$All_cast_invalid,"Positive cast, zero valid (all invalid)"),
    summary_counts(x$Duplicate_station_id,"Duplicated station key"),
    summary_counts(x$Missing_core,"Missing core counts"),
    summary_counts(x$Negative_count,"Negative counts"),
    summary_counts(x$Noninteger_count,"Noninteger counts"),
    summary_counts(x$Ballot_identity_violation,"C != I+B"),
    summary_counts(x$Option_identity_violation,"Sum option votes != B"),
    summary_counts(x$Ballots_exceed_registered,"C > E"),
    summary_counts(x$Attendance_exceed_registered,"A > E"),
    summary_counts(x$Receipt_cast_violation,"C > received ballots"),
    summary_counts(x$Eligible_primary,"Eligible main stations"),
    summary_counts(x$Eligible_fingerprint,"Eligible fingerprints/contours"),
    summary_counts(x$Eligible_regression,"Eligible turnout-vote regression"),
    summary_counts(x$Eligible_normality,"Eligible log winner vote rate"),
    summary_counts(x$Eligible_invalid_share,"Eligible invalid-ballot share")))
  audit$Election_type <- election_type
  audit$Year <- as.integer(year)
  audit <- audit[,c("Election_type","Year","Check","Count")]
  ballot_gap <- x$A-x$C
  with_gap <- which(!is.na(ballot_gap) & ballot_gap!=0)
  qc_log_mask <- x$No_ballots_received | x$Zero_cast | x$Zero_valid |
                 x$Invalid_numeric | (!is.na(ballot_gap) & ballot_gap!=0) |
                 x$Admin_invalid
  qc_columns <- c("Election_type","Year","Station_key","District","Municipality","PS_number",
      "E","Ballots_received","A","C","I","B","Zero_cast","Zero_valid",
      "No_ballots_received","Administrative_status","Administrative_comment",
      "Ballot_identity_violation","Option_identity_violation",
      "Attendance_cast_difference","Exclusion_reason","Audit_action")
  qc_records <- x[qc_log_mask,qc_columns,drop=FALSE]
  if (nrow(qc_records)==0) qc_records <- x[FALSE,qc_columns,drop=FALSE]
  candidate_map <- data.frame(
    Election_type=election_type, Year=as.integer(year),
    Option_type=if (election_type == "presidential") "candidate" else "electoral_list",
    Option_number=seq_along(s$candidates),
    Option_name_SR_Lat=imp$candidate_names,
    Source_V_column=cat_cols,
    Votes_field=sprintf("Option_%02d_votes",seq_along(s$candidates)),
    Share_pct_field=sprintf("Option_%02d_pct",seq_along(s$candidates)),
    Total_votes=as.numeric(option_totals),
    Rank_by_total=match(seq_along(option_totals), order_candidates),
    stringsAsFactors=FALSE)
  original_dictionary <- data.frame(
    Variable=paste0("V",seq_along(imp$headers)),
    Serbian_Latin=serbian_latin(imp$headers),
    Original_RZS_Cyrillic=imp$headers,
    Origin="Original RZS source column (unchanged)",
    stringsAsFactors=FALSE)
  definitions <- data.frame(
    Variable=c("Election_type","Year","Source_row","Station_key","E","A","C","I","B",
       "Ballots_received","Unused_ballots","Turnout","Attendance_pct",
       "Valid_participation_pct","Invalid_pct_cast","Invalid_pct_registered",
       "Winner_name","Second_name","Winner_votes","Second_votes",
       "Winner_pct","Second_pct","Winner_per_registered_pct",
       "Second_per_registered_pct","Log_winner_per_registered",
       "Size","Size_JHK","Special_category","Eligible_primary",
       "Eligible_cumulative","Eligible_fingerprint","Eligible_contour",
       "Eligible_regression","Eligible_normality","Eligible_invalid_share",
       "Exclusion_reason","Audit_action"),
    Serbian_Latin=c("Vrsta izbora","Godina","Red u originalnom Excel fajlu","Jedinstveni ključ biračkog mesta",
       "Upisani birači","Birači izašli na izbore","Birači koji su glasali / listići u kutiji",
       "Nevažeći listići","Važeći listići","Primljeni listići","Neupotrebljeni listići",
       "Izlaznost – listići u kutiji / upisani (%)",
       "Evidentirani izlazak / upisani (%)","Važeći listići / upisani (%)",
       "Nevažeći / listići u kutiji (%)","Nevažeći / upisani (%)",
       "Ime prvoplasiranog","Ime drugoplasiranog","Glasovi prvoplasiranog",
       "Glasovi drugoplasiranog","Udeo prvoplasiranog u važećim (%)",
       "Udeo drugoplasiranog u važećim (%)","Prvoplasirani / upisani (%)",
       "Drugoplasirani / upisani (%)","Prirodni logaritam glasova prvoplasiranog / upisani",
       "Veličina BM – kumulativnih 20% birača", "Veličina BM – JHK 20. percentil veličine",
       "Posebna administrativna kategorija BM","Uključiti u glavni uzorak",
       "Podobno za kumulativne glasove","Podobno za fingerprint",
       "Podobno za konture","Podobno za regresiju","Podobno za logaritamski prikaz",
       "Podobno za analizu nevažećih","Razlog isključenja",
       "Postupak prema zapisu nakon provere"),
    Formula_or_rule=c("Presidential or parliamentary","Election year","Excel row index","Type|Year|district|municipality|station",
       "Source count","Source count","Source count","Source count","Source count",
       "2017 source only; NA for 2022-style file","2017 source only; NA for 2022-style file",
       "100*C/E","100*A/E","100*B/E","100*I/C","100*I/E",
       "National highest vote count","National second highest vote count",
       "Winning option vote count","Runner-up option vote count","100*Winner_votes/B; NA if B=0",
       "100*Second_votes/B; NA if B=0","100*Winner_votes/E",
       "100*Second_votes/E","log(Winner_votes/E); NA if Winner_votes=0",
       "Small/Middle/Large: inclusive cumulative 20% electorate each tail",
       "Small if E < quantile(E,0.20,type=7); Large otherwise",
       "RZS district code 33 / 55 / 25-29 / other",
       "E>=100; valid records; no unverified zero-received station",
       "Main and votes and turnout defined", "Main and winner share defined",
       "Same as fingerprint","Main and turnout + winner/E defined",
       "Main and log winner/E defined","Main and winner/B + invalid counts defined",
       "All exclusion reasons; Included otherwise",
       "Retain raw values; note analysis-specific exclusion or undefined ratios"),
    stringsAsFactors=FALSE)
  schema_df <- rbind(original_dictionary[,c("Variable","Serbian_Latin")],
                     definitions[,c("Variable","Serbian_Latin")])
  references <- data.frame(
    Key=c("Election type","Election year","Source file","Source download URL","Original source MD5",
          "Run timestamp","Grouping A","Grouping B","Minimum E",
          "Primary turnout","Zero valid ballots","Zero received ballots",
          "2022 ballot receipt caveat","JHK paper DOI","JHK comparison caveat"),
    Value=c(election_type, as.character(year), basename(path), source_url,
      unname(as.character(tools::md5sum(path))),
      format(Sys.time(),tz="UTC",usetz=TRUE),
      paste0("Size: bottom/top ",ELECTORATE_FRACTION*100,
             "% of cumulative registered electorate; include all ties"),
      paste0("Size_JHK: electorate-size ",JHK_PERCENTILE*100,
             "th percentile; small E < q, large E >= q"),as.character(MIN_ELECTORATE),
      "Turnout = 100*C/E (ballots cast / registered voters)",
      "Retain when administratively complete; B=0 yields NA option percentages",
      "Exclude if received=0 unless documented verified_complete override",
      "RZS 2022-style file lacks received ballots field; zero-cast alone does not prove non-receipt",
      "10.1126/sciadv.1602363",
      "Size_JHK groups alone do not implement geographic standardization or JHK significance test"),
    stringsAsFactors=FALSE)
  cutoffs <- data.frame(Election_type=election_type, Year=year,
     Measure=c("Main N", "Main electorate","Target per tail electorate",
       "Size small boundary E", "Size small stations", "Size small electorate",
       "Size small share %", "Size small tied stations",
       "Size large boundary E", "Size large stations", "Size large electorate",
       "Size large share %", "Size large tied stations", "JHK 20th percentile q",
       "JHK small stations", "JHK large complement stations"),
     Value=c(sum(x$Eligible_primary),sum(x$E[x$Eligible_primary]),
       grouping$small$target, grouping$small$threshold,
       grouping$small$n, grouping$small$electorate, grouping$small$share,
       grouping$small$boundary_ties, grouping$large$threshold,
       grouping$large$n,grouping$large$electorate,grouping$large$share,
       grouping$large$boundary_ties,grouping$q,
       sum(x$Size_JHK=="Small",na.rm=TRUE),
       sum(x$Size_JHK=="Large",na.rm=TRUE)),stringsAsFactors=FALSE)
  zero_cases <- x[x$Zero_cast | x$Zero_valid | x$No_ballots_received,
    c("Election_type","Year","Station_key","District","Municipality","PS_number","E",
      "Ballots_received","A","C","I","B","Zero_cast","Zero_valid",
      "Administrative_status","Exclusion_reason","Eligible_primary","Size","Size_JHK"),
     drop=FALSE]
  # EN: Summarize discrepancies between attendance A and ballots cast C.
  # SR: Sažeti razlike između evidentiranog izlaska A i ubačenih listića C.
  # Harmonized, disjoint bins for the attendance-versus-ballot audit.
  # All observed differences should be preserved with signs in QC_records.
  gap_abs <- abs(x$Attendance_cast_difference)
  gap_labels <- c("0","1-5","6-10","11-15","16-20","21-25",
                  "26-30","31-35","36-40","41-45","46-50","51+")
  gap_bin <- cut(gap_abs, breaks=c(-Inf,0,5,10,15,20,25,30,35,40,45,50,Inf),
                 labels=gap_labels, right=TRUE)
  gap_distribution <- data.frame(Election_type=election_type, Year=as.integer(year),
     Abs_A_minus_C=gap_labels,
     Stations=as.integer(table(factor(gap_bin,levels=gap_labels))),
     stringsAsFactors=FALSE)
  gap_direction <- data.frame(Election_type=election_type, Year=as.integer(year),
      Difference=c("A > C","A = C","A < C"),
      Stations=c(sum(x$Attendance_cast_difference>0,na.rm=TRUE),
                 sum(x$Attendance_cast_difference==0,na.rm=TRUE),
                 sum(x$Attendance_cast_difference<0,na.rm=TRUE)),
      stringsAsFactors=FALSE)
  package <- list(
    Raw_RZS=raw,
    Master=x,
    Main=x[x$Eligible_primary,,drop=FALSE],
    Excluded=x[!x$Eligible_primary,,drop=FALSE],
    Zero_cases=zero_cases,
    QC_summary=audit,
    QC_records=qc_records,
    Gap_distribution=gap_distribution,
    Gap_direction=gap_direction,
    Size_summary=grouping$summary,
    Size_thresholds=cutoffs,
    Options=candidate_map,
    Source_dictionary=original_dictionary,
    Derived_dictionary=definitions,
    Metadata=references)
  # EN: Export 15 sheets: use Main for default analyses and Master for audit.
  # SR: Izvesti 15 listova: Main za osnovne analize, Master za reviziju.
  # English metadata and Serbian-Latin labels coexist for ease of R use.
  # Save as values, not Excel formulas: reproducibility is supplied by this R
  # script and MD5-identified unchanged source file.
  wb <- openxlsx::createWorkbook(creator="Election Forensics Data Preparation")
  for (sheet in names(package)) {
    openxlsx::addWorksheet(wb,sheet,gridLines=FALSE)
    object <- package[[sheet]]
    openxlsx::writeData(wb,sheet,object,withFilter=nrow(object)>0,
                        keepNA=FALSE,na.string="")
    openxlsx::freezePane(wb,sheet,firstRow=TRUE,firstCol=TRUE)
    hdr <- openxlsx::createStyle(fgFill="#17324D",fontColour="#FFFFFF",
                                 textDecoration="bold",wrapText=TRUE,
                                 valign="center")
    openxlsx::addStyle(wb,sheet,hdr,rows=1,cols=seq_len(ncol(object)),gridExpand=TRUE)
    openxlsx::setRowHeights(wb,sheet,rows=1,heights=33)
    openxlsx::setColWidths(wb,sheet,cols=seq_len(min(25,ncol(object))),
                           widths=if(sheet %in% c("Metadata","Derived_dictionary","Source_dictionary")) 34 else 16)
    if(sheet %in% c("Master","Main","Excluded")) {
      pcols <- which(names(object) %in% c("Turnout","Attendance_pct",
           "Valid_participation_pct","Invalid_pct_cast","Invalid_pct_registered",
           "Winner_pct","Second_pct","Winner_per_registered_pct",
           "Second_per_registered_pct") | grepl("^Option_[0-9]+_pct$",names(object)))
      if(length(pcols) && nrow(object)>0)
        openxlsx::addStyle(wb,sheet,openxlsx::createStyle(numFmt="0.000"),
                            rows=2:(nrow(object)+1L),cols=pcols,gridExpand=TRUE,
                            stack=TRUE)
    }
  }
  outfile <- file.path(OUTPUT_DIR,paste0(election_type,"_",year,"_RZS_prepared.xlsx"))
  openxlsx::saveWorkbook(wb,outfile,overwrite=TRUE)
  message("Prepared ",election_type," ",year,": original=",n," main=",sum(x$Eligible_primary),
          " zero-valid retained in main=",sum(x$Eligible_primary & x$B==0,na.rm=TRUE),
          " Size small E<=",grouping$small$threshold,
          " / large E>=",grouping$large$threshold,
          " JHK q=",format(grouping$q,digits=8)," -> ",outfile)
  list(election_type=election_type, year=year, workbook=outfile, data=x,
       qc=audit, cutoffs=cutoffs, size=grouping$summary)
}

# --- PROCESS ALL SOURCE FILES / OBRADITI SVE IZVORE -------------------------
# EN: One workbook per election type/year, plus a combined QC summary CSV.
# SR: Jedan Excel fajl po vrsti izbora i godini i zajednički CSV sa QC pregledom.
results <- vector("list",nrow(INPUTS))
for(i in seq_len(nrow(INPUTS))) {
  results[[i]] <- process_election(INPUTS$election_type[i], INPUTS$year[i],
                                  INPUTS$source[i], INPUTS$template[i],
                                  INPUTS$source_url[i])
}
# Save a compact cross-year audit, leaving the full data in year-specific files.
combined <- rbind(do.call(rbind,lapply(results,`[[`,"qc")),
                  data.frame(Election_type=character(),Year=integer(),Check=character(),Count=numeric()))
utils::write.csv(combined, file.path(OUTPUT_DIR,"cross_election_QC_summary.csv"),
                 row.names=FALSE,fileEncoding="UTF-8")
cat("\nPreparation completed. Raw files were not modified.\n")

# EN: ANALYSIS INPUT: use worksheet "Main" for subsequent forensic-method modules.
# EN: Worksheet "Master" preserves all records and eligibility/QC flags for audit.
# SR: ULAZ ZA ANALIZU: koristiti list "Main" za naredne forenzičke metode.
# SR: List "Master" čuva sve zapise i oznake podobnosti/kontrole kvaliteta.
# EN: NEXT STEP: future method modules should consume worksheet "Main" by default.
# SR: SLEDECI KORAK: buduci moduli podrazumevano citaju list "Main".
