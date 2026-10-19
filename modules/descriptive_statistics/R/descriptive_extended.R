# Election Forensics R Toolkit: extended descriptive / prosirena deskriptivna analiza
# EN: Eight reporting labels; not eight disjoint populations.
# SR: Osam oznaka grupa; to nisu osam medjusobno iskljucivih populacija.
# EN: `All` includes QC-accepted <100 stations; analytic size strata come from Main.
# SR: `All` ukljucuje proverena BM ispod 100; ostale grupe koriste Main.

# EN/SR: Keep previous correlation IDs D_01..07/M_01..07 stable; append Main as _08.
size_labels <- c('All','Less than 100','Small','Middle','Large','JHK Small','JHK Large','100 or more')
# EN/SR: Reader-friendly presentation order (Main immediately after All).
size_report_order <- c('All','100 or more','Less than 100','Small','Middle','Large','JHK Small','JHK Large')
order_size_rows <- function(x) {
  if (!nrow(x) || !('Size_group' %in% names(x))) return(x)
  x[order(match(as.character(x$Size_group),size_report_order),
          if ('Area_key' %in% names(x)) as.character(x$Area_key) else rep('',nrow(x))),,drop=FALSE]
}

# EN/SR: Explicit eligibility for separate sub-100 descriptive analysis.
# SR: BM ispod 100 nisu automatski pogodna ako nisu prosla QC.
select_under100 <- function(master, main) {
  required <- c('Station_key','Under_100','Invalid_numeric','Admin_no_ballots',
                'Admin_invalid','E','A','C','I','B','Winner_votes','Second_votes')
  if (length(setdiff(required,names(master))))
    stop('Master lacks fields needed for under-100 QC: ',
         paste(setdiff(required,names(master)),collapse=', '))
  flag <- function(x) !is.na(x) & as.logical(x)
  under <- flag(master$Under_100) & !flag(master$Invalid_numeric) &
           !flag(master$Admin_no_ballots) & !flag(master$Admin_invalid) &
           is.finite(suppressWarnings(as.numeric(master$E))) &
           as.numeric(master$E) > 0 & as.numeric(master$E) < 100
  sub <- master[under,,drop=FALSE]
  if (!nrow(sub)) return(sub)
  if (anyDuplicated(sub$Station_key) || any(sub$Station_key %in% main$Station_key))
    stop('Duplicate/overlapping Master/Main station keys')
  core <- c('E','A','C','I','B','Winner_votes','Second_votes')
  oc <- grep('^Option_[0-9]+_votes$',names(sub),value=TRUE)
  if (!length(oc)) stop('Master missing Option vote fields')
  for (nm in c(core,oc)) sub[[nm]] <- suppressWarnings(as.numeric(sub[[nm]]))
  if (anyNA(sub[,c(core,oc),drop=FALSE]) ||
      any(vapply(sub[,c(core,oc),drop=FALSE], function(z) any(!is.finite(z)|z<0|z!=floor(z)), logical(1))))
    stop('Master under-100 QC and actual numeric content disagree')
  if (any(sub$C != sub$I+sub$B) || any(sub$C>sub$E) ||
      any(sub$A>sub$E) ||
      any(rowSums(sub[,oc,drop=FALSE])!=sub$B))
    stop('Under-100 source counts do not reconcile')
  sub
}

# EN: Use Main for analytical classifications; Master for under-100 QC.
# SR: Main je osnovni analiticki uzorak; Master daje posebnu grupu ispod 100.
prepare_extended_groups <- function(master, main, options, election_type, year) {
  main <- validate_prepared(main,election_type,year,'Main')
  options <- validate_options(main,options)
  if (!all(c('Station_key','Election_type','Year') %in% names(master)))
    stop('Master missing identity fields')
  if (any(as.character(master$Election_type)!=election_type) ||
      any(as.integer(master$Year)!=as.integer(year))) stop('Master election mismatch')
  if (anyDuplicated(master$Station_key)) stop('Duplicate Station_key in Master')
  if (!all(main$Station_key %in% master$Station_key))
    stop('Main contains stations absent from Master')
  under <- select_under100(master,main)
  {
    under$Station_turnout_pct <- ifelse(under$E>0,100*under$C/under$E,NA_real_)
    under$Station_winner_pct <- ifelse(under$B>0,100*under$Winner_votes/under$B,NA_real_)
    under$Station_invalid_pct <- ifelse(under$C>0,100*under$I/under$C,NA_real_)
  }
  combined <- rbind(main,under[,names(main),drop=FALSE])
  # Rbind may drop metadata attributes; station-level percentages are recomputed.
  combined$Station_turnout_pct <- ifelse(combined$E>0,100*combined$C/combined$E,NA_real_)
  combined$Station_winner_pct <- ifelse(combined$B>0,100*combined$Winner_votes/combined$B,NA_real_)
  combined$Station_invalid_pct <- ifelse(combined$C>0,100*combined$I/combined$C,NA_real_)
  groups <- list(
    'All'=combined,
    '100 or more'=main, # EN/SR: Exactly the canonical Main analytical sample (E >= 100).
    'Less than 100'=under,
    'Small'=main[main$Size=='Small',,drop=FALSE],
    'Middle'=main[main$Size=='Middle',,drop=FALSE],
    'Large'=main[main$Size=='Large',,drop=FALSE],
    'JHK Small'=main[main$Size_JHK=='Small',,drop=FALSE],
    'JHK Large'=main[main$Size_JHK=='Large',,drop=FALSE]
  )
  stopifnot(nrow(groups$Small)+nrow(groups$Middle)+nrow(groups$Large)==nrow(main),
            nrow(groups[['JHK Small']])+nrow(groups[['JHK Large']])==nrow(main),
            nrow(groups$All)==nrow(main)+nrow(under),
            nrow(groups[['100 or more']])==nrow(main),
            identical(as.character(groups[['100 or more']]$Station_key),
                      as.character(main$Station_key)))
  list(groups=groups, options=options, eligible_n=nrow(main),
       under100_n=nrow(under), input_n=nrow(master),
       other_excluded_n=nrow(master)-nrow(combined))
}


# EN: Robust, unweighted polling-station distribution. Outliers use Tukey's
# 1.5 x IQR rule within the reported subgroup; they are NOT fraud allegations.
# SR: Robusne mere po BM. Autlajeri su 1,5 x IQR van kvartila i nisu dokaz prevare.
dist_stats <- function(z, prefix) {
  z <- as.numeric(z); z <- z[is.finite(z)]
  fields <- c('N','Mean','Median','SD','Q1','Q3','IQR','P10','P90','Outlier_count','Outlier_pct')
  ans <- stats::setNames(rep(NA_real_,length(fields)),paste0(prefix,'_',fields))
  ans[1] <- length(z)
  if(!length(z)) return(ans)
  q <- as.numeric(stats::quantile(z,c(.10,.25,.50,.75,.90),names=FALSE,type=7))
  iq <- q[4]-q[2]
  outside <- sum(z < (q[2]-1.5*iq) | z > (q[4]+1.5*iq))
  ans[c(2,3,4,5,6,7,8,9,10,11)] <- c(mean(z),q[3],
     if(length(z)>1) stats::sd(z) else NA_real_,q[2],q[4],iq,q[1],q[5],
     outside,100*outside/length(z))
  ans
}

# EN: Tested joint polling-station turnout and nationally leading-option share.
# SR: Testirana korelacija izlaznosti i udela nacionalno prvoplasirane opcije po BM.
joint_stats <- function(turnout,share) {
  ok <- is.finite(turnout) & is.finite(share)
  x <- turnout[ok]; y <- share[ok]; n <- length(x)
  out <- c(Joint_N=n,Joint_Pearson_r=NA_real_,Joint_Pearson_p=NA_real_,
           Joint_Spearman_rho=NA_real_,Joint_Spearman_p=NA_real_)
  if(n<3 || length(unique(x))<2 || length(unique(y))<2) return(out)
  a <- suppressWarnings(stats::cor.test(x,y,method='pearson'))
  b <- suppressWarnings(stats::cor.test(x,y,method='spearman',exact=FALSE))
  out[c('Joint_Pearson_r','Joint_Pearson_p','Joint_Spearman_rho','Joint_Spearman_p')] <-
    c(unname(a$estimate),a$p.value,unname(b$estimate),b$p.value)
  out
}

add_robust_statistics <- function(row, dat) {
  st <- c(dist_stats(dat$E,'Electorate'),
          dist_stats(dat$Station_turnout_pct,'Turnout'),
          dist_stats(dat$Station_winner_pct,'Winner_share'),
          dist_stats(dat$Station_invalid_pct,'Invalid_share'),
          joint_stats(dat$Station_turnout_pct,dat$Station_winner_pct))
  for(nm in names(st)) row[[nm]] <- unname(st[[nm]])
  row
}

# EN: Formal comparisons are between DISJOINT groups in each classification.
#     KW: Small/Middle/Large; Wilcoxon: JHK Small vs JHK Large.
#     Apply BH corrections separately by geographical level/outcome/test family.
# SR: KW za tri disjunktne grupe; Vilkokson za dve JHK grupe; BH korekcija.
run_group_tests <- function(prepared) {
  dat <- do.call(rbind,prepared$groups[c('Small','Middle','Large')])
  if(!nrow(dat)) stop('No Main stations for formal comparisons')
  area_keys <- function(x,lvl) if(lvl=='National') rep('RS',nrow(x)) else
    if(lvl=='District') as.character(x$District_code) else
      paste(x$District_code,x$Municipality_code,sep='|')
  result <- list(); j <- 0L
  for(level in c('National','District','Municipality')) {
    key <- area_keys(dat,level)
    for(id in unique(key)) {
      d <- dat[key==id,,drop=FALSE]
      for(outcome in c('Station_turnout_pct','Station_winner_pct')) {
        for(test in c('Size_Kruskal_Wallis','JHK_Wilcoxon')) {
          values <- as.numeric(d[[outcome]])
          labels <- if(test=='Size_Kruskal_Wallis') as.character(d$Size) else
                    as.character(d$Size_JHK)
          valid <- is.finite(values) & !is.na(labels)
          values <- values[valid]; labels <- labels[valid]
          allowed <- if(test=='Size_Kruskal_Wallis') c('Small','Middle','Large') else c('Small','Large')
          counts <- vapply(allowed,function(z)sum(labels==z),integer(1))
          medians <- vapply(allowed,function(z) if(sum(labels==z))
            stats::median(values[labels==z]) else NA_real_,numeric(1))
          pval <- NA_real_; stat <- NA_real_
          if(sum(counts>0)>=2 && length(unique(values))>=2) {
            fit <- tryCatch(if(test=='Size_Kruskal_Wallis')
              stats::kruskal.test(values~factor(labels,levels=allowed)) else
              stats::wilcox.test(values~factor(labels,levels=allowed),exact=FALSE),
              error=function(e) NULL)
            if(!is.null(fit)) {
              pval <- as.numeric(fit$p.value)
              stat <- as.numeric(fit$statistic)
            }
          }
          j <- j+1L
          result[[j]] <- data.frame(Level=level,Area_key=id,
            Outcome=if(outcome=='Station_turnout_pct') 'Turnout_pct' else 'Winner_share_pct',
            Test=test,N_used=length(values),
            N_Small=counts[1],N_Middle=if(length(counts)==3)counts[2] else NA_integer_,
            N_Large=tail(counts,1),Median_Small=medians[1],
            Median_Middle=if(length(medians)==3)medians[2] else NA_real_,
            Median_Large=tail(medians,1),Statistic=stat,P_value=pval,
            stringsAsFactors=FALSE)
        }
      }
    }
  }
  out <- do.call(rbind,result); rownames(out)<-NULL
  out$BH_q_value <- NA_real_;out$Significant_nominal <- FALSE;out$Significant_BH <- FALSE
  for(lvl in unique(out$Level))for(oc in unique(out$Outcome))for(test in unique(out$Test)) {
    id <- which(out$Level==lvl & out$Outcome==oc & out$Test==test & is.finite(out$P_value))
    if(length(id)) out$BH_q_value[id] <- stats::p.adjust(out$P_value[id],method='BH')
  }
  out$Significant_nominal <- is.finite(out$P_value) & out$P_value<.05
  out$Significant_BH <- is.finite(out$BH_q_value) & out$BH_q_value<.05
  out
}

# EN/SR: Build aggregations by group at three reporting levels.
# SR: Isti nacionalni pragovi se koriste za sva geografska podrucja.
aggregate_extended <- function(prepared, level, election_type, year) {
  rows <- list(); votes <- list(); j <- 0L
  for (label in size_labels) {
    dat <- prepared$groups[[label]]
    if (!nrow(dat)) next
    keys <- area_groups(dat,level)
    for (idx in keys) {
      j <- j+1L
      meth <- if (startsWith(label,'JHK ')) 'Size_JHK' else
        if (label %in% c('Small','Middle','Large')) 'Size' else
          if (label=='Less than 100') 'Under_100_QC' else
            if (label=='100 or more') 'Main_eligible' else 'All_QC_valid'
      rr <- summarise_area(dat,idx,election_type,year,level,meth,label)
      # EN/SR: Local leader can differ from the national leading option.
      # SR: Lokalno prvoplasirana lista moze biti razlicita od nacionalne.
      option_cols <- as.character(prepared$options$Votes_field)
      tot <- vapply(option_cols,function(nm) sum(dat[[nm]][idx]),numeric(1))
      ord <- order(-tot,seq_along(tot))
      rr$Local_leader <- as.character(prepared$options$Option_name_SR_Lat[ord[1]])
      rr$Local_leader_votes <- tot[ord[1]]
      rr$Local_second_votes <- tot[ord[2]]
      rr$Local_margin_pct <- ratio_pct(tot[ord[1]]-tot[ord[2]],rr$Valid)
      shares <- if (rr$Valid>0) tot/rr$Valid else rep(NA_real_,length(tot))
      rr$Effective_number_options <- if(all(is.finite(shares)) && sum(shares^2)>0)
        1/sum(shares^2) else NA_real_
      rr$Mean_ballots_cast <- station_stat(dat$C[idx],'mean')
      rr$SD_ballots_cast <- station_stat(dat$C[idx],'sd')
      rr$Mean_valid <- station_stat(dat$B[idx],'mean')
      rr$SD_valid <- station_stat(dat$B[idx],'sd')
      rr$Mean_invalid <- station_stat(dat$I[idx],'mean')
      rr$SD_invalid <- station_stat(dat$I[idx],'sd')
      rr <- add_robust_statistics(rr,dat[idx,,drop=FALSE])
      rows[[j]] <- rr
      votes[[j]] <- summarise_options(dat,idx,rr,prepared$options,option_cols)
    }
  }
  s <- do.call(rbind,rows); v <- do.call(rbind,votes)
  s <- order_size_rows(s)
  v <- order_size_rows(v)
  rownames(s)<-NULL; rownames(v)<-NULL
  # EN/SR: Complete vote accounting for every area and every station-size group.
  vs <- aggregate(v$Votes,by=list(k=paste(v$Area_key,v$Size_group,sep='|')),FUN=sum)
  idx <- match(paste(s$Area_key,s$Size_group,sep='|'),vs$k)
  if(anyNA(idx) || any(vs$x[idx]!=s$Valid)) stop('Option vote accounting failed')
  list(summary=s,options=v)
}

# EN/SR: Two publication-ready summary tables, retained at full numeric precision.
make_summary_tables <- function(s) {
  id <- c('Area_key','Area_name','Size_group')
  count <- s[,c(id,'Polling_stations','Registered','Attendance','Ballots_cast',
                'Valid','Invalid','Mean_E','Median_E','SD_E'),drop=FALSE]
  perf <- s[,c(id,'Polling_stations','Turnout_pct','Invalid_per_cast_pct',
               'Winner_per_valid_pct','Runnerup_per_valid_pct','Local_margin_pct',
               'Effective_number_options','Mean_turnout_pct','SD_turnout_pct',
               'Mean_winner_share_pct','SD_winner_share_pct',
               'Mean_invalid_share_pct','SD_invalid_share_pct'),drop=FALSE]
  list(counts=count,performance=perf)
}

# EN: Make wide numeric area-level matrix for correlation analysis.
# SR: Korelacije se racunaju PREKO okruga/opstina, NE unutar jednog podrucja.
correlation_input <- function(summary, options_long, options_dictionary) {
  # EN: Keep the full typed variable schema when a group has zero areas.
  # SR: Sacuvati sve promenljive i kada grupa nema nijedan okrug/opstinu.
  # EN: Returning a zero-column data.frame() would break pairwise-output creation.
  fields <- c('Polling_stations','Registered','Attendance','Ballots_cast','Valid','Invalid',
              'Winner_votes','Runnerup_votes','Turnout_pct','Attendance_pct',
              'Valid_per_registered_pct','Invalid_per_cast_pct','Invalid_per_registered_pct',
              'Winner_per_valid_pct','Runnerup_per_valid_pct','Winner_per_registered_pct',
              'Local_margin_pct','Effective_number_options','Mean_E','SD_E',
              'Mean_turnout_pct','SD_turnout_pct','Mean_winner_share_pct',
              'Mean_invalid_share_pct')
  missing <- setdiff(c('Area_key',fields),names(summary))
  if(length(missing)) stop('Correlation input missing columns: ',
                          paste(missing,collapse=', '))
  x <- summary[,c('Area_key',fields),drop=FALSE]
  for (k in seq_len(nrow(options_dictionary))) {
    num <- sprintf('Option_%02d',as.integer(options_dictionary$Option_number[k]))
    d <- options_long[options_long$Option_number==options_dictionary$Option_number[k],,drop=FALSE]
    ii <- match(x$Area_key,d$Area_key)
    x[[paste0(num,'_votes')]] <- d$Votes[ii]
    x[[paste0(num,'_share_valid_pct')]] <- d$Share_valid_pct[ii]
    x[[paste0(num,'_share_registered_pct')]] <- d$Share_registered_pct[ii]
  }
  x
}

# EN: Two-sided Pearson p-values; asterisk denotes unadjusted 5% significance.
# SR: Dvostrani Pearson p; zvezdica oznacava nominalno p < 0.05.
# EN: BH q-values are supplied for exploratory multiple-testing control.
compute_correlation <- function(x, level, group_label, method='pearson') {
  cols <- setdiff(names(x),'Area_key')
  values <- as.matrix(x[,cols,drop=FALSE]); storage.mode(values)<-'double'
  m <- length(cols); nareas <- nrow(values)
  r <- matrix(NA_real_,m,m,dimnames=list(cols,cols))
  p <- r; n <- matrix(0L,m,m,dimnames=list(cols,cols))
  if (nareas) {
    ok <- is.finite(values)
    n <- crossprod(ok*1L)
    dimnames(n)<-list(cols,cols)
    if(nareas>=3L && m>=1L) {
      suppressWarnings(r <- stats::cor(values,use='pairwise.complete.obs',method=method))
      dimnames(r)<-list(cols,cols)
      r[n<3] <- NA_real_
      diag(r) <- ifelse(diag(n)>=3 & is.finite(diag(r)),1,NA_real_)
      den <- pmax(1e-15,1-pmin(r^2,1))
      tval <- abs(r)*sqrt(pmax(n-2,0)/den)
      p[,] <- 2*stats::pt(-tval,df=pmax(n-2,1))
      p[n<3 | !is.finite(r)] <- NA_real_
      p[abs(r)>=1 & !is.na(r) & n>=3] <- 0
      diag(p) <- NA_real_
    }
  }
  display <- matrix('',m,m,dimnames=list(cols,cols))
  keep <- which(is.finite(r),arr.ind=TRUE)
  if(nrow(keep)) for(i in seq_len(nrow(keep))) {
    a <- keep[i,1]; b <- keep[i,2]
    display[a,b] <- paste0(sprintf('%.3f',r[a,b]),
                           if(a!=b && is.finite(p[a,b]) && p[a,b]<0.05) '*' else '')
  }
  k <- which(upper.tri(r),arr.ind=TRUE)
  # EN: Match metadata lengths to pair count (including zero pairs).
  # SR: Broj redova oznaka mora odgovarati broju parova, cak i kada je nula.
  details <- data.frame(Level=rep(level,nrow(k)),
    Size_group=rep(group_label,nrow(k)),
    Variable_1=cols[k[,1]],Variable_2=cols[k[,2]],
    R=r[k],P_value=p[k],N_pairs=n[k],stringsAsFactors=FALSE)
  details$BH_q_value <- rep(NA_real_,nrow(details))
  valid <- which(is.finite(details$P_value))
  if(length(valid)) details$BH_q_value[valid] <- stats::p.adjust(details$P_value[valid],method='BH')
  details$Significant_5pct <- !is.na(details$P_value) & details$P_value<0.05
  list(display=display, r=r, p=p, n=n,details=details,areas=nareas)
}

# EN/SR: Exactly 16 matrices per election = 2 levels x 8 groups.
# EN/SR: D_08/M_08 are the newly added 100-or-more (Main) matrices.
# EN/SR: Previous D_01..07/M_01..07 IDs remain unchanged.
run_all_correlations <- function(level_data, options_dictionary) {
  out <- list(); details <- list(); metadata <- list(); j <- 0L
  for(lvl in c('District','Municipality')) for(label in size_labels) {
    j <- j+1L
    s <- level_data[[lvl]]$summary
    s <- s[s$Size_group==label,,drop=FALSE]
    v <- level_data[[lvl]]$options
    v <- v[v$Size_group==label,,drop=FALSE]
    xx <- correlation_input(s,v,options_dictionary)
    cr <- compute_correlation(xx,lvl,label)
    key <- sprintf('%s_%02d',if(lvl=='District') 'D' else 'M',match(label,size_labels))
    out[[key]] <- cr
    details[[j]] <- cr$details
    metadata[[j]] <- data.frame(Matrix=key,Level=lvl,Size_group=label,
        Areas=cr$areas,Variables=nrow(cr$display),
        N_tested=sum(is.finite(cr$details$P_value)),
        Significant_nominal=sum(cr$details$Significant_5pct,na.rm=TRUE),
        Significant_BH=sum(is.finite(cr$details$BH_q_value) & cr$details$BH_q_value<0.05))
  }
  stopifnot(length(out)==16L)
  list(matrices=out, details=do.call(rbind,details),overview=do.call(rbind,metadata))
}


# EN: Joint turnout x vote-share 10-pp bins, with counts AND within-group shares.
#     Each row represents polling stations, NOT votes or geographical aggregates.
# SR: Zajednicka raspodela izlaznosti i udela pobednika po intervalima od 10 pp.
make_joint_bins <- function(prepared, level) {
  result <- list(); j<-0L
  lab <- function(z) sprintf('%02d-%02d',z*10,(z+1)*10)
  for(group in size_labels) {
    dat <- prepared$groups[[group]]
    if(!nrow(dat)) next
    areas <- area_groups(dat,level)
    for(id in names(areas)) {
      x <- dat[areas[[id]],,drop=FALSE]
      good <- is.finite(x$Station_turnout_pct) & is.finite(x$Station_winner_pct) &
        x$Station_turnout_pct >= 0 & x$Station_turnout_pct <= 100 &
        x$Station_winner_pct >= 0 & x$Station_winner_pct <= 100
      if(!any(good)) next
      a <- pmin(9L,as.integer(floor(x$Station_turnout_pct[good]/10)))
      b <- pmin(9L,as.integer(floor(x$Station_winner_pct[good]/10)))
      counts <- table(factor(a,levels=0:9),factor(b,levels=0:9))
      ij <- which(counts>0,arr.ind=TRUE)
      if(!nrow(ij)) next
      j<-j+1L
      result[[j]] <- data.frame(Level=level,Area_key=id,Size_group=group,
        Turnout_bin=lab(ij[,1]-1L),Winner_share_bin=lab(ij[,2]-1L),
        Stations=as.integer(counts[ij]),N_complete=sum(good),
        Share_in_area_group_pct=100*as.integer(counts[ij])/sum(good),
        stringsAsFactors=FALSE)
    }
  }
  if(!length(result))return(data.frame(Level=character(),Area_key=character(),
    Size_group=character(),Turnout_bin=character(),Winner_share_bin=character(),
    Stations=integer(),N_complete=integer(),Share_in_area_group_pct=numeric()))
  do.call(rbind,result)
}

# EN: Main public entry; no source files are modified.
# SR: Glavni poziv, bez menjanja ulaznih fajlova.
build_extended_descriptive <- function(master, main, options, election_type, year) {
  prepared <- prepare_extended_groups(master,main,options,election_type,year)
  levels <- list()
  for (lvl in c('National','District','Municipality'))
    levels[[lvl]] <- aggregate_extended(prepared,lvl,election_type,year)
  national <- levels$National$summary
  all <- national[national$Size_group=='All',,drop=FALSE]
  if(nrow(all)!=1L || all$Polling_stations!=nrow(prepared$groups$All))
    stop('National All reconstruction failed')
  # EN: Main (=100 or more) and QC-accepted under-100 reconstruct All.
  # SR: Main (100 ili vise) i prihvacena BM ispod 100 daju All.
  # EN: Both the Size and JHK national partitions independently reconstruct Main.
  for(lvl in c('National','District','Municipality')) {
    ss <- levels[[lvl]]$summary
    all_tot <- ss[ss$Size_group=='All',,drop=FALSE]
    main_tot <- ss[ss$Size_group=='100 or more',,drop=FALSE]
    under_tot <- ss[ss$Size_group=='Less than 100',,drop=FALSE]
    numeric_totals <- c('Polling_stations','Registered','Attendance',
                        'Ballots_cast','Valid','Invalid','Winner_votes','Runnerup_votes')
    # EN/SR: Sum across geographic areas: zero under-100 areas is valid.
    totals <- function(d) vapply(numeric_totals,function(k)sum(d[[k]]),numeric(1))
    target <- totals(all_tot); reference <- totals(main_tot)
    if(any(target!=reference+totals(under_tot)))
      stop('All != (100 or more) + (Less than 100) at ',lvl)
    size_tot <- totals(ss[ss$Size_group %in% c('Small','Middle','Large'),,drop=FALSE])
    jhk_tot <- totals(ss[ss$Size_group %in% c('JHK Small','JHK Large'),,drop=FALSE])
    if(any(reference!=size_tot) || any(reference!=jhk_tot))
      stop('Main size partitions do not reconcile at ',lvl)
    # EN/SR: Reconcile separately within each area; an area may have only E<100.
    for(area in as.character(all_tot$Area_key)) {
      by_area <- ss[as.character(ss$Area_key)==area,,drop=FALSE]
      within <- function(labels) totals(by_area[by_area$Size_group %in% labels,,drop=FALSE])
      main_area <- within('100 or more')
      if(any(within('All') != main_area + within('Less than 100')) ||
         any(main_area != within(c('Small','Middle','Large'))) ||
         any(main_area != within(c('JHK Small','JHK Large'))))
        stop('Area-wise Main and All reconciliation failed: ',lvl,' / ',area)
    }
  }
  for(lvl in c('District','Municipality')) {
    z<-levels[[lvl]]$summary
    g<-z[z$Size_group=='All',,drop=FALSE]
    if(sum(g$Registered)!=all$Registered || sum(g$Ballots_cast)!=all$Ballots_cast ||
       sum(g$Valid)!=all$Valid || sum(g$Polling_stations)!=all$Polling_stations)
      stop('Geographic reconstruction failed for ',lvl)
  }
  corrs <- run_all_correlations(levels,prepared$options)
  # EN/SR: BH adjustment of station-level joint tests by level and size group.
  for(lvl in names(levels)) {
    ss <- levels[[lvl]]$summary
    for(metric in c('Joint_Pearson_p','Joint_Spearman_p')) {
      outname <- sub('_p$','_BH_q',metric)
      ss[[outname]] <- NA_real_
      for(label in unique(ss$Size_group)) {
        ii <- which(ss$Size_group==label & is.finite(ss[[metric]]))
        if(length(ii)) ss[[outname]][ii] <- stats::p.adjust(ss[[metric]][ii],method='BH')
      }
    }
    levels[[lvl]]$summary <- ss
  }
  tests <- run_group_tests(prepared)
  joint_bins <- setNames(lapply(c('National','District','Municipality'),
    function(lvl)make_joint_bins(prepared,lvl)),c('National','District','Municipality'))
  list(levels=levels,correlations=corrs,group_tests=tests,joint_bins=joint_bins,options=prepared$options,
       coverage=data.frame(Source_stations=prepared$input_n,
        Eligible_main=prepared$eligible_n,QC_accepted_under100=prepared$under100_n,
        Excluded_from_All=prepared$other_excluded_n))
}
