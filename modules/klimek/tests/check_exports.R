# EN/SR: Run AFTER source("Klimek.R") (normal mode) / Pokrenuti posle skripta.
for (i in seq_len(nrow(INPUTS))) {
  id <- election_id(INPUTS$election_type[i],INPUTS$year[i])
  folder <- file.path(OUTPUT_DIR,id)
  stopifnot(dir.exists(folder),file.exists(file.path(folder,"tables","coverage.csv")),
            file.exists(file.path(folder,"tables","curve_endpoints.csv")))
  coverage <- readr::read_csv(file.path(folder,"tables","coverage.csv"),show_col_types=FALSE)
  stopifnot(nrow(coverage)==8L,
    coverage$Polling_stations[coverage$Group=="ALL"]==
     coverage$Polling_stations[coverage$Group=="GE100"]+
     coverage$Polling_stations[coverage$Group=="LT100"])
  ce <- readr::read_csv(file.path(folder,"tables","curve_endpoints.csv"),show_col_types=FALSE)
  stopifnot(length(unique(ce$Group))==8L,
            nrow(ce)==8L*length(unique(ce$Option_field)))
  if(WRITE_EXCEL)stopifnot(file.exists(file.path(folder,paste0(id,"_klimek_summary.xlsx"))))
  if(SAVE_PNG)stopifnot(length(list.files(file.path(folder,"figures"),pattern="\\.png$",recursive=TRUE))>0)
  if(SAVE_PDF)stopifnot(length(list.files(file.path(folder,"figures"),pattern="\\.pdf$",recursive=TRUE))>0)
  cat("PASS: export contract",id,"\n")
}
