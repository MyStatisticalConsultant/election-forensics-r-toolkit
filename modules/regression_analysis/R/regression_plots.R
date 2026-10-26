# Bilingual plotting routines for regression_analysis. Graphics-only adaptations.
# Point estimates and regression diagnostics are supplied by regression_core.R.
ra_labels <- function(lang='EN') {
  if (lang == 'SR') list(
    title_a='Izlaznost i glasovi po upisanom biraču',
    title_b1='Nevažeći listići i udeo glasova pobednika',
    title_b2='Stopa nevažećih listića i udeo glasova pobednika',
    x_a='Izlaznost (%)',y_a='Glasovi / upisani birači (%)',
    x_b1='Broj nevažećih listića',x_b2='Nevažeći listići / ubačeni listići (%)',
    y_b='Glasovi pobednika / važeći glasovi (%)',
    winner='Pobednik',runner='Drugoplasirani',
    groups=c(All_100plus='Sva BM (E >= 100)',Under100='BM sa E < 100',
             Size_Small='Size: mala BM',Size_Large='Size: velika BM',
             JHK_Small='JHK: mala BM',JHK_Large='JHK: velika BM'),
    note_a='OLS po biračkom mestu: W/E ili R/E prema izlaznosti. Mehanička povezanost i heterogenost ograničavaju tumačenje.',
    note_b='OLS opisuje povezanost, ne uzrok. Broj nevažećih listića zavisi od veličine BM; kontrolni modeli su u CSV.'
  ) else list(
    title_a='Turnout and votes per registered voter',
    title_b1='Invalid ballot count and winner vote share',
    title_b2='Invalid ballot rate and winner vote share',
    x_a='Turnout (%)',y_a='Candidate votes / registered voters (%)',
    x_b1='Number of invalid ballots',x_b2='Invalid ballots / ballots cast (%)',
    y_b='Winner votes / valid votes (%)',
    winner='Winner',runner='Runner-up',
    groups=c(All_100plus='All stations (E >= 100)',Under100='Stations E < 100',
             Size_Small='Size: Small',Size_Large='Size: Large',
             JHK_Small='JHK: Small',JHK_Large='JHK: Large'),
    note_a='Station-level OLS: W/E or R/E versus turnout. Mechanical linkage and heterogeneity limit interpretation.',
    note_b='OLS measures association, not causation. Invalid counts depend on station size; adjusted results are in CSV.'
  )
}

ra_plot_df <- function(rows,groups,kind='A') {
  if (!length(groups)) return(data.frame())
  chunks <- list()
  for (g in names(groups)) {
    ix <- groups[[g]] & is.finite(rows$turnout_pct)
    d <- rows[ix,,drop=FALSE]; if (!nrow(d)) next
    d$group <- g
    if (kind == 'A') {
      a <- d[,c('Station_key','group','turnout_pct'),drop=FALSE];names(a)[3L] <- 'x'
      aw <- a;aw$y <- d$winner_of_registered_pct;aw$role <- 'Winner'
      ar <- a;ar$y <- d$runner_of_registered_pct;ar$role <- 'RunnerUp'
      chunks[[length(chunks)+1L]] <- rbind(aw,ar)
    } else {
      col <- if (kind=='B1') 'invalid_count' else 'invalid_rate_pct'
      a <- d[,c('Station_key','group',col,'winner_of_valid_pct'),drop=FALSE]
      names(a) <- c('Station_key','group','x','y');a$role <- 'Winner'
      chunks[[length(chunks)+1L]] <- a
    }
  }
  if (!length(chunks)) return(data.frame())
  do.call(rbind,chunks)
}

ra_wrap_legend <- function(x,width=31L) {
  vapply(x,function(s) {
    if (is.na(s)||!nzchar(s)) return('')
    paste(strwrap(s,width=width),collapse='\n')
  },character(1),USE.NAMES=FALSE)
}

ra_plot_subtitle <- function(sub,set,lang='EN') {
  if (!nzchar(sub)) return(sub)
  if (!identical(set,'JHK')) return(sub)
  suffix <- if (lang=='SR') 'JHK klasifikacija veličine BM' else 'JHK station-size classification'
  paste(sub, suffix, sep=' | ')
}

# Standard facet panels: same OLS coefficients as those written to CSV.
# Annotation inset is ~5 mm at the configured PNG sizes; positions are
# determined per facet so labels do not touch the top/left frame.
ra_make_plot <- function(plotrows,fits,lang='EN',kind='A',sub='',set='Size',
                         min_n=30L,role_labels=NULL,keys_override=NULL,
                         panel_only=FALSE) {
  ra_require('ggplot2')
  if (!nrow(plotrows)) return(NULL)
  lab <- ra_labels(lang)
  role_text <- c(Winner=lab$winner,RunnerUp=lab$runner)
  if (!is.null(role_labels)) {
    for (r in c('Winner','RunnerUp')) {
      nm <- role_labels[[r]]
      if (!is.null(nm) && length(nm)==1L && !is.na(nm) && nzchar(trimws(nm)))
        role_text[[r]] <- paste0(role_text[[r]],' — ',nm)
    }
  }
  role_text <- stats::setNames(ra_wrap_legend(unname(role_text)),names(role_text))
  keys <- if (!is.null(keys_override)) keys_override else if (set=='JHK')
    c('All_100plus','JHK_Small','JHK_Large') else
    c('All_100plus','Size_Small','Size_Large','Under100')
  keys <- keys[keys %in% unique(as.character(plotrows$group))]
  if (!length(keys)) return(NULL)

  # Three-panel JHK composition: All + Small above, Large centred below.
  # Under-100 sensitivity continues to appear in the Size figures.
  if (set=='JHK' && is.null(keys_override)) {
    groups <- c('All_100plus','JHK_Small','JHK_Large')
    if (!all(groups %in% keys)) {
      # Do not silently substitute an incomplete two-panel figure.
      warning('JHK figure requires All, Small, Large data. Missing: ',
              paste(setdiff(groups,keys),collapse=', '),call.=FALSE)
      return(NULL)
    }
    panels <- lapply(groups,function(g) {
      ra_make_plot(plotrows[plotrows$group==g,,drop=FALSE],fits,
                   lang=lang,kind=kind,sub='',set='JHK_SINGLE',min_n=min_n,
                   role_labels=role_labels,keys_override=g,panel_only=TRUE)
    })
    names(panels) <- groups
    title <- if(kind=='A')lab$title_a else if(kind=='B1')lab$title_b1 else lab$title_b2
    output <- list(panels=panels,groups=groups,kind=kind,lang=lang,
       title=title,subtitle=ra_plot_subtitle(sub,'JHK',lang),caption=if(kind=='A')lab$note_a else lab$note_b,
       role_labels=role_text)
    class(output) <- 'ra_jhk_figure'
    return(output)
  }

  plotrows <- plotrows[plotrows$group %in% keys & is.finite(plotrows$x) &
                         is.finite(plotrows$y),,drop=FALSE]
  if (!nrow(plotrows)) return(NULL)
  plotrows$group <- factor(plotrows$group,levels=keys,labels=unname(lab$groups[keys]))
  plotrows$role <- factor(plotrows$role,levels=c('Winner','RunnerUp'),
                          labels=unname(role_text[c('Winner','RunnerUp')]))
  colors <- stats::setNames(c('#DA3035','#2366D6'),unname(role_text))
  base_size <- 11*1.5
  p <- ggplot2::ggplot(plotrows,ggplot2::aes(x=x,y=y)) +
    ggplot2::geom_point(ggplot2::aes(colour=role),size=.75*1.5,alpha=.24) +
    ggplot2::facet_wrap(~group,ncol=if(panel_only)1L else 2L,scales='free_x') +
    (if(kind=='A')ggplot2::coord_cartesian(ylim=c(0,100)) else ggplot2::coord_cartesian()) +
    ggplot2::theme_bw(base_size=base_size) +
    ggplot2::theme(
      plot.title=ggplot2::element_text(face='bold',size=14*1.5),
      plot.subtitle=ggplot2::element_text(size=base_size),
      axis.title=ggplot2::element_text(size=base_size),
      axis.text=ggplot2::element_text(size=base_size*.88),
      strip.text=ggplot2::element_text(face='bold',size=base_size),
      legend.text=ggplot2::element_text(size=base_size*.88),
      legend.position=if(panel_only)'none' else 'bottom',
      plot.caption=ggplot2::element_text(size=9.25*1.5,colour='grey30',hjust=0),
      plot.margin=ggplot2::margin(15,18,20,16)) +
    ggplot2::scale_colour_manual(values=colors,name=NULL,drop=TRUE) +
    ggplot2::guides(colour=ggplot2::guide_legend(nrow=1,byrow=TRUE,
      override.aes=list(alpha=1,size=2*1.5))) +
    ggplot2::labs(
      title=if(panel_only)NULL else if(kind=='A')lab$title_a else if(kind=='B1')lab$title_b1 else lab$title_b2,
      subtitle=if(panel_only)NULL else ra_plot_subtitle(sub,set,lang),
      x=if(panel_only)NULL else if(kind=='A')lab$x_a else if(kind=='B1')lab$x_b1 else lab$x_b2,
      y=if(panel_only)NULL else if(kind=='A')lab$y_a else lab$y_b,
      caption=if(panel_only)NULL else if(kind=='A')lab$note_a else lab$note_b)

  lines <- list(); texts <- list()
  for (g in keys) {
    all_group <- plotrows[plotrows$group==lab$groups[[g]],,drop=FALSE]
    if(!nrow(all_group))next
    xr <- range(all_group$x,na.rm=TRUE); yr <- range(all_group$y,na.rm=TRUE)
    dx <- diff(xr);dy <- diff(yr)
    if(!is.finite(dx)||dx==0)dx <- 1
    if(!is.finite(dy)||dy==0)dy <- 1
    roles_here <- if(kind=='A') c('Winner','RunnerUp') else 'Winner'
    # Two 2-line equations need space in physical (not group-data) height.
    # Shared 0..100 percent axes make these anchors identical in all A facets.
    a_positions <- c(Winner=92,RunnerUp=64)
    b_position <- 0.12
    for (role in roles_here) {
      fit <- fits[[paste(g,kind,role,sep='|')]]
      if(is.null(fit)||is.null(fit$fit)||fit$meta$status!='OK')next
      cf <- stats::coef(fit$fit)
      reg <- if(kind=='A')'turnout_pct' else if(kind=='B1')'invalid_count' else 'invalid_rate_pct'
      if(!reg%in%names(cf) || !is.finite(cf[[reg]]) || !is.finite(cf[[1L]]))next
      visual_role <- unname(role_text[[role]])
      lines[[length(lines)+1L]] <- data.frame(group=lab$groups[[g]],role=visual_role,
        intercept=unname(cf[[1L]]),slope=unname(cf[[reg]]),stringsAsFactors=FALSE)
      mf <- fit$meta
      pvalue <- if(is.finite(mf$f_p) && mf$f_p<.001)'p<.001' else
        if(is.finite(mf$f_p))sprintf('p=%.3f',mf$f_p) else 'p=NA'
      label <- paste(sprintf('y=%.2f %+.3f x  |  adj.R²=%.2f',
                             unname(cf[[1L]]),unname(cf[[reg]]),mf$adj_r2),
                     sprintf('F=%.1f  |  %s  |  n=%d',mf$f_stat,pvalue,as.integer(mf$n)),sep='\n')
      if(kind=='A') {
        xpos <- xr[1L] + dx*0.05
        ypos <- a_positions[[role]]
        hj <- 0; vj <- 1
      } else {
        xpos <- xr[2L] - dx*0.04
        ypos <- yr[1L] + dy*b_position
        hj <- 1; vj <- 0
      }
      texts[[length(texts)+1L]] <- data.frame(group=lab$groups[[g]],role=visual_role,
         label=label,x=xpos,y=ypos,hjust=hj,vjust=vj,stringsAsFactors=FALSE)
    }
  }
  if(length(lines)) {
    li <- do.call(rbind,lines)
    li$group <- factor(li$group,levels=unname(lab$groups[keys]))
    li$role <- factor(li$role,levels=unname(role_text))
    p <- p+ggplot2::geom_abline(data=li,
      ggplot2::aes(intercept=intercept,slope=slope,colour=role),
      linewidth=.8*1.5,show.legend=FALSE)
  }
  if(length(texts)) {
    ann <- do.call(rbind,texts)
    ann$group <- factor(ann$group,levels=unname(lab$groups[keys]))
    ann$role <- factor(ann$role,levels=unname(role_text))
    p <- p+ggplot2::geom_text(data=ann,
       ggplot2::aes(x=x,y=y,label=label,colour=role,hjust=hjust,vjust=vjust),
       size=2.65*1.5,lineheight=1.04,
       show.legend=FALSE,inherit.aes=FALSE)
  }
  p
}

ra_save_jhk <- function(fig,path,dpi=220L,w=17.5,h=13.0) {
  # One shared pair of axis titles, not three overlapping copies.  Two equal
  # plots above and the third centred below, with a single-row common legend.
  dir.create(dirname(path),recursive=TRUE,showWarnings=FALSE)
  grDevices::png(path,width=w,height=h,units='in',res=dpi,bg='white')
  on.exit(grDevices::dev.off(),add=TRUE)
  grid::grid.newpage()
  lay <- grid::grid.layout(nrow=4L,ncol=6L,
    widths=grid::unit.c(grid::unit(.86,'in'),grid::unit(1,'null'),
      grid::unit(1,'null'),grid::unit(1,'null'),grid::unit(1,'null'),
      grid::unit(.24,'in')),
    heights=grid::unit.c(grid::unit(1.12,'in'),grid::unit(1,'null'),
      grid::unit(1,'null'),grid::unit(1.80,'in')))
  grid::pushViewport(grid::viewport(layout=lay))
  grid::pushViewport(grid::viewport(layout.pos.row=1,layout.pos.col=2:5))
  grid::grid.text(fig$title,x=.01,y=.76,just=c('left','center'),
    gp=grid::gpar(fontsize=21,fontface='bold'))
  grid::grid.text(fig$subtitle,x=.01,y=.22,just=c('left','center'),
    gp=grid::gpar(fontsize=16.5))
  grid::upViewport()
  where <- list(c(2,2,3),c(2,4,5),c(3,3,4))
  for(j in seq_along(fig$panels)) {
    coords <- where[[j]]
    grid::pushViewport(grid::viewport(layout.pos.row=coords[1],
      layout.pos.col=coords[2]:coords[3]))
    grid::grid.draw(ggplot2::ggplotGrob(fig$panels[[j]]))
    grid::upViewport()
  }
  lab <- ra_labels(fig$lang)
  grid::pushViewport(grid::viewport(layout.pos.row=2:3,layout.pos.col=1))
  grid::grid.text(if(fig$kind=='A')lab$y_a else lab$y_b,
    x=.40,y=.50,rot=90,just='center',gp=grid::gpar(fontsize=16.5))
  grid::upViewport()
  grid::pushViewport(grid::viewport(layout.pos.row=4,layout.pos.col=2:5))
  xlabel <- if(fig$kind=='A')lab$x_a else
    if(fig$kind=='B1')lab$x_b1 else lab$x_b2
  grid::grid.text(xlabel,x=.50,y=.93,
    gp=grid::gpar(fontsize=16.5))
  # Both legend entries occupy the same horizontal band; their text can
  # wrap *within* each item, never into a second legend row.
  if(fig$kind=='A') {
    labels <- fig$role_labels
    grid::grid.lines(x=grid::unit(c(.08,.113),'npc'),
      y=grid::unit(c(.62,.62),'npc'),gp=grid::gpar(col='#DA3035',lwd=3))
    grid::grid.text(labels[['Winner']],x=.124,y=.62,just='left',
      gp=grid::gpar(fontsize=16.5))
    grid::grid.lines(x=grid::unit(c(.53,.563),'npc'),
      y=grid::unit(c(.62,.62),'npc'),gp=grid::gpar(col='#2366D6',lwd=3))
    grid::grid.text(labels[['RunnerUp']],x=.575,y=.62,just='left',
      gp=grid::gpar(fontsize=16.5))
  }
  # Never force a wrapping boundary after 108 characters (previously sent
  # the word "CSV." alone to another row).  The 17.5-in canvas gives room.
  grid::grid.text(fig$caption,x=.01,y=.16,just='left',
    gp=grid::gpar(fontsize=14.0,col='grey30'))
  grid::upViewport(2L)
  invisible(file.exists(path))
}

ra_save_png <- function(p,path,dpi=220L,w=15,h=10.4) {
  if(is.null(p)) return(FALSE)
  if(inherits(p,'ra_jhk_figure'))return(ra_save_jhk(p,path,dpi,w=17.5,h=13.0))
  dir.create(dirname(path),recursive=TRUE,showWarnings=FALSE)
  ggplot2::ggsave(filename=path,plot=p,width=w,height=h,units='in',
                  dpi=dpi,bg='white',limitsize=FALSE)
  file.exists(path)
}
