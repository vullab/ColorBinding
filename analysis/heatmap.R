

hsl_to_rgb <- function(h, s, l) {
  h <- h / 360
  r <- g <- b <- 0.0
  if (s == 0) {
    r <- g <- b <- l
  } else {
    hue_to_rgb <- function(p, q, t) {
      if (t < 0) { t <- t + 1.0 }
      if (t > 1) { t <- t - 1.0 }
      if (t < 1/6) { return(p + (q - p) * 6.0 * t) }
      if (t < 1/2) { return(q) }
      if (t < 2/3) { return(p + ((q - p) * ((2/3) - t) * 6)) }
      return(p)
    }
    q <- ifelse(l < 0.5, l * (1.0 + s), l + s - (l*s))
    p <- 2.0 * l - q
    r <- hue_to_rgb(p, q, h + 1/3)
    g <- hue_to_rgb(p, q, h)
    b <- hue_to_rgb(p, q, h - 1/3)
  }
  return(rgb(r,g,b))
}

rgb_to_hsl <- function(r, g, b) {
  val_max <- max(c(r, g, b))
  val_min <- min(c(r, g, b))
  h <- s <- l <- (val_max + val_min) / 2
  if (val_max == val_min){
    h <- s <- 0
  } else {
    d <- val_max - val_min
    s <- ifelse(l > 0.5, d / (2 - val_max - val_min), d / (val_max + val_min))
    if (val_max == r) { h <- (g - b) / d + (ifelse(g < b, 6, 0)) }
    if (val_max == g) { h <- (b - r) / d/ + 2 }
    if (val_max == b) { h <- (r - g) / d + 4 }
    h <- (h / 6) * 360
  }
  return(c(h=h, s=s, l=l))
}

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
  # filter(experiment == 'sequential', description == 'target (circ)') %>%
  ggplot(aes(x = resp.v, 
             y = resp.h, 
             fill=mean.log.p))+
  facet_grid(experiment~description)+
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
        legend.position = 'top',
        panel.grid = element_blank(),
        axis.text = element_text(family = 'mono'),
        axis.text.x = element_text(angle=90, hjust = 1, vjust=0.5),
        panel.border = element_rect(fill=NA, color='gray'))+
  labs(title = 'Probability of reported color source',
       y = 'A-part response',
       x = 'B-part response')

chroma = 1
cols = c('-2' = hcl(0, chroma, 50),
         '-1'= hcl(0+1*180/2, chroma, 50),
         '0'= hcl(0+2*180/2, 0.5, 50),
         '1'= hcl(0+3*180/2, 0.5, 50),
         '2'= hcl(0+4*180/2, 0.5, 50),
         '4'= hcl(180+1*180/2, 0.5, 50),
         '5'= hcl(180+1*180/2, 0.5, 50),
         '6'= hcl(180+1*180/2, 0.5, 50),
         '7'= hcl(180+1*180/2, 0.5, 50),
         '8'= hcl(180+1*180/2, 0.5, 50))

bases = c(0,200)
steps = 90/4
for(b in 1:2){
  for(i in 1:5){
    cols[(b-1)*5+i] = hsl_to_rgb(bases[b]+(i-3)*steps,0.5,0.5)
  }
}
names(cols) = as.character(c(-2:2, (-2:2)+6))

data.heatmap %>%
  filter(experiment == 'sequential', description == 'target (circ)') %>%
  ggplot(aes(x = resp.v, 
             y = resp.h))+
  # facet_grid(experiment~description)+
  # geom_tile()+
  # scale_fill_gradient(low='lightgray', high = 'black')+
  theme_minimal()+
  scale_x_continuous(breaks = c(-2:2, (-2:2)+6),
                     labels = r.labels)+
  scale_y_continuous(breaks = c(-2:2, (-2:2)+6),
                     labels = r.labels,
                     trans = "reverse")+
  geom_point(aes(size=exp(mean.log.p)*1.1), color='black')+
  geom_point(aes(color=as.character(resp.v), size=exp(mean.log.p)))+
  geom_point(aes(color=as.character(resp.h), size=exp(mean.log.p)/4))+
  scale_size_continuous(range=c(0,15))+
  scale_color_manual(values = cols)+
  theme(strip.text = element_text(face='bold'),
        legend.position = 'top',
        panel.grid = element_blank(),
        axis.text = element_text(family = 'mono'),
        axis.text.x = element_text(angle=90, hjust = 1, vjust=0.5),
        panel.border = element_rect(fill=NA, color='gray'))+
  labs(title = 'Probability of reported color source',
       y = 'A-part response',
       x = 'B-part response')


data.frame(x=(1:5)/2,y=c(1,1,1,1,1),
           resp.h = as.character(-2:2),
           resp.v = as.character((-2:2)+6)) %>%
  ggplot(aes(x = x, 
             y = y))+
  theme_minimal()+
  geom_point(size=28, color='black')+
  geom_point(aes(color=as.character(resp.v)), size=27)+
  geom_point(aes(color=as.character(resp.h)), size=13)+
  scale_color_manual(values = cols)+
  coord_cartesian(xlim=c(0,3), ylim=c(0.5,1.5))+
  theme(strip.text = element_text(face='bold'),
        legend.position = 'top',
        panel.grid = element_blank(),
        axis.text = element_text(family = 'mono'),
        axis.text.x = element_text(angle=90, hjust = 1, vjust=0.5),
        panel.border = element_rect(fill=NA, color='gray'))+
  labs(title = 'Probability of reported color source',
       y = 'A-part response',
       x = 'B-part response')

