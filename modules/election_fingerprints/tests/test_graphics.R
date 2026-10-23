# Plot construction and EN/SR titles, no real RZS inputs required.
# EN/SR: Temporarily disable auto-run while loading functions; restore so
# subsequent source("Election_fingerprints.R") actually executes the module.
.ef_fp_old_mode <- Sys.getenv("EF_FINGERPRINT_TEST_MODE",unset=NA_character_)
Sys.setenv(EF_FINGERPRINT_TEST_MODE="1")
source("Election_fingerprints.R",local=FALSE)
if(is.na(.ef_fp_old_mode)) Sys.unsetenv("EF_FINGERPRINT_TEST_MODE") else
  Sys.setenv(EF_FINGERPRINT_TEST_MODE=.ef_fp_old_mode)
rm(.ef_fp_old_mode)
check_packages()
set.seed(2012)
d <- data.frame(turnout_pct=pmin(pmax(stats::rnorm(150,63,9),0),100),
                share_pct=pmin(pmax(stats::rnorm(150,47,12),0),100))
g <- make_hist_grid(d$turnout_pct,d$share_pct,50L)
k <- make_kde_grid(d$turnout_pct,d$share_pct,50L)
# EN/SR: KDE raster must fill [0,100] exactly, without border-centre tiles.
#     For n=50, centres are 1, 3, ..., 99 percent (2-pp raster cells).
stopifnot(isTRUE(all.equal(range(k$turnout_pct),c(1,99))),
          isTRUE(all.equal(range(k$share_pct),c(1,99))),
          isTRUE(all.equal(diff(sort(unique(k$turnout_pct))),rep(2,49))))
# EN/SR: The original 0..100 endpoints remain in the INPUT data; the
#     change is solely to KDE evaluation coordinates, not sample filtering.
boundary_test <- make_kde_grid(c(d$turnout_pct,0,100),
                               c(d$share_pct,100,0),n=50L)
stopifnot(!is.null(boundary_test),nrow(boundary_test)==2500L)
stopifnot(nrow(g)==2500L,sum(g$N_stations)==nrow(d),
          !is.null(k),all(k$density_normalized>=0),
          all(k$density_normalized<=1),
          isTRUE(all.equal(max(k$density_normalized),1)))
a <- list(type="District",code="33",name="Inostranstvo",national_winner="Option_01_votes")
for(lang in c("EN","SR")) {
  ttl <- make_title(lang,"parliamentary",2022,a,"Option_01_votes",
                    "Test option","hist","valid")
  stopifnot(grepl(if(lang=="EN") "Overseas" else "Inostranstvo",ttl$main),
            grepl(if(lang=="EN") "histogram" else "histogram",ttl$subtitle))
  subttl <- make_title(lang,"parliamentary",2022,a,"Option_01_votes",
                       "Test option","hist","valid",group="JHK_SMALL")
  stopifnot(grepl(if(lang=="EN") "JHK small polling stations" else
                    "JHK mala biračka mesta",subttl$subtitle,fixed=TRUE),
            grepl("\n",subttl$subtitle,fixed=TRUE),
            identical(subttl$main,ttl$main))
  q <- create_fingerprint_plot(d,g,"hist","valid",lang,subttl)
  stopifnot(inherits(q,"ggplot") || inherits(q,"gtable") || inherits(q,"gg"))
  testfile <- tempfile(fileext=".png")
  ggplot2::ggsave(testfile,plot=q,width=11,height=8,dpi=80,bg="white")
  stopifnot(file.exists(testfile),file.info(testfile)$size>10000)
  unlink(testfile)
}
# EN/SR: Rendering a real KDE (with marginals) must not drop 796 (or
#     4*n-4) raster-border rows. Verify on a synthetic 50x50 density grid.
kde_labels <- make_title("EN","parliamentary",2022,a,
                         "Option_01_votes","Test option","kde","valid")
kde_plot <- create_fingerprint_plot(d,k,"kde","valid","EN",kde_labels)
kde_png <- tempfile(fileext=".png")
render_warnings <- character()
withCallingHandlers(
  ggplot2::ggsave(kde_png,plot=kde_plot,width=11,height=8,dpi=80,bg="white"),
  warning=function(w) {
    render_warnings <<- c(render_warnings,conditionMessage(w))
    invokeRestart("muffleWarning")
  })
stopifnot(file.exists(kde_png),file.info(kde_png)$size>10000,
          !any(grepl("geom_raster|Removed .* rows",render_warnings)))
unlink(kde_png)
# EN: Reproduce the ACTUAL default 200x200 KDE from the full production run.
#     Previous tests rendered n=50 only; the 796-cell warning is 4*200-4.
# SR: Provera stvarne podrazumevane KDE mreže 200x200 i potencijalnih
#     796 odbačenih rubnih ćelija (test sa n=50 nije bio dovoljan).
k200 <- make_kde_grid(c(d$turnout_pct,0,100),c(d$share_pct,100,0),n=200L)
stopifnot(!is.null(k200),nrow(k200)==40000L,
          isTRUE(all.equal(range(k200$turnout_pct),c(0.25,99.75))),
          isTRUE(all.equal(range(k200$share_pct),c(0.25,99.75))))
for(lang in c("EN","SR")) {
  full_labels <- make_title(lang,"parliamentary",2022,a,
    "Option_01_votes","Test option","kde","cast",group="JHK_LARGE")
  full_plot <- NULL
  out_png <- tempfile(fileext=".png")
  raster_warnings <- character()
  withCallingHandlers({
    full_plot <- create_fingerprint_plot(d,k200,"kde","cast",lang,full_labels)
    ggplot2::ggsave(out_png,plot=full_plot,width=11,height=8,dpi=80,bg="white")
  },warning=function(w) {
    raster_warnings <<- c(raster_warnings,conditionMessage(w))
    invokeRestart("muffleWarning")
  })
  stopifnot(file.exists(out_png),file.info(out_png)$size>10000,
            !any(grepl("geom_raster|Removed .* rows",raster_warnings)))
  unlink(out_png)
}
# EN/SR: Subtitle text uses the larger, nonbold setting independently
#     of the underlying numerical histogram or KDE logic.
stopifnot(identical(SUBTITLE_FONT_SIZE,14),MAIN_TITLE_FONT_SIZE>SUBTITLE_FONT_SIZE)
# Singleton histogram must not invent a continuous KDE surface.
single <- make_hist_grid(100,100,50L)
stopifnot(sum(single$N_stations)==1L)
stopifnot(is.null(make_kde_grid(50,50)))
cat("PASS: bilingual layouts, histogram/KDE rendering on default 200x200 grid without raster-border warnings, 14-pt subtitle and singleton case.\n")
