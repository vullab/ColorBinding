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
  filter(!sameObj,
         sameErr,
         partMatch != 'repeated') %>%
  group_by(subjectID, experiment, version, partMatch, erMag) %>%
  summarise(n=sum(n)) %>% 
  ungroup() %>%
  group_by(subjectID, experiment, version, erMag) %>%
  summarise(p.bound = n[partMatch=='correct']/sum(n),
            n = sum(n)) %>%
  ungroup() %>%
  filter(n>0) %>%
  group_by(experiment, version, erMag) %>%
  summarise(mean.p = mean(p.bound),
            sem.p = sd(p.bound)/sqrt(n()),
            t = t.crit(0.95, n()-1)) %>%
  mutate(description = (factor(version.code[as.character(version)],
                               levels = version.order)))%>%
  filter(erMag==1) %>%
  mutate(sig = (mean.p-0.5)>(t*sem.p))


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
                        sig = (mean.p-0.5)>(t*sem.p))) %>%
  mutate(description = factor(description, levels = c(version.order, 'total')))

g <- data.lineplot   %>%
  ggplot(aes(x = description, 
             y = mean.p, 
             ymin = mean.p-t*sem.p, 
             ymax=mean.p+t*sem.p,
             color=sig))+
  facet_grid(experiment ~ .)+
  # geom_label(data=version.summary %>% filter(version %in% version.include), 
  #            aes(x=0,y=-4, label=paste0('n=',subjects), 
  #                ymin=NULL,ymax=NULL,color=NULL),
  #            size=3)+
  scale_color_manual(values = c('TRUE' = 'black', 'FALSE'='gray'))+
  geom_hline(yintercept = 0.5)+
  geom_pointrange(size=0.3)+
  geom_line() +
  theme_minimal()+
  theme(strip.text = element_text(face='bold'),
        legend.position = 'top',
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(angle = 90, hjust=1, vjust=0.5))+
  labs(y = 'mean p(part-match) + 95% CI',
       x = NULL)

  print(g)

