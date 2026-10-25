# Synthetic algebra/QC tests. No raw Serbian data needed.
source(file.path("R","voter_rigging_functions.R"),encoding="UTF-8")
stopifnot(identical(vr_id(c("0","26"),2L),c("00","26")))
x <- 1:10; ids <- rep("M1",10)
z <- vr_loo(x,ids,10L)
stopifnot(all(z$neighbors==9L),is.finite(z$z[1]),
          abs(z$z[1]-(1-mean(2:10))/stats::sd(2:10))<1e-10)
stopifnot(all(is.na(vr_loo(1:9,rep("M1",9),10L)$z)))

set.seed(54)
n <- 480L
j <- seq_len(n)
mun <- rep(sprintf("%05d",seq_len(40)),each=12)
E <- as.numeric(rep(c(39,55,73,96,140,180,250,340,460,600,780,1000),40))
E <- E + rep(0:39,each=12)*2
B <- floor(E*(.43+.013*(j%%12)+.02*((j%%3)==0)))
C <- pmin(E,B+floor(E*.027))
W <- floor(B*(.24+.018*(j%%12)+.008*(j%%7)))
d <- data.frame(Station_key=paste0("P",j),District_code="00",
                District="Grad Beograd",Municipality_code=mun,
                Municipality=paste0("M",mun),E=E,B=B,C=C,Winner_votes=W)
A <- vr_prepare(d,"fictional","Winner_votes",list(),"A")
Bspec <- vr_prepare(d,"fictional","Winner_votes",list(),"B")
stopifnot(all(A$base_ok), sum(A$E<100)>0L,
          all.equal(A$turnout,A$B/A$E),all.equal(Bspec$turnout,Bspec$C/Bspec$E),
          all.equal(A$winner_share,A$W/A$B))
A <- vr_standardize(A,10L)
stopifnot(all(A$standardized_ok),all(A$n_neighbors==11L))
ell <- vr_ellipse(A)
stopifnot(ell$status=="OK",all(is.finite(ell$rows$mahalanobis2[A$standardized_ok])))
g <- ell$rows[ell$rows$ellipse_ok,,drop=FALSE]
testD <- vr_d_at_p(g,20)
stopifnot(testD$status=="OK",testD$small_n>=10L,testD$large_n>=10L,
          abs(testD$D-sqrt(testD$dx^2+testD$dy^2))<1e-12)
# Independently reconstruct medians, including strict percentile split.
cut <- unname(stats::quantile(g$E,.2))
small <- g[g$E<cut,,drop=FALSE]; large <- g[g$E>=cut,,drop=FALSE]
manual <- sqrt((median(small$z_t)-median(large$z_t))^2+
               (median(small$z_v)-median(large$z_v))^2)
stopifnot(abs(testD$D-manual)<1e-12)
# All equal station sizes => no small group, no fabricated distance.
bogus <- g; bogus$E <- 100
stopifnot(vr_d_at_p(bogus,20)$status=="INSUFFICIENT_GROUP")
# Cumulative vote share is vote-weighted, not mean of station percentages.
sm <- data.frame(Station_key=c("s1","s2"),E=c(200,100),B=c(150,30),
                 W=c(75,24),base_ok=c(TRUE,TRUE))
cum <- vr_cumulative(sm)
stopifnot(abs(cum$cumulative_winner_share[2]-(75+24)/(150+30))<1e-12)
# Original modified Thompson tau formula checks.
tau <- vr_thompson_tau(c(0,.1,-.1,0,0,10))
stopifnot(6L %in% tau$dropped, !(6L %in% tau$retained))
# Fixed-seed exploratory permutations, guaranteed identical on repeat.
p1 <- vr_permutation(g,20,nperm=15L,seed=19L,scope="within_municipality")
p2 <- vr_permutation(g,20,nperm=15L,seed=19L,scope="within_municipality")
stopifnot(identical(p1$draws,p2$draws),is.finite(p1$p_empirical),
          p1$p_empirical>0,p1$p_empirical<=1)
cat("PASS: Master E<100 eligibility, A/B definitions, 10-station municipal LOO,",
    "95% ellipse, median D(p), tie rule, weighted cumulative votes,",
    "modified Thompson tau, reproducible exploratory permutations.\n")
