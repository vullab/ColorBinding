library(tidyverse)

n.stim = c(5, 17)
files = c('../visual-search/NeedHayAnalysis2/fullData.txt',
          '../visual-search/NeedHayAnalysis1/needHayData3.txt',
          '../visual-search/NeedHayAnalysis1/needHayData2.txt',
          '../visual-search/NeedHayAnalysis1/needHayData.txt',
          '../visual-search/NeedHayAnalysis1/visSearch2.csv')

dat <- purrr::map_dfr(files, function(file){
  read_delim(file = file, 
             delim = ';', 
             col_names = c('sid', 'expt', 'block', 'trial', 'stimulus', 'd', 'target', 't.x', 't.y', 'rt', 'response'))})

dat <- dat %>% 
  group_by(sid, expt, block, trial, stimulus,d,rt,response) %>%
  summarize(n.items = n(),
            t.present = any(target=='t')) %>%
  filter(response != 0) %>%
  mutate(t.response = response == 1) %>%
  mutate(correct = t.response == t.present) %>%
  ungroup()

dat %>% filter(correct) %>%
  ggplot(aes(x=(rt),
             fill=t.present))+
  facet_grid(n.items ~ stimulus)+
  geom_histogram()

dat %>% filter(correct, rt>0) %>%
  group_by(expt, stimulus, sid, t.present, correct, n.items) %>%
  summarise(rt = mean(log10(rt))) %>% 
  # spread(key=n.items, value=rt) %>%
  ggplot(aes(x=n.items, y=rt, color=expt))+
  facet_grid(stimulus~t.present)+
  geom_abline(slope = 1, intercept=0)+
  geom_point(size=0.1)
dat %>% filter(correct, rt>0) %>%
  group_by(expt, stimulus, sid, t.present, correct, n.items) %>%
  summarise(rt = median(rt)) %>% 
  group_by(expt, stimulus, sid, t.present) %>% 
  filter(n()==2) %>%
  # filter(17 %in% n.items, 5 %in% n.items) %>%
  summarize(d.rt = rt[n.items==max(n.items)]-rt[n.items==min(n.items)],
            slope = d.rt / (max(n.items)-min(n.items))) %>%
  group_by(expt, t.present, stimulus) %>%
  summarize(m.slope = mean(slope),
            s.slope = sem(slope)) %>%
  ungroup() %>%
  filter(t.present) %>%
  arrange(m.slope)
  