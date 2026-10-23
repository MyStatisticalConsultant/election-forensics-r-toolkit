# New geographic diagnostics & export-coverage regression tests.
.ef_fp_old_mode <- Sys.getenv("EF_FINGERPRINT_TEST_MODE",unset=NA_character_)
Sys.setenv(EF_FINGERPRINT_TEST_MODE="1")
source("Election_fingerprints.R",local=FALSE)
if(is.na(.ef_fp_old_mode)) Sys.unsetenv("EF_FINGERPRINT_TEST_MODE") else
  Sys.setenv(EF_FINGERPRINT_TEST_MODE=.ef_fp_old_mode)
rm(.ef_fp_old_mode)
source("tests/export_validation_helpers.R",local=TRUE)
d <- data.frame(District_code=c("25","26","26","00"),
  Municipality_code=c("90001","90239","90239","70181"),
  District=c("A","Pećki okrug","Pećki okrug","Grad Beograd"),
  Municipality=c("A","Peć","Peć","Novi Beograd"),
  Size=c("Small","Middle","Large","Small"),
  Size_JHK=c("Small","Large","Large","Small"),stringsAsFactors=FALSE)
warnings_seen <- character()
a <- withCallingHandlers(make_areas(d,mode="selected",districts=TRUE,
  municipalities=TRUE,selected_districts=c("26","98"),
  selected_municipalities=c("25|90239","26|90239"),
  invalid_policy="warn",context="test_2022"),warning=function(w) {
    warnings_seen <<- c(warnings_seen,conditionMessage(w))
    invokeRestart("muffleWarning")
  })
stopifnot(length(a)==3L,
  identical(vapply(a,function(x)x$type,character(1)),c("National","District","Municipality")),
  any(grepl("unknown District_code",warnings_seen,fixed=TRUE)),
  any(grepl("25|90239",warnings_seen,fixed=TRUE)),
  any(grepl("26|90239",warnings_seen,fixed=TRUE)))
strict_error <- tryCatch({
  make_areas(d,mode="selected",districts=FALSE,municipalities=TRUE,
             selected_municipalities="25|90239",invalid_policy="error");NULL
},error=function(e)e)
stopifnot(inherits(strict_error,"error"),
          grepl("26|90239",conditionMessage(strict_error),fixed=TRUE))
# Verify status is complete for all selected areas, groups and both measures.
required <- fp_expected_areas(d,"selected",TRUE,TRUE,"26","26|90239")
groups <- c("ALL","SMALL","MIDDLE","LARGE","JHK_SMALL","JHK_LARGE")
measures <- c("valid","cast")
rows<-list()
for(j in seq_len(nrow(required))) {
  e<-required[j,,drop=FALSE]
  sub<-if(e$Area_level=="National") d else if(e$Area_level=="District")
    d[d$District_code==e$Area_code,,drop=FALSE] else
    d[paste(d$District_code,d$Municipality_code,sep="|")==e$Area_code,,drop=FALSE]
  for(g in groups) for(m in measures) {
    n<-fp_expected_group_count(sub,g)
    rows[[length(rows)+1L]]<-data.frame(Area_level=e$Area_level,Area_code=e$Area_code,
      Group=g,Turnout_definition=m,N_area_main=nrow(sub),N_main=n,
      N_included=n,N_excluded=0L)
  }
}
tab<-do.call(rbind,rows)
fp_assert_area_coverage(tab,d,"selected",TRUE,TRUE,"26","26|90239",groups,measures,"test")
bad<-tab[!(tab$Area_level=="Municipality"),,drop=FALSE]
err<-tryCatch({fp_assert_area_coverage(bad,d,"selected",TRUE,TRUE,"26","26|90239",
  groups,measures,"test");NULL},error=function(e)e)
stopifnot(inherits(err,"error"),grepl("26|90239",conditionMessage(err),fixed=TRUE))
cat("PASS: invalid-area warnings and suggestions, strict failure, complete national/district/municipality export coverage.\n")
