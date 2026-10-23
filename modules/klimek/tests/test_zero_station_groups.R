# EN: v0.1.4 regression tests: zero/one/multiple polling stations.
# SR: v0.1.4 regresioni testovi: nula, jedno i više biračkih mesta.
# Run from modules/klimek; synthetic fixtures, no Excel/RZS input required.
stopifnot(file.exists("Klimek.R"))
parse(file="Klimek.R",encoding="UTF-8")
.old <- Sys.getenv("EF_KLIMEK_TEST_MODE",unset=NA_character_)
Sys.setenv(EF_KLIMEK_TEST_MODE="1")
source("Klimek.R",encoding="UTF-8")
if(is.na(.old)) Sys.unsetenv("EF_KLIMEK_TEST_MODE") else
  Sys.setenv(EF_KLIMEK_TEST_MODE=.old)

raw <- data.frame(
  District_code=c("01","01","33"), Municipality_code=c("001","001","001"),
  E=c(200,300,60), C=c(100,165,30), B=c(95,160,29), I=c(5,5,1),
  Turnout=c(50,55,50), Option_01_votes=c(57,96,17),
  Option_02_votes=c(38,64,12),stringsAsFactors=FALSE)
empty <- raw[FALSE,,drop=FALSE]
groups <- list(ALL=raw,GE100=raw[1:2,,drop=FALSE],LT100=raw[3,,drop=FALSE],
  SMALL=raw[1,,drop=FALSE],MIDDLE=raw[2,,drop=FALSE],LARGE=empty,
  JHK_SMALL=raw[1,,drop=FALSE],JHK_LARGE=raw[2,,drop=FALSE])
opts <- data.frame(Votes_field=c("Option_01_votes","Option_02_votes"))

for(level in c("District","Municipality")) {
  sparse <- area_slices(groups,level)
  full <- area_slices(groups,level,include_empty=TRUE)
  stopifnot(length(sparse)<length(full),length(full)==2L*length(groups))
  # Nonempty observations remain identical to the earlier sparse implementation.
  stopifnot(all(names(sparse)%in%names(full)))
  for(key in names(sparse)) stopifnot(identical(sparse[[key]]$data,full[[key]]$data))
  area_id <- if(level=="District") "33" else "33|001"
  zero_key <- paste("LARGE",area_id,sep="::")
  one_key <- paste("LT100",area_id,sep="::")
  many_key <- paste("GE100",if(level=="District") "01" else "01|001",sep="::")
  stopifnot(nrow(full[[zero_key]]$data)==0L,nrow(full[[one_key]]$data)==1L,
            nrow(full[[many_key]]$data)==2L)
  rows <- do.call(rbind,lapply(full,function(z)
    area_metric_rows(z$data,z$group,level,z$key,opts,"presidential_2022")))
  stopifnot(nrow(rows)==2L*length(groups)*nrow(opts),
            all(rows$Stations[rows$Area_key==area_id & rows$Group=="LARGE"]==0L),
            all(is.na(rows$Turnout_pct[rows$Area_key==area_id & rows$Group=="LARGE"])),
            all(is.na(rows$Option_share_pct[rows$Area_key==area_id & rows$Group=="LARGE"])),
            all(rows$Option_votes[rows$Area_key==area_id & rows$Group=="LARGE"]==0),
            all(rows$Stations[rows$Area_key==area_id & rows$Group=="LT100"]==1L),
            all(rows$Stations[rows$Area_key!=area_id & rows$Group=="GE100"]==2L))
}

# EN: A rerun deletes stale Klimek images only within the selected area.
# SR: Ponovni prolaz briše samo stare A/B slike izabrane oblasti.
tmp <- tempfile("klimek-empty-")
dir <- file.path(tmp,"figures","SR","valid","District_33")
dir_other <- file.path(tmp,"figures","SR","valid","District_01")
dir.create(dir,recursive=TRUE,showWarnings=FALSE)
dir.create(dir_other,recursive=TRUE,showWarnings=FALSE)
for(nm in c("A_LARGE_combined.png","A_LARGE_faceted.pdf",
            "B_Option_01_votes_combined_jhk.png","notes.txt","A_personal.png"))
  writeLines("dummy",file.path(dir,nm))
writeLines("keep",file.path(dir_other,"A_LARGE_combined.png"))
removed <- clean_area_figures(tmp,"District_33")
stopifnot(length(removed)==3L,
          !file.exists(file.path(dir,"A_LARGE_combined.png")),
          !file.exists(file.path(dir,"A_LARGE_faceted.pdf")),
          !file.exists(file.path(dir,"B_Option_01_votes_combined_jhk.png")),
          file.exists(file.path(dir,"notes.txt")),
          file.exists(file.path(dir,"A_personal.png")),
          file.exists(file.path(dir_other,"A_LARGE_combined.png")))
unlink(tmp,recursive=TRUE)

# EN: Zero -> no plot; one -> point only; two -> line (from v0.1.3.3).
# SR: Nula -> bez slike; jedno -> tačka; dva -> linija.
stopifnot(requireNamespace("ggplot2",quietly=TRUE))
pts <- data.frame(Turnout=c(50,55),Y_valid=c(15,22),Y_option=c(70,100),
                  Series=c("One","One"))
labels <- c(One="One")
colours <- c(One="#0072B2")
stopifnot(is.null(plot_curves(pts[FALSE,,drop=FALSE],"EN","valid","",labels,colours)))
p1 <- plot_curves(pts[1,,drop=FALSE],"EN","valid","Test",labels,colours)
p2 <- plot_curves(pts,"SR","valid","Test",labels,colours)
stopifnot(inherits(p1,"ggplot"),inherits(p2,"ggplot"),
          !any(vapply(p1$layers,function(z)inherits(z$geom,"GeomLine"),logical(1))),
          any(vapply(p1$layers,function(z)inherits(z$geom,"GeomPoint"),logical(1))),
          any(vapply(p2$layers,function(z)inherits(z$geom,"GeomLine"),logical(1))))
cat("PASS: full territorial zero-station grid, N=0/NA, stale-image cleanup, zero/one/multi-point plots.\n")
