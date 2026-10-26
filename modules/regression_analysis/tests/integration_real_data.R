Sys.setenv(EF_REGRESSION_TEST_MODE='1')
source('Regression_analysis.R',encoding='UTF-8')
ra_require('readxl')
for(i in seq_len(nrow(INPUTS))){
 en<-INPUTS$election[i];p<-INPUTS$prepared_file[i]
 if(!file.exists(p))stop('Real-data test requires: ',p)
 d<-ra_read(p)
 chosen<-ra_choose_options(d,en,SELECTION,WINNER_FIELD_FALLBACKS,WINNER_VOTES_FIELD)
 choice_labels<-ra_resolve_option_labels(p,chosen,overrides=OPTION_LABELS[[en]],election=en)
 stopifnot(nrow(choice_labels)==2L,all(nzchar(choice_labels$display_label)),
  all(nzchar(choice_labels$label_source)))
 z<-ra_prepare(d,en,chosen,'C/E');valid<-sum(z$valid_counts)
 stopifnot(valid>1000L,all(z$W[z$valid_counts]+z$R[z$valid_counts]<=z$B[z$valid_counts]),
 all(is.finite(z$winner_of_registered_pct[z$valid_counts])),
 'Size_JHK'%in%names(z),any(z$Size_JHK=='Small',na.rm=TRUE),any(z$Size_JHK=='Large',na.rm=TRUE))
 gs<-ra_groups(z)
 stopifnot(sum(gs$All_100plus)>=1000L,sum(gs$JHK_Small)>=1L,sum(gs$JHK_Large)>=1L)
 cat(en,': Master=',nrow(z),' eligible=',valid,' primary=',sum(gs$All_100plus),
     ' under100=',sum(gs$Under100),' JHK Small=',sum(gs$JHK_Small),' JHK Large=',sum(gs$JHK_Large),'\n',sep='')
}
cat('PASS: Master fields, verified candidate/list names, national candidate selection and Size/JHK; no independent official-total reconciliation.\n')
