# Core calculations for approximate_normality. All units are polling stations.
an_require <- function(pkgs) {
  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly=TRUE)]
  if (length(missing)) stop('Install these R packages: ', paste(missing,collapse=', '),call.=FALSE)
}
an_num <- function(x) suppressWarnings(as.numeric(x))
an_id <- function(x,width=NULL) {
  y <- trimws(as.character(x)); y[is.na(x) | y==''] <- NA_character_
  y <- sub('\\.0$','',y)
  if (!is.null(width)) { i <- !is.na(y) & grepl('^[0-9]+$',y); y[i] <- sprintf(paste0('%0',width,'d'),as.integer(y[i])) }
  y
}
an_slug <- function(x) {
  v <- gsub('[^A-Za-z0-9_-]+','_',as.character(x))
  substr(gsub('_+','_',v),1L,90L)
}
an_write <- function(x,path) {
  dir.create(dirname(path),recursive=TRUE,showWarnings=FALSE)
  utils::write.csv(x,path,row.names=FALSE,na='',fileEncoding='UTF-8')
}
an_label <- function(election,lang='EN') {
  s <- gsub('_',' ',as.character(election),fixed=TRUE)
  if (lang=='SR') {
    s <- sub('^presidential ','Predsednički ',s)
    s <- sub('^parliamentary ','Parlamentarni ',s)
  }
  s
}
an_pick_winner <- function(d,election,field,fallbacks) {
  if (field %in% names(d)) return(field)
  f <- fallbacks[[election]]
  if (is.null(f) || !(f %in% names(d)))
    stop('Winner column missing for ',election,'. Set WINNER_VOTES_FIELD or WINNER_FIELD_FALLBACKS explicitly; check Options sheet.')
  message('[ApproxNormality] ',election,': fallback winner field ',f,'; verify against Options sheet.')
  f
}
an_read_master <- function(path,sheet='Master') {
  an_require('readxl')
  if (!file.exists(path)) stop('Prepared workbook not found: ',path)
  if (!(sheet %in% readxl::excel_sheets(path))) stop('Required sheet not found: ',sheet,' in ',path)
  as.data.frame(readxl::read_excel(path,sheet=sheet),stringsAsFactors=FALSE)
}
# E/N=registered electorate. W=winner votes. Original 2012 definition uses
# nu=log(W/(E-W)), not the log of (valid - winner)/winner.
an_prepare <- function(d,election,field='Winner_votes',fallbacks=list()) {
  required <- c('Station_key','District_code','Municipality_code','E','B','C')
  missing <- setdiff(required,names(d))
  if (length(missing)) stop('Master missing columns: ',paste(missing,collapse=', '))
  picked <- an_pick_winner(d,election,field,fallbacks)
  d$Station_key <- an_id(d$Station_key)
  d$District_code <- an_id(d$District_code,2L)
  d$Municipality_code <- an_id(d$Municipality_code)
  if (!'District' %in% names(d)) d$District <- d$District_code
  if (!'Municipality' %in% names(d)) d$Municipality <- d$Municipality_code
  if (!'Size' %in% names(d)) d$Size <- NA_character_
  d$District <- as.character(d$District); d$Municipality <- as.character(d$Municipality)
  d$Size <- as.character(d$Size)
  d$E <- an_num(d$E); d$B <- an_num(d$B); d$C <- an_num(d$C); d$W <- an_num(d[[picked]])
  if (anyDuplicated(d$Station_key[!is.na(d$Station_key)])) stop('Duplicate station keys detected: inspect Master.')
  why <- rep('',nrow(d))
  append_reason <- function(flag,reason) {
    index <- which(flag %in% TRUE)
    if (length(index)) why[index] <<- ifelse(nzchar(why[index]),paste(why[index],reason,sep=';'),reason)
  }
  append_reason(is.na(d$Station_key) | is.na(d$District_code) | is.na(d$Municipality_code),'MISSING_ID')
  finite <- is.finite(d$E) & is.finite(d$B) & is.finite(d$C) & is.finite(d$W)
  append_reason(!finite,'MISSING_COUNTS')
  counts <- finite & d$E>=1 & d$B>=0 & d$C>=d$B & d$C<=d$E & d$W>=0 & d$W<=d$B &
    d$E==floor(d$E) & d$B==floor(d$B) & d$C==floor(d$C) & d$W==floor(d$W)
  append_reason(finite & !counts,'INVALID_COUNTS')
  append_reason(counts & d$W==0,'UNDEFINED_LOG_W_ZERO')
  append_reason(counts & d$W>=d$E,'UNDEFINED_LOG_W_GE_E')
  ok <- !nzchar(why)
  d$nu <- NA_real_
  d$nu[ok] <- log(d$W[ok] / (d$E[ok] - d$W[ok]))
  d$log_defined <- ok
  d$primary_ok <- ok & d$E>=100
  d$sensitivity_under100_ok <- ok & d$E<100
  # E<100 is not a QC failure; it is intentionally excluded only from the primary analysis.
  d$qc_reason <- ifelse(ok,ifelse(d$E<100,'ELIGIBLE_UNDER100_SENSITIVITY','OK'),why)
  d$winner_source_field <- picked
  d$election <- election
  d
}
an_moments <- function(x) {
  x <- x[is.finite(x)]; n <- length(x)
  if (n<3L) return(data.frame(n=n,mean=NA_real_,sd=NA_real_,skewness=NA_real_,kurtosis=NA_real_,
                               excess_kurtosis=NA_real_,jarque_bera=NA_real_,jb_p_value=NA_real_))
  mu <- mean(x); m2 <- mean((x-mu)^2)
  s <- stats::sd(x)
  skew <- if (m2>0) mean((x-mu)^3)/m2^(1.5) else NA_real_
  kurt <- if (m2>0) mean((x-mu)^4)/m2^2 else NA_real_
  jb <- if (is.finite(skew) && is.finite(kurt)) n/6*(skew^2+(kurt-3)^2/4) else NA_real_
  data.frame(n=n,mean=mu,sd=s,skewness=skew,kurtosis=kurt,
             excess_kurtosis=kurt-3,jarque_bera=jb,
             jb_p_value=if (is.finite(jb)) stats::pchisq(jb,df=2,lower.tail=FALSE) else NA_real_)
}
# Use the same standardisation for every subgroup in one election and area.
# z = (nu - mean(nu for E>=100))/sample_sd(nu for E>=100).
an_standardize <- function(d,min_reference=30L) {
  idx <- which(d$primary_ok & is.finite(d$nu))
  n <- length(idx)
  if (n < min_reference) return(list(ok=FALSE,reason='INSUFFICIENT_PRIMARY_N',n=n))
  mu <- mean(d$nu[idx]); s <- stats::sd(d$nu[idx])
  if (!is.finite(s) || s<=1e-12) return(list(ok=FALSE,reason='ZERO_OR_INVALID_PRIMARY_SD',n=n))
  d$z <- NA_real_
  good <- which(d$log_defined & is.finite(d$nu))
  d$z[good] <- (d$nu[good]-mu)/s
  list(ok=TRUE,rows=d,params=data.frame(n_reference=n,mean_nu=mu,sd_nu=s,
                                        mean_z_primary=mean(d$z[idx]),sd_z_primary=stats::sd(d$z[idx])))
}
# Rounded integer bin indices ensure stable 0-centred, fixed-width bins:
# index k has centre k*w, covers [k*w-w/2, k*w+w/2), including negatives.
# Ties at boundaries are assigned to the bin on the right by floor(x/w+.5).
an_hist <- function(x,width=.2,grid=NULL) {
  if (!is.finite(width) || width<=0) stop('BIN_WIDTH must be finite and positive')
  x <- x[is.finite(x)]; n <- length(x)
  if (is.null(grid)) {
    if (!n) return(data.frame(bin_index=integer(),x=numeric(),left=numeric(),right=numeric(),
                             count=integer(),n=integer(),probability=numeric(),normal_probability=numeric()))
    idx <- floor(x/width+0.5)
    grid <- seq.int(as.integer(min(idx)),as.integer(max(idx)))
  }
  grid <- as.integer(grid)
  counts <- tabulate(match(floor(x/width+.5),grid),nbins=length(grid))
  center <- grid*width
  left <- center-width/2; right <- center+width/2
  data.frame(bin_index=grid,x=center,left=left,right=right,count=as.integer(counts),n=as.integer(n),
             probability=if (n>0L) counts/n else NA_real_,
             normal_probability=stats::pnorm(right)-stats::pnorm(left))
}
# Append missing (zero-probability) bins to make curves continuous on a shared grid.
an_hist_groups <- function(d,group_map,width=.2) {
  maps <- group_map[vapply(group_map,function(x) sum(x,na.rm=TRUE)>0L,logical(1))]
  if (!length(maps)) return(data.frame())
  all_z <- unlist(lapply(maps,function(flag) d$z[which(flag & is.finite(d$z))]),use.names=FALSE)
  if (!length(all_z)) return(data.frame())
  idx <- floor(all_z/width+.5)
  grid <- seq.int(as.integer(min(idx)),as.integer(max(idx)))
  out <- lapply(names(maps),function(name) {
    h <- an_hist(d$z[which(maps[[name]] & is.finite(d$z))],width,grid)
    h$group <- name
    h
  })
  do.call(rbind,out)
}
an_areas <- function(d,levels=c('national'),district_codes=NULL,municipality_codes=NULL) {
  out <- list()
  if ('national' %in% levels) out[[length(out)+1L]] <- list(level='national',key='national',mask=rep(TRUE,nrow(d)),label='National')
  if ('district' %in% levels) {
    keys <- unique(d$District_code[!is.na(d$District_code)])
    if (!is.null(district_codes)) keys <- intersect(keys,an_id(district_codes,2L))
    for (k in keys) {
      ids <- which(!is.na(d$District_code) & d$District_code==k)
      nms <- unique(d$District[ids]); label <- if (length(nms) && nzchar(nms[1])) nms[1] else k
      out[[length(out)+1L]] <- list(level='district',key=k,mask=!is.na(d$District_code) & d$District_code==k,label=label)
    }
  }
  if ('municipality' %in% levels) {
    keys <- unique(d$Municipality_code[!is.na(d$Municipality_code)])
    if (!is.null(municipality_codes)) keys <- intersect(keys,an_id(municipality_codes))
    for (k in keys) {
      ids <- which(!is.na(d$Municipality_code) & d$Municipality_code==k)
      nms <- unique(d$Municipality[ids]); label <- if (length(nms) && nzchar(nms[1])) nms[1] else k
      out[[length(out)+1L]] <- list(level='municipality',key=k,mask=!is.na(d$Municipality_code) & d$Municipality_code==k,label=label)
    }
  }
  out
}
an_stats_row <- function(election,level,area,group,x) {
  cbind(data.frame(election=election,level=level,area=area,group=group),an_moments(x))
}
