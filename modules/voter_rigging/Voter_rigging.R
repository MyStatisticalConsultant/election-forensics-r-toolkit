###############################################################################
# Election Forensics R Toolkit — voter_rigging, version 0.1.1
# Jimenez, Hidalgo & Klimek (2017), Science Advances 3:e1602363
# This release: original D(p) and Fig.4-style descriptive outputs; NOT delta(p)
# without a cross-election reference set. Read README before interpretation.
###############################################################################

# ======================== EDITABLE SECTION ===================================
INPUTS <- data.frame(
  election=c("presidential_2017","presidential_2022","parliamentary_2022"),
  prepared_file=file.path("..","rzs_data_preparation","RZS_prepared",
    c("presidential_2017_RZS_prepared.xlsx",
      "presidential_2022_RZS_prepared.xlsx",
      "parliamentary_2022_RZS_prepared.xlsx")),
  stringsAsFactors=FALSE
)
DATA_SHEET <- "Master"           # Includes E<100; do not use Main here.
WINNER_VOTES_FIELD <- "Winner_votes"
# Used ONLY if Winner_votes is missing. Verify against your Options sheet.
WINNER_FIELD_FALLBACKS <- list(
  presidential_2017="Option_06_votes",presidential_2022="Option_06_votes",
  parliamentary_2022="Option_01_votes"
)
TURNOUT_DEFINITIONS <- c("A","B") # A: B/E; B: C/E; both: W/B
GEOGRAPHIC_LEVELS <- c("national") # Add "district", "municipality" if wanted
DISTRICT_CODES <- NULL            # e.g., c("00","26")
MUNICIPALITY_CODES <- NULL        # NULL = all municipalities
GRAPH_LANGUAGES <- c("EN","SR")
P_THRESHOLDS <- seq(.5,90,by=.5) # Original supplement: 0.5,1,...90
MIN_NEIGHBORHOOD_STATIONS <- 10L  # 10 total = 9 leave-one-out neighbors
MIN_SMALL_LARGE_STATIONS <- 10L  # original supplement minimum each group
ELLIPSE_CONFIDENCE <- .95
OUTPUT_DIR <- "voter_rigging_outputs"
# Optional *exploratory* electorate-label randomisation. Not canonical δ(p).
RUN_EXPLORATORY_PERMUTATIONS <- TRUE
PERMUTATION_ONLY_LEVEL <- "national"
PERMUTATION_THRESHOLDS <- c(10,20)
PERMUTATION_REPS <- 199L
PERMUTATION_SCOPE <- "within_municipality" # or "global" (paper-style)
RANDOM_SEED <- 29042017L
PLOT_DPI <- 220L
RUN_NOW <- TRUE
# ====================== END EDITABLE SECTION =================================

source(file.path("R","voter_rigging_functions.R"),encoding="UTF-8")
source(file.path("R","voter_rigging_plots.R"),encoding="UTF-8")

vr_write <- function(x,path) utils::write.csv(x,path,row.names=FALSE,na="",fileEncoding="UTF-8")
vr_manifest_entry <- function(election,definition,area,status,n_raw,n_std,n_ellipse,n_d,n_cum,n_png,reason="")
  data.frame(election=election,definition=definition,level=area$level,area=area$key,
             status=status,n_raw=n_raw,n_standardized=n_std,n_after_ellipse=n_ellipse,
             n_valid_thresholds=n_d,n_cumulative_stations=n_cum,n_graphs=n_png,
             reason=reason,stringsAsFactors=FALSE)

vr_run <- function(inputs=INPUTS,out_dir=OUTPUT_DIR) {
  vr_require(c("readxl","ggplot2"))
  stopifnot(all(c("election","prepared_file") %in% names(inputs)))
  stopifnot(all(TURNOUT_DEFINITIONS %in% c("A","B")))
  stopifnot(all(GRAPH_LANGUAGES %in% c("EN","SR")))
  stopifnot(all(GEOGRAPHIC_LEVELS %in% c("national","district","municipality")))
  if (!all(P_THRESHOLDS>0 & P_THRESHOLDS<100)) stop("All P_THRESHOLDS must be within (0,100)")
  dir.create(out_dir,recursive=TRUE,showWarnings=FALSE)
  config <- data.frame(parameter=c("module","version","source_worksheet","turnout_definitions",
    "p_thresholds","min_neighborhood_stations","min_small_large","ellipse_confidence",
    "permutation_scope","permutation_reps","reference_standardization"),
    value=c("voter_rigging","0.1.1",DATA_SHEET,paste(TURNOUT_DEFINITIONS,collapse=";"),
     paste(P_THRESHOLDS,collapse=";"),MIN_NEIGHBORHOOD_STATIONS,MIN_SMALL_LARGE_STATIONS,
     ELLIPSE_CONFIDENCE,PERMUTATION_SCOPE,PERMUTATION_REPS,
     "UNAVAILABLE: no verified comparable international reference set"))
  vr_write(config,file.path(out_dir,"run_configuration.csv"))
  manifests <- list(); m <- 0L; perm_summary <- list(); perm_draws <- list()
  national_D <- list(); national_c <- list()
  for(i in seq_len(nrow(inputs))) {
    election <- inputs$election[i]; path <- inputs$prepared_file[i]
    message("[VoterRigging] Reading ",election,": ",path)
    raw <- vr_read_master(path,DATA_SHEET)
    for(def in TURNOUT_DEFINITIONS) {
      prep <- vr_prepare(raw,election,WINNER_VOTES_FIELD,WINNER_FIELD_FALLBACKS,def)
      z <- vr_standardize(prep,MIN_NEIGHBORHOOD_STATIONS)
      ellipse <- vr_ellipse(z,ELLIPSE_CONFIDENCE)
      d <- ellipse$rows
      dest <- file.path(out_dir,election,paste0("definition_",def))
      dir.create(dest,recursive=TRUE,showWarnings=FALSE)
      # Preserve all Master rows, including QC rejected rows, with explicit reason.
      stations <- d[,c("Station_key","District_code","District","Municipality_code",
        "Municipality","E","B","C","W","winner_source_field","turnout",
        "winner_share","base_ok","peer_mean_t","peer_sd_t","peer_mean_v","peer_sd_v",
        "z_t","z_v","n_neighbors","neighborhood_n","standardized_ok","mahalanobis2","ellipse_ok","qc_reason"),drop=FALSE]
      vr_write(stations,file.path(dest,"station_level_qc.csv"))
      base_ids <- paste(d$District_code[d$base_ok],d$Municipality_code[d$base_ok],sep="|")
      nh_counts <- table(base_ids)
      n_eligible_neighborhoods <- sum(nh_counts >= MIN_NEIGHBORHOOD_STATIONS)
      original_size_criteria <- sum(d$base_ok)>1000 && n_eligible_neighborhoods>100
      qc <- data.frame(election=election,definition=def,raw_rows=nrow(d),
        base_ok=sum(d$base_ok),too_small_registered=sum(d$base_ok & d$E<100,na.rm=TRUE),
        standardized_ok=sum(d$standardized_ok),ellipse_ok=sum(d$ellipse_ok),
        n_municipal_neighborhoods=length(nh_counts),
        n_neighborhoods_meeting_minimum=n_eligible_neighborhoods,
        meets_original_national_sample_size_conditions=original_size_criteria,
        ellipse_status=ellipse$status)
      vr_write(qc,file.path(dest,"quality_summary.csv"))
      ellipse_params <- data.frame(
        ellipse_status=ellipse$status, confidence=ELLIPSE_CONFIDENCE,
        chi_square_cutoff=if(ellipse$status=="OK") ellipse$cutoff else NA_real_,
        mean_z_turnout=if(ellipse$status=="OK") ellipse$center[1] else NA_real_,
        mean_z_votes=if(ellipse$status=="OK") ellipse$center[2] else NA_real_,
        covariance_tt=if(ellipse$status=="OK") ellipse$covariance[1,1] else NA_real_,
        covariance_tv=if(ellipse$status=="OK") ellipse$covariance[1,2] else NA_real_,
        covariance_vv=if(ellipse$status=="OK") ellipse$covariance[2,2] else NA_real_)
      vr_write(ellipse_params,file.path(dest,"ellipse_parameters.csv"))
      areas <- vr_areas(d,GEOGRAPHIC_LEVELS,DISTRICT_CODES,MUNICIPALITY_CODES)
      for(area in areas) {
        subset_all <- d[area$mask,,drop=FALSE]
        subset_filtered <- subset_all[subset_all$ellipse_ok,,drop=FALSE]
        adir <- file.path(dest,area$level,vr_slug(area$key))
        dir.create(adir,recursive=TRUE,showWarnings=FALSE)
        curves <- vr_curve(subset_filtered,P_THRESHOLDS,MIN_SMALL_LARGE_STATIONS)
        curves$election <- election
        curves$definition <- def
        curves$level <- area$level
        curves$area <- area$key
        # Don't imply an absent international reference is numerically zero.
        curves$delta_reference <- NA_real_
        curves$reference_status <- "NOT_AVAILABLE"
        vr_write(curves,file.path(adir,"D_by_size_threshold.csv"))
        # Fig.4B uses all arithmetically valid station votes, no ellipse trim.
        cum <- vr_cumulative(subset_all)
        if(nrow(cum)) {
          cum$election <- election; cum$level <- area$level; cum$area <- area$key
        }
        vr_write(cum,file.path(adir,"cumulative_vote_share.csv"))
        pd <- curves[curves$status=="OK" & is.finite(curves$D),,drop=FALSE]
        npng <- 0L
        for(lang in GRAPH_LANGUAGES) {
          plotD <- vr_plot_D(curves,lang=lang)
          plotC <- vr_plot_cumulative(cum,lang=lang)
          if(vr_save_plot(plotD,file.path(adir,paste0("Figure4A_D_",lang,".png")),dpi=PLOT_DPI)) npng <- npng+1L
          if(vr_save_plot(plotC,file.path(adir,paste0("Figure4B_cumulative_",lang,".png")),dpi=PLOT_DPI)) npng <- npng+1L
          if(vr_save_combined(plotD,plotC,file.path(adir,paste0("Figure4_style_",lang,".png")),dpi=PLOT_DPI)) npng <- npng+1L
        }
        status <- if(any(curves$status=="OK")) "PASS" else "SKIP_D"
        reason <- if(status=="PASS") "" else "Insufficient small/large groups or no valid standardized records"
        m <- m+1L
        manifests[[m]] <- vr_manifest_entry(election,def,area,status,nrow(subset_all),
              sum(subset_all$standardized_ok),sum(subset_all$ellipse_ok),nrow(pd),nrow(cum),npng,reason)
        if(area$level=="national") {
          national_D[[paste(election,def,sep="_")]] <- curves
          if(def==TURNOUT_DEFINITIONS[1] && nrow(cum)) national_c[[election]] <- cum
        }
        if(isTRUE(RUN_EXPLORATORY_PERMUTATIONS) && area$level==PERMUTATION_ONLY_LEVEL &&
           nrow(subset_filtered) >= 20L) {
          # Exactly one null curve per p. Repeated randomisation labels conditional
          # on original z-scores; not the original accepted/rejected region.
          for(p in PERMUTATION_THRESHOLDS) {
            prm <- vr_permutation(subset_filtered,p,PERMUTATION_REPS,
                       RANDOM_SEED+match(election,inputs$election)*1000L+
                       (if(def=="A") 0L else 20000L)+as.integer(p),
                       scope=PERMUTATION_SCOPE)
            summary <- data.frame(election=election,definition=def,level=area$level,
              area=area$key,p=p,observed_D=prm$obs$D,
              empirical_tail_probability=prm$p_empirical,
              permutation_scope=PERMUTATION_SCOPE,npermutations=PERMUTATION_REPS,
              inference="EXPLORATORY_NOT_ORIGINAL_DELTA")
            perm_summary[[length(perm_summary)+1L]] <- summary
            if(nrow(prm$draws)) {
              tmp <- prm$draws
              tmp$election <- election; tmp$definition <- def
              tmp$level <- area$level; tmp$area <- area$key; tmp$p <- p
              perm_draws[[length(perm_draws)+1L]] <- tmp
            }
          }
        }
      }
    }
  }
  if(length(manifests)) vr_write(do.call(rbind,manifests),file.path(out_dir,"export_manifest.csv"))
  if(length(perm_summary)) vr_write(do.call(rbind,perm_summary),file.path(out_dir,"permutation_summary.csv"))
  if(length(perm_draws)) vr_write(do.call(rbind,perm_draws),file.path(out_dir,"permutation_draws.csv"))
  # Combined national Figure 4-style (multiple Serbian elections). Separate
  # A/B panels because turnout denominator changes D, but NOT cumulative votes.
  if(length(national_D) && length(national_c)) {
    curves_cum <- do.call(rbind,national_c)
    for(def in TURNOUT_DEFINITIONS) {
      curves_D <- national_D[grepl(paste0("_",def,"$"),names(national_D))]
      if(!length(curves_D)) next
      long_D <- do.call(rbind,curves_D)
      for(lang in GRAPH_LANGUAGES) {
        gA <- vr_plot_D(long_D,lang,TRUE)
        gB <- vr_plot_cumulative(curves_cum,lang,TRUE)
        vr_save_plot(gA,file.path(out_dir,paste0("Figure4A_comparison_",def,"_",lang,".png")),dpi=PLOT_DPI)
        vr_save_plot(gB,file.path(out_dir,paste0("Figure4B_comparison_",lang,".png")),dpi=PLOT_DPI)
        vr_save_combined(gA,gB,file.path(out_dir,paste0("Figure4_style_comparison_",def,"_",lang,".png")),dpi=PLOT_DPI)
      }
    }
  }
  message("[VoterRigging] Generated descriptive D(p), cumulative series and CSV diagnostics. ",
          "No international-standardised delta(p) or reference acceptance region was estimated.")
  invisible(if(length(manifests)) do.call(rbind,manifests) else data.frame())
}

if(isTRUE(RUN_NOW) && Sys.getenv("EF_VOTER_RIGGING_TEST_MODE") != "1") vr_run()
