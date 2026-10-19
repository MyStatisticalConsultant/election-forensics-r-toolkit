# EN: Lightweight structure tests; works without RZS XLSX files.
# SR: Jednostavni strukturni testovi; ne zahtevaju izvorne XLSX fajlove RZS.
script <- "RZS_data_preparation.R"
stopifnot(file.exists(script))
lines <- readLines(script, warn=FALSE, encoding="UTF-8")
code <- paste(lines, collapse="\n")
stopifnot(grepl("EDITABLE USER CONFIGURATION", code, fixed=TRUE))
stopifnot(grepl("DO NOT CHANGE THE CODE BELOW THIS LINE", code, fixed=TRUE))
stopifnot(grepl("NE MENJAJTE KOD ISPOD OVE LINIJE", code, fixed=TRUE))
stopifnot(grepl("serbian_latin <- function", code, fixed=TRUE))
stopifnot(grepl("process_election <- function", code, fixed=TRUE))
stopifnot(grepl("Eligible_primary", code, fixed=TRUE))
stopifnot(grepl("Main=x[x$Eligible_primary", code, fixed=TRUE))
stopifnot(grepl("Master=x", code, fixed=TRUE))
stopifnot(grepl("tools::md5sum(path)", code, fixed=TRUE))
stopifnot(grepl("No_ballots_received", code, fixed=TRUE))
stopifnot(grepl("Size_JHK", code, fixed=TRUE))
stopifnot(grepl("Source_dictionary", code, fixed=TRUE))
stopifnot(grepl("Derived_dictionary", code, fixed=TRUE))
stopifnot(grepl('ANALYSIS INPUT: use worksheet "Main"', code, fixed=TRUE))
stopifnot(grepl("Election_type", code, fixed=TRUE))
stopifnot(grepl("parliamentary", code, fixed=TRUE))
stopifnot(grepl("Option_%02d_votes", code, fixed=TRUE))
stopifnot(grepl("G202219002.xlsx", code, fixed=TRUE))
parsed <- parse(text=code)
stopifnot(length(parsed)>0)
# EN: Check syntax of the separate validator without executing its data-dependent checks.
# SR: Proveriti sintaksu zasebnog validatora bez pokretanja provera koje zahtevaju podatke.
validator_file <- "tests/validate_official_totals.R"
stopifnot(file.exists(validator_file))
validator_parsed <- parse(file=validator_file, encoding="UTF-8")
stopifnot(length(validator_parsed)>0)
cat("PASS: configuration, essential functions, output contract and both R script syntaxes.\n")
cat("NOTE: not an integration/accuracy test. Independently compare actual RZS totals.\n")
