

source('heatmap.fx.R')

source('models.theory.R')





components = list('(A) uniform' = sample_unif(),
                  '(B) feature' = sample_features(0.7),
                  '(C) part' = sample_parts(0.7, 0),
                  '(D) object-ensemble' = sample_objects(0.7, 0.5),
                  '(E) whole-object' = sample_objects(0.7, 0),
                  '(F) target' = sample_target(0))
all.components= tibble()
for(n in names(components)){
  dimnames(components[[n]]) <- list(as.character(c(-2:2, (-2:2+6))),as.character(c(-2:2, (-2:2+6))))
  all.components = bind_rows(all.components,
                             components[[n]] %>% 
                               as.data.frame() %>% 
                               rownames_to_column('row') %>% 
                               gather(key=col, val=p, -row) %>%
                               mutate(row = as.numeric(row),
                                      col = as.numeric(col),
                                      component = n))
}
g <- all.components %>%
  mutate(component = factor(component, levels=names(components)),
         resp.h = row,
         resp.v = col,
         mean.log.p = log(p/2)) %>%
  plotJoint(type='bubble')+
  facet_wrap(.~component, ncol = 3)
  
print(g)

# features, with different precision.
p.mat = sample_parts(0.2, 0)
dimnames(p.mat) <- list(as.character(c(-2:2, (-2:2+6))),as.character(c(-2:2, (-2:2+6))))
p.mat %>% 
  as.data.frame() %>% 
  rownames_to_column('row') %>% 
  gather(key=col, val=p, -row) %>%
  mutate(row = as.numeric(row),
         col = as.numeric(col),
         component = n) %>%
  mutate(component = factor(component, levels=names(components)),
         resp.h = row,
         resp.v = col,
         mean.log.p = log(p/2)) %>%
  plotJoint(type='bubble') %>%
  print()


# objects, with different precision, no part binding
p.mat = sample_objects(0.2, 0)
dimnames(p.mat) <- list(as.character(c(-2:2, (-2:2+6))),as.character(c(-2:2, (-2:2+6))))
p.mat %>% 
  as.data.frame() %>% 
  rownames_to_column('row') %>% 
  gather(key=col, val=p, -row) %>%
  mutate(row = as.numeric(row),
         col = as.numeric(col),
         component = n) %>%
  mutate(component = factor(component, levels=names(components)),
         resp.h = row,
         resp.v = col,
         mean.log.p = log(p/2)) %>%
  plotJoint(type='bubble') %>%
  print()


# parts, with different precision
p.mat = sample_parts(0.2, 0)
dimnames(p.mat) <- list(as.character(c(-2:2, (-2:2+6))),as.character(c(-2:2, (-2:2+6))))
p.mat %>% 
  as.data.frame() %>% 
  rownames_to_column('row') %>% 
  gather(key=col, val=p, -row) %>%
  mutate(row = as.numeric(row),
         col = as.numeric(col),
         component = n) %>%
  mutate(component = factor(component, levels=names(components)),
         resp.h = row,
         resp.v = col,
         mean.log.p = log(p/2)) %>%
  plotJoint(type='bubble') %>%
  print()



# objects, with different precision, full binding
p.mat = sample_objects(0.2, 0)
dimnames(p.mat) <- list(as.character(c(-2:2, (-2:2+6))),as.character(c(-2:2, (-2:2+6))))
p.mat %>% 
  as.data.frame() %>% 
  rownames_to_column('row') %>% 
  gather(key=col, val=p, -row) %>%
  mutate(row = as.numeric(row),
         col = as.numeric(col),
         component = n) %>%
  mutate(component = factor(component, levels=names(components)),
         resp.h = row,
         resp.v = col,
         mean.log.p = log(p/2)) %>%
  plotJoint(type='bubble') %>%
  print()
