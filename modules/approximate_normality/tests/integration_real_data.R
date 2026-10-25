# Requires the three prepared RZS workbooks locally; never changes them.
Sys.setenv(EF_APPROX_NORMALITY_TEST_MODE='1')
source(file.path('R','approximate_normality_functions.R'),encoding='UTF-8')
files <- file.path('..','rzs_data_preparation','RZS_prepared',c(
  'presidential_2017_RZS_prepared.xlsx','presidential_2022_RZS_prepared.xlsx',
  'parliamentary_2022_RZS_prepared.xlsx'))
names(files) <- c('presidential_2017','presidential_2022','parliamentary_2022')
if (!all(file.exists(files))) stop('Missing local RZS prepared XLSX; run this test on your Toolkit PC')
for (i in seq_along(files)) {
  d <- an_read_master(files[i]); id <- names(files)[i]
  fb <- list(presidential_2017='Option_06_votes',presidential_2022='Option_06_votes',
             parliamentary_2022='Option_01_votes')
  p <- an_prepare(d,id,'Winner_votes',fb)
  stopifnot(nrow(p)>5000L,sum(p$primary_ok)>5000L,sum(p$sensitivity_under100_ok)>0,
            all(p$W[p$primary_ok]>0),all(p$W[p$primary_ok]<p$E[p$primary_ok]))
  ref <- an_standardize(p,30L)
  stopifnot(isTRUE(ref$ok),is.finite(ref$params$mean_nu),is.finite(ref$params$sd_nu))
  cat(id,': Master=',nrow(p),' primary>=100=',sum(p$primary_ok),
      ' under100=',sum(p$sensitivity_under100_ok),' reference SD=',ref$params$sd_nu,'\n',sep='')
}
cat('PASS: real-data Master contracts, QC, <100 separation and original log-vote formula.\n')
