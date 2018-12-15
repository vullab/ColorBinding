
data.heatmap <- data.counts %>% 
  filter(version %in% version.include) %>%
  mutate(resp.h = (resp.h.hv-1)*6+resp.h.pos,
         resp.v = (resp.v.hv-1)*6+resp.v.pos) %>%
  group_by(experiment, subjectID, version) %>%
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
            sem.log.p = sd.log.p/sqrt(n.ss)) %>%
  mutate(description = (factor(version.code[as.character(version)],
                               levels = version.order)))

data.heatmap %>%
  filter(!is.na(mean.log.p)) %>%
  mutate(log.p = mean.log.p) %>%
  filter(experiment == 'sequential', description == 'target (circ)') %>%
  ggplot(aes(x = resp.v, 
             y = resp.h, 
             fill=log.p))+
  # facet_grid(experiment~description)+
  geom_tile()+
  theme_minimal()+
  scale_x_continuous(breaks = c(-2:2, (-2:2)+6),
                     labels = r.labels)+
  scale_y_continuous(breaks = c(-2:2, (-2:2)+6),
                     labels = r.labels,
                     trans = "reverse")+
  scale_fill_gradient(low='lightgray', high = 'black')+
  # scale_size_continuous(range=c(0.01,2))+
  theme(strip.text = element_text(face='bold'),
        legend.position = 'right',
        panel.grid = element_blank(),
        axis.text = element_text(family = 'mono'),
        axis.text.x = element_text(angle=90, hjust = 1, vjust=0.5),
        panel.border = element_rect(fill=NA, color='gray'))+
  labs(title = 'Probability of reported color source',
       y = 'A-part response',
       x = 'B-part response')

