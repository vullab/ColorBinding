source('hslrgb.R')

cols = list()
cols[['gradient']]= c()
bases = c(0,200)
steps = 90/4
for(b in 1:2){
  for(i in 1:5){
    cols[['gradient']][(b-1)*5+i] = hsl_to_rgb(bases[b]+(i-3)*steps,0.5,0.5)
  }
}
names(cols[['gradient']]) = as.character(c(-2:2, (-2:2)+6))

cols[['unique']] = c('#FF00FF',
                     '#FFFF00',
                     '#FF0000',
                     '#000000',
                     '#AA5500',
                     '#00FF00',
                     '#00AAFF',
                     '#0000FF',
                     '#005500',
                     '#888888')

names(cols[['unique']]) = as.character(c(-2:2, (-2:2)+6))

map.theme = list(theme_minimal(), 
  scale_x_continuous(breaks = c(-2:2, (-2:2)+6),
                     labels = r.labels),
  scale_y_continuous(breaks = c(-2:2, (-2:2)+6),
                     labels = r.labels,
                     trans = "reverse"),
  theme(strip.text = element_text(face='bold'),
        legend.position = 'top',
        panel.grid = element_blank(),
        axis.text = element_text(family = 'mono'),
        axis.text.x = element_text(angle=90, hjust = 1, vjust=0.5),
        panel.border = element_rect(fill=NA, color='gray')),
  labs(title = 'Probability of reported color source',
       y = 'A-part response',
       x = 'B-part response'))


plotJoint = function(data.heatmap, type='heatmap', colors='unique'){
  if(type=='heatmap'){
    g <- data.heatmap %>%
      # filter(experiment == 'sequential', description == 'target (circ)') %>%
      ggplot(aes(x = resp.v, 
                 y = resp.h, 
                 fill=mean.log.p))+
      geom_tile()+
      scale_fill_gradient(low='lightgray', high = 'black')+
      map.theme
  } else {
    g <- data.heatmap %>%
      ggplot(aes(x = resp.v, 
                 y = resp.h))+
      geom_point(aes(size=exp(mean.log.p)*1.1), color='black')+
      geom_point(aes(color=as.character(resp.v), size=exp(mean.log.p)))+
      geom_point(aes(color=as.character(resp.h), size=exp(mean.log.p)/4))+
      scale_size_continuous(range=c(0,15), limits = c(0, 0.5))+
      scale_color_manual(values = cols[[colors]])+
      map.theme+
      theme(legend.position = 'none')
    
  }
}



