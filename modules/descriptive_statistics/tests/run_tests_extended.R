# EN/SR: Synthetic tests for v0.2 without RZS source workbooks.
parse(file='Descriptive_statistics.R',encoding='UTF-8')
parse(file='R/descriptive_core.R',encoding='UTF-8')
parse(file='R/descriptive_extended.R',encoding='UTF-8')
source('R/descriptive_core.R',encoding='UTF-8')
source('R/descriptive_extended.R',encoding='UTF-8')
main <- data.frame(Election_type=rep('presidential',8),Year=rep(2022L,8),
  Station_key=paste0('presidential|2022|',seq_len(8)),
  District_code=c(rep('01',4),rep('02',4)),District=c(rep('Šumadija',4),rep('Raška',4)),
  Municipality_code=c(rep('001',2),rep('002',2),rep('001',2),rep('003',2)),
  Municipality=c(rep('Čačak',2),rep('Smederevo',2),rep('Žiča',2),rep('Ćuprija',2)),
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
main$Winner_votes <- main$Option_01_votes
main$Second_votes <- main$Option_02_votes
under <- main[1,,drop=FALSE]
under$Station_key <- 'presidential|2022|under'
under$E <- 90; under$A <- 50; under$C <- 50; under$I <- 5; under$B <- 45
under$Eligible_primary <- FALSE
under$Size <- NA_character_; under$Size_JHK <- NA_character_
master <- rbind(main,under)
master$Under_100 <- master$E<100
master$Invalid_numeric <- FALSE
master$Admin_no_ballots <- FALSE
master$Admin_invalid <- FALSE
opts <- data.frame(Election_type='presidential',Year=2022L,
  Option_type='candidate',Option_number=1:2,
  Option_name_SR_Lat=c('Đorđe','Živko'),
  Votes_field=c('Option_01_votes','Option_02_votes'),stringsAsFactors=FALSE)
a <- build_extended_descriptive(master,main,opts,'presidential',2022)
stopifnot(a$coverage$Eligible_main==8,
          a$coverage$QC_accepted_under100==1,
          length(a$correlations$matrices)==16,
          nrow(a$levels$National$summary)==8,
          a$levels$National$summary$Polling_stations[
            a$levels$National$summary$Size_group=='All']==9,
          a$levels$National$summary$Polling_stations[
            a$levels$National$summary$Size_group=='Less than 100']==1,
          a$levels$National$summary$Polling_stations[
            a$levels$National$summary$Size_group=='100 or more']==nrow(main))
stopifnot(a$levels$National$summary$Registered[
  a$levels$National$summary$Size_group=='All']==1790,
  a$levels$National$summary$Registered[
  a$levels$National$summary$Size_group=='100 or more']==1700)
stopifnot(a$levels$National$summary$Registered[
  a$levels$National$summary$Size_group=='Less than 100']==90)
stopifnot(all(unique(a$levels$National$summary$Size_group)%in%size_labels))
stopifnot(nrow(a$correlations$overview)==16,
  all(a$correlations$overview$Level %in% c('District','Municipality')))
stopifnot(identical(as.character(opts$Option_name_SR_Lat),c('Đorđe','Živko')))
# EN/SR: Reject a bad under-100 record and keep it out of the All sample.
master$Admin_invalid[nrow(master)] <- TRUE
b <- build_extended_descriptive(master,main,opts,'presidential',2022)
stopifnot(b$coverage$QC_accepted_under100==0,
          b$levels$National$summary$Polling_stations[
            b$levels$National$summary$Size_group=='All']==8,
          b$levels$National$summary$Polling_stations[
            b$levels$National$summary$Size_group=='100 or more']==8,
          length(b$correlations$matrices)==16)
# EN/SR: An empty size group must still retain its matrix schema and metadata.
empty_group <- b$correlations$overview$Size_group == 'Less than 100'
stopifnot(sum(empty_group)==2L,
          all(b$correlations$overview$Areas[empty_group]==0L),
          all(b$correlations$overview$N_tested[empty_group]==0L),
          all(vapply(b$correlations$matrices[c('D_02','M_02')],
                     function(z) nrow(z$display)>1L &&
                       all(is.na(z$r)) && all(is.na(z$p)),logical(1))))
# EN/SR: Also exercise a truly zero-variable/zero-pair input directly.
zero <- compute_correlation(data.frame(),'District','Empty')
stopifnot(nrow(zero$details)==0L,
          length(zero$display)==0L,
          nrow(zero$details)==nrow(zero$display)*(nrow(zero$display)-1)/2)
# EN/SR: One variable has no distinct pair to report, not an error.
one <- compute_correlation(data.frame(Area_key='01',A=1),'District','One variable')
stopifnot(nrow(one$details)==0L,nrow(one$display)==1L)
cat('PASS: extended grouping, 16 correlation matrices, QC exclusions, Serbian text and syntax.\n')
