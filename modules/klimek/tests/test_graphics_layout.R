# EN/SR: Plot-only regression tests / Testovi izgleda grafika (bez RZS podataka).
# EN: Run in modules/klimek; no prepared Excel files required.
# SR: Pokrenuti iz modules/klimek; ne zahtevaju izborne Excel baze.
stopifnot(file.exists("Klimek.R"))
parse(file="Klimek.R",encoding="UTF-8")
Sys.setenv(EF_KLIMEK_TEST_MODE="1")
source("Klimek.R",encoding="UTF-8")
Sys.unsetenv("EF_KLIMEK_TEST_MODE")
stopifnot(requireNamespace("ggplot2",quietly=TRUE))
validate_settings()
sets <- b_group_sets(all_group_ids)
stopifnot(identical(sets$standard,c("ALL","GE100","LT100","SMALL","MIDDLE","LARGE")),
          identical(sets$jhk,c("JHK_SMALL","JHK_LARGE")),
          !length(intersect(sets$standard,sets$jhk)),
          identical(b_group_sets(c("JHK_LARGE","GE100"))$jhk,"JHK_LARGE"))
# EN: b_titles now accepts election type, year, area level and area name
#     as separate fields. Regression tests must follow the CURRENT interface.
# SR: b_titles sada odvojeno prima tip izbora, godinu, nivo i naziv oblasti.
heading <- b_titles("SR", "parliamentary", 2022L, "National", "National",
                    "ALEKSANDAR VUČIĆ – Zajedno možemo sve")
stopifnot(identical(heading$title,
                    "Kumulativne krive izlaznost–glasovi | parlamentarni 2022 Srbija"),
          !grepl("VUČIĆ",heading$title,fixed=TRUE),
          grepl("VUČIĆ",heading$subtitle,fixed=TRUE),
          grepl("Izborna opcija:",heading$subtitle,fixed=TRUE))
eng <- b_titles("EN", "parliamentary", 2022L, "National", "National", "Full option name")
stopifnot(identical(eng$title,
                    "Cumulative turnout–vote curves | parliamentary 2022 Serbia"),
          grepl("Electoral option:",eng$subtitle,fixed=TRUE),
          !grepl("Full option name",eng$title,fixed=TRUE))
stopifnot(identical(context_label("SR", "presidential",2017L,"District","Kolubarski okrug"),
                    "predsednički 2017 Kolubarski okrug"),
          identical(context_label("EN", "presidential",2017L,"District","Kolubarski okrug"),
                    "presidential 2017 Kolubarski district"),
          identical(context_label("EN", "presidential",2017L,"District","Kolubarski"),
                    "presidential 2017 Kolubarski district"))
# EN/SR: Unknown input must be rejected clearly instead of failing on [[.
err <- tryCatch(pretty_election_label("SR","parliamentary_2022",2022L),
                error=function(e) conditionMessage(e))
stopifnot(is.character(err),grepl("Unknown election type",err,fixed=TRUE))
stopifnot(Y_TICK_STEP==10,identical(size_friendly_full("GE100","SR"),
          "Biračka mesta sa 100 ili više registrovanih birača"),
          identical(size_friendly_full("MIDDLE","EN"),"Medium polling stations"))
stopifnot(grepl("\n",wrap_plot_text("Long multi word electoral candidate name",12),fixed=TRUE))
# A: 3 options -> two rows; check factor labels and complete title map.
demo <- data.frame(Turnout=rep(c(40,60,80),3),
                   Y_valid=rep(c(10,30,50),3),Y_option=rep(c(20,60,100),3),
                   Series=rep(c("Candidate A Very Long Name", "Candidate B ŠĐŽČĆ",
                                "Candidate C Another Name"),each=3))
keys <- c(Option_01_votes="Candidate A Very Long Name",
          Option_02_votes="Candidate B ŠĐŽČĆ",
          Option_03_votes="Candidate C Another Name")
p <- plot_curves(demo,"SR","valid","Grafikon",keys,
                 c(Option_01_votes="#0072B2",Option_02_votes="#D55E00",
                   Option_03_votes="#009E73"),legend_rows=A_LEGEND_ROWS_3PLUS)
stopifnot(inherits(p,"ggplot"),A_LEGEND_ROWS_3PLUS==2L,
          identical(p$labels$title,"Grafikon"),
          length(unique(as.character(p$data$Series)))==3L)
# EN/SR: Complete A group label appears as a separate subtitle with normal style.
p_a <- plot_curves(demo,"SR","valid",
                   chart_title("SR","A","parliamentary_2022",
                               context_label("SR","parliamentary",2022L,"National","National")),
                   keys,c(Option_01_votes="#0072B2",Option_02_votes="#D55E00",
                          Option_03_votes="#009E73"),
                   subtitle=size_friendly_full("GE100","SR"),legend_rows=2L)
stopifnot(!grepl("Biračka mesta",p_a$labels$title,fixed=TRUE),
          identical(p_a$labels$subtitle,
            "Biračka mesta sa 100 ili više registrovanih birača"))
# B: one option in TWO facets (standard / JHK), no 8-series overlay.
b <- data.frame(Turnout=rep(c(45,60,75),2),Y_valid=rep(c(20,60,100),2),
                Y_option=rep(c(20,60,100),2),
                Series=rep(c("Small","JHK Small"),each=3),
                Panel=rep(c("Standardne grupe", "JHK klasifikacija"),each=3))
p2 <- plot_curves(b,"SR","option",heading$title,
                   c(SMALL="Small",JHK_SMALL="JHK Small"),
                   c(SMALL="#D55E00",JHK_SMALL="#0072B2"),TRUE,
                   subtitle=heading$subtitle,facet_variable="Panel",facet_columns=1L)
stopifnot(inherits(p2,"ggplot"),inherits(p2$facet,"FacetWrap"),
          grepl("VUČIĆ",p2$labels$subtitle,fixed=TRUE),
          !grepl("VUČIĆ",p2$labels$title,fixed=TRUE))

# EN: Special RZS reporting districts are NOT automatically territorial districts.
# SR: Posebne administrativne RZS kategorije nisu automatski teritorijalni okruzi.
stopifnot(identical(district_reporting_category("33"),"overseas"),
          identical(district_reporting_category("033"),"overseas"),
          identical(district_reporting_category(55),"prisons"),
          identical(district_reporting_category("25"),"kosovo_associated"),
          identical(district_reporting_category("29"),"kosovo_associated"),
          identical(district_reporting_category("01"),"ordinary"))
stopifnot(identical(context_label("SR","presidential",2017L,"District",
                                      "Any source label",district_code="33"),
                    "predsednički 2017 Inostranstvo"),
          identical(context_label("EN","presidential",2017L,"District",
                                      "Any source label",district_code="33"),
                    "presidential 2017 Overseas"),
          identical(context_label("SR","parliamentary",2022L,"District",
                                      "Any source label",district_code="55"),
                    "parlamentarni 2022 Zavodi za izvršenje krivičnih sankcija"),
          identical(context_label("EN","parliamentary",2022L,"District",
                                      "Any source label",district_code="55"),
                    "parliamentary 2022 Prisons"))
# EN: Kosovo-associated codes retain the supplied RZS category label: no
#     invented geographical suffix; an existing 'okrug' is translated.
# SR: Za šifre 25–29 ne dodavati automatski 'okrug/district'.
stopifnot(identical(pretty_area_label("SR","District","Posebna kategorija","25"),
                    "Posebna kategorija"),
          identical(pretty_area_label("EN","District","Special reporting category","29"),
                    "Special reporting category"),
          identical(pretty_area_label("EN","District","Testni okrug","25"),
                    "Testni district"),
          identical(pretty_area_label("SR","District","Test district","25"),
                    "Test okrug"),
          identical(context_label("EN","presidential",2022L,"District",
                                  "Kolubarski okrug",district_code="01"),
                    "presidential 2022 Kolubarski district"))
# EN/SR: The B-family title must receive the area code too.
ex_b <- b_titles("EN","parliamentary",2022L,"District","Prisons",
                 "Full party/list name",district_code="55")
stopifnot(identical(ex_b$title,"Cumulative turnout–vote curves | parliamentary 2022 Prisons"),
          grepl("Full party/list name",ex_b$subtitle,fixed=TRUE))
# EN/SR: Verify the area code is carried through BOTH A and B plot call sites.
script_lines <- paste(readLines("Klimek.R",encoding="UTF-8",warn=FALSE),collapse="\n")
stopifnot(grepl("district_code=code",script_lines,fixed=TRUE),
          grepl("area_info$district_code",script_lines,fixed=TRUE))

cat("PASS: current B title API, localized EN/SR election and district titles, full A subtitles, 10-pp ticks, A two-row legend, B two-panel facets, RZS special areas.\n")
