# No local election workbooks required. Run from modules/approximate_normality.
Sys.setenv(EF_APPROX_NORMALITY_TEST_MODE='1')
source(file.path('R','approximate_normality_functions.R'),encoding='UTF-8')

make_sample <- function(n=90) {
  set.seed(1319)
  E <- rep(500,n); E[1:10] <- 70
  W <- as.integer(round(E*stats::plogis(seq(-2,2,length.out=n))))
  B <- pmax(W,as.integer(round(E*.75)))
  C <- pmin(E,B+2)
  data.frame(Station_key=sprintf('ps%03d',seq_len(n)),District_code='00',
             Municipality_code='71021',District='District',Municipality='Municipality',
             E=E,B=B,C=C,Winner_votes=W,Size=ifelse(seq_len(n)%%2==0,'Small','Large'))
}
d <- make_sample(90)
p <- an_prepare(d,'fixture')
stopifnot(sum(p$primary_ok)==80L,sum(p$sensitivity_under100_ok)==10L)
stopifnot(all.equal(p$nu[11],log(d$Winner_votes[11]/(d$E[11]-d$Winner_votes[11])),tolerance=1e-12)==TRUE)
stopifnot(p$nu[11]!=log((d$B[11]-d$Winner_votes[11])/d$Winner_votes[11]))
p$W[12] <- 0
p2 <- an_prepare(transform(d,Winner_votes=replace(Winner_votes,12,0)),'fixture')
stopifnot(!p2$primary_ok[12],grepl('UNDEFINED_LOG_W_ZERO',p2$qc_reason[12],fixed=TRUE))
p3 <- an_prepare(transform(d,Winner_votes=replace(Winner_votes,13,500),B=replace(B,13,500),C=replace(C,13,500)),'fixture')
stopifnot(!p3$primary_ok[13],grepl('UNDEFINED_LOG_W_GE_E',p3$qc_reason[13],fixed=TRUE))
ref <- an_standardize(p,30L)
stopifnot(isTRUE(ref$ok),abs(mean(ref$rows$z[ref$rows$primary_ok]))<1e-12,
          abs(stats::sd(ref$rows$z[ref$rows$primary_ok])-1)<1e-12)
stopifnot(all(is.finite(ref$rows$z[ref$rows$sensitivity_under100_ok])))
# Primary and subgroups must use a COMMON baseline, not per-group means and SDs.
stopifnot(abs(mean(ref$rows$z[ref$rows$primary_ok & ref$rows$Size=='Small']) -
              mean(ref$rows$z[ref$rows$primary_ok & ref$rows$Size=='Large'])) > .01)
h <- an_hist(c(-.03,0,.05,.11),.2)
stopifnot(sum(h$count)==4L, h$count[h$bin_index==0]==3L,h$count[h$bin_index==1]==1L,
          sum(h$probability)==1,all(h$normal_probability>0))
stopifnot(all.equal(h$normal_probability,stats::pnorm(h$right)-stats::pnorm(h$left))==TRUE)
m <- an_moments(stats::qnorm(seq(.001,.999,length.out=999)))
stopifnot(abs(m$skewness)<.05,abs(m$kurtosis-3)<.2,m$jarque_bera>=0)
mm <- an_hist_groups(ref$rows,list(All=ref$rows$primary_ok,
  Small=ref$rows$primary_ok & ref$rows$Size=='Small',
  Large=ref$rows$primary_ok & ref$rows$Size=='Large'),.2)
stopifnot(setequal(unique(mm$group),c('All','Small','Large')),
  all(tapply(mm$probability,mm$group,sum)>0.999999),
  all(tapply(mm$probability,mm$group,sum)<1.000001))
stopifnot(an_label('presidential_2017','EN')=='presidential 2017',
          an_label('parliamentary_2022','SR')=='Parlamentarni 2022')
cat('PASS: original log(W/(E-W)), E<100 separation, exclusions, common z-reference, fixed bins, expected normal-bin masses, skewness/kurtosis/JB, named groups.\n')
