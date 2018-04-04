library(tidyverse)
data.path = '../../data/data_norep/'

data<-NULL

for (file in list.files(data.path)){
  if ("1"==substr(file,nchar(file)-4,nchar(file)-4)){
    subjMain <- read.csv(paste0(data.path, file))
    if (nrow(subjMain)>=200){
      
      subjectName <- substr(file,7,nchar(file)-6)
      subjMain$subjectID <- subjectName
      
      if ("offsett" %in% colnames(subjMain) & !("offset" %in% colnames(subjMain))){
        subjMain$offset <- subjMain$offsett
        subjMain$offset2 <- 0
        subjMain$offsett <- NULL
      }
      
      if (ncol(subjMain)==17){
        subjMain$offset <- 0
        subjMain$offset2 <- 0
        subjMain$version <- subjMain$bars.or.spot - 2
        subjMain$actualStimOn <- NA
      }
      print(ncol(subjMain))
      if(ncol(subjMain) <= 20 & is.null(subjMain$version)){
        if (subjMain$offset[1] == 3.75){
          subjMain$version = 1 
        }else if(subjMain$offset[1] == 5){
          subjMain$version = 2
        }else if(subjMain$offset[1] == 5.5){
          subjMain$version = 3
        }else if(subjMain$offset[1] == 4.5){
          subjMain$version = 4
        }else if(subjMain$offset[1] == -10.5){
          subjMain$version = 5
        }else if(subjMain$offset[1] == -9){
          subjMain$version = 6
        }else if(subjMain$offset[1] == 0){
          print("1")
        }else{
          browser()
          print (subjMain$offset[1])
        }
        
      }
      #		print (subjMain$offset[1])
      #print (ncol(subjMain) )
      data<-rbind(data,subjMain)		
    }
    
  }
}

version.code = c(
  '-1' = 'Crosses',
  '0' = 'bulls eyes',
  '1' = "eggs (offset bulls eyes)",
  '2'  = "moons (offset bulls eyes with the middle popping out)",
  '3' = 'played with size A (abandoned)',
  '4' = 'played with size B (abandoned)',
  '5' = 'Ts that rotate around the display',
  '6' = 'stacked boxes',
  '7' = 'windows (2x2 boxes, abandoned)',
  '8' = 'dots and boxes (2x2 grid of circles and squares.)', 
  '9'  = 'non rotating Ts',
  '10' = 'stacked Ts (abandoned)',
  '11' = 'boxes with a gap',
  '12' = 'crosses that overlap',
  '13' = 'box outlines')

version.code = c(
  '-1' = 'Crosses',
  '0' = 'bulls eyes',
  '1' = "eggs",
  '2'  = "moons",
  '3' = 'played with size A (abandoned)',
  '4' = 'played with size B (abandoned)',
  '5' = 'Ts (rotating)',
  '6' = 'stacked boxes',
  '7' = 'windows (2x2 boxes, abandoned)',
  '8' = '2x2 dots and boxes', 
  '9'  = 'Ts (fixed)',
  '10' = 'stacked Ts (abandoned)',
  '11' = 'boxes +gap',
  '12' = 'crosses +overlap',
  '13' = 'box outlines')


version.summary <- data %>% count(subjectID, version) %>%
  ungroup() %>%
  group_by(version) %>%
  summarize(min.trials = min(n), max.trials = max(n), subjects = n()) %>%
  mutate(description = version.code[as.character(version)]) %>% 
  arrange(desc(subjects)) 

version.summary %>%
  knitr::kable()

data <- data %>% mutate(
  resp.h.hv = as.numeric(as.character(resp.h.hv)),
  resp.v.hv = as.numeric(as.character(resp.v.hv)),
  resp.h.pos = as.numeric(as.character(resp.h.pos)),
  resp.v.pos = as.numeric(as.character(resp.v.pos)),
  Acorrect = ifelse(resp.h.pos==0 & resp.h.hv == 1, T, F),
  Bcorrect = ifelse(resp.v.pos==0 & resp.v.hv == 2, T, F),
  anyCorrect = Acorrect | Bcorrect,
  allCorrect = Acorrect & Bcorrect,
  sameObj = resp.h.pos == resp.v.pos,
  partMatch = resp.h.hv == 1 & resp.v.hv == 2
)

tmp <- data %>% filter(version %in% version.summary$version[version.summary$subjects > 10]) %>%
  filter(sameObj) %>%
  mutate(partMatch = ifelse(partMatch, 'parts matched', 'parts swapped')) %>%
  count(subjectID, version, partMatch, pos=resp.h.pos) %>% 
  group_by(subjectID) %>%
  complete(partMatch, pos) %>%
  mutate(version = first(version[!is.na(version)]),
         n = ifelse(is.na(n), 0, n)) %>%
  ungroup() %>%
  group_by(subjectID, version) %>%
  mutate(p = n/sum(n)) %>%
  ungroup() %>%
  group_by(version, partMatch, pos) %>%
  summarise(mean.p = mean(p), sd.p = sd(p), n.ss=n(), sem.p = sd.p/sqrt(n.ss))
tmp %>% mutate(description = version.code[as.character(version)]) %>%
  ggplot(aes(x=pos, y=mean.p, color=partMatch))+
  facet_wrap(~description)+
  geom_pointrange(aes(ymin = mean.p-sem.p, ymax=mean.p+sem.p))+
  geom_line() +
  scale_color_manual(values=c('blue', 'red'))+
  theme_minimal()+
  theme(strip.text = element_text(face='bold'))
