source(file.path('R','shpilkin_core.R'),encoding='UTF-8')
inputs<-data.frame(election=c('presidential_2017','presidential_2022','parliamentary_2022'),prepared_file=file.path('..','rzs_data_preparation','RZS_prepared',c('presidential_2017_RZS_prepared.xlsx','presidential_2022_RZS_prepared.xlsx','parliamentary_2022_RZS_prepared.xlsx')))
fallback<-list(presidential_2017='Option_06_votes',presidential_2022='Option_06_votes',parliamentary_2022='Option_01_votes')
for(i in seq_len(nrow(inputs))){
 path<-inputs$prepared_file[i];if(!file.exists(path))stop('Integration data missing: ',path)
 x<-sp_read_master(path);p<-sp_prepared(x,inputs$election[i],'Winner_votes',fallback,'C/E')
 if(!any(p$hist_ok)||!any(p$test_ok))stop('No valid input after QC for ',inputs$election[i])
 if(!all(p$W[p$base_ok] <= p$B[p$base_ok]))stop('W>B contradiction')
 cat(inputs$election[i],': Master=',nrow(x),' hist_eligible=',sum(p$hist_ok),' integer_eligible=',sum(p$test_ok),' E<100=',sum(p$base_ok & p$E<100),'\n',sep='')
}
cat('PASS: real-data Master fields, winner mapping and station-level QC (not independent official-total reconciliation).\n')
