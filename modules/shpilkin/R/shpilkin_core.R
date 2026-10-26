# Election Forensics R Toolkit — Shpilkin/Kobak-Pshenichnikov core, v0.1.0
# All analytical transformations are exposed; neither histogram spikes nor
# excess-vote scenarios by themselves establish electoral manipulation.
sp_need <- function(x) { bad <- x[!vapply(x,requireNamespace,logical(1),quietly=TRUE)]; if(length(bad)) stop("Install R packages: ",paste(bad,collapse=", ")) }
sp_id <- function(x) { y<-trimws(as.character(x)); y[is.na(x)|!nzchar(y)]<-NA_character_; sub('\\.0$','',y) }
sp_num <- function(x) suppressWarnings(as.numeric(x))
sp_slug <- function(x) substr(gsub('_+','_',gsub('[^A-Za-z0-9_-]','_',as.character(x))),1,80)
sp_csv <- function(x,path) {dir.create(dirname(path),recursive=TRUE,showWarnings=FALSE); utils::write.csv(x,path,row.names=FALSE,na='',fileEncoding='UTF-8')}
sp_read_master <- function(path) {sp_need('readxl');if(!file.exists(path))stop('Prepared file missing: ',path);if(!'Master'%in%readxl::excel_sheets(path))stop('Sheet Master missing: ',path);as.data.frame(readxl::read_excel(path,sheet='Master'))}
sp_prepared <- function(d, election, winner_field='Winner_votes', fallback=list(),
                        turnout_def='C/E') {
 if(!turnout_def%in%c('C/E','B/E'))stop('TURNOUT definition must be C/E or B/E')
 req<-c('Station_key','District_code','Municipality_code','E','B','C'); missing<-setdiff(req,names(d))
 if(length(missing))stop('Missing Master fields: ',paste(missing,collapse=', '))
 use <- if(winner_field%in%names(d)) winner_field else fallback[[election]]
 if(is.null(use)||!use%in%names(d))stop('Winner column missing for ',election,'; verify Options national winner and configured fallback')
 d$Station_key<-sp_id(d$Station_key);d$District_code<-sp_id(d$District_code);d$Municipality_code<-sp_id(d$Municipality_code)
 for(col in c('E','B','C'))d[[col]]<-sp_num(d[[col]])
 d$W<-sp_num(d[[use]])
 if(!'District'%in%names(d))d$District<-d$District_code
 if(!'Municipality'%in%names(d))d$Municipality<-d$Municipality_code
 if(anyDuplicated(d$Station_key[!is.na(d$Station_key)]))stop('Duplicate polling station keys')
 reasons <- rep('OK',nrow(d))
 flag<-function(mask,txt){ idx<-base::which(mask %in% TRUE); if(length(idx))reasons[idx]<<-ifelse(reasons[idx]=='OK',txt,paste(reasons[idx],txt,sep=';')) }
 flag(is.na(d$Station_key)|is.na(d$District_code)|is.na(d$Municipality_code),'MISSING_KEY')
 cols<-d[,c('E','B','C','W')];finite<-rowSums(is.finite(as.matrix(cols)))==4L
 flag(!finite,'MISSING_COUNTS')
 invalid<-finite & (d$E<1|d$B<=0|d$C<d$B|d$C>d$E|d$W<0|d$W>d$B|
    d$E!=floor(d$E)|d$B!=floor(d$B)|d$C!=floor(d$C)|d$W!=floor(d$W))
 flag(invalid,'INVALID_COUNTS')
 d$qc_reason<-reasons
 d$base_ok<-d$qc_reason=='OK'
 d$G<-if(turnout_def=='C/E')d$C else d$B
 d$turnout_pct<-100*d$G/d$E
 d$leader_pct<-100*d$W/d$B
 flag(d$base_ok & d$E<100,'E_UNDER_100')
 flag(d$base_ok & (d$turnout_pct>=100 | d$leader_pct>=100),'BOUNDARY_100')
 d$qc_reason<-reasons
 # Descriptive histograms use values in [0,100), E >= 100.
 d$hist_ok<-d$base_ok & d$E>=100 & d$turnout_pct<100 & d$leader_pct<100
 # The integer-percentage test follows Kobak et al.: exclude observed >99%, not exactly 99%.
 d$test_ok<-d$base_ok & d$E>=100 & d$turnout_pct<=99 & d$leader_pct<=99
 d$winner_field_used<-use
 d
}
sp_areas <- function(d,levels='national',district_codes=NULL,municipality_codes=NULL) {
 stopifnot(all(levels%in%c('national','district','municipality')))
 a<-list();add<-function(level,key,name,ix)a[[length(a)+1L]]<<-list(level=level,key=key,name=name,idx=which(ix%in%TRUE))
 if('national'%in%levels)add('national','Serbia','Serbia',rep(TRUE,nrow(d)))
 if('district'%in%levels){ids<-sort(unique(stats::na.omit(d$District_code))); if(!is.null(district_codes))ids<-intersect(ids,sp_id(district_codes));
  for(k in ids){j<-which(d$District_code==k);add('district',k,paste0('District ',k,' (',d$District[j[1]],')'),d$District_code==k)}}
 if('municipality'%in%levels){x<-unique(d[!is.na(d$District_code)&!is.na(d$Municipality_code),c('District_code','Municipality_code','Municipality'),drop=FALSE]);
  for(i in seq_len(nrow(x))){ds<-x$District_code[i];mu<-x$Municipality_code[i];if(!is.null(district_codes)&&!ds%in%sp_id(district_codes))next;if(!is.null(municipality_codes)&&!mu%in%sp_id(municipality_codes))next
   add('municipality',paste(ds,mu,sep='_'),paste('Municipality',x$Municipality[i]),d$District_code==ds & d$Municipality_code==mu)}}
 a
}
# Centered bins: e.g., 50% contains 50 +/- width/2. 100% is excluded.
sp_centers <- function(width){if(!is.finite(width)||width<=0||abs(100/width-round(100/width))>1e-7)stop('Bin width must be a positive divisor of 100');seq(0,100,by=width)}
sp_bin <- function(values,width){k<-floor(values/width+0.5+1e-10); pmin(pmax(k,0L),as.integer(round(100/width)))}
sp_hist <- function(values,weights,width=.5,area_normalized=TRUE) {
 centers<-sp_centers(width); use<-is.finite(values)&values>=0&values<100&is.finite(weights)&weights>=0
 z<-numeric(length(centers)); if(any(use)){idx<-sp_bin(values[use],width)+1L;tmp<-rowsum(weights[use],idx,reorder=FALSE);z[as.integer(rownames(tmp))]<-tmp[,1]}
 total<-sum(z)
 data.frame(bin_index=seq_along(centers)-1L,bin_center_pct=centers,bin_left_pct=pmax(0,centers-width/2),bin_right_pct=pmin(100,centers+width/2),weighted_count=z,probability=if(total>0)z/total else NA_real_,density=if(total>0)z/(total*width) else NA_real_)
}
sp_descriptive <- function(d,width=.5,jitter=TRUE,seed=1L) {
 x<-d[d$hist_ok,,drop=FALSE]; if(!nrow(x))return(list(turnout=sp_hist(numeric(),numeric(),width),leader=sp_hist(numeric(),numeric(),width),stations=x))
 if(jitter){ set.seed(as.integer(seed));a<-stats::runif(nrow(x),-.5,.5);b<-stats::runif(nrow(x),-.5,.5)
   # Paper's U(-0.5,0.5) perturbation is numerator-only and plot-only.
   t<-100*(x$G+a)/x$E;v<-100*(x$W+b)/x$B
   t<-pmin(pmax(t,0),100-1e-10);v<-pmin(pmax(v,0),100-1e-10)
 } else {t<-x$turnout_pct;v<-x$leader_pct}
 x$plot_turnout_pct<-t;x$plot_leader_pct<-v
 list(turnout=sp_hist(t,rep(1,nrow(x)),width),leader=sp_hist(v,rep(1,nrow(x)),width),stations=x)
}
sp_integer_test <- function(turnout,leader,halfwidth=.05,kind='either'){
 if(!kind%in%c('either','turnout','leader','half_integer_turnout','half_integer_leader'))stop('Unknown integer test kind')
 close<-function(v,offset) is.finite(v) & abs(v-(floor(v-offset+0.5)+offset)) <= halfwidth+1e-10
 a<-close(turnout,if(kind=='half_integer_turnout') .5 else 0)
 b<-close(leader,if(kind=='half_integer_leader') .5 else 0)
 if(kind=='either')return(a|b)
 if(kind%in%c('turnout','half_integer_turnout'))return(a)
 b
}
# Binomial-null model of Kobak et al. (2016): n=E, p=G/E; n=B, p=W/B.
# Null draws are independent by numerator and their given observed denominators.
sp_mc <- function(d,reps=199L,seed=431L,width=.1,window=.05,histogram_mc=TRUE) {
 if(reps<19L||reps!=as.integer(reps))stop('reps must be integer >=19')
 g<-d[d$test_ok,,drop=FALSE]; if(nrow(g)<20L)stop('Fewer than 20 eligible stations for Monte Carlo')
 e<-g$E;b<-g$B;pr_t<-g$G/e;pr_v<-g$W/b; w<-g$E
 kinds<-c('either','turnout','leader','half_integer_turnout','half_integer_leader')
 obs_t<-g$turnout_pct;obs_v<-g$leader_pct
 obs<-vapply(kinds,function(k) sum(sp_integer_test(obs_t,obs_v,window,k)),numeric(1))
 oq<-vapply(kinds,function(k) sum(w[sp_integer_test(obs_t,obs_v,window,k)]),numeric(1))
 hto<-sp_hist(obs_t,w,width);hvo<-sp_hist(obs_v,w,width)
 # Retain MC hist matrices in memory to get exact percentile bands.
 nc<-nrow(hto); hm_t<-if(histogram_mc)matrix(0,nrow=reps,ncol=nc) else NULL
 hm_v<-if(histogram_mc)matrix(0,nrow=reps,ncol=nc) else NULL
 sim<-matrix(0L,nrow=reps,ncol=length(kinds),dimnames=list(NULL,kinds))
 set.seed(as.integer(seed))
 for(r in seq_len(reps)){
  a<-100*stats::rbinom(length(e),size=e,prob=pr_t)/e
  v<-100*stats::rbinom(length(b),size=b,prob=pr_v)/b
  for(j in seq_along(kinds))sim[r,j]<-sum(sp_integer_test(a,v,window,kinds[j]) & a<=99 & v<=99)
  if(histogram_mc){hm_t[r,]<-sp_hist(a,w,width)$weighted_count;hm_v[r,]<-sp_hist(v,w,width)$weighted_count}
 }
 summary<-do.call(rbind,lapply(seq_along(kinds),function(j){v<-sim[,j];ss<-stats::sd(v);data.frame(metric=kinds[j],observed=obs[j],observed_registered_weight=oq[j],n_stations=nrow(g),mc_reps=reps,mean_mc=mean(v),sd_mc=ss,excess=obs[j]-mean(v),z=if(ss>0)(obs[j]-mean(v))/ss else NA_real_,p_upper=(sum(v>=obs[j])+1)/(reps+1),mc_q005=unname(stats::quantile(v,.005)),mc_median=stats::median(v),mc_q995=unname(stats::quantile(v,.995)),status=if(ss>0)'OK' else 'DEGENERATE_NULL')}))
 draws<-data.frame(replicate=seq_len(reps),sim,check.names=FALSE)
 mk_band<-function(orig,m){if(is.null(m))return(data.frame());data.frame(bin_center_pct=orig$bin_center_pct,observed_registered=orig$weighted_count,mean_mc=colMeans(m),q005=apply(m,2L,stats::quantile,probs=.005,names=FALSE),q995=apply(m,2L,stats::quantile,probs=.995,names=FALSE))}
 list(summary=summary,draws=draws,turnout_band=mk_band(hto,hm_t),leader_band=mk_band(hvo,hm_v),n=nrow(g))
}
# Nonparametric conditional-excess scenario. It is NOT a proven fraud count.
# A baseline ratio winner/other-valid votes is fitted in a predeclared core of turnout bins.
sp_excess <- function(d,width=1,core=NULL,auto_window=7.5,min_core_stations=30L,
                      min_core_opposition=100,only_above_core=TRUE){
 g<-d[d$hist_ok,,drop=FALSE];centers<-sp_centers(width)
 if(nrow(g)<30L)return(list(status='INSUFFICIENT_STATIONS',bins=data.frame(),summary=data.frame()))
 bins<-sp_bin(g$turnout_pct,width)+1L
 agg<-function(z){out<-numeric(length(centers));v<-rowsum(z,bins,reorder=FALSE);out[as.integer(rownames(v))]<-v[,1];out}
 registered<-agg(g$E);winning<-agg(g$W);valid<-agg(g$B);nonwinner<-agg(g$B-g$W);n<-agg(rep(1,nrow(g)))
 if(is.null(core)){
   # Modal bin of STATION COUNTS; excludes tails, if available.
   candidates<-which(centers>=20 & centers<=80)
   if(!length(candidates))stop('No bins for automatic core')
   modal<-centers[candidates[which.max(n[candidates])]]
   core<-c(max(0,modal-auto_window),min(100,modal+auto_window))
   selection<-'AUTO_MODAL_DESCRIPTIVE'
 }else{if(length(core)!=2||any(!is.finite(core))||core[1]>=core[2]||core[1]<0||core[2]>100)stop('core must be two ordered percentages');selection<-'USER_PREDECLARED'}
 ci<-centers>=core[1] & centers<=core[2];nwcore<-sum(nonwinner[ci]);winscore<-sum(winning[ci]);ncore<-sum(n[ci]);
 good<-ncore>=min_core_stations&&nwcore>=min_core_opposition&&winscore>0
 alpha<-if(good)winscore/nwcore else NA_real_
 expected<-alpha*nonwinner
 residual<-winning-expected
 use<-if(only_above_core)centers>core[2] else rep(TRUE,length(centers))
 pos<-if(good)sum(pmax(residual[use],0)) else NA_real_;net<-if(good)sum(residual[use]) else NA_real_
 each<-data.frame(turnout_bin_center=centers,turnout_bin_width=width,n_stations=n,registered=registered,valid_votes=valid,winner_votes=winning,other_valid_votes=nonwinner,core_bin=ci,estimate_region=use,expected_winner=expected,residual_winner=residual,positive_residual=pmax(residual,0))
 ratios<-winning[ci & nonwinner>0]/nonwinner[ci & nonwinner>0]
 cv<-if(length(ratios)>1&&mean(ratios)>0)stats::sd(ratios)/mean(ratios) else NA_real_
 summ<-data.frame(status=if(!good)'INSUFFICIENT_CORE' else if(is.finite(cv)&&cv>.35)'HIGH_CORE_HETEROGENEITY' else 'DESCRIPTIVE_SCENARIO',core_selection=selection,core_lower_pct=core[1],core_upper_pct=core[2],core_stations=ncore,core_other_valid_votes=nwcore,ratio_winner_to_others=alpha,core_ratio_cv=cv,threshold_rule=if(only_above_core)'above_core' else 'all_bins',positive_residual_votes=pos,signed_residual_votes=net,observed_winner_votes=sum(winning),scenario_fraction_of_winner=if(good)pos/sum(winning) else NA_real_,scope_note='CONDITIONAL NONPARAMETRIC SCENARIO; NOT IDENTIFIED FRAUD VOTES')
 list(status=summ$status,bins=each,summary=summ)
}
sp_excess_sensitivity <- function(d,width,cores,autowindow=7.5){
 rows<-list(); for(i in seq_along(cores)){z<-sp_excess(d,width,cores[[i]],autowindow);if(nrow(z$summary)){a<-z$summary;a$scenario_id<-i;rows[[length(rows)+1L]]<-a}}
 if(length(rows))do.call(rbind,rows) else data.frame()
}
