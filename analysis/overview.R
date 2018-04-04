library(tidyverse)

RELOAD = F

if(RELOAD){
  data.paths = list('sequential' = '../sequential-selection/data/',
                    #'simultaneous.rep' =  '../simultaneous-selection/data/data_rep/',
                    'simultaneous' =  '../simultaneous-selection/data/data_norep/'
                    #'simultaneous.no-rep2' =  '../simultaneous-selection/data/data_norep2/'
  )
  
  data <- data.frame()
  
  i = 1
  colstructure = list()
  for(expt in names(data.paths)){
    files <- list.files(data.paths[[expt]])
    filetype <- files %>% 
      as.list() %>% 
      map_chr(function(file){substr(file,nchar(file)-4,nchar(file)-4)})
    files <- subset(files, filetype == '1')
    for (file in files){
      datafile <- read.csv(paste0(data.paths[[expt]], file), stringsAsFactors = F)
      if(nrow(datafile)>100){
        if("offsett" %in% names(datafile)){
          datafile <- datafile %>% 
            mutate(offset = offsett) %>%
            select(-offsett)
        }
        if(!('version' %in% names(datafile))){
          datafile$version = NA
        }
        if(!('offset' %in% names(datafile))){
          datafile$offset = NA
        }
        datafile <- datafile %>% 
          mutate(version.bars = bars.or.spot - 2,
                 version.offset = case_when(
                   offset == 3.75 ~ 1,
                   offset == 5 ~ 2,
                   offset == 5.5 ~ 3,
                   offset == 4.5 ~ 4,
                   offset == -10.5 ~ 5,
                   offset == -9 ~ 6,
                   offset == 0 ~ NA_real_,
                   TRUE ~ NA_real_)) %>%
          select(cue.length, cue.loc.int, cue.loc.x, cue.loc.y,
                 ms.precue, ms.st.cue, ms.stimon, nitems, npractice, ntrials, radius,
                 resp.h.pos, resp.v.pos, resp.h.hv, resp.v.hv,
                 version, version.bars, version.offset) %>%
          mutate(experiment = expt,
                 subjectID = substr(file,7,nchar(file)-6))
        data <- rbind(data, datafile)
      }
    }
  }
  data <- data %>% 
    mutate(version = case_when(
      !is.na(version) ~ as.integer(version),
      !(version.bars %in% c(-1,0)) ~ as.integer(version.offset),
      TRUE ~ as.integer(version.bars)
    ))
  
  save(data, file = 'alldata.Rdata')
} else  {
  load('alldata.Rdata')
}

version.code = c(
  '-1' = 'cross (+gap)',
  '0' = 'target (circ)',
  '1' = "target (egg)",
  '2'  = "target (moon)",
  '5' = 'T (rotate)',
  '6' = 'box (2x1 -gap)',
  '8' = '2x2', 
  '9'  = 'T (fixed)',
  '11' = '2x1 (+gap)',
  '12' = 'cross (-gap)',
  '13' = 'frame',
  '3' = '(abandoned) played with size A',
  '4' = '(abandoned) played with size B',
  '7' = '(abandoned) 2x2 (box)',
  '10' = '(abandoned) T (stacked)')


version.summary <- data %>% count(experiment, subjectID, version) %>%
  ungroup() %>%
  group_by(experiment, version) %>%
  summarize(min.trials = min(n), max.trials = max(n), subjects = n()) %>%
  mutate(description = version.code[as.character(version)]) %>% 
  arrange(experiment, desc(subjects)) 

version.summary %>% 
  mutate(textsum = paste0(subjects, ' (', min.trials, '-', max.trials, ' tpp)')) %>%
  select(experiment, description, textsum) %>%
  arrange(experiment, description) %>%
  spread(key = experiment, value = textsum) %>%
  knitr::kable()

# plotting same-object line plots
tmp <- data %>% 
  filter(version %in% version.summary$version[version.summary$subjects > 10]) %>%
  count(experiment, subjectID, version, resp.h.pos, resp.v.pos, resp.h.hv, resp.v.hv) %>% 
  group_by(experiment, subjectID, version) %>%
  complete(resp.h.pos, resp.v.pos, resp.h.hv, resp.v.hv,
           fill = list('n' = 0)) %>%
  mutate(sameObj = resp.h.pos == resp.v.pos,
         partMatch = case_when(
           resp.h.hv == 1 & resp.v.hv == 2 ~ 'correct',
           resp.h.hv == 2 & resp.v.hv == 1 ~ 'swapped',
           resp.h.hv == resp.v.hv ~ 'repeated',
           TRUE ~ 'error')) %>%
  filter(partMatch != 'repeated') %>%
  mutate(p = n/sum(n),
         p.smooth = (n+1)/sum(n+1),
         log.p = log(p.smooth),
         pos = resp.h.pos) %>%
  filter(sameObj) %>%
  ungroup() %>%
  group_by(experiment, version, partMatch, pos) %>%
  summarise(n.ss=n(), 
            mean.p = mean(p), 
            sd.p = sd(p), 
            sem.p = sd.p/sqrt(n.ss),
            mean.log.p = mean(log.p), 
            sd.log.p = sd(log.p), 
            sem.log.p = sd.log.p/sqrt(n.ss))

version.acc <- tmp %>% filter(partMatch == 'correct', pos==0) %>%
  group_by(version) %>% summarise(m.acc = mean(mean.p)) %>%
  arrange(desc(m.acc))

version.n <- tmp %>% group_by(experiment, 
                 description = factor(version.code[as.character(version)],
                                      levels = version.code[as.character(version.acc$version)])) %>%
  summarize(n=mean(n.ss), s.n=sd(n.ss))

tmp %>% mutate(description = factor(version.code[as.character(version)],
                                    levels = version.code[as.character(version.acc$version)])) %>%
  ggplot(aes(x = pos, 
             y = mean.log.p, 
             ymin = mean.log.p-2*sem.log.p, 
             ymax=mean.log.p+2*sem.log.p,
             color=partMatch))+
  facet_grid(experiment ~ description)+
  geom_label(data=version.n, 
             aes(x=-1.5,y=-1.2, label=paste0('n=',n), 
                 ymin=NULL,ymax=NULL,color=NULL),
             size=3)+
  geom_pointrange(size=0.3)+
  geom_line() +
  scale_color_manual(values=c('correct'='blue', 
                              'repeated'='gray', 
                              'swapped'='red', 
                              'error' = 'orange'))+
  theme_minimal()+
  theme(strip.text = element_text(face='bold'),
        legend.position = 'top',
        panel.grid.minor = element_blank())+
  labs(title = 'Probability of reported colors',
       subtitle = 'normalized after removing repetitions; showing only same source object',
       y = 'mean log(prob) +/- 2 sem',
       x = 'source object position (0=target)')

# plotting 10x10 heatmaps
tmp <- data %>% 
  filter(version %in% version.summary$version[version.summary$subjects > 10]) %>%
  count(experiment, subjectID, version, resp.h.pos, resp.v.pos, resp.h.hv, resp.v.hv) %>% 
  group_by(experiment, subjectID, version) %>%
  complete(resp.h.pos, resp.v.pos, resp.h.hv, resp.v.hv,
           fill = list('n' = 0)) %>%
  mutate(resp.h = (resp.h.hv-1)*6+resp.h.pos,
         resp.v = (resp.v.hv-1)*6+resp.v.pos) %>%
  mutate(p = n/sum(n),
         p.smooth = (n+1)/sum(n+1),
         log.p = log(p.smooth)) %>%
  mutate(log.p = ifelse(resp.h == resp.v & experiment=='simultaneous', NA, log.p)) %>%
  ungroup() %>%
  group_by(experiment, version, resp.h, resp.v) %>%
  summarise(n.ss=n(), 
            mean.p = mean(p), 
            sd.p = sd(p), 
            sem.p = sd.p/sqrt(n.ss),
            mean.log.p = mean(log.p), 
            sd.log.p = sd(log.p), 
            sem.log.p = sd.log.p/sqrt(n.ss))

r.labels = c('A -2', 'A -1', 'A  0', 'A +1', 'A +2',
             'B -2', 'B -1', 'B  0', 'B +1', 'B +2')
tmp %>% mutate(description = factor(version.code[as.character(version)],
                                    levels = version.code[as.character(version.acc$version)])) %>%
  ggplot(aes(x = resp.h, 
             y = resp.v, 
             fill=mean.log.p))+
  facet_grid(experiment ~ description)+
  geom_tile()+
  theme_minimal()+
  scale_x_continuous(breaks = c(-2:2, (-2:2)+6),
                     labels = r.labels)+
  scale_y_continuous(breaks = c(-2:2, (-2:2)+6),
                     labels = r.labels)+
  theme(strip.text = element_text(face='bold'),
        legend.position = 'top',
        panel.grid = element_blank(),
        axis.text = element_text(family = 'mono'),
        axis.text.x = element_text(angle=90, hjust = 1, vjust=0.5),
        panel.border = element_rect(fill=NA, color='gray'))+
  labs(title = 'Probability of reported color source',
       y = 'B-part response',
       x = 'A-part response')


source('model_4.R')
results <- NULL

for (versionNum in c(-1,0,1,2,5,6,8,9,11,12,13)){
  
  dataVersion <- subset(data,data$version == versionNum)
  imageMatrix <- matrix(0,10,10)
  for (rowNum in 1:nrow(dataVersion)){
    
    horizRespIdx <- dataVersion[rowNum,"resp.h.pos"]+3 + (dataVersion[rowNum,"resp.h.hv"]-1)*5
    vertRespIdx <- dataVersion[rowNum,"resp.v.pos"]+3 + (dataVersion[rowNum,"resp.v.hv"]-1)*5
    imageMatrix[horizRespIdx,vertRespIdx] = imageMatrix[horizRespIdx,vertRespIdx] + 1/nrow(dataVersion)		
  }
  
  quartz()
  image(sqrt(matrix(rev(imageMatrix),nrow=10,byrow=TRUE)[(10:1),] ),col=gray((0:128)/128))
  result <- optim(par = c(0.1,.15,.3,.5,.8,1.5), fn = fitBindingModel, data = imageMatrix)
  #	print(result$par)
  #	print(result$value)
  results <- rbind(results,c(result$par,result$value))
  #	fitBindingModel(result$par,data = imageMatrix, plot = TRUE)
}

colMeans(results)
round(results,2)

if (FALSE){
  #for each subject... 
  for (versionNum in c(-1,0,1,2,5,6,8,9)){
    for (sub in unique(data$subjectID)){#,1,2,5,6,8,9)){	
      dataVersion <- subset(data,data$version == versionNum & data$subjectID == sub)
      imageMatrix <- matrix(0,10,10)
      print(sub)
      for (rowNum in 1:nrow(dataVersion)){
        
        horizRespIdx <- dataVersion[rowNum,"resp.h.pos"]+3 + (dataVersion[rowNum,"resp.h.hv"]-1)*5
        vertRespIdx <- dataVersion[rowNum,"resp.v.pos"]+3 + (dataVersion[rowNum,"resp.v.hv"]-1)*5
        imageMatrix[horizRespIdx,vertRespIdx] = imageMatrix[horizRespIdx,vertRespIdx] + 1	
      }
      
      print(imageMatrix)
      
    }
  }
}


#ok, generally ok. Only off for doubled subject, leaving them out makes it match. 

#read old paper
#get everything I have into a ppt
#then get distributions of overall accuracy, horiz acc, vert acc
#mindful of individual differences


#object, colored shaped parts, color and shape are the features

#model with uniform guess parameter
#probability of percieving whole object
#independent part binding of color to feature - spatial dist
#independent part binding of color to object - spatial dist
#probability of getting color correct
#probabiity of double report
#need extra uncertainty of cue location?

#story about heirarchical binding - can misbind within an object, dependent not on shape-feature similarity, but shape-feature spatial confusion




