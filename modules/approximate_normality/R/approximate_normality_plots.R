# Empirical histogram probabilities (straight segments), with one colour legend
# for both empirical groups and the standard-normal reference.  A single scale
# prevents ggplot2 from merging two separate guides and drawing every key black.
an_plot_hist <- function(h,lang='EN',title='',subtitle='',caption='',xlim=c(-5,5),
                         labels=NULL,width=.2) {
  an_require('ggplot2')
  if (!nrow(h)) stop('Empty histogram table')
  groups <- unique(as.character(h$group))
  if ('normal_reference' %in% groups) stop('Reserved plot group name: normal_reference')
  h$group <- factor(as.character(h$group),levels=groups)
  normal <- unique(h[,c('bin_index','x','normal_probability')])
  normal <- normal[order(normal$x),,drop=FALSE]

  normal_label <- if (lang=='EN') 'Standard normal reference, N(0,1)' else
    'Standardna normalna raspodela, N(0,1)'
  ylab <- if (lang=='EN') 'Probability per bin' else 'Verovatnoća po intervalu'
  xlab <- if (lang=='EN') 'Rescaled logarithmic vote rate' else 'Standardizovana logaritamska stopa glasova'
  ref_note <- if (lang=='EN') 'Black: N(0,1) expected bin probabilities. Straight lines connect empirical bins; no smoothing.' else
    'Crno: očekivane verovatnoće N(0,1) po intervalu. Empirijske tačke povezane su dužima, bez izglađivanja.'
  cap <- paste(c(caption,ref_note),collapse='  ')

  # Default ggplot hue palette for the empirical groups; black is reserved for
  # the normal reference.  These explicitly mapped colours are used BOTH in the
  # drawn curves and their legend keys; no second colour/linetype guide exists.
  empirical_cols <- stats::setNames(scales::hue_pal()(length(groups)),groups)
  legend_keys <- c(groups,'normal_reference')
  legend_cols <- c(empirical_cols,normal_reference='#000000')
  display_labels <- groups
  if (!is.null(labels)) {
    translated <- unname(labels[groups])
    usable <- !is.na(translated) & nzchar(translated)
    display_labels[usable] <- translated[usable]
  }
  legend_labels <- c(display_labels,normal_label)

  ggplot2::ggplot(h,ggplot2::aes(x=x,y=probability,colour=group,group=group)) +
    ggplot2::geom_line(linewidth=.85,na.rm=TRUE) +
    ggplot2::geom_point(size=.85,alpha=.78,na.rm=TRUE) +
    ggplot2::geom_line(data=normal,
      ggplot2::aes(x=x,y=normal_probability,colour='normal_reference'),
      inherit.aes=FALSE,linewidth=1.2,show.legend=TRUE) +
    ggplot2::scale_colour_manual(
      name=NULL,values=legend_cols,limits=legend_keys,breaks=legend_keys,
      labels=legend_labels,drop=FALSE) +
    ggplot2::coord_cartesian(xlim=xlim) +
    ggplot2::scale_x_continuous(breaks=seq(ceiling(xlim[1]),floor(xlim[2]),by=1)) +
    ggplot2::labs(x=xlab,y=ylab,title=title,subtitle=subtitle,caption=cap) +
    ggplot2::theme_bw(base_size=12) +
    ggplot2::theme(legend.position='bottom',legend.text=ggplot2::element_text(size=10),
      plot.caption=ggplot2::element_text(size=8,hjust=0),plot.title=ggplot2::element_text(face='bold'),
      legend.key.width=grid::unit(1.6,'lines'),legend.box='vertical') +
    ggplot2::guides(colour=ggplot2::guide_legend(ncol=3,byrow=TRUE,
      override.aes=list(shape=NA,linetype='solid')))
}
an_plot_labels <- function(group,lang='EN') {
  en <- c(All='All stations (E >= 100)',Small='Small stations',Large='Large stations',
          Under100='Stations under 100',Reference='All stations (E >= 100)')
  sr <- c(All='Sva BM (E >= 100)',Small='Mala BM',Large='Velika BM',
          Under100='BM sa manje od 100',Reference='Sva BM (E >= 100)')
  labels <- if (lang=='SR') sr else en
  res <- labels[group]
  res[is.na(res)] <- group[is.na(res)]
  res
}
an_plot_area <- function(level,area,lang='EN') {
  if (level=='national') return(if(lang=='EN') 'National' else 'Nacionalno')
  prefix <- if (level=='district') {
    if (lang=='EN') 'District' else 'Okrug'
  } else {
    if (lang=='EN') 'Municipality' else 'Opština'
  }
  paste(prefix,area)
}
an_save_fig <- function(p,path,dpi=220L) {
  dir.create(dirname(path),recursive=TRUE,showWarnings=FALSE)
  ggplot2::ggsave(filename=path,plot=p,width=10.5,height=6.6,dpi=dpi,units='in',limitsize=TRUE)
}
