###############################################################################
# Election Forensics R Toolkit — approximate_normality v0.1.2
# Reference: Klimek, Yegorov, Hanel & Thurner (2012), PNAS 109:16469-16473.
# Reproduces Eq. for logarithmic vote rate and Fig. 2 style BINNED curves,
# not KDE. This is a descriptive shape diagnostic, NOT a fraud determination.
###############################################################################

# ============================ EDITABLE SECTION ===============================
INPUTS <- data.frame(
  election=c('presidential_2017','presidential_2022','parliamentary_2022'),
  prepared_file=file.path('..','rzs_data_preparation','RZS_prepared',c(
    'presidential_2017_RZS_prepared.xlsx',
    'presidential_2022_RZS_prepared.xlsx',
    'parliamentary_2022_RZS_prepared.xlsx')),
  stringsAsFactors=FALSE
)
DATA_SHEET <- 'Master' # Master includes E<100 for separate sensitivity figures.
WINNER_VOTES_FIELD <- 'Winner_votes'
# Used only if WINNER_VOTES_FIELD does not exist; confirm Options sheet first.
WINNER_FIELD_FALLBACKS <- list(
  presidential_2017='Option_06_votes',
  presidential_2022='Option_06_votes',
  parliamentary_2022='Option_01_votes'
)
GRAPH_LANGUAGES <- c('EN','SR')
GEOGRAPHIC_LEVELS <- c('national') # Optional 'district','municipality'
DISTRICT_CODES <- NULL            # Example: c('00','26') or NULL = all
MUNICIPALITY_CODES <- NULL        # Example: c('71021') or NULL = all
SIZE_FIELD <- 'Size'              # Prepared national Small/Large labels; alternative 'Size_JHK'
BIN_WIDTH <- 0.2                  # In standard-normal (z-score) units; configurable.
PLOT_X_LIMITS <- c(-5,5)          # Plot viewing range; CSV keeps all tail bins.
MIN_PRIMARY_STATIONS <- 30L      # For estimating stable mean and sd in one area.
MIN_PLOTTED_GROUP <- 10L         # Small/Large/Under100 groups require at least this n.
INCLUDE_UNDER100_SENSITIVITY <- TRUE
INCLUDE_CROSS_ELECTION <- TRUE
INCLUDE_WITHIN_ELECTION <- TRUE
OUTPUT_DIR <- 'approximate_normality_outputs'
PLOT_DPI <- 220L
RUN_NOW <- TRUE
# ========================== END EDITABLE SECTION =============================

source(file.path('R','approximate_normality_functions.R'),encoding='UTF-8')
source(file.path('R','approximate_normality_plots.R'),encoding='UTF-8')

an_run <- function(inputs=INPUTS,out_dir=OUTPUT_DIR) {
  an_require(c('readxl','ggplot2'))
  if (!all(c('election','prepared_file') %in% names(inputs))) stop('INPUTS needs election and prepared_file columns')
  if (anyDuplicated(inputs$election)) stop('Duplicate election IDs in INPUTS')
  if (!all(GRAPH_LANGUAGES %in% c('EN','SR'))) stop('GRAPH_LANGUAGES: only EN, SR supported')
  if (!all(GEOGRAPHIC_LEVELS %in% c('national','district','municipality'))) stop('Invalid GEOGRAPHIC_LEVELS')
  if (!(SIZE_FIELD %in% c('Size','Size_JHK'))) stop('SIZE_FIELD must be Size or Size_JHK')
  if (!is.numeric(BIN_WIDTH) || length(BIN_WIDTH)!=1L || !is.finite(BIN_WIDTH) || BIN_WIDTH<=0) stop('BIN_WIDTH must be positive')
  if (!is.numeric(PLOT_X_LIMITS) || length(PLOT_X_LIMITS)!=2L || any(!is.finite(PLOT_X_LIMITS)) || PLOT_X_LIMITS[1]>=PLOT_X_LIMITS[2]) stop('PLOT_X_LIMITS invalid')
  if (!isTRUE(INCLUDE_CROSS_ELECTION) && !isTRUE(INCLUDE_WITHIN_ELECTION)) stop('No figure category enabled')
  dir.create(out_dir,recursive=TRUE,showWarnings=FALSE)
  config <- data.frame(parameter=c('module','version','data_sheet','log_vote_rate','standardization',
    'bin_width_z','bin_probability','size_field','min_primary_stations','min_plotted_group',
    'geographic_levels','include_under100','plot_x_limits','statistical_interpretation'),
    value=c('approximate_normality','0.1.2','Master','log(W/(E-W))',
            'area-wide primary E>=100 within each election',as.character(BIN_WIDTH),
            'count within group / n_group',SIZE_FIELD,as.character(MIN_PRIMARY_STATIONS),
            as.character(MIN_PLOTTED_GROUP),paste(GEOGRAPHIC_LEVELS,collapse=';'),
            as.character(INCLUDE_UNDER100_SENSITIVITY),paste(PLOT_X_LIMITS,collapse=';'),
            'descriptive; Jarque-Bera is not a fraud test'),stringsAsFactors=FALSE)
  an_write(config,file.path(out_dir,'run_configuration.csv'))
  manifest <- list(); mi <- 0L
  stat_list <- list(); si <- 0L
  cross <- list(); cross_manifest <- list(); ci <- 0L
  # Read once, then select named areas using official codes. No upstream file is modified.
  for (i in seq_len(nrow(inputs))) {
    election <- inputs$election[i]; file <- inputs$prepared_file[i]
    message('[ApproxNormality] Reading ',election,': ',file)
    raw <- an_read_master(file,DATA_SHEET)
    d <- an_prepare(raw,election,WINNER_VOTES_FIELD,WINNER_FIELD_FALLBACKS)
    if (!(SIZE_FIELD %in% names(d)) || all(is.na(d[[SIZE_FIELD]])))
      stop('Prepared Master missing usable classification in ',SIZE_FIELD,'. Confirm source workbook and field selection.')
    d$group_size <- as.character(d[[SIZE_FIELD]])
    e_dir <- file.path(out_dir,election)
    an_write(d[,c('Station_key','District_code','District','Municipality_code','Municipality',
      'E','B','C','W','winner_source_field','Size','group_size','nu','log_defined',
      'primary_ok','sensitivity_under100_ok','qc_reason')],file.path(e_dir,'station_qc.csv'))
    qc <- data.frame(election=election,master_rows=nrow(d),log_defined=sum(d$log_defined),
      primary_e_ge_100=sum(d$primary_ok),under100_sensitivity_eligible=sum(d$sensitivity_under100_ok),
      invalid_or_undefined=sum(!d$log_defined),winner_field=unique(d$winner_source_field))
    an_write(qc,file.path(e_dir,'source_qc_summary.csv'))
    areas <- an_areas(d,GEOGRAPHIC_LEVELS,DISTRICT_CODES,MUNICIPALITY_CODES)
    for (area in areas) {
      local <- d[area$mask,,drop=FALSE]
      dest <- file.path(e_dir,area$level,an_slug(area$key))
      res <- an_standardize(local,MIN_PRIMARY_STATIONS)
      if (!res$ok) {
        mi <- mi+1L
        manifest[[mi]] <- data.frame(election=election,level=area$level,area=area$key,
          status='SKIP',reason=res$reason,n_primary=res$n,n_under100=sum(local$sensitivity_under100_ok),
          n_images=0L,stringsAsFactors=FALSE)
        next
      }
      local <- res$rows
      pars <- cbind(data.frame(election=election,level=area$level,area=area$key,
        area_label=area$label),res$params)
      an_write(pars,file.path(dest,'standardization_parameters.csv'))
      an_write(local[,c('Station_key','District_code','Municipality_code','E','B','C','W',
        'nu','z','group_size','primary_ok','sensitivity_under100_ok','qc_reason')],
        file.path(dest,'station_level_log_rates.csv'))
      primary <- local$primary_ok & is.finite(local$z)
      small <- primary & local$group_size=='Small'
      large <- primary & local$group_size=='Large'
      under100 <- local$sensitivity_under100_ok & is.finite(local$z)
      # ALL primary stations contributes to group and the standardisation.
      maps <- list(All=primary)
      if (sum(small)>=MIN_PLOTTED_GROUP) maps$Small <- small
      if (sum(large)>=MIN_PLOTTED_GROUP) maps$Large <- large
      nimg <- 0L
      if (isTRUE(INCLUDE_WITHIN_ELECTION)) {
        h <- an_hist_groups(local,maps,BIN_WIDTH)
        h <- cbind(data.frame(election=election,level=area$level,area=area$key),h)
        an_write(h,file.path(dest,'within_election_histogram_bins.csv'))
        for (language in GRAPH_LANGUAGES) {
          titles <- if (language=='EN') c('Approximate normality — station-size comparison',
            'Under-100 sensitivity comparison') else c('Približna normalnost — grupe po veličini BM',
            'Analiza osetljivosti — BM sa manje od 100 birača')
          subtitle <- paste(an_label(election,language),'·',an_plot_area(area$level,area$label,language))
          p <- an_plot_hist(h,language,titles[1],subtitle,
            if(language=='EN') 'Groups share one area-wide E>=100 mean and SD.' else
              'Grupe koriste istu sredinu i SD svih BM sa E>=100 na datom području.',
            PLOT_X_LIMITS,stats::setNames(an_plot_labels(names(maps),language),names(maps)),BIN_WIDTH)
          an_save_fig(p,file.path(dest,paste0('Figure2_style_within_',language,'.png')),PLOT_DPI)
          nimg <- nimg+1L
        }
        if (isTRUE(INCLUDE_UNDER100_SENSITIVITY) && sum(under100)>=MIN_PLOTTED_GROUP) {
          hs <- an_hist_groups(local,list(Reference=primary,Under100=under100),BIN_WIDTH)
          hs <- cbind(data.frame(election=election,level=area$level,area=area$key),hs)
          an_write(hs,file.path(dest,'under100_sensitivity_histogram_bins.csv'))
          for (language in GRAPH_LANGUAGES) {
            subtitle <- paste(an_label(election,language),'·',an_plot_area(area$level,area$label,language))
            p <- an_plot_hist(hs,language,
              if(language=='EN') 'Approximate normality — under-100 sensitivity' else 'Približna normalnost — BM sa manje od 100 birača',
              subtitle,if(language=='EN') 'E<100 excluded from the primary reference; identical baseline used here.' else
                'BM sa E<100 nisu u osnovnom uzorku; koristi se ista referentna standardizacija.',
              PLOT_X_LIMITS,c(Reference=an_plot_labels('Reference',language),Under100=an_plot_labels('Under100',language)),BIN_WIDTH)
            an_save_fig(p,file.path(dest,paste0('Figure2_style_under100_',language,'.png')),PLOT_DPI)
            nimg <- nimg+1L
          }
          maps$Under100 <- under100
        }
      }
      for (group in names(maps)) {
        x <- local$z[which(maps[[group]] & is.finite(local$z))]
        si <- si+1L; stat_list[[si]] <- an_stats_row(election,area$level,area$key,group,x)
      }
      # Original Fig. 2 was across elections; one ALL-primary distribution per election/area.
      if (isTRUE(INCLUDE_CROSS_ELECTION)) {
        key <- paste(area$level,area$key,sep='::')
        if (is.null(cross[[key]])) cross[[key]] <- list()
        cross[[key]][[election]] <- list(z=local$z[which(primary)],label=area$label,
          level=area$level,area=area$key)
      }
      mi <- mi+1L
      manifest[[mi]] <- data.frame(election=election,level=area$level,area=area$key,
        status='PASS',reason='',n_primary=sum(primary),n_under100=sum(under100),
        n_images=nimg,stringsAsFactors=FALSE)
    }
  }
  if (length(stat_list)) an_write(do.call(rbind,stat_list),file.path(out_dir,'normality_statistics.csv'))
  if (length(cross)) for (key in names(cross)) {
    entry <- cross[[key]]
    if (length(entry)<1L) next
    z <- unlist(lapply(entry,function(el) el$z),use.names=FALSE)
    idx <- floor(z/BIN_WIDTH+.5)
    grid <- seq.int(as.integer(min(idx)),as.integer(max(idx)))
    parts <- lapply(names(entry),function(el) {
      h <- an_hist(entry[[el]]$z,BIN_WIDTH,grid)
      h$group <- el
      h
    })
    hh <- do.call(rbind,parts)
    item <- entry[[1]]
    dest <- file.path(out_dir,'cross_election',item$level,an_slug(item$area))
    hh <- cbind(data.frame(level=item$level,area=item$area),hh)
    an_write(hh,file.path(dest,'cross_election_histogram_bins.csv'))
    ci <- ci+1L
    cross_manifest[[ci]] <- data.frame(level=item$level,area=item$area,
      n_elections=length(entry),status=if(length(entry)>=2L) 'PASS' else 'SKIP_ONE_ELECTION',
      n_images=if(length(entry)>=2L) length(GRAPH_LANGUAGES) else 0L)
    if (length(entry)<2L) {
      message('[ApproxNormality] Cross-election area ',key,': only one election, exported numeric curve.')
    } else for (language in GRAPH_LANGUAGES) {
      labs <- stats::setNames(an_label(names(entry),language),names(entry))
      ttl <- if (language=='EN') 'Approximate normality — comparison across elections' else
        'Približna normalnost — poređenje izbora'
      caption <- if (language=='EN') 'Each election standardized using all eligible E>=100 stations in the selected area.' else
        'Svaki izbor standardizovan je prema svim odgovarajućim BM sa E>=100 na području.'
      p <- an_plot_hist(hh,language,ttl,an_plot_area(item$level,item$label,language),
                        caption,PLOT_X_LIMITS,labs,BIN_WIDTH)
      an_save_fig(p,file.path(dest,paste0('Figure2_style_cross_elections_',language,'.png')),PLOT_DPI)
    }
  }
  if (length(manifest)) an_write(do.call(rbind,manifest),file.path(out_dir,'run_manifest.csv'))
  if (length(cross_manifest)) an_write(do.call(rbind,cross_manifest),file.path(out_dir,'cross_election_manifest.csv'))
  message('[ApproxNormality] Binned curves, normality statistics, diagnostics, and bilingual figures exported. No KDE or fraud classification.')
  invisible(list(manifest=if(length(manifest)) do.call(rbind,manifest) else data.frame(),out_dir=out_dir))
}

if (isTRUE(RUN_NOW) && Sys.getenv('EF_APPROX_NORMALITY_TEST_MODE')!='1') an_run()
