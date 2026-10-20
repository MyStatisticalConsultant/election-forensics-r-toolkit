# EN/SR: Synthetic unit tests. No RZS data required / Nisu potrebni RZS podaci.
stopifnot(file.exists("Klimek.R"))
parse(file="Klimek.R",encoding="UTF-8")
Sys.setenv(EF_KLIMEK_TEST_MODE="1")
source("Klimek.R",encoding="UTF-8")
Sys.unsetenv("EF_KLIMEK_TEST_MODE")
validate_settings()
stopifnot(length(all_group_ids)==8L,all(c("ALL","GE100","LT100","SMALL","MIDDLE","LARGE",
                                       "JHK_SMALL","JHK_LARGE")%in%all_group_ids))
# Minimal canonical data; deliberately no source file or plotting needed.
small <- function(k,e,c,b,i,turn,size=NA_character_,jhk=NA_character_,eligible=FALSE) {
  data.frame(Election_type="presidential",Year=2022L,Station_key=k,
    District_code="01",Municipality_code="001",District="Šumadijski okrug",
    Municipality="Čačak",E=e,C=c,B=b,I=i,Turnout=turn,Size=size,Size_JHK=jhk,
    Eligible_primary=eligible,Under_100=e<100,Admin_no_ballots=FALSE,
    Admin_invalid=FALSE,Invalid_numeric=FALSE,
    Option_01_votes=b*0.6,Option_02_votes=b*0.4,
    stringsAsFactors=FALSE)
}
ma <- do.call(rbind,list(
  small("a",200,100,95,5,50,"Small","Small",TRUE),
  small("b",300,165,160,5,55,"Middle","Large",TRUE),
  small("c",400,240,235,5,60,"Middle","Large",TRUE),
  small("d",500,300,295,5,60,"Large","Large",TRUE),
  small("u",60,30,29,1,50),small("v",90,54,52,2,60)))
invalid <- small("bad",50,0,0,0,0)
invalid$Invalid_numeric <- TRUE
master <- rbind(ma,invalid)
main <- ma[ma$Eligible_primary,,drop=FALSE]
groups <- make_groups(main,master)
stopifnot(nrow(groups$ALL)==6L,nrow(groups$GE100)==4L,
  nrow(groups$LT100)==2L,nrow(groups$SMALL)==1L,nrow(groups$MIDDLE)==2L,
  nrow(groups$LARGE)==1L,nrow(groups$JHK_SMALL)==1L,
  nrow(groups$JHK_LARGE)==3L, !"bad"%in%groups$ALL$Station_key)
stopifnot(sum(groups$GE100$E)==sum(groups$SMALL$E)+sum(groups$MIDDLE$E)+sum(groups$LARGE$E))
cv <- cumulative_curve(main,"Option_01_votes")
stopifnot(nrow(cv)==4L, all(diff(cv$Y_valid)>=-1e-8),
  abs(tail(cv$Y_valid,1)-60)<1e-9, abs(tail(cv$Y_option,1)-100)<1e-9,
  identical(cv$Station_key,c("a","b","c","d")))
# Demonstrate differing normalisation denominators and sorted ties.
cr <- cumulative_curve(data.frame(Station_key=c("z","a","m"),
 Turnout=c(80,50,50),B=c(20,10,20),Option_01_votes=c(10,3,7)),"Option_01_votes")
stopifnot(identical(cr$Station_key,c("a","m","z")),
          abs(tail(cr$Y_valid,1)-40)<1e-8,
          abs(tail(cr$Y_option,1)-100)<1e-8)
zero <- cumulative_curve(ma[FALSE,,drop=FALSE],"Option_01_votes")
stopifnot(nrow(zero)==0,identical(names(zero),names(cv)))
# No fraudulent permutation inference is added.
t <- tail_metric(main,"Option_01_votes","Option_02_votes",0.95)
stopifnot(t$N_stations>=1L,is.finite(t$Mean_station_margin_pp),
          !"p_value"%in%names(t))
# Ensure option selection does not infer arbitrary percentage fields.
options <- data.frame(Votes_field=c("Option_01_votes","Option_02_votes"),
  Option_number=1:2,Total_votes=c(300,200),
  Option_name_SR_Lat=c("Časna lista","Đorđe Živković"))
stopifnot(identical(selected_fields(options,"presidential_2022"),c("Option_01_votes","Option_02_votes")))
labels <- option_labels(options,"presidential_2022","SR")
stopifnot(identical(unname(labels["Option_02_votes"]),"Đorđe Živković"))
areas <- area_slices(groups,"Municipality")
stopifnot(length(areas)==8L,all(grepl("01\\|001",names(areas))))
cat("PASS: Klimek syntax, canonical group partitions, both curve normalisations, ties, empty groups, tail summaries and Unicode labels.\n")
cat("NOTE: does not replace real-data integration tests or manual figure inspection.\n")
