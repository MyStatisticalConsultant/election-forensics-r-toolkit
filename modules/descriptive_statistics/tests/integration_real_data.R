# EN: Integration checks against actual prepared Excel files when available.
# SR: Integraciona provera sa stvarnim pripremljenim Excel fajlovima (ako postoje).
source('R/descriptive_core.R',encoding='UTF-8')
if(!requireNamespace('readxl',quietly=TRUE)) stop('Install readxl first')
inputs <- data.frame(type=c('presidential','presidential','parliamentary'),
  year=c(2017L,2022L,2022L),
  path=c('../rzs_data_preparation/RZS_prepared/presidential_2017_RZS_prepared.xlsx',
         '../rzs_data_preparation/RZS_prepared/presidential_2022_RZS_prepared.xlsx',
         '../rzs_data_preparation/RZS_prepared/parliamentary_2022_RZS_prepared.xlsx'))
if(!all(file.exists(inputs$path))) {
  cat('SKIP: copy local prepared XLSX files into ../rzs_data_preparation/RZS_prepared first.\n')
} else {
  for(i in seq_len(nrow(inputs))) {
    dat <- as.data.frame(readxl::read_excel(inputs$path[i],sheet='Main',.name_repair='minimal'))
    opt <- as.data.frame(readxl::read_excel(inputs$path[i],sheet='Options'))
    result <- build_descriptive(dat,opt,inputs$type[i],inputs$year[i])
    s <- result$levels$National$summary
    all <- s[s$Classification=='Size' & s$Size_group=='All',]
    stopifnot(all$Polling_stations==nrow(dat),
              all$Registered==sum(dat$E),all$Valid==sum(dat$B))
    cat('PASS: ',inputs$type[i], ' ',inputs$year[i],
        ' (',nrow(dat),' eligible stations).\n',sep='')
  }
}
