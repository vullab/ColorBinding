library(stats4)
source('helper.functions.R')

# list of error processes
sample_unif <- function(norep = F){
  X <- matrix(1, nrow=10, ncol=10)
  X <- X/sum(X)
  if(!is.probability(X)){stop(X)}
  if(norep){X = remove.norep(X)}
  return(X)
}

sample_features <- function(s, bias = 0.5, norep=F){
  px = prob.loc(s)
  X = outer(c(bias*px,(1-bias)*px), c(bias*px,(1-bias)*px), '*')
  X <- X/sum(X)
  if(!is.probability(X)){stop(X)}
  if(norep){X = remove.norep(X)}
  return(X)
}

sample_parts <- function(s, p.swap=0, norep=F){
  px = prob.loc(s)
  subx <- outer(px, px, '*')
  X = matrix(0,ncol=10, nrow=10)
  X[1:5,6:10] <- subx*(1-p.swap)
  X[6:10,1:5] <- subx*p.swap
  X <- X/sum(X)
  if(!is.probability(X)){stop(X)}
  if(norep){X = remove.norep(X)}
  return(X)
}

sample_part_guess <- function(s, bias=0.5, norep=F){
  px = prob.loc(s)
  X1 <- outer(c(px, rep(0,5)), rep(1/10, 10), '*')
  X2 <- outer(rep(1/10, 10), c(rep(0,5), px), '*')
  X = X1*bias + X2*(1-bias)
  X <- X/sum(X)
  if(!is.probability(X)){stop(X)}
  if(norep){X = remove.norep(X)}
  return(X)
}


sample_objects <- function(s, p.swap=0, norep=F){
  px = prob.loc(s)
  X = matrix(0,ncol=10, nrow=10)
  X[cbind(1:5,6:10)] = px*(1-p.swap)
  X[cbind(6:10, 1:5)] = px*p.swap
  X <- X/sum(X)
  if(!is.probability(X)){stop(X)}
  if(norep){X = remove.norep(X)}
  return(X)
}

gen_rep <- function(X, p.rep=0){
  repX = matrix(0,ncol=10, nrow=10)
  diag(repX) <- 0.5*rowSums(X) + 0.5*colSums(X)
  X = X*(1-p.rep) + p.rep*repX
  X <- X/sum(X)
  if(!is.probability(X)){stop(X)}
  return(X)
}


# model master ------------------------------------------------------------
model_master <- function(probs, sigmas, extras, norep=F){
  debugPrint(probs)
  debugPrint(sigmas)
  debugPrint(extras)
  if(!is.probability(probs)){stop(probs)}
  # assemble independent list
  p.ind = probs['unif'] + probs['feature']
  X = probs['unif']*sample_unif(norep)
  if(probs['feature']>0){
    X = X + probs['feature']*sample_features(sigmas['feature'], bias=extras['feature.bias'], norep)
  }
  if(!norep & p.ind > 0){
    if(!is.probability(X/p.ind)){stop(X)}
    X = gen_rep(X/p.ind, extras['p.rep'])*p.ind
  }
  # add parts
  if(probs['part']>0){
    X = X + probs['part']*sample_parts(sigmas['part'], p.swap=extras['p.swap.part'], norep)
  }
  if(probs['object']>0){
    X <- X+probs['object']*sample_objects(sigmas['object'], p.swap=extras['p.swap.object'], norep)
  }  
  if(!is.probability(X)){stop(list(sum(X), X))}
  if(norep & sum(diag(X))>0){stop(X)}
  return(name.matrix(X))
}


# proc.params -------------------------------------------------------------
# args = lg.p.indep
proc.params <- function(args){
  probs = c()
  if(!is.null(args[['lg.p.indep']])){
    p.ind = logistic(args[['lg.p.indep']])
  } else {
    p.ind = 1
  }
  if(!is.null(args[['lg.p.feature']])){
    probs['feature'] = logistic(args[['lg.p.feature']])*p.ind
  } else {
    probs['feature'] = 0*p.ind
  }
  probs['unif'] = p.ind - probs['feature']
  if(!is.null(args[['lg.p.part']])){
    probs['part'] = (1-p.ind)*logistic(args[['lg.p.part']])
  } else {
    probs['part'] = (1-p.ind)*1
  }
  probs['object'] = (1-p.ind) - probs['part']
  
  sigmas = c('feature' = 0,
             'part' = 0,
             'object' = 0)
  if(!is.null(args[['log.s']])){
    sigmas = c('feature' = exp(args[['log.s']]),
             'part' = exp(args[['log.s']]),
             'object' = exp(args[['log.s']]))
  }
  if(!is.null(args[['log.s.feature']])){
    sigmas['feature'] = exp(args[['log.s.feature']])
  }
  if(!is.null(args[['log.s.part']])){
    sigmas['part'] = exp(args[['log.s.part']])
  }
  if(!is.null(args[['log.s.object']])){
    sigmas['object'] = exp(args[['log.s.object']])
  }
  extras = c(p.rep = 0,
             feature.bias = 0.5,
             p.swap.part = 0,
             p.swap.object = 0)
  if(!is.null(args[['lg.p.rep']])){
    extras['p.rep'] = logistic(args[['lg.p.rep']])
  }
  if(!is.null(args[['lg.feature.bias']])){
    extras['feature.bias'] = logistic(args[['lg.feature.bias']])
  }
  if(!is.null(args[['lg.p.swap']])){
    extras['p.swap.part'] = logistic(args[['lg.p.swap']])
    extras['p.swap.object'] = logistic(args[['lg.p.swap']])
  }
  if(!is.null(args[['lg.p.swap.part']])){
    extras['p.swap.part'] = logistic(args[['lg.p.swap.part']])
  }
  if(!is.null(args[['lg.p.swap.object']])){
    extras['p.swap.object'] = logistic(args[['lg.p.swap.object']])
  }

  list('probs' = probs, 
       'sigmas' = sigmas,
       'extras' = extras)
}

calc.nl.prior <- function(args){
  prior.fxs = list()
  default.fx = function(x){x^2}
  nl.prior = c()
  for(name in names(args)){
    if(nchar(name)>0){
      if(name %in% names(prior.fxs)){
        nl.prior[name] = prior.fxs[[name]](args[[name]])
      } else {
        nl.prior[name] = default.fx(args[[name]])
      }
    }
  }
  return(sum(nl.prior))
}

calc.nl.likelihood <- function(X, datamat){
  log.P <- log(X)
  log.P[datamat == 0] = 0
  return(-sum(log.P*datamat))
}

nloglik_master = function(args, datamat, norep){
  params <- proc.params(args)
  debugPrint(params)
  X = model_master(probs = params$probs, 
                   sigmas = params$sigmas, 
                   extras = params$extras, 
                   norep = norep)
  
  nl.prior = calc.nl.prior(args)
  nl.likelihood = calc.nl.likelihood(X, datamat)
  return(nl.likelihood+nl.prior)
}


make.param.list <- function(f){
  start.params = formals(f)
  for(name in names(start.params)){
    start.params[[name]] = 0
  }
  return(start.params)
}

model.fxs = list()

# Uniform, no repetition
model.fxs[['U']] = function(datamat, norep=F){
  nloglik_0 <- function(log.s){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# Uniform, with repetition
model.fxs[['U+']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# Uniform, Feature (no bias), with repetition
model.fxs[['UF+']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.feature, lg.p.rep, log.s.feature){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# Uniform, Feature (bias), with repetition
model.fxs[['UFb+']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.feature, lg.p.rep, log.s.feature, lg.feature.bias){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}


# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UFP+1']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.indep, lg.p.feature, lg.p.rep, log.s){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# Uniform, Feature (no bias), Parts (no swap), Objects (no swap) 1sigma, with repetition
model.fxs[['UFPO+1']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.indep, lg.p.feature, lg.p.part, lg.p.rep, log.s){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}


# Uniform, Feature (no bias), Parts (no swap), Objects (no swap) 3-sigma, with repetition
model.fxs[['UFPO+3']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.indep, lg.p.feature, lg.p.part, lg.p.rep,log.s.feature, log.s.part, log.s.object){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}


# Uniform, Feature (no bias), Parts (swap), Objects (swap) 1sigma, with repetition
model.fxs[['UFPOs+1']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.indep, lg.p.feature, lg.p.part, lg.p.rep, log.s, lg.p.swap){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}


# full - ss-swap
model.fxs[['full-v']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.indep, 
                        lg.p.feature, 
                        lg.p.part, 
                        lg.p.rep, 
                        log.s.feature, 
                        log.s, 
                        lg.feature.bias, 
                        lg.p.swap){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  start.params = formals(nloglik_0)
  for(name in names(start.params)){
    start.params[[name]] = 0
  }
  
  fit <- mle(nloglik_0, start = start.params)
  return(fit)
}


# full - feature bias
model.fxs[['full-b']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.indep, 
                        lg.p.feature, 
                        lg.p.part, 
                        lg.p.rep, 
                        log.s.feature, 
                        log.s.part, 
                        log.s.object, 
                        lg.p.swap.part, 
                        lg.p.swap.object){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  start.params = formals(nloglik_0)
  for(name in names(start.params)){
    start.params[[name]] = 0
  }
  
  fit <- mle(nloglik_0, start = start.params)
  return(fit)
}



# full - swap
model.fxs[['full-2sw']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.indep, 
                        lg.p.feature, 
                        lg.p.part, 
                        lg.p.rep, 
                        log.s.feature, 
                        log.s.part, 
                        log.s.object, 
                        lg.feature.bias){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  start.params = formals(nloglik_0)
  for(name in names(start.params)){
    start.params[[name]] = 0
  }
  
  fit <- mle(nloglik_0, start = start.params)
  return(fit)
}

# full - varying swap
model.fxs[['full-1sw']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.indep, 
                        lg.p.feature, 
                        lg.p.part, 
                        lg.p.rep, 
                        log.s.feature, 
                        log.s.part, 
                        log.s.object, 
                        lg.feature.bias, 
                        lg.p.swap){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  start.params = formals(nloglik_0)
  for(name in names(start.params)){
    start.params[[name]] = 0
  }
  
  fit <- mle(nloglik_0, start = start.params)
  return(fit)
}

# full - varying sigma
model.fxs[['full-2s']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.indep, 
                        lg.p.feature, 
                        lg.p.part, 
                        lg.p.rep, 
                        log.s, 
                        lg.feature.bias, 
                        lg.p.swap.part, 
                        lg.p.swap.object){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  start.params = formals(nloglik_0)
  for(name in names(start.params)){
    start.params[[name]] = 0
  }
  
  fit <- mle(nloglik_0, start = start.params)
  return(fit)
}


# everything van vary!
model.fxs[['full']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.indep, 
                        lg.p.feature, 
                        lg.p.part, 
                        lg.p.rep, 
                        log.s.feature, 
                        log.s.part, 
                        log.s.object, 
                        lg.feature.bias, 
                        lg.p.swap.part, 
                        lg.p.swap.object){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  start.params = formals(nloglik_0)
  for(name in names(start.params)){
    start.params[[name]] = 0
  }
  
  fit <- mle(nloglik_0, start = start.params)
  return(fit)
}
