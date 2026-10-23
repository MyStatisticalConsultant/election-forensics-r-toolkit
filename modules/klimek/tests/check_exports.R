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
  # EN/SR: Every eligible district/municipality has all eight groups for
  #     every option, even for groups with 0 stations (percentage columns NA).
  for(level in c("district","municipality")) {
    path <- file.path(folder,"tables",paste0(level,".csv"))
    if(WRITE_CSV && file.exists(path)) {
      td <- readr::read_csv(path,show_col_types=FALSE)
      area_count <- length(unique(td$Area_key))
      opts_count <- length(unique(td$Option_field))
      stopifnot(nrow(td)==area_count*8L*opts_count)
      missing <- td$Stations==0L
      if(any(missing)) stopifnot(all(is.na(td$Turnout_pct[missing])),
                               all(is.na(td$Option_share_pct[missing])))
    }
  }
  ce <- readr::read_csv(file.path(folder,"tables","curve_endpoints.csv"),show_col_types=FALSE)
  stopifnot(length(unique(ce$Group))==8L,
            nrow(ce)==8L*length(unique(ce$Option_field)))
  if(WRITE_EXCEL)stopifnot(file.exists(file.path(folder,paste0(id,"_klimek_summary.xlsx"))))
  if(SAVE_PNG)stopifnot(length(list.files(file.path(folder,"figures"),pattern="\\.png$",recursive=TRUE))>0)
  if(SAVE_PDF)stopifnot(length(list.files(file.path(folder,"figures"),pattern="\\.pdf$",recursive=TRUE))>0)
  # EN: Verify new split B figure naming when relevant, and no stale 8-line file.
  # SR: Provera novih imena B slika i odsustva zastarelog grafikona sa 8 krivih.
  figroot <- file.path(folder,"figures")
  if(PLOT_FAMILY_B && WRITE_COMBINED && B_SPLIT_COMBINED && SAVE_PNG) {
    figs <- list.files(figroot,pattern="\\.png$",recursive=TRUE)
    stopifnot(any(grepl("^B_Option_[0-9]+_votes_combined_standard\\.png$",basename(figs))),
              any(grepl("^B_Option_[0-9]+_votes_combined_jhk\\.png$",basename(figs))))
  }
  if(PLOT_FAMILY_B && WRITE_FACETED && B_TWO_PANEL_FACET && SAVE_PNG) {
    figs <- list.files(figroot,pattern="\\.png$",recursive=TRUE)
    stopifnot(any(grepl("^B_Option_[0-9]+_votes_faceted\\.png$",basename(figs))))
  }
  if(PLOT_FAMILY_B) {
    stale <- list.files(figroot,pattern="^B_Option_[0-9]+_votes_combined\\.(png|pdf)$",recursive=TRUE)
    stopifnot(length(stale)==0L)
  }
  cat("PASS: export and updated figure layout",id,"\n")
}
