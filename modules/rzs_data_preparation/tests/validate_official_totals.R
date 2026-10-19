#!/usr/bin/env Rscript
# ============================================================================
# OFFICIAL RESULTS VALIDATION / PROVERA PREMA ZVANICNIM REZULTATIMA
# EN: Independently compare prepared Master worksheets to RIK reference totals.
# SR: Nezavisno uporediti Master tabele sa referentnim zbirovima RIK-a.
# EN: Requires R, readxl, and all three generated XLSX workbooks.
# SR: Potrebni su R, readxl i tri generisana Excel fajla.
# EN: Run from modules/rzs_data_preparation/: source("tests/validate_official_totals.R")
# SR: Pokretati iz modules/rzs_data_preparation/ direktorijuma.
# ============================================================================

# --- EDITABLE / PODESAVANJA KOJA SE SMEJU MENJATI ----------------------------
OUTPUT_DIR <- "RZS_prepared"
VALIDATION_DIR <- "validation_results"
TOL <- 1e-8

# ******** DO NOT CHANGE THE CODE BELOW THIS LINE ****************************
# ******** NE MENJAJTE KOD ISPOD OVE LINIJE ***********************************

if (!requireNamespace("readxl", quietly=TRUE))
  stop("Install readxl: install.packages('readxl')")
ref_file <- "tests/official_reference_totals.csv"
option_ref_file <- "tests/official_reference_options.csv"
if (!file.exists(ref_file) || !file.exists(option_ref_file))
  stop("Run this validator from the rzs_data_preparation module root.")
if (!dir.exists(OUTPUT_DIR)) stop("Missing output directory: ", OUTPUT_DIR)
if (!dir.exists(VALIDATION_DIR)) dir.create(VALIDATION_DIR, recursive=TRUE)
refs <- read.csv(ref_file, fileEncoding="UTF-8", stringsAsFactors=FALSE)
option_refs <- read.csv(option_ref_file, fileEncoding="UTF-8", stringsAsFactors=FALSE)

log_rows <- list()
record <- function(type, year, group, metric, expected, actual, status, note="", url="") {
  x_num <- suppressWarnings(as.numeric(expected)); a_num <- suppressWarnings(as.numeric(actual))
  delta <- if (length(x_num)==1L && length(a_num)==1L &&
               !is.na(x_num) && !is.na(a_num)) a_num-x_num else NA_real_
  log_rows[[length(log_rows)+1L]] <<- data.frame(
    Election_type=type, Year=as.integer(year), Group=group, Check=metric,
    Expected=as.character(expected), Actual=as.character(actual), Difference=delta,
    Status=status, Note=note, Source_URL=url, stringsAsFactors=FALSE)
}
assert <- function(type, year, metric, ok, note="") {
  record(type, year, "INTEGRITY", metric, "TRUE", isTRUE(ok),
         if(isTRUE(ok)) "PASS" else "FAIL", note)
}
equal_num <- function(a, b, tol=TOL) {
  if (length(a)!=length(b)) return(FALSE)
  a <- suppressWarnings(as.numeric(a)); b <- suppressWarnings(as.numeric(b))
  all((is.na(a)&is.na(b)) | (!is.na(a)&!is.na(b)&abs(a-b)<=tol))
}
safe_pct <- function(n,d) { v <- rep(NA_real_,length(d)); valid <- !is.na(n)&!is.na(d)&d>0; v[valid] <- 100*n[valid]/d[valid]; v }
safe_log <- function(n,d) { v <- rep(NA_real_,length(d)); valid <- !is.na(n)&!is.na(d)&n>0&d>0; v[valid] <- log(n[valid]/d[valid]); v }
num <- function(x) suppressWarnings(as.numeric(x))
colnum <- function(x,n) if(n %in% names(x)) num(x[[n]]) else rep(NA_real_,nrow(x))

# --- ELECTION-BY-ELECTION COMPARISON / PROVERA SVAKIH IZBORA ------------------
for (ii in seq_len(nrow(unique(refs[c("Election_type","Year")])))) {
  election <- unique(refs[c("Election_type","Year")])[ii,,drop=FALSE]
  typ <- election$Election_type[[1]]; yr <- as.integer(election$Year[[1]])
  label <- paste0(typ, "_", yr)
  workbook <- file.path(OUTPUT_DIR,paste0(label,"_RZS_prepared.xlsx"))
  if (!file.exists(workbook)) {
    record(typ, yr, "INTEGRITY", "Output workbook exists", "TRUE", "FALSE", "FAIL",
           paste("Missing:",workbook))
    next
  }
  tabs <- readxl::excel_sheets(workbook)
  required <- c("Raw_RZS","Master","Main","Excluded","Options","QC_summary","Metadata")
  has_tabs <- all(required %in% tabs)
  assert(typ,yr,"Required worksheet set",has_tabs)
  if (!has_tabs) next
  master <- as.data.frame(readxl::read_excel(workbook,sheet="Master",.name_repair="minimal"))
  main <- as.data.frame(readxl::read_excel(workbook,sheet="Main",.name_repair="minimal"))
  excluded <- as.data.frame(readxl::read_excel(workbook,sheet="Excluded",.name_repair="minimal"))
  original <- as.data.frame(readxl::read_excel(workbook,sheet="Raw_RZS",.name_repair="minimal"))
  options <- as.data.frame(readxl::read_excel(workbook,sheet="Options",.name_repair="minimal"))
  qc <- as.data.frame(readxl::read_excel(workbook,sheet="QC_summary",.name_repair="minimal"))
  required_cols <- c("Election_type","Year","Station_key","E","A","C","I","B",
                     "Options_sum","Eligible_primary","Exclusion_reason","Turnout",
                     "Attendance_pct","Invalid_pct_cast","Winner_votes","Winner_pct",
                     "Log_winner_per_registered")
  has_cols <- all(required_cols %in% names(master))
  assert(typ,yr,"Required Master columns",has_cols)
  if (!has_cols) next

  # EN: Retain all station records. Main+Excluded must exactly partition Master.
  # SR: Svi zapisi moraju ostati dostupni: Main + Excluded = Master.
  assert(typ,yr,"Master row count equals Main plus Excluded",
         nrow(master)==nrow(main)+nrow(excluded))
  master_key <- as.character(master$Station_key)
  main_key <- as.character(main$Station_key)
  excluded_key <- as.character(excluded$Station_key)
  assert(typ,yr,"Station keys unique and present", !anyNA(master_key) &&
         !anyDuplicated(master_key) && !any(!nzchar(master_key)))
  assert(typ,yr,"Exact Master partition by station key",
         !anyDuplicated(c(main_key,excluded_key)) &&
         identical(sort(master_key),sort(c(main_key,excluded_key))))
  assert(typ,yr,"Correct election type and year",
         all(master$Election_type==typ) && all(num(master$Year)==yr))
  eligible <- master$Eligible_primary %in% c(TRUE, 1, "TRUE")
  assert(typ,yr,"Main corresponds to Eligible_primary=TRUE",
         identical(sort(main_key),sort(master_key[eligible])))
  assert(typ,yr,"Excluded corresponds to Eligible_primary=FALSE",
         identical(sort(excluded_key),sort(master_key[!eligible])))
  assert(typ,yr,"No duplicate or missing option votes",
         !anyDuplicated(options$Option_number) && !anyNA(options$Option_number))

  # EN: Check copies of original RZS columns against raw worksheet without repairs.
  # SR: Originalne V-kolone moraju odgovarati podacima u Raw_RZS tabeli.
  vcols <- grep("^V[0-9]+$", names(original),value=TRUE)
  if (nrow(original)==nrow(master) && all(vcols %in% names(master))) {
    intact <- all(vapply(vcols,function(v) {
      a <- as.character(original[[v]]); b <- as.character(master[[v]])
      all((is.na(a)&is.na(b))|(!is.na(a)&!is.na(b)&a==b))
    },logical(1)))
    assert(typ,yr,"Original RZS V columns unchanged",intact)
  } else assert(typ,yr,"Original RZS V columns unchanged",FALSE,
                "Original row counts or source columns differ")
  idx <- if(yr==2017L) c(E=8L,A=11L,C=12L,I=13L,B=14L) else c(E=6L,A=7L,C=8L,I=9L,B=10L)
  for (field in names(idx)) {
    raw_field <- paste0("V",idx[[field]])
    assert(typ,yr,paste0("Source column mapping ",field," = ",raw_field),
           raw_field %in% names(master) && equal_num(colnum(master,field),colnum(master,raw_field)))
  }

  # EN: Independently recalculate mathematical invariants and derived fields.
  # SR: Ponovo izračunati osnovne identitete i izvedene promenljive.
  e <- colnum(master,"E"); a <- colnum(master,"A"); c <- colnum(master,"C")
  invalid <- colnum(master,"I"); valid <- colnum(master,"B")
  assert(typ,yr,"Per-station ballot identity C = I + B", equal_num(c,invalid+valid))
  assert(typ,yr,"Per-station Options_sum = B", equal_num(colnum(master,"Options_sum"),valid))
  assert(typ,yr,"Turnout = 100*C/E",equal_num(colnum(master,"Turnout"),safe_pct(c,e)))
  assert(typ,yr,"Attendance_pct = 100*A/E",equal_num(colnum(master,"Attendance_pct"),safe_pct(a,e)))
  assert(typ,yr,"Invalid_pct_cast = 100*I/C",equal_num(colnum(master,"Invalid_pct_cast"),safe_pct(invalid,c)))
  assert(typ,yr,"Winner_pct = 100*Winner_votes/B",equal_num(colnum(master,"Winner_pct"),safe_pct(colnum(master,"Winner_votes"),valid)))
  assert(typ,yr,"Log_winner_per_registered correctly defined",
         equal_num(colnum(master,"Log_winner_per_registered"),safe_log(colnum(master,"Winner_votes"),e)))
  assert(typ,yr,"All core station counts nonmissing",
         all(is.finite(e) & is.finite(a) & is.finite(c) & is.finite(invalid) & is.finite(valid)))
  assert(typ,yr,"All station counts nonnegative",
         all(e>=0 & a>=0 & c>=0 & invalid>=0 & valid>=0,na.rm=TRUE))

  # EN: Compare official totals against full Master (NEVER filtered Main).
  # SR: Zvanične ukupne vrednosti porediti samo sa kompletnom Master tabelom.
  ref_here <- refs[refs$Election_type==typ & refs$Year==yr,,drop=FALSE]
  for (j in seq_len(nrow(ref_here))) {
    rr <- ref_here[j,]
    measured <- if(rr$Metric=="Stations") nrow(master) else sum(colnum(master,rr$Metric))
    totals_match <- isTRUE(all.equal(as.numeric(measured),as.numeric(rr$Expected), tolerance=0))
    status <- if(totals_match) "PASS" else if(rr$Mismatch_policy=="REVIEW") "REVIEW" else "FAIL"
    record(typ,yr,"OFFICIAL TOTAL",rr$Metric,rr$Expected,measured,status,rr$Reference_note,rr$Source_URL)
  }

  # EN: Compare every candidate/list in ballot order to independent RIK totals.
  # SR: Proveriti svaki pojedinačni rezultat kandidata/liste prema RIK-u.
  option_here <- option_refs[option_refs$Election_type==typ & option_refs$Year==yr,,drop=FALSE]
  assert(typ,yr,"Number of candidate/list options matches reference",nrow(options)==nrow(option_here))
  for (j in seq_len(nrow(option_here))) {
    rr <- option_here[j,]; vote_column <- sprintf("Option_%02d_votes",rr$Option_number)
    actual <- if(vote_column %in% names(master)) sum(colnum(master,vote_column)) else NA_real_
    is_match <- !is.na(actual) && actual==as.numeric(rr$Official_votes)
    record(typ,yr,"OFFICIAL OPTION",sprintf("Option_%02d",rr$Option_number),
           rr$Official_votes,actual,if(is_match) "PASS" else "FAIL",
           as.character(rr$Option_name_for_identification),rr$Source_URL)
    if(nrow(options)>=j) {
      opt_idx <- match(as.numeric(rr$Option_number), num(options$Option_number))
      if (!is.na(opt_idx) && "Total_votes" %in% names(options))
        assert(typ,yr,paste0(vote_column," matches Options worksheet"),
               identical(as.numeric(options$Total_votes[opt_idx]),as.numeric(actual)))
    }
  }
  # EN: Independent summary arithmetic cross-check.
  # SR: Provera da li sumarne QC brojke odgovaraju pojedinačnim zapisima.
  check_lookup <- function(nm) {
    idx <- which(qc$Check==nm)
    if(length(idx)!=1L) return(NA_real_)
    num(qc$Count[idx])
  }
  assert(typ,yr,"QC summary input record count",identical(check_lookup("RZS input records"),as.numeric(nrow(master))))
  assert(typ,yr,"QC summary primary eligible count",identical(check_lookup("Eligible main stations"),as.numeric(sum(eligible))))
  cat(sprintf("Validated %s (%d polling stations).\n",label,nrow(master)))
}

# --- SAVE MACHINE-READABLE AUDIT / SNIMITI REVIZIJSKI ZAPIS ------------------
report <- do.call(rbind,log_rows)
report_path <- file.path(VALIDATION_DIR,"official_validation_results.csv")
write.csv(report,report_path,row.names=FALSE,fileEncoding="UTF-8",na="")
counts <- table(factor(report$Status,levels=c("PASS","REVIEW","FAIL")))
cat("\nValidation summary / Rezime provere:\n")
print(counts)
cat("Saved:",report_path,"\n")
if (counts[["FAIL"]] > 0L) {
  stop("FAIL checks present. Inspect report. / Postoje neuspešne provere.")
}
if (counts[["REVIEW"]] > 0L) {
  message("REVIEW items remain: do not describe validation as unqualified PASS.")
} else {
  message("PASS: all configured validation checks passed.")
}
