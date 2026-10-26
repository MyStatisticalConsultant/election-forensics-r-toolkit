# Election Forensics R Toolkit: regression_analysis core v0.1.6
# Scientific diagnostics only. Statistical associations do not establish fraud.
ra_require <- function(pkgs) {
  no <- pkgs[!vapply(pkgs,requireNamespace,logical(1),quietly=TRUE)]
  if(length(no)) stop('Install missing packages: ',paste(no,collapse=', '),call.=FALSE)
}
ra_num <- function(x) suppressWarnings(as.numeric(as.character(x)))
ra_id <- function(x) { z<-trimws(as.character(x));z[is.na(x)|!nzchar(z)]<-NA_character_;sub('\\.0$','',z) }
ra_slug <- function(x) { z<-gsub('[^A-Za-z0-9_-]','_',as.character(x));substr(gsub('_+','_',z),1L,90L) }
ra_csv <- function(x,p) {dir.create(dirname(p),recursive=TRUE,showWarnings=FALSE);utils::write.csv(x,p,row.names=FALSE,na='',fileEncoding='UTF-8')}
ra_read <- function(p,sheet='Master') {
  ra_require('readxl');if(!file.exists(p))stop('Missing RZS workbook: ',p)
  if(!sheet %in% readxl::excel_sheets(p))stop('Missing worksheet ',sheet,' in ',p)
  as.data.frame(readxl::read_excel(p,sheet=sheet))
}
ra_option_cols <- function(d) grep('^Option_[0-9]+_votes$',names(d),value=TRUE)
ra_choose_options <- function(d,election,selection=list(),winner_fallbacks=list(),winner_field='Winner_votes') {
  opts<-ra_option_cols(d);if(length(opts)<2L)stop('At least two Option_NN_votes columns are required in ',election)
  good<-is.finite(d$E)&d$E>0&is.finite(d$B)&d$B>0&is.finite(d$C)&d$C>=d$B&d$C<=d$E
  sums<-vapply(opts,function(v){x<-ra_num(d[[v]]);sum(x[good & is.finite(x) & x>=0],na.rm=TRUE)},numeric(1))
  if(election %in% names(selection) && length(selection[[election]])) {
    chosen<-selection[[election]]
    if(length(chosen)!=2L||anyDuplicated(chosen)||!all(chosen %in% opts))stop('SELECTION for ',election,' must name exactly two distinct available option vote columns')
    reason<-'USER_SELECTED'
  } else {
    ord<-names(sort(sums,decreasing=TRUE));chosen<-head(ord,2L);reason<-'NATIONAL_TOP_TWO'
  }
  wf<-if(winner_field %in% names(d))winner_field else winner_fallbacks[[election]]
  if(is.null(wf) || !(wf %in% names(d)))stop('Missing national winner field or fallback for ',election)
  if(!all(is.finite(ra_num(d[[wf]][good]))))stop('Winner field contains missing/non-numeric values among relevant stations')
  # An explicit cross-check, never silently rename an opponent as the winner.
  sumw<-sum(ra_num(d[[wf]][good]));matchwinner<-names(sums)[abs(sums-sumw)<.5]
  if(!length(matchwinner))stop('Winner_votes / fallback does not match any Option_* aggregate for ',election,'. Verify Master and Options mapping.')
  if(length(matchwinner)>1L)stop('Ambiguous winner identity; equal national option totals. Specify and verify source fields.')
  if(chosen[1L]!=matchwinner[1L] && reason=='NATIONAL_TOP_TWO') {
    stop('Prepared winner field does not match the highest national option in ',election,'; verify Options worksheet and winner selection.')
  }
  if(reason=='USER_SELECTED' && chosen[1L]!=matchwinner[1L])stop('The first user-selected option must be the prepared national winner.')
  data.frame(election=election,role=c('Winner','RunnerUp'),option_field=chosen,
             national_votes=as.numeric(sums[chosen]),selection_mode=reason,winner_field=wf,
             stringsAsFactors=FALSE)
}
ra_prepare <- function(d,election,choices,turnout='C/E') {
  req<-c('Station_key','District_code','Municipality_code','E','B','C','Size','Size_JHK')
  missing<-setdiff(req,names(d));if(length(missing))stop('Master missing fields: ',paste(missing,collapse=', '))
  if(!(turnout %in% c('C/E','B/E')))stop('turnout must be C/E or B/E')
  d$Station_key<-ra_id(d$Station_key);d$District_code<-ra_id(d$District_code);d$Municipality_code<-ra_id(d$Municipality_code)
  if(anyDuplicated(d$Station_key[!is.na(d$Station_key)]))stop('Duplicated Station_key values')
  for(cn in c('E','B','C',choices$option_field)) d[[cn]]<-ra_num(d[[cn]])
  d$W<-d[[choices$option_field[choices$role=='Winner']]]
  d$R<-d[[choices$option_field[choices$role=='RunnerUp']]]
  if(!'District'%in%names(d))d$District<-d$District_code
  if(!'Municipality'%in%names(d))d$Municipality<-d$Municipality_code
  d$Size<-as.character(d$Size); d$Size_JHK<-as.character(d$Size_JHK)
  ok_key<-!is.na(d$Station_key)&!is.na(d$District_code)&!is.na(d$Municipality_code)
  counts<-as.matrix(d[,c('E','B','C','W','R')]);finite<-rowSums(is.finite(counts))==5L
  valid<-finite & d$E>=1 & d$B>=1 & d$C>=d$B & d$C<=d$E &
    d$W>=0 & d$R>=0 & (d$W+d$R)<=d$B &
    rowSums(abs(counts-round(counts))>1e-8,na.rm=TRUE)==0
  d$valid_counts<-ok_key & valid
  d$exclusion_reason<-ifelse(!ok_key,'MISSING_STATION_OR_AREA',ifelse(!finite,'MISSING_COUNTS',ifelse(!valid,'INVALID_COUNTS','OK')))
  d$turnout_def<-turnout;d$turnout_pct<-100*(if(turnout=='C/E')d$C else d$B)/d$E
  d$winner_of_registered_pct<-100*d$W/d$E;d$runner_of_registered_pct<-100*d$R/d$E
  d$winner_of_valid_pct<-100*d$W/d$B
  d$invalid_count<-d$C-d$B;d$invalid_rate_pct<-100*d$invalid_count/d$C
  d$log_registered<-log(d$E);d$election<-election
  # Additional candidate votes are not needed for the A or B regression.
  d
}
ra_groups <- function(d,include_under100=TRUE,min_e=100) {
  eligible<-d$valid_counts & is.finite(d$E)
  primary<-eligible & d$E>=min_e
  out<-list(All_100plus=primary)
  if(include_under100)out$Under100<-eligible & d$E<min_e
  out$Size_Small<-primary & !is.na(d$Size) & d$Size=='Small'
  out$Size_Large<-primary & !is.na(d$Size) & d$Size=='Large'
  out$JHK_Small<-primary & !is.na(d$Size_JHK) & d$Size_JHK=='Small'
  out$JHK_Large<-primary & !is.na(d$Size_JHK) & d$Size_JHK=='Large'
  out
}
ra_areas <- function(d,levels='national',district_codes=NULL,municipality_codes=NULL){
  if(!all(levels%in%c('national','district','municipality')))stop('Unsupported geographic level')
  out<-list();add<-function(level,key,label,mask)out[[length(out)+1L]]<<-list(level=level,key=key,label=label,mask=mask)
  if('national'%in%levels)add('national','national','Serbia',rep(TRUE,nrow(d)))
  if('district'%in%levels)for(k in sort(unique(stats::na.omit(d$District_code)))) {
    if(!is.null(district_codes) && !(k%in%ra_id(district_codes)))next
    m<-!is.na(d$District_code)&d$District_code==k;v<-unique(d$District[m]);add('district',k,paste('District',v[1L]),m)
  }
  if('municipality'%in%levels)for(k in sort(unique(stats::na.omit(d$Municipality_code)))) {
    m<-!is.na(d$Municipality_code)&d$Municipality_code==k
    if(!is.null(municipality_codes)&&!(k%in%ra_id(municipality_codes)))next
    if(!is.null(district_codes)&&!any(d$District_code[m]%in%ra_id(district_codes)))next
    v<-unique(d$Municipality[m]);add('municipality',k,paste('Municipality',v[1L]),m)
  }
  out
}
ra_empty_coeff <- function(){data.frame(model_id=character(),term=character(),estimate=numeric(),se_ols=numeric(),t_ols=numeric(),p_ols=numeric(),ci95_low=numeric(),ci95_high=numeric(),se_hc3=numeric(),t_hc3=numeric(),p_hc3=numeric(),ci95_hc3_low=numeric(),ci95_hc3_high=numeric(),stringsAsFactors=FALSE)}
ra_fit <- function(dat,model_id,formula,min_n=30L,min_unique=5L,max_fes=120L){
  # Same observations enter the estimate, variance, influence and plotting CSVs.
  varnames<-all.vars(formula);complete<-stats::complete.cases(dat[,varnames,drop=FALSE])
  z<-dat[complete,,drop=FALSE];status<-'OK'; fit<-NULL
  if(nrow(z)<min_n)status<-'INSUFFICIENT_N'
  if(status=='OK' && length(unique(z[[varnames[2L]]]))<min_unique)status<-'INSUFFICIENT_X_VARIATION'
  if(status=='OK' && 'Municipality_code'%in%varnames && length(unique(z$Municipality_code))>max_fes)status<-'TOO_MANY_FIXED_EFFECTS'
  if(status=='OK'){
    fit<-tryCatch(stats::lm(formula,data=z,model=TRUE,x=TRUE),error=function(e)NULL)
    if(is.null(fit) || fit$df.residual<4L)status<-'SINGULAR_OR_LOW_DF'
  }
  meta<-data.frame(model_id=model_id,formula=paste(deparse(formula),collapse=''),status=status,
                   n=nrow(z),r2=NA_real_,adj_r2=NA_real_,f_stat=NA_real_,f_df1=NA_real_,f_df2=NA_real_,f_p=NA_real_,
                   sigma=NA_real_,bp_lm=NA_real_,bp_p=NA_real_,n_cook_gt_4_over_n=NA_integer_, stringsAsFactors=FALSE)
  if(status!='OK')return(list(meta=meta,coeff=ra_empty_coeff(),rows=data.frame(),fit=NULL))
  sx<-summary(fit); ff<-sx$fstatistic
  meta$r2<-sx$r.squared;meta$adj_r2<-sx$adj.r.squared;meta$sigma<-sx$sigma
  if(!is.null(ff)){meta$f_stat<-unname(ff[1L]);meta$f_df1<-unname(ff[2L]);meta$f_df2<-unname(ff[3L]);meta$f_p<-stats::pf(ff[1L],ff[2L],ff[3L],lower.tail=FALSE)}
  n<-nrow(z);h<-stats::hatvalues(fit);e<-stats::residuals(fit)
  cs<-sx$coefficients; terms<-rownames(cs)
  # HC3 sandwich variance with rank-aware design; no external dependency.
  X<-stats::model.matrix(fit); piv<-fit$qr$pivot[seq_len(fit$rank)];Xr<-X[,piv,drop=FALSE]
  bread<-tryCatch(solve(crossprod(Xr)),error=function(e)NULL)
  covhc<-if(is.null(bread))NULL else { w<-(e/pmax(1-h,1e-8))^2; bread %*% crossprod(Xr,Xr*w) %*% bread }
  se_hc3<-rep(NA_real_,length(terms));names(se_hc3)<-terms
  if(!is.null(covhc))se_hc3[colnames(Xr)]<-sqrt(pmax(0,diag(covhc)))
  b<-unname(cs[,1L]);se<-unname(cs[,2L]);tols<-unname(cs[,3L]);pols<-unname(cs[,4L]);rh<-unname(se_hc3[terms]);th<-b/rh
  ph<-2*stats::pt(abs(th),df=fit$df.residual,lower.tail=FALSE)
  critical<-stats::qt(.975,df=fit$df.residual)
  coeff<-data.frame(model_id=model_id,term=terms,estimate=b,se_ols=se,t_ols=tols,p_ols=pols,
                    ci95_low=b-critical*se,ci95_high=b+critical*se,se_hc3=rh,t_hc3=th,p_hc3=ph,
                    ci95_hc3_low=b-critical*rh,ci95_hc3_high=b+critical*rh,stringsAsFactors=FALSE)
  # Breusch-Pagan auxiliary regression on fitted values (one explanatory regressor).
  if(n>=10L && stats::var(e^2)>0 && stats::var(stats::fitted(fit))>0){
    aux<-stats::lm(I(e^2)~stats::fitted(fit)); meta$bp_lm<-n*summary(aux)$r.squared;meta$bp_p<-stats::pchisq(meta$bp_lm,1L,lower.tail=FALSE)
  }
  cd<-stats::cooks.distance(fit);meta$n_cook_gt_4_over_n<-sum(cd>4/n,na.rm=TRUE)
  rows<-data.frame(Station_key=z$Station_key,observed=stats::model.response(stats::model.frame(fit)),
                   fitted=stats::fitted(fit),residual=e,leverage=h,cooks_distance=cd,stringsAsFactors=FALSE)
  list(meta=meta,coeff=coeff,rows=rows,fit=fit)
}
ra_lukinova_rows <- function(d){
  w<-d[,c('Station_key','District_code','Municipality_code','E','B','C','Size','Size_JHK','turnout_pct','winner_of_registered_pct','runner_of_registered_pct'),drop=FALSE]
  data.frame(w,stringsAsFactors=FALSE)
}
ra_invalid_rows <- function(d){
  d[,c('Station_key','District_code','Municipality_code','E','B','C','Size','Size_JHK','turnout_pct','W','invalid_count','invalid_rate_pct','winner_of_valid_pct','log_registered'),drop=FALSE]
}

# Read candidate/list names from the upstream Options dictionary by ballot number.
# Selection by vote total remains in ra_choose_options; display lookup is separate.
# Never infer candidate identity from Option_XX or from a party's supposed ballot rank.
ra_option_labels_from_table <- function(options,choice,overrides=NULL,election='election') {
  if(!'option_field'%in%names(choice)||!'role'%in%names(choice))stop('Malformed selected options')
  out<-rep(NA_character_,nrow(choice));source<-rep(NA_character_,nrow(choice))
  if(!is.null(overrides)&&length(overrides)) {
    # Named character vectors and named lists are both supported. With an
    # atomic character vector, [[missing_name]] raises 'subscript out of
    # bounds' instead of returning NULL. Check membership before indexing:
    # unspecified option fields must fall back to the verified Options sheet.
    if(!(is.character(overrides)||is.list(overrides)))
      stop('OPTION_LABELS override must be a named character vector or named list for ',election,call.=FALSE)
    nm<-names(overrides)
    if(is.null(nm)||anyNA(nm)||any(!nzchar(nm))||anyDuplicated(nm))
      stop('OPTION_LABELS override requires unique, non-empty option-field names for ',election,call.=FALSE)
    for(j in seq_len(nrow(choice))) {
      field<-choice$option_field[j]
      if(!(field %in% nm))next
      v<-overrides[[field]]
      if(length(v)!=1L || !is.character(v) || is.na(v) || !nzchar(trimws(v)))
        stop('OPTION_LABELS override for ',field,' must contain one non-empty text label.',call.=FALSE)
      out[j]<-trimws(v);source[j]<-'OPTION_LABELS_OVERRIDE'
    }
  }
  if(!is.null(options)&&is.data.frame(options)&&nrow(options)) {
    cn<-names(options)
    normalize<-function(s)gsub('[^a-z0-9]','',tolower(iconv(as.character(s),to='ASCII//TRANSLIT',sub='')))
    norm<-normalize(cn)
    no_col<-match(TRUE,norm%in%c('optionnumber','optionno','ballotnumber','ballotorder','optionindex'))
    field_col<-match(TRUE,norm%in%c('optionfield','votecolumn','votefield','standardcolumn'))
    name_candidates<-c('optionname','optionlabel','candidatename','listname',
        'candidateorlist','candidatelist','officialname','ballotname','originalname',
        'originalheader','sourceheader','optiontext','optiondescription','label',
        'name','candidate','list','partyname','heading')
    cand_cols<-which(norm%in%name_candidates)
    if(!length(cand_cols))cand_cols<-which(grepl('name|label|candidate|list|title|text|header',norm) &
      !grepl('votes|count|number|total|column|field',norm))
    # Drop generic English/RZS technical fields even if spreadsheet order changes.
    if(length(cand_cols))cand_cols<-cand_cols[order(match(norm[cand_cols],name_candidates))]
    opt_no<-if(length(no_col)==1L&&!is.na(no_col)) suppressWarnings(as.integer(as.character(options[[no_col]]))) else rep(NA_integer_,nrow(options))
    opt_field<-if(length(field_col)==1L&&!is.na(field_col))as.character(options[[field_col]]) else rep(NA_character_,nrow(options))
    for(j in which(is.na(out))) {
      field<-choice$option_field[j]
      num<-suppressWarnings(as.integer(sub('^Option_0*([0-9]+)_votes$','\\1',field)))
      idx<-which((is.finite(opt_no)&opt_no==num)|(!is.na(opt_field)&opt_field==field))
      if(length(idx)!=1L)next
      if(!length(cand_cols))next
      for(col in cand_cols) {
        v<-trimws(as.character(options[[col]][idx]))
        if(!is.na(v) && nzchar(v) && !grepl('^Option[_ ]*[0-9]+(_votes)?$',v,ignore.case=TRUE) &&
            !grepl('^V[0-9]+$',v,ignore.case=TRUE)) {
          out[j]<-v;source[j]<-paste0('Options:',cn[col]);break
        }
      }
    }
  }
  if(anyNA(out)) stop('Missing verified candidate/list names for ',election,': ',
     paste(choice$option_field[is.na(out)],collapse=', '),'. ',
     'Check the Options worksheet or enter named OPTION_LABELS overrides.',call.=FALSE)
  if(anyDuplicated(out))stop('Ambiguous duplicate candidate/list display names in ',election,call.=FALSE)
  # Romanise Cyrillic labels for consistent EN / Serbian-Latin plots.
  out<-ra_cyrillic_to_latin(out)
  if(anyNA(out)||any(!nzchar(out)))stop('Empty display name for ',election,call.=FALSE)
  choice$display_label<-out
  choice$label_source<-source
  choice
}

ra_cyrillic_to_latin <- function(x) {
  # Standard Serbian Latin transliteration; preserve other Unicode scripts unchanged.
  from<-c('Љ','Њ','Џ','Ђ','Ћ','Ж','Ч','Ш','љ','њ','џ','ђ','ћ','ж','ч','ш',
          'А','Б','В','Г','Д','Е','З','И','Ј','К','Л','М','Н','О','П','Р','С','Т','У','Ф','Х','Ц',
          'а','б','в','г','д','е','з','и','ј','к','л','м','н','о','п','р','с','т','у','ф','х','ц')
  to<-c('Lj','Nj','Dž','Đ','Ć','Ž','Č','Š','lj','nj','dž','đ','ć','ž','č','š',
        'A','B','V','G','D','E','Z','I','J','K','L','M','N','O','P','R','S','T','U','F','H','C',
        'a','b','v','g','d','e','z','i','j','k','l','m','n','o','p','r','s','t','u','f','h','c')
  y<-as.character(x)
  for(j in seq_along(from))y<-gsub(from[j],to[j],y,fixed=TRUE)
  y
}

ra_resolve_option_labels <- function(workbook,choice,overrides=NULL,election='election',sheet='Options') {
  ra_require('readxl')
  opts<-NULL
  if(sheet%in%readxl::excel_sheets(workbook))
    opts<-as.data.frame(readxl::read_excel(workbook,sheet=sheet),stringsAsFactors=FALSE)
  ra_option_labels_from_table(opts,choice,overrides=overrides,election=election)
}
