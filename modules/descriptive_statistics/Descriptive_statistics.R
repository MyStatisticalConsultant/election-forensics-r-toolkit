#!/usr/bin/env Rscript
# =============================================================================
# ELECTION FORENSICS R TOOLKIT | DESCRIPTIVE STATISTICS v0.3.1
# SR: Deskriptivna statistika: Srbija, okruzi, opstine, 8 grupa BM.
# EN: Two summary tables per level, 16 correlation matrices per election.
# =============================================================================
# ================= EDITABLE USER CONFIGURATION / PODESAVANJA ==================
INPUTS <- data.frame(
  election_type=c('presidential','presidential','parliamentary'),
  year=c(2017L,2022L,2022L),
  prepared_file=c('../rzs_data_preparation/RZS_prepared/presidential_2017_RZS_prepared.xlsx',
                  '../rzs_data_preparation/RZS_prepared/presidential_2022_RZS_prepared.xlsx',
                  '../rzs_data_preparation/RZS_prepared/parliamentary_2022_RZS_prepared.xlsx'),
  stringsAsFactors=FALSE
)
OUTPUT_DIR <- 'descriptive_outputs'
DISPLAY_DECIMALS <- 2L
WRITE_CSV <- TRUE   # EN/SR: Excel-friendly UTF-8 BOM / UTF-8 sa BOM za Excel.
WRITE_WORD <- TRUE  # EN/SR: Requires officer + flextable / Potrebni paketi.
# EN: Correlations across AREA aggregates, not within-area station correlations.
# SR: Korelacije izmedju AGREGATA podrucja, ne korelacije BM unutar podrucja.
# =============================================================================
# ******** DO NOT CHANGE THE CODE BELOW THIS LINE *****************************
# ******** NE MENJAJTE KOD ISPOD OVE LINIJE ***********************************
# =============================================================================
stopifnot(is.data.frame(INPUTS),nrow(INPUTS)>0,
  all(c('election_type','year','prepared_file')%in%names(INPUTS)),
  !anyNA(INPUTS),all(INPUTS$election_type%in%c('presidential','parliamentary')),
  !anyDuplicated(paste(INPUTS$election_type,INPUTS$year)),
  is.character(OUTPUT_DIR),length(OUTPUT_DIR)==1L,nzchar(OUTPUT_DIR),
  DISPLAY_DECIMALS%in%0:10,is.logical(WRITE_CSV),length(WRITE_CSV)==1L,
  is.logical(WRITE_WORD),length(WRITE_WORD)==1L)
needed <- c('readxl','openxlsx','readr')
missing <- setdiff(needed,rownames(installed.packages()))
if(length(missing)) stop('Install required packages: ',paste(missing,collapse=', '))
source(file.path('R','descriptive_core.R'),encoding='UTF-8')
source(file.path('R','descriptive_extended.R'),encoding='UTF-8')
dir.create(OUTPUT_DIR,showWarnings=FALSE,recursive=TRUE)

# EN/SR: Styled Excel worksheets, preserving the Unicode Serbian names.
write_sheet <- function(wb,name,dat,decimals=3L) {
  dat <- as.data.frame(dat,check.names=FALSE,stringsAsFactors=FALSE)
  openxlsx::addWorksheet(wb,name,gridLines=FALSE)
  openxlsx::writeData(wb,name,dat,withFilter=nrow(dat)>0,keepNA=FALSE)
  openxlsx::freezePane(wb,name,firstRow=TRUE,firstCol=TRUE)
  if(ncol(dat)) {
    hd <- openxlsx::createStyle(fgFill='#17324D',fontColour='#FFFFFF',
              textDecoration='bold',wrapText=TRUE,valign='center')
    openxlsx::addStyle(wb,name,hd,rows=1,cols=seq_len(ncol(dat)),gridExpand=TRUE)
    openxlsx::setRowHeights(wb,name,rows=1,heights=34)
    openxlsx::setColWidths(wb,name,cols=seq_len(ncol(dat)),widths=17)
    wide <- grep('Area_name|Option_name|Variable|Size_group|Local_leader|Key|Value',names(dat))
    if(length(wide)) openxlsx::setColWidths(wb,name,cols=wide,widths=32)
    cols <- which(vapply(dat,is.numeric,logical(1)))
    if(length(cols) && nrow(dat)) {
      count_cols <- which(names(dat) %in% c('Polling_stations','Registered','Attendance',
         'Ballots_cast','Valid','Invalid','Winner_votes','Runnerup_votes',
         'Local_leader_votes','Local_second_votes','Votes','Option_number',
         'Year','N_pairs','Areas','Variables','N_tested','Significant_nominal','Significant_BH',
         'N_used','N_Small','N_Middle','N_Large','Joint_N','Stations','N_complete','Electorate_Outlier_count',
         'Turnout_Outlier_count','Winner_share_Outlier_count','Invalid_share_Outlier_count'))
      decimal_cols <- setdiff(cols,count_cols)
      if(length(count_cols))
        openxlsx::addStyle(wb,name,openxlsx::createStyle(numFmt='#,##0'),
           rows=2:(nrow(dat)+1L),cols=count_cols,gridExpand=TRUE,stack=TRUE)
      if(length(decimal_cols))
        openxlsx::addStyle(wb,name,openxlsx::createStyle(numFmt=paste0('0.',strrep('0',decimals))),
           rows=2:(nrow(dat)+1L),cols=decimal_cols,gridExpand=TRUE,stack=TRUE)
    }
  }
}

# EN: CSV with BOM to prevent Excel's locale-dependent mis-decoding.
# SR: CSV sa UTF-8 BOM, da Excel pravilno procita Š, Đ, Ž, Č, Ć.
write_csv_bom <- function(x,path) readr::write_excel_csv(x,path,na='')

# EN: One complete Word document PER ELECTION: compact principal tables,
# district and municipality appendices, with computed inferential tests.
# SR: Jedan Word izvestaj PO IZBORIMA, sa tabelama i testovima.
write_election_word <- function(out,stem) {
  if(!WRITE_WORD) return(invisible(NULL))
  if(!requireNamespace('officer',quietly=TRUE) || !requireNamespace('flextable',quietly=TRUE)) {
    message('Skipping Word: install.packages(c("officer","flextable"))');return(invisible(NULL))
  }
  fmt <- function(x) {
    x <- as.data.frame(x,stringsAsFactors=FALSE,check.names=FALSE)
    for(nm in names(x))if(is.numeric(x[[nm]])) {
      integer_field <- nm %in% c('PS','Registered','Cast','Valid','Invalid','Winner','Runnerup','N','Electorate','N_used')
      is_p <- nm %in% c('P_value','BH_q_value','Spearman p')
      x[[nm]] <- ifelse(!is.finite(x[[nm]]),'—',
        ifelse(is_p & is.finite(x[[nm]]) & x[[nm]]<0.001,'<0.001',
          formatC(x[[nm]],format='f',digits=if(is_p)3 else if(integer_field)0 else DISPLAY_DECIMALS,big.mark=',')))
    }
    x
  }
  add_table <- function(doc,d,label) {
    doc <- officer::body_add_par(doc,label,style='heading 2')
    if(!nrow(d)) return(officer::body_add_par(doc,'No observations / Nema opažanja.',style='Normal'))
    ft <- flextable::flextable(fmt(d))
    ft <- flextable::theme_booktabs(ft)
    ft <- flextable::fontsize(ft,size=7.4,part='all')
    ft <- flextable::autofit(ft)
    ft <- flextable::set_table_properties(ft,layout='autofit')
    flextable::body_add_flextable(doc,ft)
  }
  doc <- officer::read_docx()
  doc <- officer::body_add_par(doc,paste('Election Forensics |',stem),style='heading 1')
  doc <- officer::body_add_par(doc,'Tables and appendices | Tabele i prilozi',style='Normal')
  doc <- officer::body_add_par(doc,
   'Population: All = Main (100 or more registered voters) + QC-accepted less-than-100 stations. The Size and JHK rows are alternate partitions of Main; reporting groups overlap and must not be added together.',style='Normal')
  nat <- out$levels$National$summary
  ix <- match(size_report_order,nat$Size_group)
  nat <- nat[ix[!is.na(ix)],,drop=FALSE]
  denom <- nat$Registered[nat$Size_group=='All'][1]
  ncast <- nat$Ballots_cast[nat$Size_group=='All'][1]
  nv <- nat$Valid[nat$Size_group=='All'][1]
  ni <- nat$Invalid[nat$Size_group=='All'][1]
  t1 <- data.frame(Group=nat$Size_group,Registered=nat$Registered,
    'Registered %'=100*nat$Registered/denom,Cast=nat$Ballots_cast,
    'Cast %'=100*nat$Ballots_cast/ncast,Valid=nat$Valid,
    'Valid %'=100*nat$Valid/nv,Invalid=nat$Invalid,
    'Invalid %'=100*nat$Invalid/ni,check.names=FALSE)
  t2 <- data.frame(Group=nat$Size_group,Registered=nat$Registered,
                   PS=nat$Polling_stations,'Mean electorate'=nat$Mean_E,check.names=FALSE)
  doc <- add_table(doc,t1,'Table 1 | Electorate and ballots by size')
  doc <- add_table(doc,t2,'Table 2 | Polling stations and average electorate')
  doc <- add_table(doc,nat[,c('Size_group','Turnout_pct','Winner_per_valid_pct','Runnerup_per_valid_pct','Effective_number_options',
                              'Turnout_Median','Turnout_IQR','Turnout_P10','Turnout_P90','Turnout_Outlier_count'),drop=FALSE],
                   'Table 3 | Robust turnout and electoral option indicators')
  tests <- out$group_tests
  doc <- add_table(doc,tests[tests$Level=='National',c('Outcome','Test','N_used','Median_Small','Median_Middle','Median_Large','P_value','BH_q_value'),drop=FALSE],
    'Table 4 | Applied national group-comparison tests')
  doc <- officer::body_add_par(doc,
   'Kruskal-Wallis compares the three disjoint Size groups; Wilcoxon compares the two JHK groups. Tests are exploratory; significance does not establish fraud. BH q-values adjust across geographical units in each level/outcome/test family.',style='Normal')
  for(lvl in c('District','Municipality')) {
    doc <- officer::body_add_par(doc,paste('Appendix |',lvl),style='heading 1')
    s <- out$levels[[lvl]]$summary
    for(gr in size_report_order) {
      sub <- s[s$Size_group==gr,,drop=FALSE]
      if(!nrow(sub)) next
      sub <- sub[order(sub$Area_key),,drop=FALSE]
      a <- data.frame(Area=sub$Area_name,Registered=sub$Registered,Valid=sub$Valid,
                      Winner=sub$Winner_votes,Runnerup=sub$Runnerup_votes,
                      'Valid / registered %'=sub$Valid_per_registered_pct,
                      'Winner / valid %'=sub$Winner_per_valid_pct,
                      'Runnerup / valid %'=sub$Runnerup_per_valid_pct,check.names=FALSE)
      doc <- add_table(doc,a,paste('Appendix A |',lvl,'|',gr))
      b <- data.frame(Area=sub$Area_name,PS=sub$Polling_stations,
          'Turnout %'=sub$Turnout_pct,'Turnout median'=sub$Turnout_Median,
          'Turnout IQR'=sub$Turnout_IQR,'Winner share median'=sub$Winner_share_Median,
          'Joint Spearman'=sub$Joint_Spearman_rho,
          'Spearman p'=sub$Joint_Spearman_p,check.names=FALSE)
      doc <- add_table(doc,b,paste('Appendix B |',lvl,'|',gr,'| dispersion and association'))
    }
    ts <- tests[tests$Level==lvl,,drop=FALSE]
    ts <- ts[order(ts$Area_key,ts$Outcome,ts$Test),,drop=FALSE]
    doc <- add_table(doc,ts[,c('Area_key','Outcome','Test','N_used','P_value','BH_q_value','Significant_BH'),drop=FALSE],
                     paste('Appendix C |',lvl,'| applied comparison tests'))
  }
  path <- file.path(OUTPUT_DIR,paste0(stem,'_journal_tables.docx'))
  print(doc,target=path)
  invisible(path)
}

# EN/SR: Persist all eight groups, full option tables, and 16 correlation matrices.
write_extended <- function(out,stem) {
  folder <- file.path(OUTPUT_DIR,stem)
  dir.create(folder,showWarnings=FALSE,recursive=TRUE)
  wb <- openxlsx::createWorkbook(creator='Election Forensics R Toolkit')
  meta <- data.frame(
    Item=c('Version','Population','Eligible Main','QC-accepted under 100',
           'Master records','QC-excluded from All','100-or-more input','Correlation method',
           'Correlation sample unit','Significance','Multiplicity','Source integrity'),
    Value=c('0.3.1','All = Main + QC-accepted under-100 only',
            out$coverage$Eligible_main,out$coverage$QC_accepted_under100,
            out$coverage$Source_stations,out$coverage$Excluded_from_All,
            'Main worksheet (E >= 100, QC eligible)',
            'Pearson','District or municipality aggregate',
            'Two-sided p < 0.05, * on r; exploratory only',
            'Benjamini-Hochberg q in CSV details','Prepared source XLSX unchanged'))
  write_sheet(wb,'README',meta)
  for(lvl in c('National','District','Municipality')) {
    z <- out$levels[[lvl]]
    tt <- make_summary_tables(order_size_rows(z$summary))
    prefix <- switch(lvl,National='Nat',District='Dist',Municipality='Mun')
    write_sheet(wb,paste0(prefix,'_counts'),tt$counts,DISPLAY_DECIMALS)
    write_sheet(wb,paste0(prefix,'_rates'),tt$performance,DISPLAY_DECIMALS)
    write_sheet(wb,paste0(prefix,'_options'),order_size_rows(z$options),DISPLAY_DECIMALS)
    if(WRITE_CSV) {
      write_csv_bom(tt$counts,file.path(folder,paste0(tolower(lvl),'_table1_counts.csv')))
      write_csv_bom(tt$performance,file.path(folder,paste0(tolower(lvl),'_table2_rates.csv')))
      write_csv_bom(z$options,file.path(folder,paste0(tolower(lvl),'_options.csv')))
    }

  }
  write_sheet(wb,'Group_tests',out$group_tests,DISPLAY_DECIMALS)
  for(lvl in c('National','District','Municipality'))
    write_sheet(wb,paste0(substr(lvl,1,3),'_joint_bins'),out$joint_bins[[lvl]],DISPLAY_DECIMALS)
  for(lvl in c('National','District','Municipality')) write_sheet(wb,paste0(substr(lvl,1,3),'_robust'),out$levels[[lvl]]$summary,DISPLAY_DECIMALS)
  write_sheet(wb,'Options_dictionary',out$options)
  write_sheet(wb,'Correlation_overview',out$correlations$overview)
  for(key in names(out$correlations$matrices)) {
    cr <- out$correlations$matrices[[key]]
    sheet <- paste0('Corr_',key)
    display <- as.data.frame(cr$display,check.names=FALSE,stringsAsFactors=FALSE)
    display <- data.frame(Variable=rownames(cr$display),display,check.names=FALSE,stringsAsFactors=FALSE)
    write_sheet(wb,sheet,display)
  }
  if(WRITE_CSV) {
    write_csv_bom(out$group_tests,file.path(folder,'group_significance_tests.csv'))
    for(lvl in c('National','District','Municipality'))
      write_csv_bom(out$joint_bins[[lvl]],file.path(folder,paste0(tolower(lvl),'_joint_turnout_winner_bins.csv')))
    for(lvl in c('National','District','Municipality'))
      write_csv_bom(out$levels[[lvl]]$summary,file.path(folder,paste0(tolower(lvl),'_robust_distributions.csv')))
    write_csv_bom(out$correlations$details,file.path(folder,'correlation_pairs_p_q_n.csv'))
    write_csv_bom(out$correlations$overview,file.path(folder,'correlation_overview.csv'))
  }
  output_xlsx <- file.path(OUTPUT_DIR,paste0(stem,'.xlsx'))
  openxlsx::saveWorkbook(wb,output_xlsx,overwrite=TRUE)
  output_xlsx
}

# EN/SR: One run per election, never modifying either Master or Main.
for(i in seq_len(nrow(INPUTS))) {
  et <- INPUTS$election_type[i]; yr <- INPUTS$year[i]
  p <- INPUTS$prepared_file[i]
  if(!file.exists(p)) stop('Prepared XLSX not found: ',p)
  message('Reading ',et,' ',yr,': ',p)
  master <- as.data.frame(readxl::read_excel(p,sheet='Master',.name_repair='minimal'),
                          stringsAsFactors=FALSE)
  main <- as.data.frame(readxl::read_excel(p,sheet='Main',.name_repair='minimal'),
                        stringsAsFactors=FALSE)
  options <- as.data.frame(readxl::read_excel(p,sheet='Options'),stringsAsFactors=FALSE)
  result <- build_extended_descriptive(master,main,options,et,yr)
  stem <- paste0(et,'_',yr,'_descriptive')
  outfile <- write_extended(result,stem)
  wordfile <- write_election_word(result,stem)
  message('Completed ',et,' ',yr,': eligible=',result$coverage$Eligible_main,
          '; under100 valid=',result$coverage$QC_accepted_under100,
          '; correlation matrices=',length(result$correlations$matrices),
          '; output=',outfile)
}
cat('Descriptive analysis completed. Prepared source workbooks were not modified.\n')
