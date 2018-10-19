logistic = function(x){1/(1+exp(-x))}
prob_norm <- function(x){ return(x/sum(x))}
dlaplace <- function(x, m, s){1/(2*s)*exp(-abs(x-m)/s)}
prob.loc <- function(s){
  prob_norm(dlaplace(-2:2, 0, s))
}

# possible processes:
# 1. random guess
# 2. two parts
r.labels = c('A -2', 'A -1', 'A  0', 'A +1', 'A +2',
             'B -2', 'B -1', 'B  0', 'B +1', 'B +2')

dress.matrix <- function(X, norep){
  if(norep){
    diag(X) = 0
  }
  X = X/sum(X)
  rownames(X) <- r.labels
  colnames(X) <- r.labels
  return(X)
}

sample_unif <- function(norep = F){
  X <- matrix(1, nrow=10, ncol=10)
  return(dress.matrix(X, norep))
}

sample_features <- function(s, bias = 0.5, norep=F){
  px = prob.loc(s)
  X = outer(c(bias*px,(1-bias)*px), c(bias*px,(1-bias)*px), '*')
  return(dress.matrix(X, norep))
}

sample_parts <- function(s, p.swap=0, norep=F){
  px = prob.loc(s)
  subx <- outer(px, px, '*')
  X = matrix(0,ncol=10, nrow=10)
  X[1:5,6:10] <- subx*(1-p.swap)
  X[6:10,1:5] <- subx*p.swap
  return(dress.matrix(X, norep))
}

sample_objects <- function(s, p.swap=0, norep=F){
  px = prob.loc(s)
  X = matrix(0,ncol=10, nrow=10)
  X[cbind(1:5,6:10)] = px*(1-p.swap)
  X[cbind(6:10, 1:5)] = px*p.swap
  return(dress.matrix(X, norep))
}

gen_rep <- function(X, p.rep=0){
  repX = matrix(0,ncol=10, nrow=10)
  diag(repX) <- 0.5*rowSums(X) + 0.5*colSums(X)
  X = X*(1-p.rep) + p.rep*repX
  return(dress.matrix(X, F))
}

model_0 <- function(probs, p.rep, s, norep=F){
  if(round(sum(probs),8)!=1){stop(probs)}
  p.ind = probs['unif'] + probs['feature']
  X = (sample_unif(norep)*probs['unif'] + sample_features(s, bias=0.5, norep)*probs['feature'])/p.ind
  if(!norep){
    X = gen_rep(X, p.rep)
  }
  X <- X*p.ind+sample_parts(s, p.swap=0, norep)*probs['part']+sample_objects(s, p.swap=0, norep)*probs['object']
  return(dress.matrix(X, norep))
}

library(stats4)


fit_0 <- function(datamat, norep=F){
  nloglik_0 <- function(lg.p.indep, lg.p.feature, lg.p.part, lg.p.rep, log.s){
    p.ind = logistic(lg.p.indep)
    probs = c()
    probs['feature'] = logistic(lg.p.feature)*p.ind
    probs['unif'] = p.ind - probs['feature']
    probs['part'] = (1-p.ind)*logistic(lg.p.part)
    probs['object'] = (1-p.ind) - probs['part']
    
    p.rep = logistic(lg.p.rep)
    
    s = exp(log.s)
    
    X = model_0(probs, p.rep, s, norep)
    log.P <- log(X)
    log.P[datamat == 0] = 0
    nl.prior = +lg.p.indep^2+(lg.p.feature)^2+lg.p.part^2+lg.p.rep^2+(log.s)^2
    nl.likelihood = -sum(log.P*datamat)
    # print(round(c(probs, 
    #         c('p.rep'=p.rep, 
    #           's'=s, 
    #           'nl.prior'=nl.prior, 
    #           'nl.likelihood' = nl.likelihood)),3))
    return(nl.likelihood+nl.prior)
  }
  
  fit <- mle(nloglik_0, 
      start = list('lg.p.indep'=0, 'lg.p.feature'=0, 'lg.p.part'=0, 'lg.p.rep'=0, 'log.s'=0))
  
  as.data.frame(t(as.matrix(coef(fit)))) %>% 
    mutate(LL = logLik(fit)) %>%
    return()
}

coef2p <- function(coefs){
  p.ind = logistic(coefs[['lg.p.indep']])
  probs = c()
  probs['feature'] = logistic(coefs[['lg.p.feature']])*p.ind
  probs['unif'] = p.ind - probs['feature']
  probs['part'] = (1-p.ind)*logistic(coefs[['lg.p.part']])
  probs['object'] = (1-p.ind) - probs['part']
  p.rep = logistic(coefs[['lg.p.rep']])
  s = exp(coefs[['log.s']])
  X = model_0(probs, p.rep, s, norep)
  return(X)
}

