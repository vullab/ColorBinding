
data.lineplot <- data.counts %>% 
  filter(version %in% version.include) %>%
  mutate(sameObj = resp.h.pos == resp.v.pos,
         pos = resp.h.pos,
         partMatch = case_when(
           resp.h.hv == 1 & resp.v.hv == 2 ~ 'matched',
           resp.h.hv == 2 & resp.v.hv == 1 ~ 'swapped',
           resp.h.hv == resp.v.hv ~ 'repeated',
           TRUE ~ 'error')) %>%
  filter(partMatch != 'repeated') %>%
  group_by(experiment, subjectID, version) %>%
  mutate(p.smooth = (n+1)/sum(n+1),
         log.p = log(p.smooth)) %>%
  filter(sameObj) %>%
  ungroup() %>%
  group_by(experiment, version, partMatch, pos) %>%
  summarise(n.ss=n(), 
            mean.log.p = mean(log.p), 
            sd.log.p = sd(log.p), 
            sem.log.p = sd.log.p/sqrt(n.ss),
            t = qt(0.975, n.ss-1)) %>% 
  mutate(description = (factor(version.code[as.character(version)],
                               levels = version.order)))

g <- data.lineplot  %>%
  ggplot(aes(x = pos, 
             y = mean.log.p, 
             ymin = mean.log.p-t*sem.log.p, 
             ymax=mean.log.p+t*sem.log.p,
             color=partMatch))+
  facet_grid(experiment ~ description)+
  # geom_label(data=version.summary %>% filter(version %in% version.include), 
  #            aes(x=-1.5,y=-1.2, label=paste0('n=',subjects), 
  #                ymin=NULL,ymax=NULL,color=NULL),
  #            size=3)+
  geom_pointrange(size=0.3, width=10)+
  geom_line() +
  scale_color_manual(values=c('matched'='blue', 
                              'repeated'='gray', 
                              'swapped'='red', 
                              'error' = 'orange'))+
  theme_minimal()+
  theme(strip.text = element_text(face='bold'),
        legend.position = 'top',
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank())+
  labs(
    #title = 'Probability of reported colors',
     #  subtitle = 'normalized after removing repetitions; showing only same source object',
       y = 'mean log(prob) + 95% CI',
       x = 'source object position (0=target)')+
  guides(color = guide_legend(title='part-color'))

print(g)
