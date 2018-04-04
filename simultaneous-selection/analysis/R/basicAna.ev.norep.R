# setwd('/Users/tflew/Google Drive/Vul_Lab/ColorBind/Colorbinding_cory/colorbindingCory/data')
library(ggplot2)
load('fits.rep.Rdata')
data$repetition = 'rep'
data$subject = data$subjectID
tmp <- data[,c('resp.h.idx', 'resp.v.idx', 'version', 'repetition', 'subject')]
load('fits.norep.Rdata')
data$repetition = 'norep'
data$subject = data$subjectID
data <- data[,c('resp.h.idx', 'resp.v.idx', 'version', 'repetition', 'subject')]
data <- rbind(data, tmp)

mynames <- c('-1' = 'crosses',
    '0' = 'bullseyes',
  '1'= "eggs",
  '2'= "moons",
  '5' = 'T (rotate)',
  '6'= '1x2',
  '8' = '2x2',
  '9' = 'T (fixed)',
  '11' = '1x2 (gap)',
  '12' = 'crosses (overlap)',
  '13' = 'boxes (crosses aspect)')

data$version <- mynames[as.character(data$version)]

recoded.df= data.frame()
for(v in unique(data$version)){
  for(r in unique(data$repetition)){
    print(c(v,r))
    tmp <- subset(data, data$version == v & data$repetition==r)
    tmp <- table(tmp$resp.h.idx, tmp$resp.v.idx)
    
    tmp <- data.frame(tmp)
    tmp$version = v
    tmp$repetition = r
    tmp$Freq = tmp$Freq / sum(tmp$Freq)
    tmp$Var1 = as.numeric(as.character(tmp$Var1))
    tmp$Var2 = as.numeric(as.character(tmp$Var2))
    tmp$type = ifelse(tmp$Var1 == tmp$Var2, 'repetition',
                      ifelse(tmp$Var1 %in% c(1:5), 
                             ifelse(tmp$Var2 %in% c(1:5), 'one-right', 'both-right'),
                             ifelse(tmp$Var2 %in% c(1:5), 'both-wrong', 'one-right')))
    recoded.df <- rbind(recoded.df, tmp)
    
  }
}

colors = c('repetition' = '#999999',
           'both-right' = '#00DD00',
           'both-wrong' = '#DD0000',
           'one-right' = '#BB9900')
tmp <- recoded.df %>% group_by(version) %>%  
  summarise(mu= mean(Freq[Var1==3 & Var2==8]))
tmp <- tmp[order(tmp$mu),]
recoded.df$version = factor(recoded.df$version, levels = tmp$version, ordered=TRUE)
g <- ggplot(recoded.df, aes(y=Var1, x=Var2, size=Freq, color = type))+
  facet_grid(repetition~version)+
  geom_point()+
  theme_bw()+
  scale_y_reverse(breaks = 1:10)+
  scale_x_continuous(breaks = 1:10)+
  scale_color_manual(values=colors)
g+theme(legend.position='none', 
        axis.title=element_blank(),
        axis.text=element_blank(),
        axis.ticks=element_blank())



recoded.df= data.frame()
for(v in unique(data$version)){
  for(r in unique(data$repetition)){
    tmp <- subset(data, data$version == v & data$repetition==r)
    
    for(s in unique(tmp$subject)){
      tmp2 = subset(tmp, tmp$subject==s)
      dat <- table(tmp2$resp.h.idx, tmp2$resp.v.idx)
      
      dat <- data.frame(dat)
      dat$version = v
      dat$repetition = r
      dat$subject = s
      dat$Freq = dat$Freq / sum(dat$Freq)
      dat$Var1 = as.numeric(as.character(dat$Var1))
      dat$Var2 = as.numeric(as.character(dat$Var2))
      dat$V1.right = dat$Var1 %in% 1:5
      dat$V2.right = dat$Var2 %in% 6:10
      dat$V1.offset = (dat$Var1-1) %% 5 - 2
      dat$V2.offset = (dat$Var2-1) %% 5 - 2
      dat$type = ifelse(dat$Var1 == dat$Var2, 'repetition',
                        ifelse(dat$V1.right, 
                               ifelse(dat$V2.right, 'both-right', 'one-right'),
                               ifelse(dat$V2.right, 'one-right', 'both-wrong')))
      
      
      recoded.df <- rbind(recoded.df, dat)
    }
  }
}
tmp <- recoded.df %>% group_by(version) %>%  
  summarise(mu= mean(Freq[Var1==3 & Var2==8]))
tmp <- tmp[order(tmp$mu),]
recoded.df$version = factor(recoded.df$version, levels = tmp$version, ordered=TRUE)

matchy <- recoded.df %>% group_by(version, repetition, subject) %>%
  summarise(p.correct = Freq[Var1==3 & Var2==8],
            p.flipped = Freq[Var1==8 & Var2==3],
            p.match.all = sum(Freq[V1.right & V2.right & abs(V1.offset)==1 & abs(V2.offset)==1]),
            p.nomatch.all = sum(Freq[!V1.right & !V2.right & abs(V1.offset)==1 & abs(V2.offset)==1]),
            p.match.nowhole = sum(Freq[V1.right & V2.right & abs(V1.offset)>0 & abs(V2.offset)>0 & V1.offset!=V2.offset]),
            p.nomatch.nowhole = sum(Freq[!V1.right & !V2.right & abs(V1.offset)>0 & abs(V2.offset)>0 & V1.offset!=V2.offset]))
matchy$logodds.target = log(matchy$p.correct+1/500)-log(matchy$p.flipped+1/500)
matchy$logodds.all = log(matchy$p.match.all+1/500)-log(matchy$p.nomatch.all+1/500)
matchy$logodds.nowhole = log(matchy$p.match.nowhole+1/500)-log(matchy$p.nomatch.nowhole+1/500)
matchy.stats <- matchy %>% group_by(version, repetition) %>%
  summarise(n = n(), 
            p.correct.mu = mean(p.correct),
            p.correct.se = sd(p.correct)/sqrt(n),
            p.target.mu = mean(p.correct+p.flipped),
            p.target.se = sd(p.correct+p.flipped)/sqrt(n),
            logodds.target.mu = mean(logodds.target), 
            logodds.target.se = sd(logodds.target)/sqrt(n), 
            logodds.all.mu = mean(logodds.all), 
            logodds.all.se = sd(logodds.all)/sqrt(n), 
            logodds.nowhole.mu = mean(logodds.nowhole), 
            logodds.nowhole.se = sd(logodds.nowhole)/sqrt(n)) %>%
  mutate(df=n-1,
         t.target = logodds.target.mu/logodds.target.se,
         t.all = logodds.all.mu/logodds.all.se,
         t.nowhole = logodds.nowhole.mu/logodds.nowhole.se)

mytheme = theme_bw()+  
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5, size = 14, face = "bold"),
        axis.text.y = element_text(size = 14, face = "bold"),
        axis.title.y = element_text(size = 16, face = "bold"),
        axis.title.x = element_blank(),
        legend.position = "top",
        legend.text = element_text(size = 14, face = "bold"),
        legend.title = element_blank())

ggplot(matchy.stats, 
       aes(x=version, 
           y=p.target.mu, 
           ymax=p.target.mu+p.target.se, 
           ymin=p.target.mu-p.target.se,
           color=repetition,
           group=repetition))+
  geom_pointrange(size=1)+
  ylab('Prob. target colors?')+
  mytheme


ggplot(matchy.stats, 
       aes(x=version, 
           y=p.correct.mu, 
           ymax=p.correct.mu+p.correct.se, 
           ymin=p.correct.mu-p.correct.se,
           color=repetition,
           group=repetition))+
  geom_pointrange(size=1)+
  ylab('Prob. correct conjunction?')+
  mytheme

ggplot(matchy.stats, 
       aes(x=version, 
           y=logodds.target.mu, 
           ymax=logodds.target.mu+logodds.target.se, 
           ymin=logodds.target.mu-logodds.target.se,
           color=repetition,
           group=repetition))+
  geom_pointrange(size=1)+
  ylab('Log odds correct parts on target?')+
  mytheme

ggplot(matchy.stats, 
       aes(x=version, 
           y=logodds.all.mu, 
           ymax=logodds.all.mu+logodds.all.se, 
           ymin=logodds.all.mu-logodds.all.se,
           color=repetition,
           group=repetition))+
  geom_pointrange(size=1)+
  ylab('Log odds correct parts? (no targets)')+
  mytheme

ggplot(matchy.stats, 
       aes(x=version, 
           y=logodds.nowhole.mu, 
           ymax=logodds.nowhole.mu+logodds.nowhole.se, 
           ymin=logodds.nowhole.mu-logodds.nowhole.se,
           color=repetition,
           group=repetition))+
  geom_pointrange(size=1)+
  ylab('Log odds correct parts? (no whole intr.)')+
  mytheme

