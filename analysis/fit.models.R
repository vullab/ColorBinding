source('models.R')

if(RELOAD){
  model.names = names(model.fxs)
  
  fit_summary = function(fit, datamat, norep){
    estimates <- as.data.frame(coef(summary(fit))) %>% 
      rownames_to_column('parameter')
    args <- as.list(coef(fit))
    params <- proc.params(args)
    prediction <- model_master(params$probs,
                               params$sigmas,
                               params$extras,
                               norep)
    tibble(estimates = list(estimates), 
           internal = list(args),
           params = list(params),
           P = list(prediction),
           nl.likelihood = calc.nl.likelihood(prediction, datamat),
           nl.prior = calc.nl.prior(args),
           n.params = length(args),
           n.obs = sum(datamat))
  }
  
  data.fit <- data.counts %>% 
    filter(version %in% version.include) %>%
    mutate(resp.A = (resp.h.hv-1)*5+resp.h.pos+3,
           resp.B = (resp.v.hv-1)*5+resp.v.pos+3) %>%
    select(experiment, subjectID, version, resp.A, resp.B, n) %>% 
    group_by(experiment, version, subjectID) %>% 
    do(tibble(datamat = list(getMatrix(.)))) %>% 
    ungroup()
  
  pb <- txtProgressBar(min = 0, max = nrow(data.fit)*length(model.names), style = 3)
  k = 0
  fits = data.frame()
  for(model.name in model.names){
    for(i in 1:nrow(combo)){
      setTxtProgressBar(pb, k)
      current <- data.fit %>% 
        slice(i) %>%
        select(-datamat)
      D <- data.fit$datamat[[i]]
      
      nr = ifelse(current$experiment=='simultaneous', T, F)
      
      fit <- model.fxs[[model.name]](D, nr)
      
      fits <- fit %>% 
        fit_summary(D, nr) %>%
        bind_cols(current) %>%
        mutate(model = model.name) %>%
        bind_rows(fits)
      k = k+1
    }
  }
  fits <- fits %>% 
    mutate(n.params = ifelse(model == 'U', 0, n.params))
  
  save(data.fit, fits, model.names, file='model.fits.Rdata')
} else {
  load('model.fits.Rdata')
}

maxLL = function(D, smooth=1, norep=F){
  sm = matrix(1, ncol=10, nrow=10)
  if(norep){
    diag(sm) = 0
  }
  sm = sm/sum(sm)
  D <- D+sm*smooth
  P = D/sum(D)
  log.P = log(P)
  log.P[D==0] = 0
  -sum(log.P*D)
}

best = c()
worst = c()
for(i in 1:nrow(data.fit)){
  N = sum(data.fit$datamat[[i]])
  best[i] = maxLL(data.fit$datamat[[i]], 
                  1, 
                  data.fit$experiment[i]=='simultaneous')/N
  worst[i] = ifelse(data.fit$experiment[i]=='simultaneous', 
                    log(90), 
                    log(100))
}
data.best <- data.fit %>% 
  mutate(best.ll = best,
         worst.ll = worst) %>%
  select(-datamat)
