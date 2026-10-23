# EN/SR: Run only AFTER source("Election_fingerprints.R") has generated outputs.
# Verify national, district AND municipality outputs (not only national).
.ef_fp_old_mode <- Sys.getenv("EF_FINGERPRINT_TEST_MODE",unset=NA_character_)
Sys.setenv(EF_FINGERPRINT_TEST_MODE="1")
source("Election_fingerprints.R",local=FALSE)
if(is.na(.ef_fp_old_mode)) Sys.unsetenv("EF_FINGERPRINT_TEST_MODE") else
  Sys.setenv(EF_FINGERPRINT_TEST_MODE=.ef_fp_old_mode)
rm(.ef_fp_old_mode)
source("tests/export_validation_helpers.R",local=TRUE)
for(i in seq_len(nrow(INPUTS))) {
  id <- election_id(INPUTS$election_type[[i]],INPUTS$year[[i]])
  report_path <- file.path(OUTPUT_DIR,id,"fingerprints_status.csv")
  if(!file.exists(report_path)) stop("Missing fingerprint status: ",report_path,
    " — run source('Election_fingerprints.R') with EF_FINGERPRINT_TEST_MODE unset")
  tab <- readr::read_csv(report_path,show_col_types=FALSE,
    col_types=readr::cols(.default=readr::col_guess(),
      Area_level=readr::col_character(),Area_code=readr::col_character(),
      Group=readr::col_character(),Turnout_definition=readr::col_character(),
      KDE_status=readr::col_character()))
  src <- read_prepared(INPUTS$prepared_file[[i]],INPUTS$election_type[[i]],INPUTS$year[[i]])
  groups <- c("ALL",if(PLOT_SIZE_GROUPS) SIZE_GROUPS else character())
  expected <- fp_assert_area_coverage(tab,src$main,AREA_MODE,GENERATE_DISTRICTS,
     GENERATE_MUNICIPALITIES,SELECT_DISTRICT_CODES,SELECT_MUNICIPALITY_KEYS,
     groups,TURNOUT_MEASURES,id)
  for(k in seq_len(nrow(tab))) {
    row<-tab[k,,drop=FALSE]
    area_dir <- if(row$Area_level=="National") "National" else if(row$Area_level=="District")
      paste0("District_",safe_name(row$Area_code)) else
      paste0("Municipality_",safe_name(gsub("\\|","_",row$Area_code)))
    grpdir <- if(row$Group=="ALL") file.path(OUTPUT_DIR,id,area_dir) else
      file.path(OUTPUT_DIR,id,area_dir,"groups",row$Group)
    measure <- row$Turnout_definition
    if(SAVE_INPUT_AUDIT && !file.exists(file.path(grpdir,paste0("audit_",measure,".csv"))))
      stop("Missing input audit: ",grpdir," / ",measure)
    gridpath<-file.path(grpdir,paste0("grid_hist_",measure,".csv"))
    if(SAVE_GRID_CSV) {
      if(row$N_included>0L) {
        if(!file.exists(gridpath)) stop("Missing histogram grid: ",gridpath)
        g<-readr::read_csv(gridpath,show_col_types=FALSE)
        if(sum(g$N_stations)!=row$N_included) stop("Histogram grid count mismatch: ",gridpath)
      } else if(file.exists(gridpath)) stop("Stale empty-group grid: ",gridpath)
    }
    for(lang in GRAPH_LANGUAGES) for(ext in c(if(SAVE_PNG) "png",if(SAVE_PDF) "pdf")) {
      histfile<-file.path(grpdir,lang,paste0("fingerprint_hist_",measure,".",ext))
      if(PLOT_HISTOGRAM && row$N_included>0L && !file.exists(histfile))
        stop("Missing histogram: ",histfile)
      if((!PLOT_HISTOGRAM || row$N_included==0L) && file.exists(histfile))
        stop("Stale histogram: ",histfile)
      kdefile<-file.path(grpdir,lang,paste0("fingerprint_kde_",measure,".",ext))
      if(PLOT_KDE && row$KDE_status=="generated" && !file.exists(kdefile))
        stop("Missing KDE supplement: ",kdefile)
      if((!PLOT_KDE || row$KDE_status!="generated") && file.exists(kdefile))
        stop("Stale KDE supplement: ",kdefile)
    }
  }
  levels<-unique(expected$Area_level)
  cat("PASS: all geographic exports",id,"—",
      paste(sprintf("%s=%d",levels,vapply(levels,function(l)
        sum(expected$Area_level==l),integer(1))),collapse=", "),
      "; all size groups, turnout definitions, station counts and files reconcile.\n")
}
