# -1 - Original Crosses
# 0 - OG bulls eyes
# 1- "eggs" - offset bulls eyes
# 2- "moons" offset bulls eyes with the middle popping out
# 5 - T's that rotate around the display
# 6- stacked boxes (I thought this would be really hard to keep straight, since they are the same shape, but no… )
# 8 - dots and boxes, 2x2 grid of circles and squares. 
# 9 - non rotating T's
# 11 - boxes with a gap
# 12 - crosses that overlap in the middle (similar to -1 but with overlap)
# 13 - box outlines (crosses with flipped aspect ratios)
source('modelAna.ev.rep.R')
source('modelAna.ev.norep.R')
load('fits.norep.Rdata')
tmp <- fits
load('fits.rep.Rdata')
fits <- rbind(fits, tmp)
save('fits', file='allfits.Rdata')

load('allfits.Rdata')

mynames <- c('-1' = 'crosses',
             '0' = 'bullseyes',
             '1'= "eggs",
             '2'= "moons",
             '5' = 'T (rotate)',
             '6'= '1x2',
             '8' = '2x2',
             '9' = 'T (fixed)',
             '11' = '1x2 (gap)',
             '12' = 'crosses (overlap)',
             '13' = 'boxes (crosses aspect)')

fits$version <- mynames[as.character(fits$version)]
load('level.order.Rdata')
fits$version = factor(fits$version, levels=lvl.order, ordered=TRUE)
nrow(fits)
usesubs = names(table(fits$subject))[table(fits$subject)==4]
fits = subset(fits, fits$subject %in% usesubs)
fits <- fits %>% 
  group_by(repetition, version, subject) %>% 
  mutate(rBIC = BIC-BIC[model=='all'], rAIC = AIC-AIC[model=='all']) %>% 
  ungroup()
model.comparison <- fits %>% group_by(repetition, version) %>%
  summarise(AIC.better.wpart = mean(rAIC[model=='nopart']>0),
            AIC.better.wwhole = mean(rAIC[model=='nowhole']>0))

ggplot(model.comparison, aes(x=version, y=AIC.better.wpart))+facet_grid(.~repetition)+
  geom_point()


fits$net.p.target = logistic(fits$p.target)
fits$net.p.whole = (1-logistic(fits$p.target))*logistic(fits$p.whole)
fits$net.p.part = (1-logistic(fits$p.target))*(1-logistic(fits$p.whole))*logistic(fits$p.part)
fits$net.p.color = (1-logistic(fits$p.target))*(1-logistic(fits$p.whole))*(1-logistic(fits$p.part))*logistic(fits$p.color)
fits$net.p.uniform = (1-logistic(fits$p.target))*(1-logistic(fits$p.whole))*(1-logistic(fits$p.part))*(1-logistic(fits$p.color))

a <- fits %>% 
  group_by(model, repetition, version) %>% 
  summarise(net.p.uniform.mu = mean(net.p.uniform),
            net.p.uniform.se = sd(net.p.uniform)/sqrt(length(net.p.uniform)),
            net.p.target.mu = mean(net.p.target),
            net.p.target.se = sd(net.p.target)/sqrt(length(net.p.whole)),
            net.p.whole.mu = mean(net.p.whole),
            net.p.whole.se = sd(net.p.whole)/sqrt(length(net.p.whole)),
            net.p.part.mu = mean(net.p.part),
            net.p.part.se = sd(net.p.part)/sqrt(length(net.p.whole)),
            net.p.color.mu = mean(net.p.color),
            net.p.color.se = sd(net.p.color)/sqrt(length(net.p.whole)),
            p.target.mu = mean(p.target),
            p.target.se = sd(p.target)/sqrt(length(net.p.whole)),
            p.whole.mu = mean(p.whole),
            p.whole.se = sd(p.whole)/sqrt(length(net.p.whole)),
            p.part.mu = mean(p.part),
            p.part.se = sd(p.part)/sqrt(length(net.p.whole)),
            p.color.mu = mean(p.color),
            p.color.se = sd(p.color)/sqrt(length(net.p.whole)),
            scale.mu = mean(scale),
            scale.se = sd(scale)/sqrt(length(net.p.whole))
  )

divisions = data.frame()
divisions = rbind(divisions, 
                  data.frame(group = interaction(a$repetition, a$version),
                             repetition = a$repetition, 
                             version = a$version,
                             model = a$model,
                             response = 'target',
                             probability = a$net.p.target.mu,
                             cum.prob = a$net.p.target.mu,
                             probability.se = a$net.p.target.se))
divisions = rbind(divisions, 
                  data.frame(group = interaction(a$repetition, a$version),
                             repetition = a$repetition, 
                             version = a$version,
                             model = a$model,
                             response = 'whole',
                             probability = a$net.p.whole.mu,
                             cum.prob = a$net.p.target.mu+a$net.p.whole.mu,
                             probability.se = a$net.p.whole.se))
divisions = rbind(divisions, 
                  data.frame(group = interaction(a$repetition, a$version),
                             repetition = a$repetition, 
                             version = a$version,
                             model = a$model,
                             response = 'part',
                             probability = a$net.p.part.mu,
                             cum.prob = a$net.p.target.mu+a$net.p.whole.mu+a$net.p.part.mu,
                             probability.se = a$net.p.part.se))
divisions = rbind(divisions, 
                  data.frame(group = interaction(a$repetition, a$version),
                             repetition = a$repetition, 
                             version = a$version,
                             model = a$model,
                             response = 'color',
                             probability = a$net.p.color.mu,
                             cum.prob = a$net.p.target.mu+a$net.p.whole.mu+a$net.p.part.mu+a$net.p.color.mu,
                             probability.se = a$net.p.color.se))
divisions = rbind(divisions, 
                  data.frame(group = interaction(a$repetition, a$version),
                             repetition = a$repetition, 
                             version = a$version,
                             model = a$model,
                             response = 'uniform',
                             probability = a$net.p.uniform.mu,
                             cum.prob = a$net.p.target.mu+a$net.p.whole.mu+a$net.p.part.mu+a$net.p.color.mu+a$net.p.uniform.mu,
                             probability.se = a$net.p.uniform.se))
ggplot(divisions, aes(x=group, y=probability, ymin=probability-probability.se, ymax=probability+probability.se, fill=response))+
  facet_grid(.~model)+
  geom_bar(position = 'fill', stat='identity')

colors = c('target'='#000000',
           'uniform'='#AAAAAA',
           'part'='#DD0000',
           'whole'='#00AA00',
           'color'='#8888FF')

ggplot(subset(divisions, divisions$model=='all'), 
       aes(x=version, y=probability, ymin=probability-probability.se, ymax=probability+probability.se, fill=response))+
  facet_grid(.~repetition)+
  geom_bar(position = 'fill', stat='identity')+
  geom_pointrange(aes( y=cum.prob, ymin=cum.prob-probability.se, ymax=cum.prob+probability.se))+
  scale_y_continuous(expand=c(0,0), limits = c(0,1))+mytheme+scale_fill_manual(values = colors)

# axes:
# p.color - p.part - p.whole
# y = p.whole
# x = p.part - p.color
plot((a$net.p.part.mu-a$net.p.whole.mu)/(1-a$net.p.uniform.mu), a$net.p.color.mu/(1-a$net.p.uniform.mu),xlim = c(-1,1), ylim=c(0,1))
plot(a$scale.mu, a$net.p.color.mu/(1-a$net.p.uniform.mu))
