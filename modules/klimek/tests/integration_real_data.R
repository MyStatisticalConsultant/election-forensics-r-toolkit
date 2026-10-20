# EN/SR: Optional real-data integration with three locally prepared workbooks.
Sys.setenv(EF_KLIMEK_TEST_MODE="1")
source("Klimek.R",encoding="UTF-8")
Sys.unsetenv("EF_KLIMEK_TEST_MODE")
check_packages()
expected_n <- c(presidential_2017=8023L,presidential_2022=7787L,parliamentary_2022=7787L)
for(i in seq_len(nrow(INPUTS))) {
  id <- election_id(INPUTS$election_type[i],INPUTS$year[i])
  src <- read_prepared(INPUTS$prepared_file[i],INPUTS$election_type[i],INPUTS$year[i])
  g <- make_groups(src$main,src$master)
  stopifnot(nrow(g$GE100)==expected_n[[id]],
    nrow(g$ALL)==nrow(g$GE100)+nrow(g$LT100),
    sum(g$GE100$E)==sum(g$SMALL$E)+sum(g$MIDDLE$E)+sum(g$LARGE$E),
    sum(g$GE100$E)==sum(g$JHK_SMALL$E)+sum(g$JHK_LARGE$E))
  for(gr in names(g)) {
    d <- g[[gr]]
    if(nrow(d)) stopifnot(abs(sum(d$B)-sum(rowSums(d[,option_fields(src$options),drop=FALSE])))<1e-8)
    for(f in option_fields(src$options)) {
      cu <- cumulative_curve(d,f)
      if(nrow(cu)) {
        vote <- sum(d[[f]][is.finite(d$Turnout) & is.finite(d$B) & is.finite(d[[f]])])
        valid <- sum(d$B[is.finite(d$Turnout) & is.finite(d$B) & is.finite(d[[f]])])
        stopifnot(abs(tail(cu$Y_valid,1)-100*vote/valid)<1e-8,
                  if(vote>0) abs(tail(cu$Y_option,1)-100)<1e-8 else all(is.na(cu$Y_option)))
      }
    }
  }
  cat("PASS:",id,"(",nrow(src$main)," Main stations;",nrow(g$LT100)," QC-accepted under 100).\n")
}
cat("PASS: all groups and every national option curve endpoint reconcile to prepared workbooks.\n")
