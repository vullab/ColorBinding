source('model.ed.2016-08-30.R')
v = predictMat(p.target=-2, 
           p.whole = -2, 
           p.part = -1.5,
           p.color = 0,
           p.rep = -100,
           scale=log(0.65), 
           norep=0)
rownames(v) = 1:10
colnames(v) = 1:10
dat <- as.data.frame(as.table(v))
dat$Var1  = as.numeric(as.character(dat$Var1))
dat$Var2  = as.numeric(as.character(dat$Var2))
dat$V1.right = dat$Var1 %in% 1:5
dat$V2.right = dat$Var2 %in% 6:10
dat$V1.offset = (dat$Var1-1) %% 5 - 2
dat$V2.offset = (dat$Var2-1) %% 5 - 2
dat$type = ifelse(dat$Var1 == dat$Var2, 'repetition',
                  ifelse(dat$V1.right, 
                         ifelse(dat$V2.right, 'both-right', 'one-right'),
                         ifelse(dat$V2.right, 'one-right', 'both-wrong')))

colors = c('repetition' = '#999999',
           'both-right' = '#00DD00',
           'both-wrong' = '#DD0000',
           'one-right' = '#BB9900')

g <- ggplot(dat, aes(y=Var1, x=Var2, size=Freq, color = type))+
  geom_point()+
  theme_bw()+
  scale_y_reverse(breaks = 1:10)+
  scale_x_continuous(breaks = 1:10)+
  scale_color_manual(values=colors)+theme(legend.position='none', 
                                          axis.title=element_blank(),
                                          axis.text=element_blank(),
                                          axis.ticks=element_blank())

print(g)
