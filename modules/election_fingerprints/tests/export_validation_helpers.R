# Independently verify which geographic areas MUST appear in the export.
# EN/SR: Independent expectation from the prepared Main workbook, not make_areas().
fp_expected_areas <- function(d, mode, districts, municipalities,
                              selected_districts, selected_municipalities) {
  all_dist <- unique(as.character(d$District_code))
  all_muni <- unique(paste(as.character(d$District_code),
                           as.character(d$Municipality_code),sep="|"))
  x <- data.frame(Area_level="National",Area_code="ALL",stringsAsFactors=FALSE)
  if(mode=="national") return(x)
  if(districts) {
    codes <- if(mode=="selected") intersect(all_dist,as.character(selected_districts)) else all_dist
    if(length(codes)) x<-rbind(x,data.frame(Area_level="District",Area_code=codes))
  }
  if(municipalities) {
    codes <- if(mode=="selected") intersect(all_muni,as.character(selected_municipalities)) else all_muni
    if(length(codes)) x<-rbind(x,data.frame(Area_level="Municipality",Area_code=codes))
  }
  x
}
fp_expected_group_count <- function(d, group) {
  if(group=="ALL") return(nrow(d))
  if(group=="SMALL") return(sum(d$Size=="Small"))
  if(group=="MIDDLE") return(sum(d$Size=="Middle"))
  if(group=="LARGE") return(sum(d$Size=="Large"))
  if(group=="JHK_SMALL") return(sum(d$Size_JHK=="Small"))
  if(group=="JHK_LARGE") return(sum(d$Size_JHK=="Large"))
  stop("Unknown polling-station size group: ",group)
}
fp_assert_area_coverage <- function(tab,d,mode,districts,municipalities,
                                    selected_districts,selected_municipalities,
                                    groups,measures,id="") {
  required_cols <- c("Area_level","Area_code","Group","Turnout_definition",
                     "N_area_main","N_main","N_included","N_excluded")
  if(!all(required_cols%in%names(tab))) stop("Status missing columns: ",
    paste(setdiff(required_cols,names(tab)),collapse=", "))
  expected <- fp_expected_areas(d,mode,districts,municipalities,
                                selected_districts,selected_municipalities)
  actual <- unique(tab[,c("Area_level","Area_code"),drop=FALSE])
  mk <- function(x) paste(as.character(x$Area_level),as.character(x$Area_code),sep="::")
  missing <- setdiff(mk(expected),mk(actual))
  extra <- setdiff(mk(actual),mk(expected))
  if(length(missing)||length(extra)) stop("Geographic export coverage mismatch ",id,
    "; missing=",paste(missing,collapse=", "),
    "; unexpected=",paste(extra,collapse=", "))
  expected_groups<-expand.grid(Group=groups,Turnout_definition=measures,
                                stringsAsFactors=FALSE)
  for(j in seq_len(nrow(expected))) {
    lvl<-expected$Area_level[[j]]; code<-expected$Area_code[[j]]
    rows<-tab[tab$Area_level==lvl & tab$Area_code==code,,drop=FALSE]
    rowkeys<-paste(rows$Group,rows$Turnout_definition,sep="::")
    reqkeys<-paste(expected_groups$Group,expected_groups$Turnout_definition,sep="::")
    if(anyDuplicated(rowkeys)||!setequal(rowkeys,reqkeys)||nrow(rows)!=length(reqkeys))
      stop("Missing/duplicate size-group/turnout rows for ",id," / ",lvl," / ",code)
    sub <- if(lvl=="National") d else if(lvl=="District")
      d[as.character(d$District_code)==code,,drop=FALSE] else
      d[paste(d$District_code,d$Municipality_code,sep="|")==code,,drop=FALSE]
    for(k in seq_len(nrow(rows))) {
      row<-rows[k,,drop=FALSE]
      expected_n<-fp_expected_group_count(sub,as.character(row$Group))
      if(row$N_area_main!=nrow(sub) || row$N_main!=expected_n ||
         row$N_included+row$N_excluded!=expected_n)
        stop("Invalid station counts in ",id," / ",lvl," / ",code,
          " / ",row$Group," / ",row$Turnout_definition,
          "; expected group N=",expected_n,"; reported=",row$N_main)
    }
  }
  invisible(expected)
}
