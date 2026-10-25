# Run after source('Approximate_normality.R') with default national settings.
root <- 'approximate_normality_outputs'
necessary <- c(file.path(root,'run_configuration.csv'),file.path(root,'run_manifest.csv'),
               file.path(root,'normality_statistics.csv'),
               file.path(root,'cross_election','national','national','cross_election_histogram_bins.csv'))
if (!all(file.exists(necessary))) stop('Missing required export: ',paste(necessary[!file.exists(necessary)],collapse=', '))
m <- utils::read.csv(file.path(root,'run_manifest.csv'),stringsAsFactors=FALSE)
if (!any(m$status=='PASS')) stop('No successful areas in run manifest')
if (!all(c('election','n_primary','n_under100','status') %in% names(m))) stop('Missing manifest columns')
elections <- unique(m$election[m$status=='PASS'])
for (e in elections) {
  dir <- file.path(root,e,'national','national')
  if (!file.exists(file.path(dir,'standardization_parameters.csv'))) next
  mandatory <- c('station_qc.csv','source_qc_summary.csv')
  if (!all(file.exists(file.path(root,e,mandatory)))) stop('Missing source diagnostics for ',e)
  for (p in c('within_election_histogram_bins.csv','station_level_log_rates.csv'))
    if (!file.exists(file.path(dir,p))) stop('Missing numerical diagnostics: ',dir,'/',p)
}
cat('PASS: configuration, master QC, normality statistics, standardization and histogram CSV exports.\n')
