# Election Forensics R Toolkit — voter_rigging
# Source-aligned core routines (Jimenez, Hidalgo & Klimek, 2017).
# NO significance claim without independent, comparable election reference curves.

vr_require <- function(pkgs) {
  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) stop("Install missing R packages: ", paste(missing, collapse=", "), call. = FALSE)
}
vr_num <- function(x) suppressWarnings(as.numeric(x))
vr_id <- function(x, width=NULL) {
  y <- trimws(as.character(x))
  y[is.na(x) | !nzchar(y)] <- NA_character_
  y <- sub("\\.0$", "", y)
  if (!is.null(width)) {
    z <- !is.na(y) & grepl("^[0-9]+$",y)
    y[z] <- sprintf(paste0("%0",width,"d"), as.integer(y[z]))
  }
  y
}
vr_slug <- function(x) {
  v <- gsub("[^A-Za-z0-9_-]+", "_", as.character(x))
  substr(gsub("_+", "_", v), 1L, 90L)
}
vr_assert_cols <- function(d, names_needed) {
  missing <- setdiff(names_needed, names(d))
  if (length(missing)) stop("Missing prepared Master columns: ",
                            paste(missing, collapse=", "), call. = FALSE)
}
vr_read_master <- function(filepath, sheet="Master") {
  vr_require("readxl")
  if (!file.exists(filepath)) stop("Missing prepared RZS workbook: ", filepath)
  if (!sheet %in% readxl::excel_sheets(filepath))
    stop("Cannot find worksheet '",sheet,"' in ",filepath)
  as.data.frame(readxl::read_excel(filepath, sheet=sheet))
}
vr_winner_col <- function(d, election, explicit_field, fallback_by_election) {
  if (explicit_field %in% names(d)) return(explicit_field)
  fallback <- fallback_by_election[[election]]
  if (is.null(fallback) || !(fallback %in% names(d)))
    stop("Missing winner field '",explicit_field,"'. Fallback '",fallback,
         "' also unavailable for ",election,". Confirm the nationally selected winner and the prepared Master schema.")
  message("[VoterRigging] ",election,": using explicitly configured winner field ",fallback,
          " (verify national winner in Options worksheet)")
  fallback
}

# Keep even E<100 when arithmetically valid. No Eligible_contour/Eligible_primary
# flags are reused: those may exclude very small stations by design.
vr_prepare <- function(d, election, winner_field="Winner_votes", fallbacks=list(),
                       definition="A") {
  if (!definition %in% c("A","B")) stop("definition must be A or B")
  required <- c("Station_key","District_code","Municipality_code","E","B","C")
  vr_assert_cols(d, required)
  source_field <- vr_winner_col(d,election,winner_field,fallbacks)
  d$Station_key <- vr_id(d$Station_key)
  d$District_code <- vr_id(d$District_code,2L)
  d$Municipality_code <- vr_id(d$Municipality_code)
  d$E <- vr_num(d$E); d$B <- vr_num(d$B); d$C <- vr_num(d$C)
  d$W <- vr_num(d[[source_field]])
  if (!"District" %in% names(d)) d$District <- d$District_code
  if (!"Municipality" %in% names(d)) d$Municipality <- d$Municipality_code
  d$District <- as.character(d$District)
  d$Municipality <- as.character(d$Municipality)
  dup <- duplicated(d$Station_key) & !is.na(d$Station_key)
  dup <- dup | (duplicated(d$Station_key, fromLast=TRUE) & !is.na(d$Station_key))
  if (any(dup)) stop("Duplicate Station_key: cannot safely use these as polling station IDs")
  reasons <- rep("",nrow(d))
  append_reason <- function(flag, msg) {
    ix <- which(flag %in% TRUE)
    if (length(ix)) reasons[ix] <<- ifelse(nzchar(reasons[ix]),
                                               paste(reasons[ix],msg,sep=";"),msg)
  }
  missing_key <- is.na(d$Station_key) | is.na(d$District_code) | is.na(d$Municipality_code)
  append_reason(missing_key,"MISSING_GEOGRAPHIC_KEY")
  missing_num <- !is.finite(d$E) | !is.finite(d$B) | !is.finite(d$C) | !is.finite(d$W)
  append_reason(missing_num,"MISSING_OR_NONFINITE_COUNTS")
  invalid <- !missing_num & (d$E < 1 | d$B <= 0 | d$C < d$B | d$C > d$E |
                            d$W < 0 | d$W > d$B | d$E != floor(d$E) |
                            d$B != floor(d$B) | d$C != floor(d$C) |
                            d$W != floor(d$W))
  append_reason(invalid,"INVALID_COUNTS")
  d$turnout <- if (definition=="A") d$B/d$E else d$C/d$E
  d$winner_share <- d$W/d$B
  bad_rates <- !missing_num & !invalid &
    (!is.finite(d$turnout) | !is.finite(d$winner_share) |
       d$turnout < 0 | d$turnout > 1 | d$winner_share < 0 | d$winner_share > 1)
  append_reason(bad_rates,"INVALID_RATES")
  d$base_ok <- !nzchar(reasons)
  d$qc_reason <- ifelse(d$base_ok,"OK",reasons)
  d$winner_source_field <- source_field
  d
}

# Each neighborhood must have >=10 eligible stations: each target therefore
# has at least 9 OTHER eligible stations (leave-one-out).
vr_loo <- function(x, ids, min_neighborhood=10L) {
  z <- rep(NA_real_, length(x)); nref <- integer(length(x))
  nhood <- rep(0L, length(x))
  peer_m <- rep(NA_real_,length(x)); peer_s <- rep(NA_real_,length(x))
  ok <- is.finite(x) & !is.na(ids) & nzchar(ids)
  for (idx in split(which(ok),ids[ok], drop=TRUE)) {
    v <- x[idx]; n <- length(v)
    nref[idx] <- n-1L; nhood[idx] <- n
    if (n < min_neighborhood || n < 3L) next
    peer_n <- n-1L
    sx <- sum(v); sx2 <- sum(v*v)
    peer_sum <- sx-v
    peer_mean <- peer_sum/peer_n
    peer_var <- (sx2-v*v - peer_sum^2/peer_n)/(peer_n-1L)
    peer_var[peer_var < 0 & peer_var > -1e-9] <- 0
    good <- is.finite(peer_var) & peer_var > 1e-12
    tmp <- rep(NA_real_,n)
    tmp[good] <- (v[good]-peer_mean[good])/sqrt(peer_var[good])
    z[idx] <- tmp
    peer_m[idx[good]] <- peer_mean[good]
    peer_s[idx[good]] <- sqrt(peer_var[good])
  }
  list(z=z, neighbors=nref, neighborhood_n=nhood,
       neighbor_mean=peer_m,neighbor_sd=peer_s)
}

vr_standardize <- function(d, min_neighborhood=10L) {
  d$z_t <- NA_real_; d$z_v <- NA_real_
  d$peer_mean_t <- NA_real_; d$peer_sd_t <- NA_real_
  d$peer_mean_v <- NA_real_; d$peer_sd_v <- NA_real_
  d$n_neighbors <- 0L; d$neighborhood_n <- 0L
  i <- which(d$base_ok)
  if (!length(i)) {
    d$standardized_ok <- FALSE
    return(d)
  }
  ids <- paste(d$District_code[i],d$Municipality_code[i],sep="|")
  a <- vr_loo(d$turnout[i],ids,min_neighborhood)
  b <- vr_loo(d$winner_share[i],ids,min_neighborhood)
  d$z_t[i] <- a$z; d$z_v[i] <- b$z
  d$peer_mean_t[i] <- a$neighbor_mean; d$peer_sd_t[i] <- a$neighbor_sd
  d$peer_mean_v[i] <- b$neighbor_mean; d$peer_sd_v[i] <- b$neighbor_sd
  d$n_neighbors[i] <- pmin(a$neighbors,b$neighbors)
  d$neighborhood_n[i] <- a$neighborhood_n
  d$standardized_ok <- d$base_ok & is.finite(d$z_t) & is.finite(d$z_v)
  d$qc_reason[d$base_ok & d$neighborhood_n < min_neighborhood] <- "NEIGHBORHOOD_TOO_SMALL"
  d$qc_reason[d$base_ok & d$neighborhood_n >= min_neighborhood & !d$standardized_ok] <- "ZERO_REFERENCE_VARIANCE"
  d
}

# One global (country/election) elliptical filter; use sample mean + covariance
# and chi-square(2) 0.95 cutoff. No Gaussian claim is required for the z scores.
vr_ellipse <- function(d, conf=.95) {
  d$mahalanobis2 <- NA_real_; d$ellipse_ok <- FALSE
  ix <- which(d$standardized_ok)
  if(length(ix) < 4L) return(list(rows=d,status="INSUFFICIENT_STANDARDIZED_STATIONS"))
  x <- as.matrix(d[ix,c("z_t","z_v")])
  mu <- colMeans(x); sigma <- stats::cov(x)
  if (any(!is.finite(sigma)) || min(eigen(sigma,symmetric=TRUE,only.values=TRUE)$values) <= 1e-10)
    return(list(rows=d,status="SINGULAR_COVARIANCE"))
  md <- stats::mahalanobis(x, center=mu, cov=sigma)
  threshold <- stats::qchisq(conf,df=2)
  d$mahalanobis2[ix] <- md
  d$ellipse_ok[ix] <- md <= threshold
  d$qc_reason[d$standardized_ok & !d$ellipse_ok] <- "OUTSIDE_95_PERCENT_ELLIPSE"
  list(rows=d,status="OK",cutoff=threshold,center=mu,covariance=sigma)
}

# p-th percentile split as in supplement: E < Q_p = Small, E >= Q_p = Large.
# D(p) is distance between *coordinate-wise medians* (NOT KDE modes).
vr_d_at_p <- function(d,p,min_group=10L) {
  stopifnot(length(p)==1L, is.finite(p),p>0,p<100)
  g <- d[is.finite(d$E) & is.finite(d$z_t) & is.finite(d$z_v),,drop=FALSE]
  if(!nrow(g)) return(data.frame(p=p,cutoff=NA_real_,small_n=0L,large_n=0L,
    med_small_t=NA_real_,med_small_v=NA_real_,med_large_t=NA_real_,med_large_v=NA_real_,
    dx=NA_real_,dy=NA_real_,D=NA_real_,status="NO_ELIGIBLE_STATIONS"))
  cutoff <- as.numeric(stats::quantile(g$E,p/100,names=FALSE,type=7))
  small <- g[g$E < cutoff,,drop=FALSE]; large <- g[g$E >= cutoff,,drop=FALSE]
  ns <- nrow(small); nl <- nrow(large)
  if(min(ns,nl) < min_group) return(data.frame(p=p,cutoff=cutoff,small_n=ns,large_n=nl,
    med_small_t=NA_real_,med_small_v=NA_real_,med_large_t=NA_real_,med_large_v=NA_real_,
    dx=NA_real_,dy=NA_real_,D=NA_real_,status="INSUFFICIENT_GROUP"))
  ms <- c(stats::median(small$z_t),stats::median(small$z_v))
  ml <- c(stats::median(large$z_t),stats::median(large$z_v))
  shift <- ms-ml
  data.frame(p=p,cutoff=cutoff,small_n=ns,large_n=nl,
    med_small_t=ms[1],med_small_v=ms[2],med_large_t=ml[1],med_large_v=ml[2],
    dx=shift[1],dy=shift[2],D=sqrt(sum(shift^2)),status="OK")
}
vr_curve <- function(d,thresholds=seq(.5,90,by=.5),min_group=10L) {
  ans <- lapply(thresholds,function(p) vr_d_at_p(d,p,min_group))
  do.call(rbind,ans)
}

# Fig 4B: Sort by registered electorate descending and aggregate VOTES, not
# unweighted percentages: sum(W_i) / sum(B_i) for first i stations.
# Tie breaking by unique polling-station key produces deterministic ranks.
vr_cumulative <- function(d) {
  g <- d[d$base_ok & is.finite(d$E) & is.finite(d$W) & is.finite(d$B),
          c("Station_key","E","B","W"),drop=FALSE]
  if (!nrow(g)) return(data.frame(rank=integer(0),station_key=character(0),
      station_electorate=numeric(0),cumulative_registered=numeric(0),
      cumulative_valid=numeric(0),cumulative_winner=numeric(0),
      cumulative_winner_share=numeric(0),stringsAsFactors=FALSE))
  g <- g[order(-g$E,g$Station_key),,drop=FALSE]
  data.frame(rank=seq_len(nrow(g)),station_key=g$Station_key,
    station_electorate=g$E,cumulative_registered=cumsum(g$E),
    cumulative_valid=cumsum(g$B),cumulative_winner=cumsum(g$W),
    cumulative_winner_share=cumsum(g$W)/cumsum(g$B),
    stringsAsFactors=FALSE)
}

vr_areas <- function(d, geographic_levels, district_codes=NULL, municipality_codes=NULL) {
  if (!is.null(district_codes)) {
    bad <- setdiff(vr_id(district_codes,2L),unique(stats::na.omit(d$District_code)))
    if(length(bad)) stop("Unknown DISTRICT_CODES: ",paste(bad,collapse=", "))
  }
  if (!is.null(municipality_codes)) {
    bad <- setdiff(vr_id(municipality_codes),unique(stats::na.omit(d$Municipality_code)))
    if(length(bad)) stop("Unknown MUNICIPALITY_CODES: ",paste(bad,collapse=", "))
  }
  areas <- list()
  add <- function(level,key,label,mask) {
    areas[[length(areas)+1L]] <<- list(level=level,key=key,label=label,
                                        mask=mask & !is.na(mask))
  }
  if("national" %in% geographic_levels) add("national","Serbia","Serbia",rep(TRUE,nrow(d)))
  if("district" %in% geographic_levels) {
    for(id in sort(unique(stats::na.omit(d$District_code)))) {
      if(!is.null(district_codes) && !id %in% vr_id(district_codes,2L)) next
      ix <- which(d$District_code==id)
      nm <- as.character(d$District[ix[1]])
      add("district",id,paste0("District ",id," (",nm,")"),d$District_code==id)
    }
  }
  if("municipality" %in% geographic_levels) {
    ids <- unique(d[!is.na(d$Municipality_code) & !is.na(d$District_code),
                    c("District_code","Municipality_code","Municipality"),drop=FALSE])
    for(j in seq_len(nrow(ids))) {
      dist <- ids$District_code[j]; code <- ids$Municipality_code[j]
      if(!is.null(district_codes) && !dist %in% vr_id(district_codes,2L)) next
      if(!is.null(municipality_codes) && !code %in% vr_id(municipality_codes)) next
      add("municipality",paste(dist,code,sep="_"),paste0("Municipality ",code," (",ids$Municipality[j],")"),
          d$District_code==dist & d$Municipality_code==code)
    }
  }
  areas
}

# Supplementary modified Thompson tau: standalone implementation for future
# international reference work; NOT applied to just the 3 Serbian elections.
vr_thompson_tau <- function(x,alpha=.05,min_n=3L) {
  if(any(!is.finite(x))) stop("Finite reference distances only")
  retained <- seq_along(x); dropped <- integer(0); trace <- list(); step <- 0L
  while(length(retained)>=max(3L,min_n)) {
    y <- x[retained]; n <- length(y); s <- stats::sd(y)
    if(!is.finite(s) || s<=0) break
    t <- stats::qt(1-alpha/2,df=n-2)
    crit <- t*(n-1)/sqrt(n*(n-2+t^2))
    dev <- abs(y-mean(y))/s
    k <- which.max(dev); step <- step+1L
    isout <- dev[k] > crit
    trace[[step]] <- data.frame(step=step,n=n,item=retained[k],
                                deviation=dev[k],critical=crit,removed=isout)
    if(!isout) break
    dropped <- c(dropped,retained[k]); retained <- retained[-k]
  }
  list(retained=retained,dropped=dropped,
       trace=if(length(trace)) do.call(rbind,trace) else data.frame())
}

# Supplement: permute electorate-size labels, keep observed z scores fixed.
# This is an EXPLORATORY diagnostic, not delta(p) nor its accepted region.
vr_permutation <- function(g,p,nperm=199L,seed=1129L,scope="within_municipality") {
  if(!scope %in% c("within_municipality","global")) stop("Invalid scope")
  obs <- vr_d_at_p(g,p,min_group=10L)
  if(obs$status!="OK") return(list(obs=obs,draws=data.frame(),p_empirical=NA_real_))
  set.seed(seed)
  draws <- numeric(nperm)
  for(b in seq_len(nperm)) {
    pdat <- g
    if(scope=="global") {
      pdat$E <- sample(pdat$E,length(pdat$E))
    } else {
      ids <- paste(pdat$District_code,pdat$Municipality_code,sep="|")
      for(idx in split(seq_len(nrow(pdat)),ids))
        if(length(idx)>1L) pdat$E[idx] <- sample(pdat$E[idx],length(idx))
    }
    res <- vr_d_at_p(pdat,p,min_group=10L)
    draws[b] <- res$D
  }
  ok <- is.finite(draws)
  empirical <- if(any(ok)) (1+sum(draws[ok]>=obs$D))/(1+sum(ok)) else NA_real_
  list(obs=obs,draws=data.frame(iteration=seq_len(nperm),D_random=draws),
       p_empirical=empirical)
}
