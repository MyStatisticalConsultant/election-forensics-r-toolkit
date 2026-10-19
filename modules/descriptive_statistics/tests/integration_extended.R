# EN/SR: Run from modules/descriptive_statistics after preparing the three XLSX files.
source('R/descriptive_core.R',encoding='UTF-8')
source('R/descriptive_extended.R',encoding='UTF-8')
rows <- data.frame(type=c('presidential','presidential','parliamentary'),
                   year=c(2017L,2022L,2022L),stringsAsFactors=FALSE)
for(i in seq_len(nrow(rows))) {
  p <- file.path('..','rzs_data_preparation','RZS_prepared',
     paste0(rows$type[i],'_',rows$year[i],'_RZS_prepared.xlsx'))
  stopifnot(file.exists(p))
  master <- as.data.frame(readxl::read_excel(p,sheet='Master',.name_repair='minimal'))
  main <- as.data.frame(readxl::read_excel(p,sheet='Main',.name_repair='minimal'))
  options <- as.data.frame(readxl::read_excel(p,sheet='Options'))
  res <- build_extended_descriptive(master,main,options,rows$type[i],rows$year[i])
  stopifnot(nrow(res$correlations$overview)==16,
    res$coverage$Eligible_main==nrow(main),
    res$levels$National$summary$Polling_stations[
      res$levels$National$summary$Size_group=='100 or more']==nrow(main),
    res$levels$National$summary$Registered[
      res$levels$National$summary$Size_group=='100 or more']==sum(main$E),
    res$coverage$Source_stations==nrow(master),
    sum(res$levels$District$summary$Registered[
      res$levels$District$summary$Size_group=='All'])==
      res$levels$National$summary$Registered[
        res$levels$National$summary$Size_group=='All'],
    sum(res$levels$Municipality$summary$Ballots_cast[
      res$levels$Municipality$summary$Size_group=='All'])==
      res$levels$National$summary$Ballots_cast[
        res$levels$National$summary$Size_group=='All'])
  # EN/SR: Check newly computed tests, robust summaries and joint bins.
  stopifnot(nrow(res$group_tests)>0,
    all(c('Turnout_Median','Turnout_IQR','Turnout_P10','Turnout_P90',
      'Turnout_Outlier_count','Joint_Spearman_rho','Joint_Spearman_p') %in%
      names(res$levels$District$summary)),
    nrow(res$joint_bins$National)>0,
    length(res$joint_bins)==3,
    all(res$group_tests$P_value[is.finite(res$group_tests$P_value)]>=0),
    all(res$group_tests$P_value[is.finite(res$group_tests$P_value)]<=1))
  message('PASS: extended ',rows$type[i],' ',rows$year[i],
    ' | under100=',res$coverage$QC_accepted_under100,
    ' | matrices=',nrow(res$correlations$overview))
}
