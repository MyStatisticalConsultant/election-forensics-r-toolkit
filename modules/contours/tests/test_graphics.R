# v0.1.4 — synthetic geometry and export tests; no official RZS data required.
# Tests restore EF_CONTOUR_TEST_MODE even if an assertion fails.
(function() {
  previous_flag <- Sys.getenv("EF_CONTOUR_TEST_MODE", unset=NA_character_)
  on.exit({
    if(is.na(previous_flag)) Sys.unsetenv("EF_CONTOUR_TEST_MODE")
    else Sys.setenv(EF_CONTOUR_TEST_MODE=previous_flag)
  }, add=TRUE)
  Sys.setenv(EF_CONTOUR_TEST_MODE="1")
  source("Contours.R", local=TRUE)

  set.seed(83721)
  n <- 180L
  x <- data.frame(
    z_turnout=c(rnorm(n,-.42,.63),rnorm(n,.52,.68)),
    z_winner=c(rnorm(n,-.58,.66),rnorm(n,.62,.60)),
    Size=rep(c("Large","Small"),each=n),
    Size_JHK=rep(c("Large","Small"),each=n),
    standardized_ok=TRUE,
    stringsAsFactors=FALSE)
  g <- contour_geometry(x,"Size",15L,180L)
  stopifnot(isTRUE(g$ok),
            nrow(g$data)==2*n,
            identical(levels(g$data$class),c("Large","Small")),
            identical(as.integer(g$counts[c("Large","Small")]),c(n,n)),
            length(g$h)==2L,all(is.finite(g$h)),
            all(g$effective_sd>0),
            isTRUE(all.equal(g$h,4*g$effective_sd,tolerance=1e-10)),
            nrow(g$kde_modes)==2L,
            identical(g$kde_modes$class,c("Large","Small")))

  # The arrow MUST originate at the Large-group KDE mode and point to Small.
  arrow <- mode_arrow_data(g)
  stopifnot(!is.null(arrow),nrow(arrow)==1L,
            isTRUE(all.equal(arrow$x,g$kde_modes$x[1])),
            isTRUE(all.equal(arrow$y,g$kde_modes$y[1])),
            isTRUE(all.equal(arrow$xend,g$kde_modes$x[2])),
            isTRUE(all.equal(arrow$yend,g$kde_modes$y[2])),
            sqrt((arrow$xend-arrow$x)^2+(arrow$yend-arrow$y)^2) > .08)

  # No arbitrary arrow if modal displacement is too small.
  stopifnot(is.null(mode_arrow_data(g,minimum_distance=100)))

  area <- list(level="national",code="national",display_EN="Serbia",display_SR="Srbija")
  for(lang in c("EN","SR")) {
    p <- make_figure(g,"presidential_2017",area,"Size","A",lang,"Synthetic winner")
    layers <- vapply(p$layers,function(layer) class(layer$geom)[1],character(1))
    stopifnot(any(layers=="GeomDensity2d"),
              sum(layers=="GeomSegment")==1L,
              sum(layers=="GeomPoint")==1L)
    layer1 <- ggplot2::ggplot_build(p)$data[[1]]
    alphas <- layer1$alpha[is.finite(layer1$alpha)]
    stopifnot(length(alphas)>0L,
              min(alphas)>=CONTOUR_ALPHA_RANGE[1]-1e-6,
              max(alphas)<=CONTOUR_ALPHA_RANGE[2]+1e-6,
              diff(range(alphas)) > .4)
    png_path <- tempfile(fileext=".png")
    ggplot2::ggsave(png_path,p,width=7,height=5.25,dpi=120,bg="white")
    stopifnot(file.exists(png_path),file.info(png_path)$size>3000)
    unlink(png_path)
  }

  # Graph must still render if no arrow can reasonably be drawn.
  g$kde_modes$x[2] <- g$kde_modes$x[1]
  g$kde_modes$y[2] <- g$kde_modes$y[1]
  p <- make_figure(g,"presidential_2017",area,"Size","B","EN","Synthetic winner")
  layers <- vapply(p$layers,function(layer) class(layer$geom)[1],character(1))
  stopifnot(!any(layers=="GeomSegment"),!any(layers=="GeomPoint"))

  cat("PASS: smoothed group KDE, fading outer contours, large-to-small KDE-mode arrow, bilingual legend and PNG.\n")
})()
