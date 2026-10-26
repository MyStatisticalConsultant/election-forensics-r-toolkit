root<-'regression_analysis_outputs'
if(!dir.exists(root))stop('Missing output folder: run Regression_analysis.R first')
for(nm in c('run_configuration.csv','export_manifest.csv'))if(!file.exists(file.path(root,nm)))stop('Missing ',nm)
m<-utils::read.csv(file.path(root,'export_manifest.csv'))
stopifnot(nrow(m)>=length(INPUTS)*length(TURNOUT_DEFINITIONS),all(m$n_primary>=0))
for(i in seq_len(nrow(INPUTS))){
 en<-INPUTS$election[i]
 if(!file.exists(file.path(root,en,'selected_options.csv')))stop('Missing national option selection for ',en)
 choices<-utils::read.csv(file.path(root,en,'selected_options.csv'),stringsAsFactors=FALSE)
 stopifnot(all(c('display_label','label_source')%in%names(choices)),nrow(choices)==2L,
   all(nzchar(choices$display_label)),all(nzchar(choices$label_source)),
   !any(grepl('^Option[_ ]?[0-9]+',choices$display_label)))
 for(def in TURNOUT_DEFINITIONS){
  defid<-if(def=='C/E')'turnout_C_over_E' else 'turnout_B_over_E'
  base<-file.path(root,en,defid,'national','national')
  for(fn in c('model_summary.csv','model_coefficients.csv','model_station_residuals.csv',
    'lukinova_station_values.csv','invalid_station_values.csv','group_sample_counts.csv')){
   if(!file.exists(file.path(base,fn)))stop('Missing exported file: ',file.path(base,fn))
  }
  a<-utils::read.csv(file.path(base,'model_summary.csv'))
  stopifnot(any(a$model=='A'),any(a$model=='B1'),any(a$model=='B2'),any(grepl('Controlled',a$model)))
  for(kind in c('A','B1','B2'))for(classname in SIZE_CLASSIFICATIONS)for(lang in GRAPH_LANGUAGES){
    f<-file.path(base,paste0('Regression_',kind,'_',classname,'_',lang,'.png'))
    if(!file.exists(f)||file.info(f)$size<5000L)stop('Missing/empty graphic: ',f)
  }
 }
}
cat('PASS: national exports, regression coefficients/diagnostics/residuals, controlled models, verified candidate labels, bilingual Size and three-panel JHK figures.\n')
