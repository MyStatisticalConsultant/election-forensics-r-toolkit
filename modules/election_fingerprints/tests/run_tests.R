# Unit tests / Jedinični testovi — independent of real RZS workbooks.
# EN/SR: Temporarily disable auto-run while loading functions; restore so
# subsequent source("Election_fingerprints.R") actually executes the module.
.ef_fp_old_mode <- Sys.getenv("EF_FINGERPRINT_TEST_MODE",unset=NA_character_)
Sys.setenv(EF_FINGERPRINT_TEST_MODE="1")
source("Election_fingerprints.R",local=FALSE)
if(is.na(.ef_fp_old_mode)) Sys.unsetenv("EF_FINGERPRINT_TEST_MODE") else
  Sys.setenv(EF_FINGERPRINT_TEST_MODE=.ef_fp_old_mode)
rm(.ef_fp_old_mode)
stopifnot(identical(pretty_election("presidential",2017,"SR"),"predsednički 2017"),
          identical(pretty_election("parliamentary",2022,"EN"),"parliamentary 2022"),
          identical(area_label("National","National","ALL","SR"),"Srbija"),
          identical(area_label("District","Kolubarski okrug","07","EN"),"Kolubarski district"),
          identical(area_label("District","Kolubarski","07","SR"),"Kolubarski okrug"),
          identical(area_label("District","Foreign","33","SR"),"Inostranstvo"),
          identical(area_label("District","Foreign","33","EN"),"Overseas"),
          identical(area_label("District","Prisons","55","EN"),"Prisons"),
          identical(area_label("District","Kosovo special","25","EN"),"Kosovo special"))
opts <- data.frame(Votes_field=c("Option_01_votes","Option_02_votes"),
                   Option_name_SR_Lat=c("OPCIJA 1","OPCIJA 2"),Total_votes=c(20,30))
stopifnot(identical(choose_option(opts,"presidential_2022"),"Option_02_votes"),
          identical(choose_option(opts,"presidential_2022","manual",
                   list(presidential_2022="Option_01_votes")),"Option_01_votes"))
d <- data.frame(Election_type="presidential",Year=2022,
 Station_key=paste0("PS",1:5),District_code=c("00","00","00","33","55"),
 District=c("Grad Beograd","Grad Beograd","Grad Beograd","Inostranstvo","Prisons"),
 Municipality_code=c("1","1","2","3","4"),Municipality=c("A","A","B","C","D"),
 E=c(100,200,100,150,100),B=c(50,100,0,70,50),C=c(60,120,20,80,110),
 Option_01_votes=c(30,40,0,35,25),
 Size=c("Small","Middle","Large","Small","Large"),
 Size_JHK=c("Small","Large","Large","Small","Large"),Eligible_primary=TRUE,
 stringsAsFactors=FALSE)
r1 <- prepare_rates(d,"Option_01_votes","valid")
r2 <- prepare_rates(d,"Option_01_votes","cast")
stopifnot(nrow(r1)==5L, sum(r1$Status=="included")==4L,
          r1$Status[3]=="invalid_valid_ballots",r1$Status[5]=="included",
          r2$Status[5]=="invalid_turnout_numerator",
          isTRUE(all.equal(r1$turnout_pct[1],50)),
          isTRUE(all.equal(r1$share_pct[1],60)),
          isTRUE(all.equal(r2$turnout_pct[1],60)),
          isTRUE(all.equal(r2$share_pct[1],60)))
g <- make_hist_grid(c(0,0.1,99.9,100),c(0,0.1,99.9,100),50)
stopifnot(nrow(g)==2500L,sum(g$N_stations)==4L,
          sum(g$N_stations>0)==2L,max(g$N_stations)==2L)
a <- make_areas(d,mode="selected",districts=TRUE,municipalities=FALSE,
                selected_districts=c("33","55"))
stopifnot(length(a)==3L,identical(a[[2]]$code,"33"),
          nrow(a[[2]]$data)==1L,identical(a[[3]]$code,"55"))
stopifnot(length(make_areas(d,mode="national"))==1L)
# EN/SR: Distinct Size/Size_JHK partitions, fixed national membership and N=0.
stopifnot(isTRUE(PLOT_SIZE_GROUPS),identical(SIZE_GROUPS,
          c("SMALL","MIDDLE","LARGE","JHK_SMALL","JHK_LARGE")),
          identical(size_group_labels("MIDDLE","SR"),"Srednja biračka mesta"),
          identical(size_group_labels("JHK_LARGE","EN"),"JHK large polling stations"),
          identical(size_classification("JHK_SMALL"),"Size_JHK"))
sg<-make_size_groups(d)
stopifnot(length(sg)==5L,nrow(sg$SMALL)==2L,nrow(sg$MIDDLE)==1L,
          nrow(sg$LARGE)==2L,nrow(sg$JHK_SMALL)==2L,nrow(sg$JHK_LARGE)==3L,
          sum(vapply(sg[c("SMALL","MIDDLE","LARGE")],nrow,integer(1)))==nrow(d),
          sum(vapply(sg[c("JHK_SMALL","JHK_LARGE")],nrow,integer(1)))==nrow(d))
special <- make_size_groups(a[[2]]$data)
stopifnot(nrow(special$MIDDLE)==0L,nrow(special$SMALL)==1L,
          nrow(special$JHK_LARGE)==0L)
cat("PASS: canonical rates, 2D PS counts, inclusive bin boundaries,\n",
    "national-option selection, geography, special areas, bilingual labels,",
    "both national size partitions and zero-size groups.\n",sep="")
