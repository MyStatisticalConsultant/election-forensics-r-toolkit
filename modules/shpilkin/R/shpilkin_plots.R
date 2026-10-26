# Visualization routines: all plotted numerical values are also exported as CSV.
sp_plot_labels <- function(lang='EN'){
 if(lang=='SR')list(turnout='Izlaznost (%)',leader='Glasovi pobednika (%)',density='Gustina verovatnoće',year='Izbori',registered='Upisani birači (milioni)',w='Glasovi',observed='Posmatrano',expected='Referentna kriva: skalirani ostali glasovi',band='MC interval 99%',n='Broj biračkih mesta',title='Špilkin – raspodele po procentnim intervalima',ref='Simulacioni referentni interval',excess='Uslovna procena viška glasova',comparison='Poređenje izbora',turnoutfacet='Izlaznost',leaderfacet='Udeo glasova pobednika') else
 list(turnout='Turnout (%)',leader="Winner's vote share (%)",density='Probability density',year='Election',registered='Registered voters (millions)',w='Votes',observed='Observed',expected='Baseline: scaled other votes',band='MC 99% interval',n='Number of polling stations',title='Shpilkin – percentage distributions',ref='Simulated reference interval',excess='Conditional excess-votes scenario',comparison='Election comparison',turnoutfacet='Turnout',leaderfacet='Winner vote share')
}
sp_pretty <- function(z,lang='EN'){
 out<-gsub('_',' ',z,fixed=TRUE);out<-sub('^presidential','Presidential',out);out<-sub('^parliamentary','Parliamentary',out)
 if(lang=='SR'){out<-sub('^Presidential','Predsednički',out);out<-sub('^Parliamentary','Parlamentarni',out)}
 out
}
sp_fig_theme <- function(){ggplot2::theme_bw(base_size=12)+ggplot2::theme(legend.position='bottom',legend.box='vertical',plot.title=ggplot2::element_text(face='bold'),plot.caption=ggplot2::element_text(size=8,hjust=0),legend.key.width=grid::unit(1.6,'lines'))}
sp_save <- function(p,path,dpi=220L,w=10.5,h=6.0){dir.create(dirname(path),recursive=TRUE,showWarnings=FALSE);ggplot2::ggsave(path,plot=p,width=w,height=h,dpi=dpi,units='in')}
sp_curve_plot <- function(hist,measure,lang='EN',subtitle='',caption=''){
 x<-sp_plot_labels(lang);lab<-if(measure=='turnout')x$turnout else x$leader
 ggplot2::ggplot(hist,ggplot2::aes(x=bin_center_pct,y=density))+
  ggplot2::geom_line(colour='#2563EB',linewidth=.9)+
  ggplot2::labs(title=x$title,subtitle=subtitle,x=lab,y=x$density,caption=caption)+
  ggplot2::coord_cartesian(xlim=c(0,100))+sp_fig_theme()
}
sp_multi_plot <- function(hist_long,lang='EN'){
 x<-sp_plot_labels(lang)
 tmp<-hist_long;tmp$facet<-ifelse(tmp$measure=='turnout',x$turnoutfacet,x$leaderfacet)
 tmp$facet<-factor(tmp$facet,levels=c(x$leaderfacet,x$turnoutfacet))
 tmp$election<-factor(tmp$election,levels=unique(tmp$election))
 color_count<-length(levels(tmp$election))
 palette<-grDevices::hcl.colors(color_count,'Dark 3')
 lg<-setNames(vapply(levels(tmp$election),sp_pretty,character(1),lang=lang),levels(tmp$election))
 ggplot2::ggplot(tmp,ggplot2::aes(x=bin_center_pct,y=density,colour=election,group=election))+
  ggplot2::geom_line(linewidth=.9)+ggplot2::facet_wrap(~facet,ncol=1,scales='free_y')+
  ggplot2::scale_colour_manual(values=palette,breaks=levels(tmp$election),labels=lg)+
  ggplot2::coord_cartesian(xlim=c(0,100))+
  ggplot2::labs(title=x$comparison,x=x$turnout,y=x$density,colour=x$year,
    caption=if(lang=='EN')'Station-weighted histogram density. Bins are configurable; this is descriptive, not an integer-anomaly test.' else
           'Gustina histograma po BM. Intervali su podesivi; ovo je opisni prikaz, a ne test celobrojnih anomalija.')+
  sp_fig_theme()+ggplot2::guides(colour=ggplot2::guide_legend(nrow=ceiling(color_count/3),byrow=TRUE))
}
sp_mc_plot <- function(band,measure,lang='EN',subtitle=''){
 x<-sp_plot_labels(lang);title<-if(measure=='turnout')x$turnout else x$leader
 b<-band;b$observed_registered<-b$observed_registered/1e6;b$mean_mc<-b$mean_mc/1e6;b$q005<-b$q005/1e6;b$q995<-b$q995/1e6
 ggplot2::ggplot(b,ggplot2::aes(x=bin_center_pct))+
  ggplot2::geom_ribbon(ggplot2::aes(ymin=q005,ymax=q995),fill='grey65',alpha=.32)+
  ggplot2::geom_line(ggplot2::aes(y=mean_mc),colour='black',linewidth=.65)+
  ggplot2::geom_line(ggplot2::aes(y=observed_registered),colour='#D62828',linewidth=.65)+
  ggplot2::scale_x_continuous(breaks=seq(0,100,by=10))+
  ggplot2::coord_cartesian(xlim=c(0,100))+
  ggplot2::labs(title=paste(title,'–',x$ref),subtitle=subtitle,x=title,y=x$registered,
    caption=if(lang=='EN')'Red: observed; black: binomial Monte Carlo mean; grey: simulated 0.5–99.5% envelope. 0.1 pp centered bins.' else
    'Crveno: posmatrano; crno: Monte Karlo srednja vrednost; sivo: simulacioni interval 0,5–99,5%. Intervali 0,1 pp.')+
  sp_fig_theme()
}
# Curve-following shading for positive high-turnout excesses. Each trapezoid or
# triangle follows linear interpolation of the two curves between adjacent bin
# centres; crossings are interpolated explicitly. This is graphical shading,
# NOT the numerical estimator, which sums the stored positive bin residuals.
sp_excess_shade_polygons <- function(bins, core_upper) {
 empty <- data.frame(x=numeric(0), y=numeric(0), polygon_id=integer(0))
 needed <- c('turnout_bin_center','turnout_bin_width','winner_votes',
             'expected_winner','estimate_region')
 if (!all(needed %in% names(bins))) stop('Missing excess-shading columns')
 if (!nrow(bins) || !is.finite(core_upper)) return(empty)
 b <- bins[order(bins$turnout_bin_center),,drop=FALSE]
 reg <- !is.na(b$estimate_region) &
        as.character(b$estimate_region) %in% c('TRUE','1')
 if (!any(reg) || nrow(b) < 2L) return(empty)
 # Do not interpolate into non-estimation bins. The first shaded x is the
 # left edge of the earliest eligible high-turnout bin, never below core end.
 first_high_edge <- min(b$turnout_bin_center[reg] -
                        b$turnout_bin_width[reg]/2)
 left_limit <- max(core_upper, first_high_edge)
 polys <- list()
 for (i in seq_len(nrow(b)-1L)) {
   if (!reg[i+1L]) next
   x1 <- b$turnout_bin_center[i]; x2 <- b$turnout_bin_center[i+1L]
   w1 <- b$turnout_bin_width[i]; w2 <- b$turnout_bin_width[i+1L]
   v <- c(x1,x2,w1,w2,b$winner_votes[i],b$winner_votes[i+1L],
          b$expected_winner[i],b$expected_winner[i+1L])
   if (!all(is.finite(v)) || x2<=x1 || w1<=0 || w2<=0 ||
       x2-x1 > 1.000001*max(w1,w2)) next
   lo <- max(x1,left_limit); hi <- x2
   if (lo>=hi) next
   # Linear interpolation, in THOUSANDS of votes (the plotted units).
   observed <- function(x) (b$winner_votes[i] +
                (b$winner_votes[i+1L]-b$winner_votes[i])*(x-x1)/(x2-x1))/1000
   expected <- function(x) (b$expected_winner[i] +
                (b$expected_winner[i+1L]-b$expected_winner[i])*(x-x1)/(x2-x1))/1000
   dl <- observed(lo)-expected(lo); dr <- observed(hi)-expected(hi)
   if (max(dl,dr)<=0) next
   left <- lo; right <- hi
   if (dl < 0 && dr > 0) left <- lo - dl*(hi-lo)/(dr-dl)
   if (dl > 0 && dr < 0) right <- lo - dl*(hi-lo)/(dr-dl)
   if (right-left<=1e-12) next
   # One polygon per adjacent segment; no rectangles or fill beyond a curve.
   polys[[length(polys)+1L]] <- data.frame(
     x=c(left,right,right,left),
     y=c(observed(left),observed(right),expected(right),expected(left)),
     polygon_id=length(polys)+1L)
 }
 if (!length(polys)) return(empty)
 do.call(rbind,polys)
}

sp_excess_plot <- function(bins,summary,lang='EN',subtitle=''){
 x<-sp_plot_labels(lang)
 b<-bins
 if(!nrow(b)||!nrow(summary)||!is.finite(summary$ratio_winner_to_others[1]))return(NULL)
 required<-c('turnout_bin_center','turnout_bin_width','winner_votes',
             'expected_winner','estimate_region','positive_residual')
 if(!all(required %in% names(b)))stop('Excess plotting requires exported excess_turnout_bins columns')
 if(!'positive_residual_votes' %in% names(summary))stop('Excess summary is missing positive_residual_votes')
 # Shade the positive portion BETWEEN the piecewise-linear red and blue
 # curves, clipped at the high-turnout boundary; never draw grey rectangles.
 shade <- sp_excess_shade_polygons(b,as.numeric(summary$core_upper_pct[1]))
 total<-as.numeric(summary$positive_residual_votes[1])
 share<-if('scenario_fraction_of_winner' %in% names(summary))
             as.numeric(summary$scenario_fraction_of_winner[1]) else NA_real_
 total_label<-if(is.finite(total)) format(round(total),big.mark=if(lang=='EN')',' else '.',decimal.mark=if(lang=='EN')'.' else ',',scientific=FALSE,trim=TRUE) else 'NA'
 share_label<-if(is.finite(share)) sprintf(' (%.2f%%)',100*share) else ''
 amount_label<-if(lang=='EN')paste0('Conditional positive excess: ',total_label,' votes',share_label) else
                          paste0('Uslovni pozitivni višak: ',total_label,' glasova',share_label)
 # Explicit two-line captions. Each line is short enough for EN/SR exports.
 # Caption layout is independent of the numeric residual calculation.
 note <- if (lang=='EN') paste(
   'Grey: positive gap between curves beyond the reference range.',
   'Excess sums positive bin residuals, not polygon area; it does not prove fraud.',
   sep='\n'
 ) else paste(
   'Sivo: pozitivna razlika krivih iznad referentnog raspona.',
   'Višak je zbir pozitivnih reziduala, ne površina; nije dokaz prevare.',
   sep='\n'
 )
 ggplot2::ggplot(b,ggplot2::aes(x=turnout_bin_center))+
  ggplot2::geom_polygon(data=shade,ggplot2::aes(x=x,y=y,group=polygon_id),
                        inherit.aes=FALSE,fill='grey55',alpha=.48,colour=NA)+
  ggplot2::geom_line(ggplot2::aes(y=winner_votes/1000,colour=x$observed),linewidth=1)+
  ggplot2::geom_line(ggplot2::aes(y=expected_winner/1000,colour=x$expected),linewidth=1)+
  ggplot2::geom_vline(xintercept=c(summary$core_lower_pct[1],summary$core_upper_pct[1]),
                       linetype='dotted',colour='grey40')+
  ggplot2::scale_colour_manual(values=setNames(c('#D62828','#2563EB'),c(x$observed,x$expected)),
                                breaks=c(x$observed,x$expected))+
  ggplot2::labs(title=x$excess,subtitle=paste(subtitle,amount_label,sep='\n'),
                x=x$turnout,y=paste(x$w,'(thousands)'),colour=NULL,caption=note)+
  ggplot2::coord_cartesian(xlim=c(0,100))+sp_fig_theme()+
  ggplot2::theme(
    plot.caption=ggplot2::element_text(size=8,hjust=0,lineheight=1.2,
                                        margin=ggplot2::margin(t=8,unit='pt')),
    plot.margin=ggplot2::margin(t=8,r=12,b=12,l=10,unit='pt')
  )
}
