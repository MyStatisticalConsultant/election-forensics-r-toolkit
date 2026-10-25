# Run after source("Voter_rigging.R") for national selected election(s).
x <- "voter_rigging_outputs"
needed <- c("run_configuration.csv","export_manifest.csv")
missing <- needed[!file.exists(file.path(x,needed))]
if(length(missing)) stop("Missing outputs: ",paste(missing,collapse=", "))
m <- utils::read.csv(file.path(x,"export_manifest.csv"),stringsAsFactors=FALSE)
if(nrow(m)==0L) stop("Empty manifest")
if(!all(c("election","definition","status","n_valid_thresholds") %in% names(m)))
  stop("Unexpected manifest schema")
if(!any(m$n_valid_thresholds>0)) warning("No valid D(p) thresholds, inspect station QC")
cat("PASS: manifest, configuration and numeric diagnostics found;",
    nrow(m),"requested election/definition/geography sets.\n")
