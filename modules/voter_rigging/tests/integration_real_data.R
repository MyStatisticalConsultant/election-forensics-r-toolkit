# Optional integration input audit; run on the user's own prepared Master XLSX.
source(file.path("R","voter_rigging_functions.R"),encoding="UTF-8")
paths <- file.path("..","rzs_data_preparation","RZS_prepared",
  c("presidential_2017_RZS_prepared.xlsx","presidential_2022_RZS_prepared.xlsx",
    "parliamentary_2022_RZS_prepared.xlsx"))
if(!all(file.exists(paths))) stop("Missing RZS prepared files; inspect INPUTS in Voter_rigging.R")
for(i in seq_along(paths)) {
  d <- vr_read_master(paths[i],"Master")
  elect <- c("presidential_2017","presidential_2022","parliamentary_2022")[i]
  fb <- list(presidential_2017="Option_06_votes",presidential_2022="Option_06_votes",
             parliamentary_2022="Option_01_votes")
  d <- vr_prepare(d,elect,"Winner_votes",fb,"A")
  d <- vr_standardize(d,10L)
  cat(elect,"Master rows:",nrow(d),"Eligible including <100:",sum(d$base_ok),
      "Small (<100) eligible:",sum(d$base_ok & d$E<100),
      "Standardized:",sum(d$standardized_ok),"\n")
  if(sum(d$standardized_ok)<20L)
    warning("Very few standardized stations for ",elect)
}
cat("PASS: real-data input contracts and valid station-level QC completed.\n")
