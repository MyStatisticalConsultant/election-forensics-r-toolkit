out<-'shpilkin_outputs'
for(f in c('run_configuration.csv','export_manifest.csv','national_comparison_histograms.csv','National_comparison_EN.png','National_comparison_SR.png')){
 path<-file.path(out,f);if(!file.exists(path))stop('Missing export: ',path)}
m<-utils::read.csv(file.path(out,'export_manifest.csv'),stringsAsFactors=FALSE)
stopifnot(nrow(m)>0,all(c('mc_status','png_count','hist_eligible')%in%names(m)))
for(i in seq_len(nrow(m))){z<-file.path(out,m$election[i],if(m$turnout_definition[i]=='C/E')'turnout_C_over_E' else 'turnout_B_over_E',m$level[i],gsub('[^A-Za-z0-9_-]','_',m$area[i]));
 for(f in c('quality_summary.csv'))if(!file.exists(file.path(z,f)))stop('Missing area export: ',file.path(z,f));
 if(m$status[i]=='OK')for(f in c('descriptive_turnout_bins.csv','descriptive_winner_bins.csv','excess_summary.csv','excess_sensitivity.csv'))if(!file.exists(file.path(z,f)))stop('Missing export: ',file.path(z,f));
 if(m$mc_status[i]=='OK')for(f in c('integer_mc_summary.csv','integer_mc_replicates.csv','integer_turnout_mc_histogram.csv','integer_winner_mc_histogram.csv'))if(!file.exists(file.path(z,f)))stop('Missing MC export: ',file.path(z,f));
}
cat('PASS: configuration, manifests, bilingual national plots, descriptive/intermediate/MC/excess numerical CSV exports.\n')
