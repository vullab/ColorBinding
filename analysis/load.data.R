require(tidyverse)

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
  
  # subject summary
  drop.labels = data %>% 
    count(experiment, subjectID, version) %>% 
    filter(n<200) %>%
    mutate(drop.labels = paste(experiment,version,subjectID,sep='-')) %>%
    .$drop.labels
  
  data = data %>% 
    filter(!(paste(experiment,version,subjectID,sep='-') %in% drop.labels))

  # convert into tabular list
  data.counts <- data %>% 
    count(experiment, subjectID, version, resp.h.pos, resp.v.pos, resp.h.hv, resp.v.hv) %>% 
    group_by(experiment, subjectID, version) %>%
    complete(resp.h.pos, resp.v.pos, resp.h.hv, resp.v.hv,
             fill = list('n' = 0)) %>%
    ungroup()
  
  save(data, data.counts, file = 'alldata.Rdata')
} else  {
  load('alldata.Rdata')
}

version.code = c(
  '-1' = 'cross (+gap)',
  '0' = 'target (circ)',
  '1' = "target (egg)",
  '2'  = "target (moon)",
  '5' = 'T (rotate)',
  '6' = '2x1 (-gap)',
  '8' = '2x2', 
  '9'  = 'T (fixed)',
  '11' = '2x1 (+gap)',
  '12' = 'cross (-gap)',
  '13' = 'frame',
  '3' = '(abandoned) played with size A',
  '4' = '(abandoned) played with size B',
  '7' = '(abandoned) 2x2 (box)',
  '10' = '(abandoned) T (stacked)')

r.labels = c('A -2', 'A -1', 'A  0', 'A +1', 'A +2',
             'B -2', 'B -1', 'B  0', 'B +1', 'B +2')

source('version.summary.R')


