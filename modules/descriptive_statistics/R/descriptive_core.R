# Election Forensics R Toolkit -- descriptive statistics engine (v0.1.0)
# EN: Pure functions for eligible prepared polling-station records.
# SR: Funkcije za deskriptivnu analizu prethodno pripremljenih biračkih mesta.
# EN: Do not recalculate the original Size/Size_JHK boundaries by area.
# SR: Pragovi Size/Size_JHK se ne preračunavaju po okrugu/opštini.

stop_if <- function(condition, message) if (isTRUE(condition)) stop(message, call. = FALSE)

# EN/SR: Safe aggregate ratio / Bezbedan odnos zbirnih veličina.
ratio_pct <- function(numerator, denominator) {
  if (length(denominator) != 1L || is.na(denominator) || denominator <= 0 || is.na(numerator))
    return(NA_real_)
  100 * numerator / denominator
}

# EN/SR: Sample statistic excluding undefined values / Statistika bez NA vrednosti.
station_stat <- function(x, statistic = c('mean','median','sd','min','max','p20','p80')) {
  statistic <- match.arg(statistic)
  x <- as.numeric(x)
  x <- x[is.finite(x)]
  if (!length(x)) return(NA_real_)
  if (statistic == 'sd') return(if(length(x) < 2L) NA_real_ else stats::sd(x))
  if (statistic == 'mean') return(mean(x))
  if (statistic == 'median') return(stats::median(x))
  if (statistic == 'min') return(min(x))
  if (statistic == 'max') return(max(x))
  as.numeric(stats::quantile(x, probs = if(statistic=='p20') 0.20 else 0.80,
                              names = FALSE, type = 7))
}

# EN: Prepare input from Main (or the eligible subset of Master); never drop silently.
# SR: Učitati Main (ili podoban podskup Master); nema prikrivenog brisanja redova.
validate_prepared <- function(dat, election_type, year, input_sheet = 'Main') {
  essential <- c('Election_type','Year','Station_key','District_code','District',
                 'Municipality_code','Municipality','PS_number','E','A','C','I','B',
                 'Winner_votes','Second_votes','Size','Size_JHK','Eligible_primary')
  absent <- setdiff(essential, names(dat))
  stop_if(length(absent)>0, paste('Missing canonical fields:',paste(absent,collapse=', ')))
  stop_if(!input_sheet %in% c('Main','Master'), 'INPUT_SHEET must be Main or Master')
  stop_if(nrow(dat)==0L, 'Prepared data has no polling stations')
  if (input_sheet == 'Master') dat <- dat[!is.na(dat$Eligible_primary) & dat$Eligible_primary,,drop=FALSE]
  stop_if(anyNA(dat[,c('Election_type','Year','Station_key','District_code',
                       'Municipality_code','E','A','C','I','B')]),
          'Input contains missing essential identifiers or counts')
  stop_if(any(as.character(dat$Election_type)!=election_type) ||
          any(as.integer(dat$Year)!=as.integer(year)), 'Workbook election identity mismatch')
  stop_if(!nrow(dat), 'No eligible observations in input')
  stop_if(anyNA(dat$Eligible_primary) || any(!dat$Eligible_primary),
          'Main input must contain only Eligible_primary == TRUE')
  stop_if(anyDuplicated(as.character(dat$Station_key)) > 0,
          'Duplicate Station_key in eligible input')
  for (key in c('District_code','District','Municipality_code','Municipality','PS_number'))
    dat[[key]] <- trimws(as.character(dat[[key]]))
  stop_if(any(!nzchar(dat$District_code) | !nzchar(dat$Municipality_code)),
          'Blank administrative codes')
  counts <- c('E','A','C','I','B','Winner_votes','Second_votes')
  for (key in counts) dat[[key]] <- as.numeric(dat[[key]])
  stop_if(anyNA(dat[, counts]), 'Missing required numeric counts')
  stop_if(any(vapply(dat[, counts,drop=FALSE], function(x) any(x<0 | x != floor(x)), logical(1))),
          'Negative or non-integer count in prepared Main')
  stop_if(any(dat$C != dat$I + dat$B), 'Ballot identity C=I+B fails')
  stop_if(any(dat$C > dat$E | dat$A > dat$E), 'Counts exceed registered electorate')
  stop_if(any(!dat$Size %in% c('Small','Middle','Large')) || anyNA(dat$Size),
          'Invalid Size classification')
  stop_if(any(!dat$Size_JHK %in% c('Small','Large')) || anyNA(dat$Size_JHK),
          'Invalid Size_JHK classification')
  opt_cols <- grep('^Option_[0-9]+_votes$',names(dat),value=TRUE)
  stop_if(length(opt_cols)<2L,'No option vote columns found')
  for (key in opt_cols) dat[[key]] <- as.numeric(dat[[key]])
  stop_if(anyNA(dat[,opt_cols,drop=FALSE]), 'Option vote columns contain missing values')
  stop_if(any(vapply(dat[,opt_cols,drop=FALSE],function(x) any(x<0 | x!=floor(x)), logical(1))),
          'Invalid option vote counts')
  stop_if(any(abs(rowSums(dat[,opt_cols,drop=FALSE])-dat$B)>1e-8),
          'Sum of option votes does not equal B')
  dat$Station_turnout_pct <- ifelse(dat$E>0,100*dat$C/dat$E,NA_real_)
  dat$Station_winner_pct <- ifelse(dat$B>0,100*dat$Winner_votes/dat$B,NA_real_)
  dat$Station_invalid_pct <- ifelse(dat$C>0,100*dat$I/dat$C,NA_real_)
  attr(dat, 'option_cols') <- opt_cols
  dat
}

# EN/SR: Split districts by district code, municipalities by district+municipality.
# SR: Okrug prema šifri okruga; opština prema šiframa okruga i opštine.
area_groups <- function(dat, level = c('National','District','Municipality')) {
  level <- match.arg(level)
  n <- nrow(dat)
  if (level == 'National') return(list(RS=seq_len(n)))
  code <- if(level=='District') as.character(dat$District_code) else
    paste(dat$District_code,dat$Municipality_code,sep='|')
  split(seq_len(n),factor(code,levels=unique(code)))
}

# EN/SR: Sum-first ratios, and explicitly unweighted station-level statistics.
# SR: Procenti iz zbirnih brojeva i odvojeno neponderisane statistike po BM.
summarise_area <- function(dat, idx, election_type, year, level,
                           classification, group_label) {
  x <- dat[idx,,drop=FALSE]
  stop_if(!nrow(x),'Cannot summarise empty group')
  district <- if(level=='National') 'RS' else as.character(x$District_code[1])
  municipality <- if(level=='Municipality') as.character(x$Municipality_code[1]) else ''
  id <- if(level=='National') 'RS' else if(level=='District') district else
    paste(district,municipality,sep='|')
  name <- if(level=='National') 'Republic of Serbia' else
    if(level=='District') as.character(x$District[1]) else as.character(x$Municipality[1])
  totals <- vapply(x[,c('E','A','C','I','B','Winner_votes','Second_votes'),drop=FALSE],sum,numeric(1))
  data.frame(
    Election_type=election_type, Year=as.integer(year), Level=level,
    Area_key=id, District_code=district, Municipality_code=municipality,
    Area_name=name, Classification=classification, Size_group=group_label,
    Polling_stations=nrow(x), Registered=unname(totals['E']), Attendance=unname(totals['A']),
    Ballots_cast=unname(totals['C']), Valid=unname(totals['B']), Invalid=unname(totals['I']),
    Winner_votes=unname(totals['Winner_votes']), Runnerup_votes=unname(totals['Second_votes']),
    Turnout_pct=ratio_pct(unname(totals['C']),unname(totals['E'])),
    Attendance_pct=ratio_pct(unname(totals['A']),unname(totals['E'])),
    Valid_per_registered_pct=ratio_pct(unname(totals['B']),unname(totals['E'])),
    Invalid_per_cast_pct=ratio_pct(unname(totals['I']),unname(totals['C'])),
    Invalid_per_registered_pct=ratio_pct(unname(totals['I']),unname(totals['E'])),
    Winner_per_valid_pct=ratio_pct(unname(totals['Winner_votes']),unname(totals['B'])),
    Runnerup_per_valid_pct=ratio_pct(unname(totals['Second_votes']),unname(totals['B'])),
    Winner_per_registered_pct=ratio_pct(unname(totals['Winner_votes']),unname(totals['E'])),
    Mean_E=station_stat(x$E,'mean'),Median_E=station_stat(x$E,'median'),
    SD_E=station_stat(x$E,'sd'),Min_E=station_stat(x$E,'min'),
    Max_E=station_stat(x$E,'max'),
    N_turnout=sum(is.finite(x$Station_turnout_pct)),
    Mean_turnout_pct=station_stat(x$Station_turnout_pct,'mean'),
    Median_turnout_pct=station_stat(x$Station_turnout_pct,'median'),
    SD_turnout_pct=station_stat(x$Station_turnout_pct,'sd'),
    P20_turnout_pct=station_stat(x$Station_turnout_pct,'p20'),
    P80_turnout_pct=station_stat(x$Station_turnout_pct,'p80'),
    N_winner_share=sum(is.finite(x$Station_winner_pct)),
    Mean_winner_share_pct=station_stat(x$Station_winner_pct,'mean'),
    Median_winner_share_pct=station_stat(x$Station_winner_pct,'median'),
    SD_winner_share_pct=station_stat(x$Station_winner_pct,'sd'),
    N_invalid_share=sum(is.finite(x$Station_invalid_pct)),
    Mean_invalid_share_pct=station_stat(x$Station_invalid_pct,'mean'),
    Median_invalid_share_pct=station_stat(x$Station_invalid_pct,'median'),
    SD_invalid_share_pct=station_stat(x$Station_invalid_pct,'sd'),
    stringsAsFactors=FALSE, check.names=FALSE)
}

# EN: Build long table containing votes/shares for ALL candidates or lists.
# SR: Duga tabela sa glasovima i procentima za SVE kandidate ili liste.
summarise_options <- function(dat, idx, head, options, option_cols) {
  x <- dat[idx,,drop=FALSE]
  votes <- vapply(option_cols,function(col) sum(as.numeric(x[[col]])),numeric(1))
  data.frame(head[rep(1L,length(option_cols)),
                  c('Election_type','Year','Level','Area_key','District_code',
                    'Municipality_code','Area_name','Classification','Size_group'),drop=FALSE],
             Option_number=as.integer(options$Option_number),
             Option_type=as.character(options$Option_type),
             Option_name_SR_Lat=as.character(options$Option_name_SR_Lat),
             Option_field=option_cols,
             Votes=unname(votes),
             Share_valid_pct=vapply(votes, ratio_pct,numeric(1), denominator=sum(x$B)),
             Share_registered_pct=vapply(votes,ratio_pct,numeric(1),denominator=sum(x$E)),
             stringsAsFactors=FALSE,row.names=NULL)
}

# EN: The "All" row is repeated under each classification for easy comparison.
# SR: Red "All" postoji za obe klasifikacije radi lakšeg poređenja.
aggregate_level <- function(dat, options, level) {
  option_cols <- as.character(options$Votes_field)
  keys <- area_groups(dat,level)
  all_summary <- list(); all_options <- list(); balances <- list()
  i <- 0L; j <- 0L
  for (idx in keys) {
    size_counts <- c(Small=sum(dat$Size[idx]=='Small'),
                     Middle=sum(dat$Size[idx]=='Middle'),Large=sum(dat$Size[idx]=='Large'))
    jhk_counts <- c(Small=sum(dat$Size_JHK[idx]=='Small'),Large=sum(dat$Size_JHK[idx]=='Large'))
    stop_if(sum(size_counts)!=length(idx)||sum(jhk_counts)!=length(idx),
            'Classification partition is incomplete')
    for (method in c('Size','Size_JHK')) {
      categories <- if(method=='Size') c('All','Small','Middle','Large') else c('All','Small','Large')
      for (category in categories) {
        selected <- if(category=='All') idx else idx[as.character(dat[[method]][idx])==category]
        if(!length(selected)) next
        i <- i+1L
        row <- summarise_area(dat,selected,as.character(dat$Election_type[1]),
                              as.integer(dat$Year[1]),level,method,category)
        all_summary[[i]] <- row
        all_options[[i]] <- summarise_options(dat,selected,row,options,option_cols)
      }
    }
    j <- j+1L
    balances[[j]] <- data.frame(Level=level,
      Area_key=if(level=='National') 'RS' else if(level=='District')
        as.character(dat$District_code[idx[1]]) else
        paste(dat$District_code[idx[1]],dat$Municipality_code[idx[1]],sep='|'),
      All_stations=length(idx), Size_total=sum(size_counts), Size_JHK_total=sum(jhk_counts),
      All_E=sum(dat$E[idx]),
      Size_E=sum(dat$E[idx[dat$Size[idx]=='Small']])+sum(dat$E[idx[dat$Size[idx]=='Middle']])+sum(dat$E[idx[dat$Size[idx]=='Large']]),
      Size_JHK_E=sum(dat$E[idx[dat$Size_JHK[idx]=='Small']])+sum(dat$E[idx[dat$Size_JHK[idx]=='Large']]),
      stringsAsFactors=FALSE)
  }
  summary <- do.call(rbind,all_summary)
  options_out <- do.call(rbind,all_options)
  coverage <- do.call(rbind,balances)
  rownames(summary)<-NULL; rownames(options_out)<-NULL; rownames(coverage)<-NULL
  stop_if(any(coverage$All_stations!=coverage$Size_total |
              coverage$All_stations!=coverage$Size_JHK_total |
              coverage$All_E!=coverage$Size_E | coverage$All_E!=coverage$Size_JHK_E),
          paste('Coverage reconstruction failed for',level))
  vote_sums <- aggregate(options_out$Votes,
       by=list(Key=paste(options_out$Area_key,options_out$Classification,
                         options_out$Size_group,sep='|')),FUN=sum)
  summary_keys <- paste(summary$Area_key,summary$Classification,summary$Size_group,sep='|')
  stop_if(anyNA(match(summary_keys,vote_sums$Key)) ||
          any(abs(vote_sums$x[match(summary_keys,vote_sums$Key)]-summary$Valid)>1e-8),
          'Candidate/list totals do not sum to valid ballots')
  list(summary=summary, options=options_out, coverage=coverage)
}

# EN: Check complete Options map before any aggregation.
# SR: Proveriti mapu kandidata/lista pre agregiranja.
validate_options <- function(dat, options) {
  required <- c('Election_type','Year','Option_type','Option_number',
                'Option_name_SR_Lat','Votes_field')
  stop_if(length(setdiff(required,names(options)))>0,'Invalid Options worksheet columns')
  oc <- grep('^Option_[0-9]+_votes$',names(dat),value=TRUE)
  options$Votes_field <- as.character(options$Votes_field)
  stop_if(anyDuplicated(options$Votes_field)>0 || anyDuplicated(options$Option_number)>0,
          'Duplicate Options definitions')
  stop_if(!setequal(options$Votes_field,oc),'Options map != prepared Option_XX_votes fields')
  stop_if(any(as.character(options$Election_type)!=as.character(dat$Election_type[1])) ||
          any(as.integer(options$Year)!=as.integer(dat$Year[1])),
          'Options map election identity mismatch')
  options <- options[match(oc,options$Votes_field),,drop=FALSE]
  stop_if(anyNA(options$Option_name_SR_Lat) || any(!nzchar(as.character(options$Option_name_SR_Lat))),
          'Blank candidate/list labels')
  rownames(options)<-NULL
  options
}

# EN: Compile national/district/municipality outputs and cross-check reconstructions.
# SR: Izračunati republičke, okružne i opštinske rezultate i proveriti zbirove.
build_descriptive <- function(dat, options, election_type, year, input_sheet='Main') {
  dat <- validate_prepared(dat,election_type,year,input_sheet)
  options <- validate_options(dat,options)
  levels <- c('National','District','Municipality')
  ans <- setNames(lapply(levels,function(lvl) aggregate_level(dat,options,lvl)),levels)
  national <- ans$National$summary
  full <- national[national$Classification=='Size' & national$Size_group=='All',,drop=FALSE]
  stop_if(nrow(full)!=1L || full$Polling_stations!=nrow(dat) ||
          full$Registered!=sum(dat$E) || full$Valid!=sum(dat$B),
          'National reconstruction failed')
  for (lvl in c('District','Municipality')) {
    s <- ans[[lvl]]$summary
    all <- s[s$Classification=='Size' & s$Size_group=='All',,drop=FALSE]
    stop_if(sum(all$Polling_stations)!=nrow(dat)||sum(all$Registered)!=sum(dat$E)||
            sum(all$Valid)!=sum(dat$B),paste('Unreconciled',lvl,'totals'))
  }
  list(levels=ans, option_map=options,
       metadata=data.frame(Key=c('Election_type','Year','Input_sheet','Eligible_stations',
                                  'Size_rule','Size_JHK_rule','Population_scope',
                                  'Winner_definition','Ratios','Station_descriptives'),
         Value=c(election_type,as.character(year),input_sheet,as.character(nrow(dat)),
                 'National cumulative electorate: lower/upper ~20%; middle remainder',
                 'National station-size 20th percentile; large=complement',
                 'Eligible_primary only (E>=100 and upstream QC accepted)',
                 'Leading and runner-up options by NATIONAL total, not local ranks',
                 'Compute shares from summed votes/denominators; NA for zero denominator',
                 'Unweighted mean/median/SD and sample counts; SD=NA for N<2'),
        stringsAsFactors=FALSE))
}
