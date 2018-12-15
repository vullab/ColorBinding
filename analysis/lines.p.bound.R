

t.crit = function(conf.level, df){
  alpha = 1-conf.level
  qt(1-alpha/2, df)
}

data.lineplot = data.counts %>% 
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
  filter(sameObj,
         sameErr,
         partMatch %in% c('correct','swapped')) %>%
  group_by(subjectID, experiment, version, pos) %>% 
  summarize(p.binding = n[partMatch=='correct']/sum(n[partMatch %in% c('correct','swapped')]),
            n = sum(n[partMatch %in% c('correct','swapped')])) %>%
  filter(n>0) %>%
  group_by(experiment, version, pos) %>%
  summarise(mean.p.binding = mean(p.binding),
            se.p.binding = sd(p.binding)/sqrt(n()),
            t = t.crit(0.95, n()-1)) %>%
  mutate(description = (factor(version.code[as.character(version)],
                               levels = version.order))) %>%
  mutate(sig = (mean.p.binding-0.5)>(t*se.p.binding))


data.lineplot  %>%
  ggplot(aes(x = pos, 
             y = mean.p.binding, 
             ymin = mean.p.binding-t*se.p.binding, 
             ymax=mean.p.binding+t*se.p.binding,
             color=experiment))+
  facet_grid(.~description)+
  geom_hline(yintercept = 0.5, color='gray') +
  geom_pointrange(size=0.3)+
  geom_line() +
  theme_minimal()+
  theme(strip.text = element_text(face='bold'),
        legend.position = 'right',
        panel.grid.minor = element_blank())+
  labs(title = 'Probability of correct part binding',
       subtitle = 'showing only same source object',
       y = 'p(correct part binding)',
       x = 'source object position (0=target)')



