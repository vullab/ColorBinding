# more likely to report colors from same object?

t.crit = function(conf.level, df){
  alpha = 1-conf.level
  qt(1-alpha/2, df)
}


data.lineplot <- data.counts %>% 
  filter(version %in% version.include) %>%
  mutate(sameErr = abs(resp.h.pos) == abs(resp.v.pos),
         erMag = abs(resp.h.pos),
         sameObj= resp.h.pos == resp.v.pos,
         pos = resp.h.pos,
         partMatch = case_when(
           resp.h.hv == 1 & resp.v.hv == 2 ~ 'matched',
           resp.h.hv == 2 & resp.v.hv == 1 ~ 'swapped',
           resp.h.hv == resp.v.hv ~ 'repeated',
           TRUE ~ 'error')) %>%
  filter(sameErr,
         partMatch != 'repeated') %>%
  group_by(subjectID, experiment, version, partMatch, erMag) %>% 
  summarise(p.bound = sum(n[sameObj])/sum(n),
            n = sum(n)) %>%
  ungroup() %>%
  group_by(subjectID, experiment, version, erMag) %>% 
  summarize(delta.p = p.bound[partMatch == 'matched'] - p.bound[partMatch=='swapped']) %>%
  filter(!is.na(delta.p)) %>%
  group_by(experiment, version, erMag) %>%
  summarise(mean.p = mean(delta.p),
            sem.p = sd(delta.p)/sqrt(n()),
            t = t.crit(0.95, n()-1),
            n = n()) %>%
  mutate(description = (factor(version.code[as.character(version)],
                               levels = version.order))) %>%
  filter(erMag == 1) %>%
  mutate(sig = (mean.p-0.0)>(t*sem.p))

data.lineplot = data.lineplot %>% 
  select(experiment, description, mean.p, sem.p, t, sig) %>%
  bind_rows(data.lineplot %>% 
  group_by(experiment) %>%
  mutate(weight = 1/sem.p^2,
         weight = weight/sum(weight)) %>%
  summarize(mean.p.w = sum(mean.p*weight),
            sem.p.w = sqrt(sum(sem.p^2*weight)),
            sem.p = sd(mean.p)/sqrt(n()),
            mean.p = mean(mean.p),
            t = qt(0.975, n()-1),
            description = 'total',
            sig = (mean.p-0.0)>(t*sem.p))) %>%
  mutate(description = factor(description, levels = c(version.order, 'total'))) 

g <- data.lineplot  %>%
  ggplot(aes(x = description, 
             y = mean.p, 
             ymin = mean.p-t*sem.p, 
             ymax=mean.p+t*sem.p,
             color=sig))+
  facet_grid(experiment ~ .)+
  geom_hline(yintercept = 0.0, color='gray')+
  # geom_point(data = filter(data.lineplot, sig), 
  #            aes(x = description, 
  #                y = mean.p),
  #            size=2.5, color='black')+
  geom_pointrange(size=0.6, fatten=1)+
  # geom_line() +
  
  scale_color_manual(values = c('TRUE' = 'black', 'FALSE'='gray'))+
  # scale_color_manual(values=c('matched'='blue', 
  #                             'repeated'='gray', 
  #                             'swapped'='red', 
  #                             'error' = 'orange'))+
  theme_minimal()+
  theme(strip.text = element_text(face='bold'),
        panel.grid.major.x = element_blank(),
        legend.position = 'none',
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 90, hjust=1, vjust=0.5))+
  guides(color=guide_legend(title='Part-matched'))+
  labs(
    #title = 'Probability of colors coming from same object, given they came from an adjacent object',
     #  subtitle = 'normalized after removing repetitions; showing only same source object',
       y = 'mean difference \n p(same object | matched) \n minus\n p(same object | swapped)\n + 95% CI',
       x = NULL)+
  guides(color=guide_legend(title='part-color'))
print(g)
