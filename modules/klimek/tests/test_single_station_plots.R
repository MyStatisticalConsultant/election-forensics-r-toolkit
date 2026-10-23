# EN: Graphics regression tests for polling-station groups with one observation.
# SR: Regresioni testovi grafikona za grupe sa samo jednim biračkim mestom.
# Run from modules/klimek; no Excel workbooks are needed.
stopifnot(file.exists("Klimek.R"))
parse(file="Klimek.R",encoding="UTF-8")
old_flag <- Sys.getenv("EF_KLIMEK_TEST_MODE", unset=NA_character_)
Sys.setenv(EF_KLIMEK_TEST_MODE="1")
source("Klimek.R",encoding="UTF-8")
if (is.na(old_flag)) Sys.unsetenv("EF_KLIMEK_TEST_MODE") else
  Sys.setenv(EF_KLIMEK_TEST_MODE=old_flag)
stopifnot(requireNamespace("ggplot2",quietly=TRUE))

# EN: One singleton among multi-point series (as in overseas/LARGE 2022).
# SR: Jedna usamljena tačka uz drugu seriju koja ima više opažanja.
x <- data.frame(Turnout=c(61, 48, 63, 76),
                Y_valid=c(44, 8, 22, 41),
                Y_option=c(100,20,60,100),
                Series=c("Large", "Small", "Small", "Small"),
                Panel=c("Standard", "Standard", "Standard", "Standard"))
colours <- c(SMALL="#D55E00", LARGE="#0072B2")
labels <- c(SMALL="Small", LARGE="Large")
p <- plot_curves(x,"EN","valid","Test title",labels,colours)
stopifnot(inherits(p,"ggplot"))
line_layers <- which(vapply(p$layers,function(z) inherits(z$geom,"GeomLine"),logical(1)))
point_layers <- which(vapply(p$layers,function(z) inherits(z$geom,"GeomPoint"),logical(1)))
stopifnot(length(line_layers)==1L, length(point_layers)>=1L,
          nrow(p$layers[[line_layers[[1]]]]$data)==3L,
          nrow(p$layers[[point_layers[[1]]]]$data)==1L,
          p$layers[[point_layers[[1]]]]$data$Series[[1]]=="Large")
# The plot should also build without the single-observation geom_line warning.
warns <- character()
withCallingHandlers(ggplot2::ggplot_build(p),
  warning=function(w) {
    warns <<- c(warns,conditionMessage(w))
    invokeRestart("muffleWarning")
  })
stopifnot(!any(grepl("Each group consists of only one observation",warns,fixed=TRUE)))

# EN: Completely isolated series should show one point and no line layer.
# SR: Kada postoji samo jedna tačka, ne treba dodavati geom_line sloj.
p1 <- plot_curves(x[1,,drop=FALSE],"SR","valid","Naslov",
                  c(LARGE="Velika"),c(LARGE="#0072B2"))
stopifnot(inherits(p1,"ggplot"),
          !any(vapply(p1$layers,function(z) inherits(z$geom,"GeomLine"),logical(1))),
          any(vapply(p1$layers,function(z) inherits(z$geom,"GeomPoint"),logical(1))))
# EN/SR: Rendering, not just ggplot_build(), exercises geom_line drawing.
render_warnings <- character()
figure_file <- tempfile(fileext=".png")
withCallingHandlers(ggplot2::ggsave(figure_file,plot=p,width=5,height=4,dpi=96),
  warning=function(w) {
    render_warnings <<- c(render_warnings,conditionMessage(w))
    invokeRestart("muffleWarning")
  })
stopifnot(file.exists(figure_file),file.info(figure_file)$size>0,
          !any(grepl("Each group consists of only one observation",
                     render_warnings,fixed=TRUE)))
unlink(figure_file)

# EN/SR: With facets, series/panel combinations are grouped independently.
y <- rbind(x, transform(x[1,,drop=FALSE], Panel="JHK"))
pf <- plot_curves(y,"EN","option","Test title",labels,colours,TRUE,
                  facet_variable="Panel",facet_columns=1L)
stopifnot(inherits(pf,"ggplot"),
          length(which(vapply(pf$layers,function(z) inherits(z$geom,"GeomLine"),logical(1))))==1L,
          nrow(pf$layers[[which(vapply(pf$layers,function(z) inherits(z$geom,"GeomPoint"),logical(1)))[1]]]$data)==2L)
cat("PASS: singleton series rendered as points; no bogus line or geom_line singleton warnings.\n")
