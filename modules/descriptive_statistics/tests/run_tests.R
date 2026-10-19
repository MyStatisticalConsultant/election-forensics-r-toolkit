# EN/SR: Synthetic unit tests for the descriptive engine; no official XLSX required.
parse(file='Descriptive_statistics.R',encoding='UTF-8')
parse(file='R/descriptive_core.R',encoding='UTF-8')
source('R/descriptive_core.R',encoding='UTF-8')
dat <- data.frame(Election_type=rep('presidential',8),Year=rep(2022L,8),
  Station_key=paste0('presidential|2022|',seq_len(8)),
  District_code=c(rep('01',4),rep('02',4)),District=c(rep('A',4),rep('B',4)),
  Municipality_code=c(rep('001',2),rep('002',2),rep('001',2),rep('003',2)),
  Municipality=c(rep('A1',2),rep('A2',2),rep('B1',2),rep('B3',2)),
  PS_number=as.character(seq_len(8)),
  E=c(100,100,200,300,100,200,300,400),
  A=c(50,55,110,165,60,130,210,260),
  C=c(50,55,110,165,60,130,210,260),
  I=c(5,5,10,15,6,13,21,26),
  B=c(45,50,100,150,54,117,189,234),
  Option_01_votes=c(30,30,60,80,30,60,100,120),
  Option_02_votes=c(15,20,40,70,24,57,89,114),
  Size=c('Small','Small','Middle','Middle','Small','Middle','Large','Large'),
  Size_JHK=c('Small','Small','Large','Large','Small','Large','Large','Large'),
  Eligible_primary=rep(TRUE,8),stringsAsFactors=FALSE)
dat$Winner_votes <- dat$Option_01_votes
dat$Second_votes <- dat$Option_02_votes
opts <- data.frame(Election_type=rep('presidential',2),Year=rep(2022L,2),
  Option_type=rep('Candidate',2),Option_number=1:2,
  Option_name_SR_Lat=c('First','Second'),Votes_field=c('Option_01_votes','Option_02_votes'))
res <- build_descriptive(dat,opts,'presidential',2022)
n <- res$levels$National$summary
stopifnot(nrow(n)==7L,identical(sort(unique(n$Classification)),c('Size','Size_JHK')))
stopifnot(identical(sort(unique(n[n$Classification=='Size','Size_group'])),c('All','Large','Middle','Small')))
stopifnot(identical(sort(unique(n[n$Classification=='Size_JHK','Size_group'])),c('All','Large','Small')))
all <- n[n$Classification=='Size' & n$Size_group=='All',,drop=FALSE]
stopifnot(all$Polling_stations==8,all$Registered==1700,all$Valid==939,
          all$Ballots_cast==1040,all$Invalid==101,
          abs(all$Turnout_pct-100*1040/1700)<1e-10,
          abs(all$Winner_per_valid_pct-100*510/939)<1e-10)
stopifnot(nrow(res$levels$District$coverage)==2L,
          nrow(res$levels$Municipality$coverage)==4L)
# EN/SR: The same municipality code in different districts is NOT merged.
stopifnot(any(res$levels$Municipality$coverage$Area_key=='01|001'),
          any(res$levels$Municipality$coverage$Area_key=='02|001'))
# EN/SR: Weighted aggregate differs from mean of station ratios.
stopifnot(abs(all$Turnout_pct-all$Mean_turnout_pct)>0.01)
# EN/SR: Every group and area has a complete option-vote accounting identity.
for(level in c('National','District','Municipality')) {
  stopifnot(all(res$levels[[level]]$coverage$All_stations==res$levels[[level]]$coverage$Size_total),
            all(res$levels[[level]]$coverage$All_stations==res$levels[[level]]$coverage$Size_JHK_total))
}
err <- try(build_descriptive(transform(dat,B=B+1),opts,'presidential',2022),silent=TRUE)
stopifnot(inherits(err,'try-error'))
cat('PASS: descriptive-engine syntax, grouping, disjoint partitions, weighted rates, options and failure checks.\n')
