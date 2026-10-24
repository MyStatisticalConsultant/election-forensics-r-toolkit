# Run from modules/contours; tests need no RZS Excel files.
# Run tests in a private function scope and ALWAYS restore the caller's flag.
# Setting EF_CONTOUR_TEST_MODE=1 suppresses the production output runner only
# while the synthetic tests are executing.  This fixes the v0.1.0 issue where
# the flag remained set after a PASS, preventing source("Contours.R") from running.
(function() {
  previous_flag <- Sys.getenv("EF_CONTOUR_TEST_MODE", unset=NA_character_)
  on.exit({
    if(is.na(previous_flag)) Sys.unsetenv("EF_CONTOUR_TEST_MODE")
    else Sys.setenv(EF_CONTOUR_TEST_MODE=previous_flag)
  }, add=TRUE)
  Sys.setenv(EF_CONTOUR_TEST_MODE="1")
  source("Contours.R", local=TRUE)

# Manually reproduce leave-one-out sample mean/SD within municipalities.
v <- c(1,2,3,4,5,6,10,12,14,16,18,20)
g <- rep(c("m1","m2"),each=6)
z <- leave_one_out_z(v,g,5L)
for(i in seq_along(v)) {
  j <- setdiff(which(g==g[[i]]),i)
  stopifnot(isTRUE(all.equal(z$z[[i]],(v[[i]]-mean(v[j]))/stats::sd(v[j]),tolerance=1e-9)))
}
stopifnot(all(z$neighbors == 5L))
# Ineligible few-neighbor groups and zero-variance group must be NA.
stopifnot(all(is.na(leave_one_out_z(1:3,rep("m",3),5L)$z)))
stopifnot(all(is.na(leave_one_out_z(rep(3,6),rep("m",6),5L)$z)))
# Both definitions and group handling.
d <- data.frame(Station_key=paste0("s",1:12), District_code=rep("01",12),
 District="A", Municipality_code=rep(c("001","002"),each=6),Municipality="M",
 E=rep(200,12), B=rep(100,12), C=rep(120,12), Winner_votes=rep(60,12),
 Size=rep(c("Small","Large"),each=6), Size_JHK=rep(c("Small","Large"),each=6),
 stringsAsFactors=FALSE)
a <- prepare_rates(d,"Winner_votes","A")
b <- prepare_rates(d,"Winner_votes","B")
stopifnot(all(a$turnout_raw==.5),all(b$turnout_raw==.6),
          all(a$winner_raw==.6),all(b$winner_raw==.6))
# Equal underlying rates (raw) -> leave-one-out SD = 0; skip all.
sa <- standardize_municipality(a,5L)
stopifnot(all(!sa$standardized_ok))
cat("PASS: definitions A/B, municipality leave-one-out, insufficient reference, zero variance.\n")
})()
