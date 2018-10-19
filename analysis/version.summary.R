# version summaries

if(RELOAD){
  version.summary <- data %>% 
    mutate(correct = resp.h.hv == 1 & resp.v.hv == 2 & resp.h.pos == 0 & resp.v.pos == 0) %>%
    group_by(experiment, subjectID, version) %>%
    summarize(n=n(), p.correct = mean(correct)) %>%
    ungroup() %>%
    group_by(experiment, version) %>%
    summarize(min.trials = min(n), max.trials = max(n), subjects = n(), mean.accuracy = mean(p.correct)) %>%
    arrange(experiment, desc(subjects)) 
  
  version.include = version.summary %>% 
    filter(subjects > 10) %>% 
    .$version %>% 
    unique()
  
  version.order = version.code[version.summary %>% 
                                 group_by(version) %>% 
                                 summarise(m.acc = mean(mean.accuracy)) %>%
                                 arrange(desc(version %in% version.include), desc(m.acc)) %>%
                                 .$version %>%
                                 as.character()] %>%
    unname()
  
  version.summary <- version.summary %>%
    mutate(description = factor(version.code[as.character(version)],
                                levels = version.order))
  
  save(version.summary, version.include, version.order, file='version.summary.Rdata')
} else {
  load('version.summary.Rdata')
}