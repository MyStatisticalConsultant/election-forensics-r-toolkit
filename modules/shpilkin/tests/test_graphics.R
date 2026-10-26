source(file.path('R','shpilkin_core.R'),encoding='UTF-8')
source(file.path('R','shpilkin_plots.R'),encoding='UTF-8')
sp_need('ggplot2')
set.seed(7);x<-pmax(1,pmin(99,stats::rnorm(170,55,12)))
h<-sp_hist(x,rep(1,length(x)),.5)
long<-rbind(data.frame(election='presidential_2017',measure='turnout',h),
 data.frame(election='presidential_2017',measure='leader',h),
 data.frame(election='presidential_2022',measure='turnout',h),
 data.frame(election='presidential_2022',measure='leader',h),
 data.frame(election='parliamentary_2022',measure='turnout',h),
 data.frame(election='parliamentary_2022',measure='leader',h),
 data.frame(election='parliamentary_2023',measure='turnout',h),
 data.frame(election='parliamentary_2023',measure='leader',h))
plots<-list(sp_curve_plot(h,'turnout','EN'),sp_curve_plot(h,'leader','SR'),sp_multi_plot(long,'EN'),sp_multi_plot(long,'SR'))
for(p in plots)stopifnot(inherits(p,'ggplot'))
# Test that the Monte Carlo band and the assumption-dependent excess chart are graphics.
band<-data.frame(bin_center_pct=h$bin_center_pct,observed_registered=h$weighted_count*1000,mean_mc=h$weighted_count*900,q005=h$weighted_count*700,q995=h$weighted_count*1100)
plots[[5]]<-sp_mc_plot(band,'leader','SR')
bins<-data.frame(turnout_bin_center=0:100,turnout_bin_width=rep(1,101),
 winner_votes=1000+10*(0:100),expected_winner=rep(1200,101),
 estimate_region=(0:100)>60)
bins$positive_residual<-pmax(0,bins$winner_votes-bins$expected_winner)
real_excess<-sum(bins$positive_residual[bins$estimate_region])
summary<-data.frame(ratio_winner_to_others=1,core_lower_pct=45,core_upper_pct=60,
 positive_residual_votes=real_excess,scenario_fraction_of_winner=.06)
# Treat formatting warnings as errors; Serbian uses '.' for thousands, ',' for decimals.
strict_excess_plot<-function(lang) withCallingHandlers(
  sp_excess_plot(bins,summary,lang),
  warning=function(w) stop(paste('Unexpected plotting warning:',conditionMessage(w)),call.=FALSE)
)
plots[[6]]<-strict_excess_plot('EN')
plots[[7]]<-strict_excess_plot('SR')
stopifnot(grepl('24,200',plots[[6]]$labels$subtitle,fixed=TRUE),
          grepl('24.200',plots[[7]]$labels$subtitle,fixed=TRUE))
# Polygon shading must track BOTH empirical polylines (not rectangular bins).
# The positive *numeric* total remains the independently calculated sum of
# CSV residuals; graphical polygon area is not the estimator.
for(p in plots[6:7]){
 stopifnot(inherits(p$layers[[1]]$geom,'GeomPolygon'))
 pg<-p$layers[[1]]$data
 stopifnot(nrow(pg)>0L, nrow(pg) %% 4L == 0L,
           min(pg$x) >= 60.5-1e-9, max(pg$x)<=100+1e-9,
           all(pg$y >= 0),
           isTRUE(all.equal(real_excess,as.numeric(summary$positive_residual_votes[1]))))
 # At every polygon vertex, y must lie precisely on the red or blue curve.
 for(j in seq_len(nrow(pg))){
   xpos<-pg$x[j]
   k<-findInterval(xpos,bins$turnout_bin_center)
   k<-max(1L,min(k,nrow(bins)-1L))
   frac<-(xpos-bins$turnout_bin_center[k])/
         (bins$turnout_bin_center[k+1L]-bins$turnout_bin_center[k])
   red<-(bins$winner_votes[k]+frac*(bins$winner_votes[k+1L]-bins$winner_votes[k]))/1000
   blue<-(bins$expected_winner[k]+frac*(bins$expected_winner[k+1L]-bins$expected_winner[k]))/1000
   stopifnot(pg$y[j]>=min(red,blue)-1e-8,
             pg$y[j]<=max(red,blue)+1e-8,
             min(abs(pg$y[j]-red),abs(pg$y[j]-blue))<1e-8)
 }
 stopifnot(grepl('Conditional positive excess|Uslovni pozitivni višak',p$labels$subtitle),
           !grepl('Monte Carlo|Monte Karlo',paste(unlist(p$scales$scales[[1]]$labels),collapse=' ')))
 # Bottom annotations must appear on exactly TWO lines in either language.
 caption_lines <- strsplit(p$labels$caption,'\n',fixed=TRUE)[[1]]
 stopifnot(length(caption_lines)==2L,
           all(nzchar(trimws(caption_lines))),
           all(nchar(caption_lines,type='chars')<=84L),
           grepl('positive',paste(caption_lines,collapse=' '),ignore.case=TRUE) ||
           grepl('pozitivn',paste(caption_lines,collapse=' '),ignore.case=TRUE))
}
# The crossings of the red and blue lines must be inserted at fractional x.
cross<-data.frame(turnout_bin_center=c(70,71,72),turnout_bin_width=rep(1,3),
 winner_votes=c(90,110,90),expected_winner=c(100,100,100),
 estimate_region=c(TRUE,TRUE,TRUE),positive_residual=c(0,10,0))
poly_cross<-sp_excess_shade_polygons(cross,69.5)
stopifnot(nrow(poly_cross)==8L,
          isTRUE(all.equal(min(poly_cross$x),70.5)),
          isTRUE(all.equal(max(poly_cross$x),71.5)))
# A non-positive tail must produce no grey polygon.
bins0<-bins;bins0$winner_votes<-pmax(0,bins0$expected_winner-100)
bins0$positive_residual<-rep(0,nrow(bins0))
summary0<-summary;summary0$positive_residual_votes<-0
p0<-sp_excess_plot(bins0,summary0,'EN')
stopifnot(nrow(p0$layers[[1]]$data)==0L)
tmp<-tempfile('sp_graphics_');dir.create(tmp)
for(i in seq_along(plots)){sp_save(plots[[i]],file.path(tmp,sprintf('test_%d.png',i)),dpi=72L,w=7,h=4);stopifnot(file.info(file.path(tmp,sprintf('test_%d.png',i)))$size>1500)}
unlink(tmp,recursive=TRUE)
cat('PASS: bilingual plots, MC envelopes, curve-following polygon shading with interpolated crossings, correct reference legend, two-line captions and PNG exports.\n')
