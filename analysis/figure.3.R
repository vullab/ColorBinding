source('load.data.R')
source('heatmap.fx.R')

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

g <- data.heatmap %>%
  plotJoint(type='heatmap')+
  theme(legend.position='right')+
  facet_grid(experiment ~ description)

print(g)
