# Offline synthetic numerical tests, no input workbook needed.
source(file.path('R','shpilkin_core.R'),encoding='UTF-8')
sp_check<-function(z,msg='Assertion failed')if(!isTRUE(z))stop(msg,call.=FALSE)
d<-data.frame(Station_key=paste0('s',seq_len(120)),District_code=rep('00',120),Municipality_code=rep('M1',120),
 E=rep(1000,120),B=rep(600,120),C=rep(610,120),Winner_votes=rep(350,120))
d$E[1]<-50;d$B[1]<-30;d$C[1]<-31;d$Winner_votes[1]<-20
p<-sp_prepared(d,'testing','Winner_votes',list(),'C/E')
sp_check(p$turnout_pct[2]==61,'C/E calculation')
sp_check(abs(p$leader_pct[2]-100*350/600)<1e-10,'W/B calculation')
sp_check(!p$hist_ok[1]&&sum(p$hist_ok)==119,'Under100 excluded')
pb<-sp_prepared(d,'testing','Winner_votes',list(),'B/E');sp_check(pb$turnout_pct[2]==60,'B/E definition')
# a centered histogram 50% puts values 49.91 and 50.09 into 50 +/- .125
h<-sp_hist(c(49.91,50.09,51),c(1,2,3),.25)
sp_check(h$weighted_count[sp_bin(50,.25)+1]==3,'Centred bin 50')
sp_check(sum(h$weighted_count)==6,'Histogram weights')
sp_check(abs(sum(h$density)*.25-1)<1e-10,'Histogram area')
sp_check(all(sp_integer_test(c(59.95,62.96),c(11.11,10),.05,'either')==c(TRUE,TRUE)),'Integer OR test')
sp_check(sp_integer_test(59.5,21.1,.05,'half_integer_turnout'),'Half integer control')
sp_check(!sp_integer_test(59.5,21.1,.05,'turnout'),'Half integer not ordinary integer')
# MC null is exactly reproducible and is based on binomial sampling.
d2<-d;d2$E<-rep(1000,120);d2$B<-rep(500,120);d2$C<-rep(600,120)
d2$Winner_votes<-rep(220,120);d2$Winner_votes[1:60]<-200
d2$C[1:60]<-550;d2$B[1:60]<-510
pr<-sp_prepared(d2,'testing','Winner_votes',list(),'C/E')
a<-sp_mc(pr,reps=21L,seed=77L,width=.1)
b<-sp_mc(pr,reps=21L,seed=77L,width=.1)
sp_check(identical(a$draws,b$draws),'MC seed reproducibility')
sp_check(all(c('either','turnout','leader','half_integer_turnout','half_integer_leader')%in%a$summary$metric),'MC metrics')
sp_check(abs(sum(a$turnout_band$observed_registered)-sum(pr$E[pr$test_ok]))<1,'Weighted histogram registered total')
ex<-sp_excess(pr,width=1,core=c(50,60),min_core_stations=10)
sp_check(nrow(ex$bins)>0&&is.finite(ex$summary$ratio_winner_to_others),'Excess core and ratio')
sp_check(ex$summary$ratio_winner_to_others>0,'Nonwinner baseline')
cat('PASS: C/E and B/E; winner W/B; station eligibility; centred histograms; E-weighted 0.1pp bins; integer/half-integer controls; binomial MC reproducibility; conditional excess baseline.\n')
