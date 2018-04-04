# setwd('/Users/tflew/Google Drive/Vul_Lab/ColorBind/Colorbinding_cory/colorbindingCory/data')
library(ggplot2)
load('fits.rep.Rdata')

mynames <- c('-1' = 'Crosses',
    '0' = 'bullseyes',
  '1'= "eggs",
  '2'= "moons",
  '5' = 'egocentric Ts',
  '6'= '1x2',
  '8' = '2x2',
  '9' = 'allocentric Ts',
  '11' = 'boxes',
  '12' = 'overlap crosses',
  '13' = 'flipped aspect crosses')

recoded.df= data.frame()
for(v in levels(data$version)){
  tmp <- subset(data, data$version == v)
  tmp <- table(tmp$resp.h.idx, tmp$resp.v.idx)
  
  tmp <- data.frame(tmp)
  tmp$version = v
  tmp$Freq = tmp$Freq / sum(tmp$Freq)
  tmp$Var1 = as.numeric(as.character(tmp$Var1))
  tmp$Var2 = as.numeric(as.character(tmp$Var2))
  tmp$type = ifelse(tmp$Var1 == tmp$Var2, 'repetition',
                    ifelse(tmp$Var1 %in% c(1:5), 
                           ifelse(tmp$Var2 %in% c(1:5), 'one-right', 'both-right'),
                           ifelse(tmp$Var2 %in% c(1:5), 'both-wrong', 'one-right')))
  recoded.df <- rbind(recoded.df, tmp)
}

colors = c('repetition' = '#999999',
           'both-right' = '#00DD00',
           'both-wrong' = '#DD0000',
           'one-right' = '#888800')
recoded.df$version <- mynames[as.character(recoded.df$version)]

g <- ggplot(recoded.df, aes(y=Var1, x=Var2, size=Freq, color = type))+
  facet_wrap(~version)+
  geom_point()+
  theme_bw()+
  scale_color_manual(values=colors)
g+scale_y_reverse()

