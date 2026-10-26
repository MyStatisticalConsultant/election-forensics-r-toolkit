###############################################################################
# Election Forensics R Toolkit | regression_analysis v0.1.8 (development)
# Two diagnostic methods: Lukinova et al. (2011) and Mebane-inspired invalid-ballot regressions.
# Run from modules/regression_analysis/: source('Regression_analysis.R')
###############################################################################
# ============================== EDITABLE SECTION =============================
INPUTS <- data.frame(
 election=c('presidential_2017','presidential_2022','parliamentary_2022'),
 prepared_file=file.path('..','rzs_data_preparation','RZS_prepared',c(
 'presidential_2017_RZS_prepared.xlsx','presidential_2022_RZS_prepared.xlsx',
 'parliamentary_2022_RZS_prepared.xlsx')),stringsAsFactors=FALSE)
DATA_SHEET <- 'Master'
WINNER_VOTES_FIELD <- 'Winner_votes'
WINNER_FIELD_FALLBACKS <- list(presidential_2017='Option_06_votes',
 presidential_2022='Option_06_votes',parliamentary_2022='Option_01_votes')
# Automatically select national top two options. Override with named two-column vector per election.
SELECTION <- list() # e.g. list(presidential_2022=c('Option_06_votes','Option_02_votes'))
# Names are read automatically from the RZS 'Options' dictionary by ballot number.
# Use named overrides only when source metadata are missing/incorrect; never guess.
# Partial named vectors/lists are allowed: other selected names come from Options.
OPTION_LABELS <- list() # e.g. list(presidential_2022=c(Option_06_votes='Verified Name'))
TURNOUT_DEFINITIONS <- c('C/E','B/E') # C/E primary; B/E sensitivity.
GEOGRAPHIC_LEVELS <- c('national') # Optional 'district', 'municipality'
DISTRICT_CODES <- NULL             # Optional district IDs, e.g. c('00','26')
MUNICIPALITY_CODES <- NULL         # Optional municipality IDs
GRAPH_LANGUAGES <- c('EN','SR')    # Serbian Latin, not Cyrillic.
SIZE_CLASSIFICATIONS <- c('Size','Size_JHK') # BOTH prepared national schemes; no local recalculation.
INCLUDE_UNDER100_SENSITIVITY <- TRUE
MIN_ELECTORATE <- 100L
MIN_REGRESSION_N <- 30L
MIN_UNIQUE_X <- 5L
RUN_CONTROLLED_MODELS <- TRUE
INCLUDE_MUNICIPALITY_FIXED_EFFECTS <- TRUE # when feasible (max 120 FE)
MAX_FIXED_EFFECTS <- 120L
PLOT_DPI <- 220L
OUTPUT_DIR <- 'regression_analysis_outputs'
RUN_NOW <- TRUE
# ============================ END EDITABLE SECTION ===========================
source(file.path('R','regression_core.R'),encoding='UTF-8')
source(file.path('R','regression_plots.R'),encoding='UTF-8')
ra_run <- function(inputs=INPUTS,out_dir=OUTPUT_DIR){
 ra_require(c('readxl','ggplot2'))
 if(!all(c('election','prepared_file')%in%names(inputs))||anyDuplicated(inputs$election))stop('INPUTS: unique election and prepared_file columns required')
 if(!all(TURNOUT_DEFINITIONS%in%c('C/E','B/E')))stop('TURNOUT_DEFINITIONS must be C/E or B/E')
 if(!all(SIZE_CLASSIFICATIONS%in%c('Size','Size_JHK'))||!length(SIZE_CLASSIFICATIONS))stop('Invalid classification')
 if(!all(GRAPH_LANGUAGES%in%c('EN','SR')))stop('GRAPH_LANGUAGES accepts EN, SR')
 dir.create(out_dir,recursive=TRUE,showWarnings=FALSE)
 config<-data.frame(parameter=c('module','version','worksheet','turnout_definitions','geographic_levels',
  'size_classifications','minimum_electorate','under100_sensitivity','minimum_regression_n',
  'minimum_unique_x','hc3_method','controlled_models','municipality_fixed_effects','max_fixed_effects','interpretation'),
  value=c('regression_analysis','0.1.8',DATA_SHEET,paste(TURNOUT_DEFINITIONS,collapse=';'),
  paste(GEOGRAPHIC_LEVELS,collapse=';'),paste(SIZE_CLASSIFICATIONS,collapse=';'),MIN_ELECTORATE,
  INCLUDE_UNDER100_SENSITIVITY,MIN_REGRESSION_N,MIN_UNIQUE_X,'HC3 robust t with residual df',
  RUN_CONTROLLED_MODELS,INCLUDE_MUNICIPALITY_FIXED_EFFECTS,MAX_FIXED_EFFECTS,'diagnostic associations; NOT fraud evidence'))
 ra_csv(config,file.path(out_dir,'run_configuration.csv'))
 manifest<-list(); counter<-0L
 for(i in seq_len(nrow(inputs))){
  en<-inputs$election[i];path<-inputs$prepared_file[i]
  message('[Regression] Reading ',en,': ',path)
  raw<-ra_read(path,DATA_SHEET)
  choice<-ra_choose_options(raw,en,SELECTION,WINNER_FIELD_FALLBACKS,WINNER_VOTES_FIELD)
  choice<-ra_resolve_option_labels(path,choice,
          overrides=OPTION_LABELS[[en]],election=en)
  message('[Regression] ',en,': ',paste(paste(choice$role,choice$display_label,sep='='),collapse='; '))
  e_dir<-file.path(out_dir,en);ra_csv(choice,file.path(e_dir,'selected_options.csv'))
  for(def in TURNOUT_DEFINITIONS){
   d<-ra_prepare(raw,en,choice,def)
   unit<-if(def=='C/E')'turnout_C_over_E' else 'turnout_B_over_E'
   base_dir<-file.path(e_dir,unit)
   qc_cols<-c('Station_key','District_code','Municipality_code','E','B','C','Size','Size_JHK',
     'W','R','valid_counts','exclusion_reason','turnout_def','turnout_pct',
     'winner_of_registered_pct','runner_of_registered_pct','winner_of_valid_pct','invalid_count','invalid_rate_pct')
   ra_csv(d[,qc_cols,drop=FALSE],file.path(base_dir,'station_qc.csv'))
   areas<-ra_areas(d,GEOGRAPHIC_LEVELS,DISTRICT_CODES,MUNICIPALITY_CODES)
   for(area in areas){
    z<-d[area$mask,,drop=FALSE]
    loc<-file.path(base_dir,area$level,ra_slug(area$key))
    groups<-ra_groups(z,INCLUDE_UNDER100_SENSITIVITY,MIN_ELECTORATE)
    group_summary<-do.call(rbind,lapply(names(groups),function(g){
     ix<-groups[[g]]
     data.frame(election=en,definition=def,level=area$level,area=area$key,group=g,
      n=sum(ix),n_master=nrow(z),n_qc_eligible=sum(z$valid_counts),
      n_primary_eligible=sum(z$valid_counts & z$E>=MIN_ELECTORATE))}))
    ra_csv(group_summary,file.path(loc,'group_sample_counts.csv'))
    coeffs<-list(); metas<-list(); resids<-list(); fits<-list();k<-0L
    for(g in names(groups)){
     dd<-z[groups[[g]],,drop=FALSE]
     if(!nrow(dd))next
     for(role in c('Winner','RunnerUp')){
      formula<-if(role=='Winner')winner_of_registered_pct~turnout_pct else runner_of_registered_pct~turnout_pct
      mid<-paste('A',g,role,sep='_')
      ff<-ra_fit(dd,mid,formula,MIN_REGRESSION_N,MIN_UNIQUE_X,MAX_FIXED_EFFECTS)
      fits[[paste(g,'A',role,sep='|')]]<-ff
      k<-k+1L;metas[[k]]<-cbind(data.frame(election=en,definition=def,level=area$level,area=area$key,group=g,model='A',role=role),ff$meta)
      if(nrow(ff$coeff))coeffs[[length(coeffs)+1L]]<-cbind(data.frame(election=en,definition=def,level=area$level,area=area$key,group=g,model='A',role=role),ff$coeff)
      if(nrow(ff$rows))resids[[length(resids)+1L]]<-cbind(data.frame(group=g,model='A',role=role),ff$rows)
     }
     for(kind in c('B1','B2')){
      xv<-if(kind=='B1')'invalid_count' else 'invalid_rate_pct'
      form<-stats::as.formula(paste('winner_of_valid_pct ~',xv))
      mid<-paste(kind,g,'Winner',sep='_')
      ff<-ra_fit(dd,mid,form,MIN_REGRESSION_N,MIN_UNIQUE_X,MAX_FIXED_EFFECTS)
      fits[[paste(g,kind,'Winner',sep='|')]]<-ff
      k<-k+1L;metas[[k]]<-cbind(data.frame(election=en,definition=def,level=area$level,area=area$key,group=g,model=kind,role='Winner'),ff$meta)
      if(nrow(ff$coeff))coeffs[[length(coeffs)+1L]]<-cbind(data.frame(election=en,definition=def,level=area$level,area=area$key,group=g,model=kind,role='Winner'),ff$coeff)
      if(nrow(ff$rows))resids[[length(resids)+1L]]<-cbind(data.frame(group=g,model=kind,role='Winner'),ff$rows)
      if(RUN_CONTROLLED_MODELS){
       # These are ADDITIONAL sensitivity analyses, not the source regression.
       cv<-stats::as.formula(paste('winner_of_valid_pct ~',xv,'+ turnout_pct + log_registered'))
       add_forms<-list(Controlled=cv)
       if(INCLUDE_MUNICIPALITY_FIXED_EFFECTS && area$level!='municipality' &&
          length(unique(stats::na.omit(dd$Municipality_code)))>1L &&
          length(unique(stats::na.omit(dd$Municipality_code)))<=MAX_FIXED_EFFECTS){
        dd$Municipality_code<-factor(dd$Municipality_code)
        add_forms$Controlled_Municipality_FE<-stats::as.formula(paste('winner_of_valid_pct ~',xv,'+ turnout_pct + log_registered + Municipality_code'))
       }
       for(suffix in names(add_forms)){
        mm<-paste(kind,suffix,sep='_');mid<-paste(mm,g,'Winner',sep='_')
        ff<-ra_fit(dd,mid,add_forms[[suffix]],MIN_REGRESSION_N,MIN_UNIQUE_X,MAX_FIXED_EFFECTS)
        k<-k+1L;metas[[k]]<-cbind(data.frame(election=en,definition=def,level=area$level,area=area$key,group=g,model=mm,role='Winner'),ff$meta)
        if(nrow(ff$coeff))coeffs[[length(coeffs)+1L]]<-cbind(data.frame(election=en,definition=def,level=area$level,area=area$key,group=g,model=mm,role='Winner'),ff$coeff)
        if(nrow(ff$rows))resids[[length(resids)+1L]]<-cbind(data.frame(group=g,model=mm,role='Winner'),ff$rows)
       }
      }
     }
    }
    ra_csv(if(length(metas))do.call(rbind,metas) else data.frame(status='NO_GROUPS'),file.path(loc,'model_summary.csv'))
    ra_csv(if(length(coeffs))do.call(rbind,coeffs) else ra_empty_coeff(),file.path(loc,'model_coefficients.csv'))
    ra_csv(if(length(resids))do.call(rbind,resids) else data.frame(),file.path(loc,'model_station_residuals.csv'))
    ra_csv(ra_lukinova_rows(z),file.path(loc,'lukinova_station_values.csv'))
    ra_csv(ra_invalid_rows(z),file.path(loc,'invalid_station_values.csv'))
    plot_counts<-0L
    for(set in SIZE_CLASSIFICATIONS){
     gs<-groups[c('All_100plus',if(set=='Size')c('Size_Small','Size_Large') else c('JHK_Small','JHK_Large'),if(INCLUDE_UNDER100_SENSITIVITY)'Under100')]
     for(kind in c('A','B1','B2')){
      pd<-ra_plot_df(z,gs,kind)
      if(!nrow(pd))next
      for(lang in GRAPH_LANGUAGES){
       subtitle<-paste(gsub('_',' ',en),area$label,def,sep=' | ')
       plot_set <- if(set=='Size_JHK') 'JHK' else set
       p<-ra_make_plot(pd,fits,lang,kind,subtitle,plot_set,MIN_REGRESSION_N,stats::setNames(choice$display_label,choice$role))
       fp<-file.path(loc,paste0('Regression_',kind,'_',set,'_',lang,'.png'))
       if(ra_save_png(p,fp,PLOT_DPI))plot_counts<-plot_counts+1L
      }
     }
    }
    counter<-counter+1L;manifest[[counter]]<-data.frame(election=en,definition=def,level=area$level,area=area$key,
     master_rows=nrow(z),n_primary=sum(z$valid_counts & z$E>=MIN_ELECTORATE),
     n_under100=sum(z$valid_counts & z$E<MIN_ELECTORATE),models=length(metas),png=plot_counts)
   }
  }
 }
 ra_csv(if(length(manifest))do.call(rbind,manifest) else data.frame(),file.path(out_dir,'export_manifest.csv'))
 message('[Regression] Lukinova and invalid-ballot regressions exported. Associations do not establish electoral manipulation.')
 invisible(if(length(manifest))do.call(rbind,manifest) else data.frame())
}
if(isTRUE(RUN_NOW) && Sys.getenv('EF_REGRESSION_TEST_MODE')!='1')ra_run()
