source(file.path("R","voter_rigging_functions.R"),encoding="UTF-8")
source(file.path("R","voter_rigging_plots.R"),encoding="UTF-8")
vr_require("ggplot2")
stopifnot(
  identical(vr_pretty_election(c("presidential_2017","parliamentary_2022"),"EN"),
            c("presidential 2017","parliamentary 2022")),
  identical(vr_pretty_election(c("presidential_2017","parliamentary_2022"),"SR"),
            c("predsednički 2017","parlamentarni 2022")),
  vr_legend_columns(1)==1L,
  vr_legend_columns(3)==3L,
  vr_legend_columns(4)==3L,
  vr_legend_columns(7)==3L
)

px <- seq(.5,90,by=.5)
elections <- c("presidential_2017","presidential_2022",
               "parliamentary_2022","parliamentary_2023")
g <- do.call(rbind,lapply(seq_along(elections),function(i)
  data.frame(p=px,D=.1*i+.004*px,status="OK",election=elections[[i]],definition="A")))
g_B <- g; g_B$definition <- "B"; g_B$D <- g_B$D*.975
cum <- do.call(rbind,lapply(seq_along(elections),function(i)
  data.frame(rank=2:120,cumulative_winner_share=.39+.018*i+.06*log(2:120)/log(120),
             election=elections[[i]])))
out <- tempfile("voter_rigging_graphics_")
dir.create(out)
for(lang in c("EN","SR")) {
  pA <- vr_plot_D(g,lang=lang,is_multi=TRUE)
  pA_B <- vr_plot_D(g_B,lang=lang,is_multi=TRUE)
  pB <- vr_plot_cumulative(cum,lang=lang,is_multi=TRUE)
  # 50% reference guide must be in the first layer, before actual vote shares.
  ref <- ggplot2::layer_data(pB,1)
  stopifnot(nrow(ref)==1L,abs(ref$yintercept[[1]]-.5)<1e-12)
  stopifnot(grepl("B/E",pA$labels$subtitle,fixed=TRUE),
            grepl("C/E",pA_B$labels$subtitle,fixed=TRUE))
  # Plotmath expressions can be deparsed to multiple strings. Test the
  # complete expression, not every individual string returned by deparse().
  # This also checks that the descriptive D(p), not reference-based delta(p),
  # is displayed and that p is italicised in both languages.
  y_label <- paste(deparse(pA$labels$y, width.cutoff=500L), collapse=" ")
  stopifnot(is.expression(pA$labels$y),
            grepl("plain(D)", y_label, fixed=TRUE),
            grepl("italic(p)", y_label, fixed=TRUE),
            grepl(if(lang == "EN") "Effect size" else "Veličina efekta",
                  y_label, fixed=TRUE))
  # Four elections must use a maximum of three legend columns (two rows).
  stopifnot(length(elections)==4L,vr_legend_columns(length(elections))==3L)
  stopifnot(vr_save_plot(pA,file.path(out,paste0("A_",lang,".png")),dpi=90L),
            vr_save_plot(pB,file.path(out,paste0("B_",lang,".png")),dpi=90L),
            vr_save_combined(pA,pB,file.path(out,paste0("AB_",lang,".png")),dpi=90L))
}
files <- list.files(out,full.names=TRUE)
stopifnot(length(files)==6L,all(file.info(files)$size>4000L))
unlink(out,recursive=TRUE)
cat("PASS: bilingual D(p) axis, turnout A/B subtitles, 50% Figure 4B guide, clean/wrapped legends and PNG exports.\n")
