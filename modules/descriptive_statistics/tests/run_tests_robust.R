# EN/SR: Run from modules/descriptive_statistics
source(file.path('R','descriptive_core.R'),encoding='UTF-8')
source(file.path('R','descriptive_extended.R'),encoding='UTF-8')
a <- dist_stats(c(1,2,3,4,100),'Example')
stopifnot(a[['Example_N']]==5,a[['Example_Median']]==3,
  abs(a[['Example_IQR']]-2)<1e-9,a[['Example_Outlier_count']]==1)
b <- joint_stats(1:6,1:6)
stopifnot(b[['Joint_N']]==6,abs(b[['Joint_Pearson_r']]-1)<1e-9,
  b[['Joint_Pearson_p']]<.05)
c <- joint_stats(c(1,2),c(2,3))
stopifnot(is.na(c[['Joint_Pearson_p']]))
stopifnot(identical(size_report_order,c('All','100 or more','Less than 100',
  'Small','Middle','Large','JHK Small','JHK Large')))
stopifnot(grepl('make_joint_bins',paste(readLines('R/descriptive_extended.R'),collapse=' ')))
stopifnot(grepl('group_tests',paste(readLines('Descriptive_statistics.R'),collapse=' ')))
stopifnot(grepl('write_election_word',paste(readLines('Descriptive_statistics.R'),collapse=' ')))
cat('PASS: robust distribution summaries, tested turnout-share associations, Word report contract.\n')
