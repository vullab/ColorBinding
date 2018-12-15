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

sample_target <- function(norep = F){
  X = matrix(0,ncol=10, nrow=10)
  X[3,8] = 1
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

sample_ensembles <- function(s, p.swap=0.5, norep=F){
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
    X = X + probs['feature']*sample_features(sigmas['feature'], 
                                             bias=extras['feature.bias'], 
                                             norep)
  }
  if(!norep & p.ind > 0){
    if(!is.probability(X/p.ind)){stop(X)}
    X = gen_rep(X/p.ind, extras['p.rep'])*p.ind
  }

  if(probs['target']>0){
    X = X + probs['target']*sample_target(norep)
  }
  # add parts
  if(probs['part']>0){
    X = X + probs['part']*sample_parts(sigmas['part'], 
                                       p.swap=extras['p.swap.part'], 
                                       norep)
  }
  if(probs['ensemble'] > 0){
    X <- X+probs['ensemble']*sample_ensembles(sigmas['ensemble'], 
                                              p.swap=extras['p.swap.ensemble'], 
                                              norep)
  }
  if(probs['object']>0){
    X <- X+probs['object']*sample_objects(sigmas['object'], 
                                          p.swap=extras['p.swap.object'], 
                                          norep)
  }  
  if(!is.probability(X)){stop(list(sum(X), X))}
  if(norep & sum(diag(X))>0){stop(X)}
  return(name.matrix(X))
}


# proc.params -------------------------------------------------------------

# probs:
# unif      indep
# feature
# parts     pseudo    bound
# ensembles
# objects   whole



proc.params <- function(args){
  probs = c()
  p.left = 1
  if(!is.null(args[['lg.p.object']])){
    probs['object'] = p.left*logistic(args[['lg.p.object']])
    p.left = p.left - probs['object']
  } else {
    probs['object'] = 0
  }
  if(!is.null(args[['lg.p.part']])){
    probs['part'] = p.left*logistic(args[['lg.p.part']])
    p.left = p.left - probs['part']
  } else {
    probs['part'] = 0
  }
  if(!is.null(args[['lg.p.ensemble']])){
    probs['ensemble'] = p.left*logistic(args[['lg.p.ensemble']])
    p.left = p.left - probs['ensemble']
  } else {
    probs['ensemble'] = 0
  }
  if(!is.null(args[['lg.p.feature']])){
    probs['feature'] = p.left*logistic(args[['lg.p.feature']])
    p.left = p.left - probs['feature']
  } else {
    probs['feature'] = 0
  }
  if(!is.null(args[['lg.p.target']])){
    probs['target'] = p.left*logistic(args[['lg.p.target']])
    p.left = p.left - probs['target']
  } else {
    probs['target'] = 0
  }
  probs['unif'] = p.left
  
  # parse sigmas.
  sigmas = c('feature' = 0,
             'part' = 0,
             'ensemble' = 0,
             'object' = 0)
  if(!is.null(args[['log.s']])){
    sigmas = c('feature' = exp(args[['log.s']]),
               'part' = exp(args[['log.s']]),
               'ensemble' = exp(args[['log.s']]),
               'object' = exp(args[['log.s']]))
  }
  if(!is.null(args[['log.s.feature']])){
    sigmas['feature'] = exp(args[['log.s.feature']])
  }
  if(!is.null(args[['log.s.ensemble']])){
    sigmas['ensemble'] = exp(args[['log.s.ensemble']])
  }
  if(!is.null(args[['log.s.part']])){
    sigmas['part'] = exp(args[['log.s.part']])
  }
  if(!is.null(args[['log.s.object']])){
    sigmas['object'] = exp(args[['log.s.object']])
  }
  
  # parse extra parameters
  extras = c(p.rep = 0,
             feature.bias = 0.5,
             p.swap.part = 0,
             p.swap.ensemble = 0.5,
             p.swap.object = 0)
  if(!is.null(args[['lg.p.rep']])){
    extras['p.rep'] = logistic(args[['lg.p.rep']])
  }
  if(!is.null(args[['lg.feature.bias']])){
    extras['feature.bias'] = logistic(args[['lg.feature.bias']])
  }

  list('probs' = probs, 
       'sigmas' = sigmas,
       'extras' = extras)
}

fx.prior.low.p = function(x){
  -dbeta(logistic(x), 1, 10, log=T)-pmin(x,-5)
}

calc.nl.prior <- function(args){
  prior.fxs = list()
  prior.fxs = list('lg.p.object' = fx.prior.low.p,
                   'lg.p.ensemble' = fx.prior.low.p,
                   'lg.p.part' = fx.prior.low.p)
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

source('model.theory.specs.R')

