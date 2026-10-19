# EN: Run only AFTER source('Descriptive_statistics.R').
# SR: Pokrenuti samo POSLE generisanja deskriptivnih izlaza.
stopifnot(requireNamespace('readxl',quietly=TRUE))
refs <- data.frame(type=c('presidential','presidential','parliamentary'),
                   year=c(2017L,2022L,2022L),stringsAsFactors=FALSE)
for(i in seq_len(nrow(refs))) {
  stem <- paste0(refs$type[i],'_',refs$year[i],'_descriptive')
  xlsx <- file.path('descriptive_outputs',paste0(stem,'.xlsx'))
  stopifnot(file.exists(xlsx))
  sheets <- readxl::excel_sheets(xlsx)
  expect <- c('Nat_counts','Nat_rates','Dist_counts','Dist_rates',
    'Mun_counts','Mun_rates','Nat_options','Dist_options','Mun_options',
    sprintf('Corr_D_%02d',1:8),sprintf('Corr_M_%02d',1:8))
  expect <- c(expect,'Group_tests','Nat_robust','Dis_robust','Mun_robust',
              'Nat_joint_bins','Dis_joint_bins','Mun_joint_bins')
  stopifnot(all(expect %in% sheets))
  tests <- as.data.frame(readxl::read_excel(xlsx,sheet='Group_tests'))
  stopifnot(nrow(tests)>0,
     all(c('P_value','BH_q_value','Outcome','Test')%in%names(tests)),
     all(tests$P_value[is.finite(tests$P_value)]>=0),
     all(tests$P_value[is.finite(tests$P_value)]<=1))
  robust <- as.data.frame(readxl::read_excel(xlsx,sheet='Nat_robust'))
  stopifnot(all(c('Turnout_Median','Turnout_IQR','Turnout_Outlier_count',
                       'Joint_Spearman_rho','Joint_Spearman_p')%in%names(robust)))
  joint <- as.data.frame(readxl::read_excel(xlsx,sheet='Nat_joint_bins'))
  stopifnot(nrow(joint)>0,sum(joint$Stations)>0)
  if(exists('WRITE_WORD',envir=.GlobalEnv,inherits=FALSE) &&
     isTRUE(get('WRITE_WORD',envir=.GlobalEnv))) {
    word <- file.path('descriptive_outputs',paste0(stem,'_journal_tables.docx'))
    stopifnot(file.exists(word))
  }
  tab <- as.data.frame(readxl::read_excel(xlsx,sheet='Nat_counts'))
  stopifnot(all(c('All','100 or more','Less than 100')%in%tab$Size_group),
            tab$Polling_stations[tab$Size_group=='100 or more'] ==
              as.integer(as.data.frame(readxl::read_excel(xlsx,sheet='README'))$Value[3]),
            all(tab$Size_group%in%c('All','100 or more','Less than 100','Small','Middle',
                                     'Large','JHK Small','JHK Large')))
  # EN/SR: Independent published reference totals for Main (=100 or more).
  ref_path <- file.path('tests','reference_100_or_more_totals.csv')
  if(file.exists(ref_path)) {
    reference <- utils::read.csv(ref_path,stringsAsFactors=FALSE)
    r <- reference[reference$Election==paste0(refs$type[i],'_',refs$year[i]),,drop=FALSE]
    if(nrow(r)==1L) {
      main_row <- tab[tab$Size_group=='100 or more',,drop=FALSE]
      all_row <- tab[tab$Size_group=='All',,drop=FALSE]
      stopifnot(nrow(main_row)==1L,nrow(all_row)==1L,
        main_row$Polling_stations==r$Main_stations,
        main_row$Registered==r$Main_registered,
        main_row$Ballots_cast==r$Main_cast,
        main_row$Valid==r$Main_valid,
        main_row$Invalid==r$Main_invalid,
        all_row$Polling_stations==r$All_stations,
        all_row$Registered==r$All_registered)
    }
  }
  corr <- as.data.frame(readxl::read_excel(xlsx,sheet='Correlation_overview'))
  stopifnot(nrow(corr)==16L)
  folder <- file.path('descriptive_outputs',stem)
  if(file.exists(file.path(folder,'district_options.csv'))) {
    con <- file(file.path(folder,'district_options.csv'),'rb')
    bom <- readBin(con,what='raw',n=3)
    close(con)
    stopifnot(identical(bom,as.raw(c(0xEF,0xBB,0xBF))))
  }
  if(refs$type[i]=='presidential' && refs$year[i]==2017L) {
    opt <- as.data.frame(readxl::read_excel(xlsx,sheet='Nat_options'))
    # EN/SR: Expect authentic Serbian diacritics, not ANSI mojibake.
    stopifnot(any(grepl('[ŠĐŽČĆšđžčć]', opt$Option_name_SR_Lat)))
  }
  message('PASS: exported tables, correlation matrices, and UTF-8 BOM: ',stem)
}
