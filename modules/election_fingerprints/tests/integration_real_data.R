# Integration reads prepared workbooks WITHOUT regenerating them.
# EN/SR: Temporarily disable auto-run while loading functions; restore so
# subsequent source("Election_fingerprints.R") actually executes the module.
.ef_fp_old_mode <- Sys.getenv("EF_FINGERPRINT_TEST_MODE",unset=NA_character_)
Sys.setenv(EF_FINGERPRINT_TEST_MODE="1")
source("Election_fingerprints.R",local=FALSE)
if(is.na(.ef_fp_old_mode)) Sys.unsetenv("EF_FINGERPRINT_TEST_MODE") else
  Sys.setenv(EF_FINGERPRINT_TEST_MODE=.ef_fp_old_mode)
rm(.ef_fp_old_mode)
stopifnot(requireNamespace("readxl",quietly=TRUE))
expected_main <- c(presidential_2017=8023L,presidential_2022=7787L,parliamentary_2022=7787L)
for(i in seq_len(nrow(INPUTS))) {
 tp<-INPUTS$election_type[[i]]; yr<-INPUTS$year[[i]]
 id<-election_id(tp,yr)
 src<-read_prepared(INPUTS$prepared_file[[i]],tp,yr)
 stopifnot(nrow(src$main)==expected_main[[id]])
 win<-choose_option(src$options,id)
 groups<-make_size_groups(src$main)
 stopifnot(sum(vapply(groups[c("SMALL","MIDDLE","LARGE")],nrow,integer(1)))==nrow(src$main),
           sum(vapply(groups[c("JHK_SMALL","JHK_LARGE")],nrow,integer(1)))==nrow(src$main))
 for(g in groups) {
   for(method in c("valid","cast")) {
     sub<-prepare_rates(g,win,method)
     included<-sub[sub$Status=="included",,drop=FALSE]
     if(nrow(included)) {
       grid<-make_hist_grid(included$turnout_pct,included$share_pct,HIST_BINS)
       stopifnot(sum(grid$N_stations)==nrow(included))
     }
   }
 }
 for(method in c("valid","cast")) {
   all<-prepare_rates(src$main,win,method)
   used<-all[all$Status=="included",,drop=FALSE]
   stopifnot(nrow(used)>0L,nrow(used)<=nrow(src$main),
             all(used$turnout_pct>=0&used$turnout_pct<=100),
             all(used$share_pct>=0&used$share_pct<=100))
   gg<-make_hist_grid(used$turnout_pct,used$share_pct,HIST_BINS)
   stopifnot(sum(gg$N_stations)==nrow(used))
 }
 cat("PASS:",id,"(",nrow(src$main),"Main stations; source winner",win,")\n")
}
