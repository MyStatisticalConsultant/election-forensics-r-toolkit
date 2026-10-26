# Run from modules/regression_analysis.
Sys.setenv(EF_REGRESSION_TEST_MODE='1')
source('Regression_analysis.R',encoding='UTF-8')
set.seed(123)
n<-120L; e<-c(rep(90L,15),seq(100,515,length.out=105))
e<-round(e);c<-round(e*seq(.4,.82,length.out=n))
# Test an identification condition that the REAL model enforces: at least
# MIN_UNIQUE_X distinct x-values. The previous 3-ballot ceiling accidentally
# created only four values (0,1,2,3), so B1 was correctly skipped.
b<-c-pmin(12L,pmax(0L,round(c*.02)))
w<-pmin(b-1L,round(b*seq(.46,.65,length.out=n)));r<-pmin(b-w,round(b*.20))
d<-data.frame(Station_key=sprintf('st%03d',seq_len(n)),District_code='00',Municipality_code=rep(sprintf('m%02d',1:6),each=20),
 E=e,B=b,C=c,Winner_votes=w,Option_06_votes=w,Option_02_votes=r,Option_03_votes=b-w-r,
 Size=rep(c('Small','Middle','Large'),length.out=n),Size_JHK=ifelse(rank(e)<=24,'Small','Large'))
ch<-ra_choose_options(d,'presidential_2022',winner_fallbacks=list(presidential_2022='Option_06_votes'))
stopifnot(ch$option_field[1L]=='Option_06_votes',ch$option_field[2L]=='Option_03_votes')
p<-ra_prepare(d,'presidential_2022',ch,'C/E')
stopifnot(all.equal(p$turnout_pct,100*p$C/p$E),all.equal(p$winner_of_registered_pct,100*p$W/p$E),
 all.equal(p$winner_of_valid_pct,100*p$W/p$B),all.equal(p$invalid_rate_pct,100*(p$C-p$B)/p$C),all(p$valid_counts))
g<-ra_groups(p,TRUE);stopifnot(sum(g$Under100)==15,sum(g$JHK_Small)==9,
 sum(g$Size_Small)<sum(g$All_100plus),sum(g$Size_Large)<sum(g$All_100plus))
stopifnot(sum(g$JHK_Large)==96L)
q<-ra_prepare(d,'presidential_2022',ch,'B/E')
stopifnot(all.equal(q$turnout_pct,100*q$B/q$E),identical(p$winner_of_valid_pct,q$winner_of_valid_pct))
# Recover exact OLS slope and covariance on controlled fixture.
xx<-seq(20,99,length.out=80)
# Orthogonal, nonzero deterministic noise preserves the EXACT OLS coefficients
# (3 and 0.75), while avoiding an essentially perfect residual-free fit.
noise<-stats::residuals(stats::lm(sin(seq_along(xx)*1.37)~xx))
z<-data.frame(Station_key=sprintf('a%03d',1:80),turnout_pct=xx,
 winner_of_registered_pct=3+0.75*xx+0.35*noise,Municipality_code=rep('A',80))
f<-ra_fit(z,'formula_check',winner_of_registered_pct~turnout_pct)
stopifnot(f$meta$status=='OK',abs(stats::coef(f$fit)['turnout_pct']-.75)<1e-10,
 abs(stats::coef(f$fit)['(Intercept)']-3)<1e-10,nrow(f$rows)==80,
 is.finite(f$coeff$se_hc3[2L]),nrow(f$coeff)==2L)
# Invalid-count and rate are different regressors; test both independently.
stopifnot(length(unique(p$invalid_count[p$valid_counts]))>=5L)
fb1<-ra_fit(p,'B1_test',winner_of_valid_pct~invalid_count)
fb2<-ra_fit(p,'B2_test',winner_of_valid_pct~invalid_rate_pct)
stopifnot(fb1$meta$status=='OK',fb2$meta$status=='OK',
 any(fb1$coeff$term=='invalid_count'),any(fb2$coeff$term=='invalid_rate_pct'))
# A degenerate x with <5 distinct values must be SKIPPED, not forced into a fit.
low_var<-p;low_var$invalid_count<-as.numeric(low_var$invalid_count %% 3L)
skip<-ra_fit(low_var,'low_variation',winner_of_valid_pct~invalid_count)
stopifnot(skip$meta$status=='INSUFFICIENT_X_VARIATION',is.null(skip$fit))
# Test filter/skip is explicit, not silently fitted with two observations.
short<-ra_fit(p[1:8,],'low_n',winner_of_valid_pct~invalid_count)
stopifnot(short$meta$status=='INSUFFICIENT_N',is.null(short$fit))
# QC must reject winner+runner votes > valid ballots. Always corrupt the
# dynamically selected runner-up, NOT an arbitrary option (e.g. Option_02).
bad<-d
runner_field<-ch$option_field[ch$role=='RunnerUp']
winner_field<-ch$option_field[ch$role=='Winner']
stopifnot(length(runner_field)==1L,length(winner_field)==1L,
          runner_field%in%names(bad),winner_field%in%names(bad),
          bad[[winner_field]][1L]>0)
bad[[runner_field]][1L]<-bad$B[1L]
pp<-ra_prepare(bad,'presidential_2022',ch,'C/E')
stopifnot(isFALSE(pp$valid_counts[1L]),pp$exclusion_reason[1L]=='INVALID_COUNTS')
# JHK labels remain fixed when a municipality is selected.
stopifnot(identical(p$Size_JHK[p$Municipality_code=='m01'],as.character(d$Size_JHK[d$Municipality_code=='m01'])))
# Labels are taken from the Options dictionary, never guessed from Option_XX.
options_fixture<-data.frame(Option_number=c(6L,3L),
 Option_name=c('Александар Вучић','Drugi kandidat'),
 Total_votes=c(1000,450),stringsAsFactors=FALSE)
labeled<-ra_option_labels_from_table(options_fixture,ch,election='synthetic')
stopifnot(identical(labeled$display_label,c('Aleksandar Vučić','Drugi kandidat')),
 identical(labeled$label_source,c('Options:Option_name','Options:Option_name')))
overridden<-ra_option_labels_from_table(options_fixture,ch,
 overrides=c(Option_06_votes='Verified winner'),election='synthetic')
stopifnot(overridden$display_label[1L]=='Verified winner',
          overridden$display_label[2L]=='Drugi kandidat',
          identical(overridden$label_source,
                    c('OPTION_LABELS_OVERRIDE','Options:Option_name')))
# Regression for the v0.1.4 failure: partial named character-vector lookup
# must not attempt [[missing_field]], which throws subscript out of bounds.
runner_only<-ra_option_labels_from_table(options_fixture,ch,
 overrides=c(Option_03_votes='Verified runner'),election='synthetic')
stopifnot(identical(runner_only$display_label,c('Aleksandar Vučić','Verified runner')),
 identical(runner_only$label_source,c('Options:Option_name','OPTION_LABELS_OVERRIDE')))
list_override<-ra_option_labels_from_table(options_fixture,ch,
 overrides=list(Option_06_votes='Winner from list'),election='synthetic')
stopifnot(identical(list_override$display_label,c('Winner from list','Drugi kandidat')))
both_override<-ra_option_labels_from_table(NULL,ch,
 overrides=c(Option_06_votes='Verified winner',Option_03_votes='Verified runner'),
 election='synthetic')
stopifnot(identical(both_override$display_label,c('Verified winner','Verified runner')))
unnamed_override<-tryCatch(ra_option_labels_from_table(options_fixture,ch,
 overrides=c('Unlabelled'),election='synthetic'),error=function(e)e)
stopifnot(inherits(unnamed_override,'error'),
 grepl('requires unique',conditionMessage(unnamed_override),fixed=TRUE))
missing_name<-tryCatch(ra_option_labels_from_table(options_fixture[,c('Option_number','Total_votes')],
 ch,election='synthetic'),error=function(e)e)
stopifnot(inherits(missing_name,'error'),grepl('Missing verified',conditionMessage(missing_name),fixed=TRUE))
cat('PASS: winner/runner-up, Lukinova coefficients, turnout A/B, valid B1/B2 fixtures, insufficient-x skips, HC3, QC, Size/JHK groups, partial named option overrides.\n')
