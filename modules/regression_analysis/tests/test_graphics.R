# Run from modules/regression_analysis. No prepared RZS files required.
Sys.setenv(EF_REGRESSION_TEST_MODE='1')
source('Regression_analysis.R',encoding='UTF-8')
ra_require('ggplot2')
set.seed(12)
n<-140L
z<-data.frame(Station_key=as.character(seq_len(n)),turnout_pct=seq(20,95,length.out=n),
 winner_of_registered_pct=seq(10,75,length.out=n)+.7*sin(seq_len(n)*1.19),
 runner_of_registered_pct=seq(5,15,length.out=n)+.3*cos(seq_len(n)*1.17),
 winner_of_valid_pct=seq(25,80,length.out=n)+1.1*sin(seq_len(n)*.73),
 invalid_count=round(seq(1,20,length.out=n)),invalid_rate_pct=seq(.2,3,length.out=n))
g<-list(All_100plus=rep(TRUE,n),Size_Small=seq_len(n)<=70,
 Size_Large=seq_len(n)>70,JHK_Small=seq_len(n)<=28,
 JHK_Large=seq_len(n)>28,Under100=seq_len(n)<=12)
f<-list()
for(gg in names(g))for(kind in c('A','B1','B2'))
  for(role in if(kind=='A')c('Winner','RunnerUp')else 'Winner') {
    d<-z[g[[gg]],,drop=FALSE]
    fm<-switch(kind,A=if(role=='Winner')winner_of_registered_pct~turnout_pct else runner_of_registered_pct~turnout_pct,
      B1=winner_of_valid_pct~invalid_count,B2=winner_of_valid_pct~invalid_rate_pct)
    f[[paste(gg,kind,role,sep='|')]]<-ra_fit(d,'plot_fixture',fm,20L)
  }
root<-tempfile('regression_plot_test_');dir.create(root)
verified_labels<-c(Winner='Synthetic winner',RunnerUp='Synthetic runner')
for(kind in c('A','B1','B2'))for(set in c('Size','JHK'))for(lang in c('EN','SR')){
  gr<-if(set=='Size')g[c('All_100plus','Size_Small','Size_Large','Under100')]
      else g[c('All_100plus','JHK_Small','JHK_Large','Under100')]
  pd<-ra_plot_df(z,gr,kind)
  plot<-ra_make_plot(pd,f,lang,kind,'Synthetic election | National',set,
                     role_labels=verified_labels)
  if(set=='JHK') {
    stopifnot(inherits(plot,'ra_jhk_figure'),
      identical(plot$groups,c('All_100plus','JHK_Small','JHK_Large')),
      grepl('JHK',plot$subtitle,fixed=TRUE),
      length(plot$panels)==3L,
      all(vapply(plot$panels,inherits,logical(1),'ggplot')),
      !any(grepl('Under100',plot$groups,fixed=TRUE)),
      all(vapply(plot$panels,function(p)nlevels(p$data$group)==1L,logical(1))),
      all(vapply(plot$panels,function(p)is.null(p$labels$x)&&is.null(p$labels$y),logical(1))),
      !grepl('\\n',plot$caption))
  } else {
    stopifnot(inherits(plot,'ggplot'),nlevels(plot$data$group)==4L,
      length(plot$layers)>=2L)
  }
  outfile<-file.path(root,paste0(paste(kind,set,lang,sep='_'),'.png'))
  stopifnot(ra_save_png(plot,outfile,90L,14.8,9.2),file.info(outfile)$size>10000L)
}
# All labels are 50% larger than in v0.1.3. They use data-inset positions,
# not x=-Inf / y=Inf, avoiding formula text at the panel border.
pd<-ra_plot_df(z,g[c('All_100plus','Size_Small','Size_Large','Under100')],'A')
p<-ra_make_plot(pd,f,'EN','A','Synthetic','Size',role_labels=verified_labels)
stopifnot(!grepl('Lukinova',p$labels$title,ignore.case=TRUE),
  grepl('turnout',p$labels$title,ignore.case=TRUE),
  all(grepl('Synthetic',levels(p$data$role))),
  identical(p$theme$plot.title$size,21),
  isTRUE(all.equal(as.numeric(p$theme$plot.caption$size),9.25*1.5)),
  length(p$layers)>=3L)
ann<-p$layers[[length(p$layers)]]$data
stopifnot(nrow(ann)>0L,all(is.finite(ann$x)),all(is.finite(ann$y)),
  all(grepl('adj.R²',ann$label,fixed=TRUE)),
  all(grepl('n=',ann$label,fixed=TRUE)))
# The two turnout equations must share a common top-left X inset, with
# winner above runner-up, including the Large panel (no overlapping labels).
for (facet_name in unique(as.character(ann$group))) {
  a <- ann[as.character(ann$group)==facet_name,,drop=FALSE]
  if(nrow(a)!=2L)next  # Low-variation or small groups may be skipped.
  winner <- grepl('^Winner',as.character(a$role))
  runner <- grepl('^Runner-up',as.character(a$role))
  stopifnot(sum(winner)==1L,sum(runner)==1L,
            a$y[winner]>a$y[runner],
            a$y[winner]-a$y[runner]>=25,
            isTRUE(all.equal(a$x[winner],a$x[runner])),
            all(a$hjust==0),all(a$vjust==1))
}
# B1/B2 equations should be in the bottom-right, not the top-left where
# the dense invalid-ballot scatter obscures them.
for (kind in c('B1','B2')) {
  pd_b<-ra_plot_df(z,g[c('All_100plus','Size_Small','Size_Large','Under100')],kind)
  pb<-ra_make_plot(pd_b,f,'EN',kind,'Synthetic','Size',role_labels=verified_labels)
  ab<-pb$layers[[length(pb$layers)]]$data
  stopifnot(nrow(ab)>=2L,all(ab$hjust==1),all(ab$vjust==0))
  for (facet_name in unique(as.character(ab$group))) {
    b<-ab[as.character(ab$group)==facet_name,,drop=FALSE]
    grp<-pb$data[as.character(pb$data$group)==facet_name,,drop=FALSE]
    xr<-range(grp$x,na.rm=TRUE);yr<-range(grp$y,na.rm=TRUE)
    stopifnot(all(b$x>xr[1]+0.85*diff(xr)),
              all(b$y<yr[1]+0.30*diff(yr)))
  }
}
# Fixed 0..100 vertical coordinates prevent a narrow-variance Large subgroup
# from pulling both two-row equations into the same tiny band.
stopifnot(isTRUE(all.equal(as.numeric(p$coordinates$limits$y),c(0,100))))
# Legend has one horizontal row; verify if ggplot2 exposes the guide params.
legend_guide<-p$guides$guides$colour
if(!is.null(legend_guide) && !is.null(legend_guide$params$nrow))
  stopifnot(as.integer(legend_guide$params$nrow)==1L)
# Verify normal bilingual invalid/count/rate axes.
stopifnot(grepl('nevažećih',ra_labels('SR')$x_b1,fixed=TRUE),
 grepl('nevažeći',ra_labels('SR')$x_b2,ignore.case=TRUE),
 grepl('invalid',ra_labels('EN')$x_b1,ignore.case=TRUE),
 grepl('invalid',ra_labels('EN')$x_b2,ignore.case=TRUE))
cat('PASS: bilingual figures; fixed-axis separated A equations; taller JHK three-panel composition with shared axes; one-line footnote; single-row legend; bottom-right B1/B2 annotations.\n')
