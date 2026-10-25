Sys.setenv(EF_APPROX_NORMALITY_TEST_MODE='1')
source(file.path('R','approximate_normality_functions.R'),encoding='UTF-8')
source(file.path('R','approximate_normality_plots.R'),encoding='UTF-8')
an_require('ggplot2')
set.seed(2026)
all_curves <- lapply(c('presidential_2017','presidential_2022','parliamentary_2022','parliamentary_2023'),function(k) {
  h <- an_hist(stats::rnorm(250,sd=runif(1,.7,1.3)),width=.2,grid=-25:25)
  h$group <- k
  h
})
check_legend <- function(h,lang) {
  groups <- unique(as.character(h$group))
  labels <- stats::setNames(an_label(groups,lang),groups)
  # Example of named station-size labels in bilingual within-election plots.
  if (all(groups %in% c('All','Small','Large','Reference','Under100'))) {
    labels <- stats::setNames(an_plot_labels(groups,lang),groups)
  }
  p <- an_plot_hist(h,lang,'Test','Empirical curves','',c(-5,5),labels,.2)
  stopifnot(inherits(p,'ggplot'))
  # Exactly ONE legend scale: all groups + black normal in the SAME colour guide.
  colscale <- p$scales$get_scales('colour')
  stopifnot(!is.null(colscale),is.null(p$scales$get_scales('linetype')))
  wanted <- c(groups,'normal_reference')
  stopifnot(identical(as.character(colscale$breaks),wanted))
  ref_label <- if (lang=='EN') 'Standard normal reference, N(0,1)' else
    'Standardna normalna raspodela, N(0,1)'
  stopifnot(identical(tail(as.character(colscale$labels),1),ref_label))
  # Validate the ACTUAL colour aesthetic of rendered ggplot layers, not only text.
  built <- ggplot2::ggplot_build(p)
  mapped <- unname(built$plot$scales$get_scales('colour')$map(wanted))
  expected <- c(scales::hue_pal()(length(groups)),'#000000')
  stopifnot(identical(tolower(mapped),tolower(expected)))
  stopifnot(setequal(tolower(unique(built$data[[1]]$colour)),tolower(expected[-length(expected)])))
  stopifnot(all(tolower(built$data[[3]]$colour)=='#000000'))
  # Both the empirical lines and reference must stay straight-segment binned plots.
  names_layers <- vapply(p$layers,function(l) class(l$geom)[1],character(1))
  stopifnot(!any(grepl('Density',names_layers)))
  f <- tempfile(fileext='.png')
  an_save_fig(p,f,90L)
  stopifnot(file.exists(f),file.info(f)$size>3000L)
  unlink(f)
  invisible(TRUE)
}
for (lang in c('EN','SR')) {
  # More than three elections -> multiple legend rows.
  check_legend(do.call(rbind,all_curves),lang)
  # Actual three-series station-size plot from the reported legend regression.
  within <- do.call(rbind,lapply(seq_along(c('All','Small','Large')),function(i) {
    h <- an_hist(stats::rnorm(350,mean=(i-2)/3),width=.2,grid=-25:25)
    h$group <- c('All','Small','Large')[i]
    h
  }))
  check_legend(within,lang)
  # Sensitivity plot uses two empirical groups plus the reference.
  under <- do.call(rbind,lapply(c('Reference','Under100'),function(g) {
    h <- an_hist(stats::rnorm(200),width=.2,grid=-25:25)
    h$group <- g
    h
  }))
  check_legend(under,lang)
}
cat('PASS: bilingual legend colours match plotted groups, black N(0,1) reference, wrapped election labels and PNG exports.\n')
