# Run from reports/presentation: Rscript make_figures.R
# Aggregate values transcribed from the approved CRM and GA4 reports.
# No contact-level data or live tracking configuration is read.
library(ggplot2)
dir.create('figures', showWarnings = FALSE)
navy <- '#075579'; teal <- '#087e8b'; grey <- '#bdcbd3'
base <- theme_minimal(base_size=19, base_family='sans') +
  theme(panel.grid.major.y=element_blank(), panel.grid.minor=element_blank(),
        panel.grid.major.x=element_line(colour='#e5eaee'),
        axis.title.y=element_blank(), axis.text=element_text(colour='#253342'),
        plot.title=element_text(face='bold',colour=navy,size=21),
        plot.subtitle=element_text(colour='#596575',size=15,margin=margin(b=16)),
        legend.position='top', legend.title=element_blank(),
        plot.margin=margin(16,30,12,12))
save_plot <- function(name,p,w=9,h=4.8) {
  ggsave(file.path('figures',paste0(name,'.png')),p,width=w,height=h,dpi=180,bg='white')
}
school <- read.csv('figures/school_name_distribution.csv', check.names=FALSE)
order <- c('1 CRM name','2 CRM names','3 CRM names','4–5 CRM names','6+ CRM names')
school$category <- factor(school$category,levels=rev(order))
p <- ggplot(school,aes(organisations,category,fill=category=='1 CRM name'))+
 geom_col(width=.55,show.legend=FALSE)+geom_text(aes(label=organisations),hjust=-.2,size=6)+
 scale_fill_manual(values=c(teal,grey))+
 scale_x_continuous(limits=c(0,116),breaks=c(0,25,50,75,100),expand=c(0,0))+
 labs(title='How many CRM names refer to each approved school?',subtitle='Reviewed mapping population only, 250 approved schools',x='Approved schools')+base
save_plot('school_names',p,w=10,h=4.8)
d <- data.frame(category=factor(c('Same name only','Name + organisation','Name + phone','Name + phone and organisation'),levels=rev(c('Same name only','Name + organisation','Name + phone','Name + phone and organisation'))),n=c(997,290,61,31))
p <- ggplot(d,aes(n,category))+geom_col(fill=teal,width=.55)+geom_text(aes(label=n),hjust=-.18,size=6)+
 scale_x_continuous(limits=c(0,1130),breaks=c(0,250,500,750,1000),expand=c(0,0))+
 labs(title='Evidence supporting contact review',subtitle='1,379 candidate records, assigned to mutually exclusive categories',x='Candidate records')+base
save_plot('contact_review',p,w=10)
d <- data.frame(channel=factor(c('Direct','Organic Search','Referral'),levels=c('Referral','Organic Search','Direct')),sessions=c(46708,40092,4190),share=c(50.6,43.5,4.5))
p <- ggplot(d,aes(sessions,channel,fill=channel))+geom_col(width=.5,show.legend=FALSE)+
 geom_text(aes(label=paste0(format(sessions,big.mark=',',trim=TRUE),' (',share,'%)')),hjust=-.08,size=6)+
 scale_fill_manual(values=c(grey,teal,navy))+
 scale_x_continuous(limits=c(0,65000),breaks=c(0,20000,40000,60000),labels=function(x)format(x,big.mark=',',trim=TRUE),expand=c(0,0))+
 labs(title='Main acquisition channels',subtitle='Annual channel sessions, July 2025–June 2026',x='Sessions')+base
save_plot('channels',p,w=10,h=4.8)
d <- data.frame(category=rep(c('Science Talent Search','Events & Conferences','Homepage','Account'),2),measure=rep(c('Landing-page sessions','Page views'),each=4),pct=c(31.7,15.6,17.7,3.6,35.3,14.6,12.8,11.6))
d$category <- factor(d$category,levels=rev(c('Science Talent Search','Events & Conferences','Homepage','Account')))
p <- ggplot(d,aes(pct,category,fill=measure))+geom_col(position=position_dodge(.75),width=.62)+
 geom_text(aes(label=paste0(pct,'%')),position=position_dodge(.75),hjust=-.12,size=5.5)+
 scale_fill_manual(values=c(navy,'#8abcc2'))+scale_x_continuous(limits=c(0,44),breaks=c(0,10,20,30,40),labels=function(x)paste0(x,'%'),expand=c(0,0))+
 labs(title='STS leads both entry and overall viewing',subtitle='Selected content categories; each measure has its own denominator',x='Share of the corresponding annual report total')+base
save_plot('content',p,w=10,h=5)
d <- data.frame(event=factor(c('Form starts','Form submissions','File downloads'),levels=c('File downloads','Form submissions','Form starts')),n=c(20562,11890,9756))
p <- ggplot(d,aes(n,event))+geom_col(fill=teal,width=.5)+geom_text(aes(label=format(n,big.mark=',',trim=TRUE)),hjust=-.12,size=6)+
 scale_x_continuous(limits=c(0,27000),breaks=c(0,10000,20000),labels=function(x)format(x,big.mark=',',trim=TRUE),expand=c(0,0))+
 labs(title='GA4 records substantial interaction activity',subtitle='Independent annual event totals, July 2025–June 2026',x='Recorded events')+base
save_plot('tracking',p)
