
data.lineplot <- data.counts %>% 
  filter(version %in% version.include) %>%
  mutate(sameErr = abs(resp.h.pos) == abs(resp.v.pos),
         erMag = abs(resp.h.pos),
         sameObj= resp.h.pos == resp.v.pos,
         pos = resp.h.pos,
         partMatch = case_when(
           resp.h.hv == 1 & resp.v.hv == 2 ~ 'correct',
           resp.h.hv == 2 & resp.v.hv == 1 ~ 'swapped',
           resp.h.hv == resp.v.hv ~ 'repeated',
           TRUE ~ 'error')) %>%
  group_by(experiment, subjectID, version) %>%
  mutate(p.smooth = (n+1)/sum(n+1),
         log.p = log(p.smooth)) %>%
  filter(!sameObj,
         sameErr,
         partMatch != 'repeated') %>%
  ungroup() %>%
  group_by(experiment, version, partMatch, erMag) %>%
  summarise(n.ss=n(), 
            mean.log.p = mean(log.p), 
            sd.log.p = sd(log.p), 
            sem.log.p = sd.log.p/sqrt(n.ss)) %>% 
  mutate(description = (factor(version.code[as.character(version)],
                               levels = version.order)))

data.lineplot  %>%
  ggplot(aes(x = erMag, 
             y = mean.log.p, 
             ymin = mean.log.p-2*sem.log.p, 
             ymax=mean.log.p+2*sem.log.p,
             color=partMatch))+
  facet_grid(experiment ~ description)+
  # geom_label(data=version.summary %>% filter(version %in% version.include), 
  #            aes(x=0,y=-4, label=paste0('n=',subjects), 
  #                ymin=NULL,ymax=NULL,color=NULL),
  #            size=3)+
  geom_pointrange(size=0.3)+
  geom_line() +
  scale_color_manual(values=c('correct'='blue', 
                              'repeated'='gray', 
                              'swapped'='red', 
                              'error' = 'orange'))+
  scale_x_continuous(breaks=c(1,2), limits = c(0.5,2.5))+
  theme_minimal()+
  theme(strip.text = element_text(face='bold'),
        legend.position = 'right',
        panel.grid.minor = element_blank())+
  labs(title = 'Probability of reported colors',
       subtitle = 'normalized after removing repetitions; showing only same source object',
       y = 'mean log(prob) +/- 2 sem',
       x = 'source object position (0=target)')


