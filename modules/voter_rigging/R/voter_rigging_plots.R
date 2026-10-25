# Figure 4-style visualisation (NOT a literal reproduction of Fig. 4A,
# because delta(p) requires independent cross-election reference distributions).
# Plotting changes v0.1.1 affect presentation only, never calculations/CSV values.
vr_label <- function(lang, en, sr) if(lang == "SR") sr else en

vr_pretty_election <- function(elections, lang="EN") {
  v <- gsub("_", " ", as.character(elections), fixed=TRUE)
  if(lang == "SR") {
    v <- sub("^presidential\\b", "predsednički", v, ignore.case=TRUE, perl=TRUE)
    v <- sub("^parliamentary\\b", "parlamentarni", v, ignore.case=TRUE, perl=TRUE)
  }
  v
}

# Kept for backward compatibility with any external code calling vr_title.
vr_title <- function(election) vr_pretty_election(election,"EN")

# At most three election names on a legend row; additional elections wrap.
vr_legend_columns <- function(n) min(3L, max(1L, as.integer(n)))

vr_turnout_subtitle <- function(curve,lang="EN") {
  if(!"definition" %in% names(curve)) return("")
  ds <- unique(as.character(curve$definition[!is.na(curve$definition)]))
  if(length(ds) != 1L) return("")
  if(ds == "A") {
    vr_label(lang, "Turnout definition A: valid / registered (B/E)",
                   "Definicija izlaznosti A: važeći / upisani (B/E)")
  } else if(ds == "B") {
    vr_label(lang, "Turnout definition B: cast / registered (C/E)",
                   "Definicija izlaznosti B: listići u kutiji / upisani (C/E)")
  } else ""
}

vr_plot_D <- function(curve,lang="EN",is_multi=FALSE) {
  vr_require("ggplot2")
  g <- curve[is.finite(curve$D) & curve$status=="OK",,drop=FALSE]
  if(nrow(g)<2L) return(NULL)
  if(!"election" %in% names(g)) g$election <- "Election"
  elections <- unique(as.character(g$election))
  g$election <- factor(g$election,levels=elections)
  def <- vr_turnout_subtitle(g,lang)
  descriptor <- vr_label(lang,
    "Median-centre distance; no international reference or rejection band",
    "Rastojanje medijana; bez međunarodne referentne oblasti")
  subtext <- if(nzchar(def)) paste(def,descriptor,sep="\n") else descriptor
  ylabel <- if(lang=="SR") {
    expression("Veličina efekta, " * plain(D) * "(" * italic(p) * ")")
  } else {
    expression("Effect size, " * plain(D) * "(" * italic(p) * ")")
  }

  ggplot2::ggplot(g,ggplot2::aes(x=p,y=D,colour=election,group=election)) +
    ggplot2::geom_line(linewidth=.85) +
    ggplot2::scale_x_continuous(limits=c(0,90),breaks=seq(0,90,15)) +
    ggplot2::scale_colour_discrete(
      breaks=elections, labels=vr_pretty_election(elections,lang)) +
    ggplot2::guides(colour=ggplot2::guide_legend(
      ncol=vr_legend_columns(length(elections)),byrow=TRUE)) +
    ggplot2::labs(
      title=vr_label(lang,"A — Small–large discrepancy D(p)",
                     "A — Razlika malih i velikih BM: D(p)"),
      subtitle=subtext,
      x=vr_label(lang,"Size threshold p (%)","Prag veličine BM, p (%)"),
      y=ylabel, colour=NULL,
      caption=vr_label(lang,
        "Descriptive effect size D(p) only — NOT the paper's reference-standardised δ(p).",
        "Samo opisna veličina efekta D(p) — NIJE referentno standardizovana δ(p) iz rada.")) +
    ggplot2::theme_bw(base_size=11)+
    ggplot2::theme(plot.title=ggplot2::element_text(face="bold",size=12),
                   legend.position=if(is_multi) "bottom" else "none",
                   legend.box="vertical",
                   plot.caption=ggplot2::element_text(size=7))
}

vr_plot_cumulative <- function(curves,lang="EN",is_multi=FALSE) {
  vr_require("ggplot2")
  g <- curves[is.finite(curves$cumulative_winner_share) & curves$rank>=2,,drop=FALSE]
  if(nrow(g)<2L) return(NULL)
  if(!"election" %in% names(g)) g$election <- "Election"
  elections <- unique(as.character(g$election))
  g$election <- factor(g$election,levels=elections)
  ggplot2::ggplot(g,ggplot2::aes(x=rank,y=cumulative_winner_share,
                                colour=election,group=election)) +
    # The 50% guide is drawn behind the observed series, in both languages.
    ggplot2::geom_hline(yintercept=.5,colour="grey45",linetype="dashed",linewidth=.5) +
    ggplot2::geom_line(linewidth=.85) +
    ggplot2::scale_x_log10() +
    ggplot2::scale_y_continuous(labels=function(x)paste0(round(100*x),"%")) +
    ggplot2::scale_colour_discrete(
      breaks=elections,labels=vr_pretty_election(elections,lang)) +
    ggplot2::guides(colour=ggplot2::guide_legend(
      ncol=vr_legend_columns(length(elections)),byrow=TRUE)) +
    ggplot2::labs(
      title=vr_label(lang,"B — Cumulative winner vote share",
                         "B — Kumulativni udeo glasova pobednika"),
      subtitle=vr_label(lang,
        "Polling stations ordered by electorate size; identical under turnout definitions A and B",
        "BM poređana po broju upisanih; ista kriva za definicije izlaznosti A i B"),
      x=vr_label(lang,"Polling-station rank (log scale)","Rang biračkog mesta (log skala)"),
      y=vr_label(lang,"Cumulative vote share","Kumulativni udeo glasova"),colour=NULL,
      caption=vr_label(lang,
        "Cumulative winner votes / cumulative valid votes; dashed line marks 50%.",
        "Kumulativni glasovi pobednika / kumulativni važeći glasovi; isprekidana linija označava 50%.")) +
    ggplot2::theme_bw(base_size=11)+
    ggplot2::theme(plot.title=ggplot2::element_text(face="bold",size=12),
                   legend.position=if(is_multi) "bottom" else "none",
                   legend.box="vertical",
                   plot.caption=ggplot2::element_text(size=7))
}

vr_save_plot <- function(p,path,width=7,height=5,dpi=220L) {
  if(is.null(p)) return(FALSE)
  ggplot2::ggsave(path,plot=p,width=width,height=height,dpi=dpi,units="in",bg="white")
  TRUE
}
vr_save_combined <- function(pA,pB,path,width=12,height=5,dpi=220L) {
  if(is.null(pA)||is.null(pB)) return(FALSE)
  grDevices::png(path,width=width,height=height,units="in",res=dpi,bg="white")
  on.exit(grDevices::dev.off(),add=TRUE)
  grid::grid.newpage()
  grid::pushViewport(grid::viewport(layout=grid::grid.layout(1,2)))
  print(pA,vp=grid::viewport(layout.pos.row=1,layout.pos.col=1),newpage=FALSE)
  print(pB,vp=grid::viewport(layout.pos.row=1,layout.pos.col=2),newpage=FALSE)
  grid::upViewport()
  TRUE
}
