###############################################################################
# Election Forensics R Toolkit — shpilkin v0.1.1
# Three distinct methods: descriptive density curves; Kobak et al. (2016)
# binomial Monte Carlo integer-percentage anomalies; conditional Shpilkin
# nonparametric excess-votes scenario. See METHODOLOGY.md before interpreting.
###############################################################################
# ======================== EDITABLE SECTION ===================================
INPUTS <- data.frame(
 election=c('presidential_2017','presidential_2022','parliamentary_2022'),
 prepared_file=file.path('..','rzs_data_preparation','RZS_prepared',
 c('presidential_2017_RZS_prepared.xlsx','presidential_2022_RZS_prepared.xlsx',
   'parliamentary_2022_RZS_prepared.xlsx')),stringsAsFactors=FALSE)
DATA_SHEET <- 'Master'
WINNER_VOTES_FIELD <- 'Winner_votes'
# Explicit fallback ONLY when the common Winner_votes field is unavailable;
# verify these against the election's Options worksheet BEFORE publication.
WINNER_FIELD_FALLBACKS <- list(presidential_2017='Option_06_votes',
 presidential_2022='Option_06_votes',parliamentary_2022='Option_01_votes')
TURNOUT_DEFINITIONS <- c('C/E','B/E')  # C/E main; B/E sensitivity; winner always W/B
GEOGRAPHIC_LEVELS <- c('national')    # Optionally: 'district','municipality'
DISTRICT_CODES <- NULL               # e.g. c('00','26')
MUNICIPALITY_CODES <- NULL
GRAPH_LANGUAGES <- c('EN','SR')
DESCRIPTIVE_BIN_WIDTH <- 0.5          # Serbia: readable; use 0.25 for sensitivity
DESCRIPTIVE_JITTER <- TRUE            # U(-0.5,0.5) numerator, FIGURES ONLY
INTEGER_BIN_WIDTH <- 0.1            # Original paper, must not depend on above
INTEGER_WINDOW_HALF_WIDTH <- 0.05   # Original test: integer +/- 0.05 pp
RUN_MONTE_CARLO <- TRUE
MONTE_CARLO_LEVELS <- c('national')    # Local area simulations can be expensive
MONTE_CARLO_REPS <- 999L             # Exploratory default; use 10000L to match source replicate count
MONTE_CARLO_MIN_STATIONS <- 40L
EXCESS_BIN_WIDTH <- 1                # Turnout-bin size for conditional excess model
EXCESS_CORE_RANGE <- NULL           # NULL: modal-turnout +/- 7.5pp, recorded and flagged
EXCESS_AUTO_WINDOW <- 7.5
EXCESS_SENSITIVITY_WINDOWS <- c(5,7.5,10)
RANDOM_SEED <- 20161026L
PLOT_DPI <- 220L
OUTPUT_DIR <- 'shpilkin_outputs'
RUN_NOW <- TRUE
# ====================== END EDITABLE SECTION =================================
source(file.path('R','shpilkin_core.R'),encoding='UTF-8')
source(file.path('R','shpilkin_plots.R'),encoding='UTF-8')
sp_run <- function(inputs=INPUTS,out_dir=OUTPUT_DIR){
 sp_need(c('readxl','ggplot2'))
 stopifnot(all(c('election','prepared_file')%in%names(inputs)))
 if(anyDuplicated(inputs$election))stop('Election IDs must be unique')
 if(!all(TURNOUT_DEFINITIONS%in%c('C/E','B/E')))stop('Unsupported definition')
 if(!all(GRAPH_LANGUAGES%in%c('EN','SR')))stop('Only EN and SR graphics languages supported')
 sp_centers(DESCRIPTIVE_BIN_WIDTH);sp_centers(INTEGER_BIN_WIDTH);sp_centers(EXCESS_BIN_WIDTH)
 dir.create(out_dir,recursive=TRUE,showWarnings=FALSE)
 options<-data.frame(parameter=c('module','version','worksheet','turnout_definitions',
 'descriptive_bin_width_pp','descriptive_jitter','integer_bin_width_pp',
 'integer_window_half_width_pp','mc_reps','mc_seed','mc_levels','excess_bin_width_pp',
 'excess_core_range','excess_auto_window','method_warning'),
 value=c('shpilkin','0.1.2','Master',paste(TURNOUT_DEFINITIONS,collapse=';'),
 DESCRIPTIVE_BIN_WIDTH,DESCRIPTIVE_JITTER,INTEGER_BIN_WIDTH,INTEGER_WINDOW_HALF_WIDTH,
 MONTE_CARLO_REPS,RANDOM_SEED,paste(MONTE_CARLO_LEVELS,collapse=';'),EXCESS_BIN_WIDTH,
 if(is.null(EXCESS_CORE_RANGE))'AUTO, CHECK SENSITIVITY' else paste(EXCESS_CORE_RANGE,collapse=';'),
 EXCESS_AUTO_WINDOW,'NO FRAUD CLASSIFICATION; conditional excess is assumption dependent'))
 sp_csv(options,file.path(out_dir,'run_configuration.csv'))
 manifest<-list();comparisons<-list()
 k<-0L
 for(i in seq_len(nrow(inputs))){
  election<-inputs$election[i];file<-inputs$prepared_file[i];message('[Shpilkin] Reading ',election,': ',file)
  raw<-sp_read_master(file)
  for(def in TURNOUT_DEFINITIONS){
   prepared<-sp_prepared(raw,election,WINNER_VOTES_FIELD,WINNER_FIELD_FALLBACKS,def)
   dest<-file.path(out_dir,election,if(def=='C/E')'turnout_C_over_E' else 'turnout_B_over_E')
   dir.create(dest,recursive=TRUE,showWarnings=FALSE)
   cols<-c('Station_key','District_code','Municipality_code','E','B','C','G','W','winner_field_used',
     'turnout_pct','leader_pct','base_ok','hist_ok','test_ok','qc_reason')
   sp_csv(prepared[,cols],file.path(dest,'station_level_qc.csv'))
   areas<-sp_areas(prepared,GEOGRAPHIC_LEVELS,DISTRICT_CODES,MUNICIPALITY_CODES)
   for(a in areas){
    d<-prepared[a$idx,,drop=FALSE];loc<-file.path(dest,a$level,sp_slug(a$key));dir.create(loc,recursive=TRUE,showWarnings=FALSE)
    eligible<-sum(d$hist_ok);ntest<-sum(d$test_ok);status<-if(eligible>=20)'OK' else 'INSUFFICIENT_ELIGIBLE'
    qc<-data.frame(election=election,definition=def,level=a$level,area=a$key,master_rows=nrow(d),
      qc_base_ok=sum(d$base_ok),hist_eligible=eligible,integer_test_eligible=ntest,
      under100=sum(d$base_ok & d$E<100),excluded_from_integer=sum(!d$test_ok))
    sp_csv(qc,file.path(loc,'quality_summary.csv'))
    png_n<-0L
    if(eligible>=20L){
     ds<-sp_descriptive(d,DESCRIPTIVE_BIN_WIDTH,DESCRIPTIVE_JITTER,RANDOM_SEED+i*100+if(def=='C/E')1L else 2L)
     sp_csv(ds$stations[,c('Station_key','E','B','C','W','turnout_pct','leader_pct','plot_turnout_pct','plot_leader_pct')],file.path(loc,'descriptive_station_rates.csv'))
     sp_csv(ds$turnout,file.path(loc,'descriptive_turnout_bins.csv'));sp_csv(ds$leader,file.path(loc,'descriptive_winner_bins.csv'))
     if(a$level=='national' && def==TURNOUT_DEFINITIONS[1]){
       comparisons[[paste(election,'turnout')]]<-data.frame(election=election,measure='turnout',ds$turnout)
       comparisons[[paste(election,'leader')]]<-data.frame(election=election,measure='leader',ds$leader)
     }
     for(lang in GRAPH_LANGUAGES){
      sub<-paste(sp_pretty(election,lang),a$name,def,sep=' | ')
      sp_save(sp_curve_plot(ds$turnout,'turnout',lang,sub),file.path(loc,paste0('Descriptive_turnout_',lang,'.png')),PLOT_DPI);png_n<-png_n+1L
      sp_save(sp_curve_plot(ds$leader,'leader',lang,sub),file.path(loc,paste0('Descriptive_winner_',lang,'.png')),PLOT_DPI);png_n<-png_n+1L
     }
     # Conditional nonparametric method: a clearly labeled assumption-based scenario.
     ex<-sp_excess(d,EXCESS_BIN_WIDTH,EXCESS_CORE_RANGE,EXCESS_AUTO_WINDOW)
     if(nrow(ex$bins))sp_csv(ex$bins,file.path(loc,'excess_turnout_bins.csv'))
     if(nrow(ex$summary))sp_csv(ex$summary,file.path(loc,'excess_summary.csv'))
     # Compute alternative modal reference half-widths explicitly.
     sensitivity<-lapply(EXCESS_SENSITIVITY_WINDOWS,function(w){r<-sp_excess(d,EXCESS_BIN_WIDTH,NULL,w);z<-r$summary;z$auto_window<-w;z})
     sp_csv(do.call(rbind,sensitivity),file.path(loc,'excess_sensitivity.csv'))
     if(nrow(ex$bins) && nrow(ex$summary) && is.finite(ex$summary$ratio_winner_to_others))for(lang in GRAPH_LANGUAGES){
      p<-sp_excess_plot(ex$bins,ex$summary,lang,paste(sp_pretty(election,lang),a$name,def,sep=' | '));if(!is.null(p)){sp_save(p,file.path(loc,paste0('Excess_scenario_',lang,'.png')),PLOT_DPI);png_n<-png_n+1L}}
    }
    mcstatus<-'DISABLED_OR_LOCAL'
    if(RUN_MONTE_CARLO && a$level %in% MONTE_CARLO_LEVELS && ntest>=MONTE_CARLO_MIN_STATIONS){
     mc<-sp_mc(d,MONTE_CARLO_REPS,RANDOM_SEED+i*1000+if(def=='C/E')10L else 20L,INTEGER_BIN_WIDTH,INTEGER_WINDOW_HALF_WIDTH)
     sp_csv(mc$summary,file.path(loc,'integer_mc_summary.csv'))
     sp_csv(mc$draws,file.path(loc,'integer_mc_replicates.csv'))
     sp_csv(mc$turnout_band,file.path(loc,'integer_turnout_mc_histogram.csv'))
     sp_csv(mc$leader_band,file.path(loc,'integer_winner_mc_histogram.csv'))
     mcstatus<-'OK'
     for(lang in GRAPH_LANGUAGES){
      sub<-paste(sp_pretty(election,lang),a$name,def,sep=' | ')
      sp_save(sp_mc_plot(mc$turnout_band,'turnout',lang,sub),file.path(loc,paste0('Integer_MC_turnout_',lang,'.png')),PLOT_DPI);png_n<-png_n+1L
      sp_save(sp_mc_plot(mc$leader_band,'leader',lang,sub),file.path(loc,paste0('Integer_MC_winner_',lang,'.png')),PLOT_DPI);png_n<-png_n+1L
     }
    } else if(RUN_MONTE_CARLO && a$level %in% MONTE_CARLO_LEVELS)mcstatus<-'INSUFFICIENT_STATIONS'
    k<-k+1L;manifest[[k]]<-data.frame(election=election,turnout_definition=def,level=a$level,area=a$key,status=status,mc_status=mcstatus,master_rows=nrow(d),hist_eligible=eligible,test_eligible=ntest,png_count=png_n)
   }
  }
 }
 if(length(manifest))sp_csv(do.call(rbind,manifest),file.path(out_dir,'export_manifest.csv'))
 if(length(comparisons)>0){z<-do.call(rbind,comparisons);sp_csv(z,file.path(out_dir,'national_comparison_histograms.csv'))
  for(lang in GRAPH_LANGUAGES)sp_save(sp_multi_plot(z,lang),file.path(out_dir,paste0('National_comparison_',lang,'.png')),PLOT_DPI,11,8)}
 message('[Shpilkin] Exported descriptive histograms, integer-percentage MC and conditional excess-votes scenarios. No determination of electoral fraud.')
 invisible(if(length(manifest))do.call(rbind,manifest) else data.frame())
}
if(isTRUE(RUN_NOW) && Sys.getenv('EF_SHPILKIN_TEST_MODE')!='1')sp_run()
