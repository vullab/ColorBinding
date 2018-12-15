model.fxs = list()
# 
# # Uniform, no repetition
# model.fxs[['U']] = function(datamat, norep=F){
#   nloglik_0 <- function(log.s){
#     return(nloglik_master(as.list(match.call()), datamat, norep))
#   }
#   return(mle(nloglik_0, start = make.param.list(nloglik_0)))
# }

# Uniform, with repetition
model.fxs[['U']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# Uniform, Feature (no bias), with repetition
model.fxs[['UF']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.feature, log.s.feature){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# # Uniform, Feature (bias), with repetition
# model.fxs[['UFb']] = function(datamat, norep=F){
#   nloglik_0 <- function(lg.p.rep, lg.p.feature, log.s.feature, lg.feature.bias){
#     return(nloglik_master(as.list(match.call()), datamat, norep))
#   }
#   return(mle(nloglik_0, start = make.param.list(nloglik_0)))
# }


# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UFP']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.feature,  lg.p.indep, log.s){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# Uniform, Feature (no bias), Parts (no swap), Objects (no swap) 1sigma, with repetition
model.fxs[['UFPOs']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.indep, lg.p.feature, lg.p.part, lg.p.rep, log.s, lg.p.swap.object){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}


# # Uniform, Feature (no bias), Parts (no swap), Objects (no swap) 3-sigma, with repetition
# model.fxs[['UFPO+3']] = function(datamat, norep=F){
#   nloglik_0 <- function(lg.p.indep, lg.p.feature, lg.p.part, lg.p.rep,log.s.feature, log.s.part, log.s.object){
#     return(nloglik_master(as.list(match.call()), datamat, norep))
#   }
#   return(mle(nloglik_0, start = make.param.list(nloglik_0)))
# }
# 
# 
# # Uniform, Feature (no bias), Parts (no swap), Objects (swap) 1sigma, with repetition
# model.fxs[['UFPOs+1']] = function(datamat, norep=F){
#   nloglik_0 <- function(lg.p.indep, lg.p.feature, lg.p.part, lg.p.rep, log.s, lg.p.swap.object){
#     return(nloglik_master(as.list(match.call()), datamat, norep))
#   }
#   return(mle(nloglik_0, start = make.param.list(nloglik_0)))
# }
# 
# 

# Uniform, Feature (no bias), Parts (no swap), Objects (swap) 3sigma, with repetition
model.fxs[['UFPOs+3']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.indep, 
                        lg.p.feature,
                        lg.p.part, 
                        lg.p.rep, 
                        log.s.feature, 
                        log.s.part,
                        log.s.object, 
                        lg.p.swap.object){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# 
# # Uniform, Feature (with bias), Parts (no swap), Objects (swap) 3sigma, with repetition
# model.fxs[['UFPOs+3+b']] = function(datamat, norep=F){
#   nloglik_0 <- function(lg.p.indep, 
#                         lg.p.feature,
#                         lg.p.part, 
#                         lg.p.rep, 
#                         log.s.feature, 
#                         log.s.part,
#                         log.s.object, 
#                         lg.feature.bias, 
#                         lg.p.swap.object){
#     return(nloglik_master(as.list(match.call()), datamat, norep))
#   }
#   return(mle(nloglik_0, start = make.param.list(nloglik_0)))
# }
# 
# 
# # full - ss-swap
# model.fxs[['full-v']] = function(datamat, norep=F){
#   nloglik_0 <- function(lg.p.indep, 
#                         lg.p.feature, 
#                         lg.p.part, 
#                         lg.p.rep, 
#                         log.s.feature, 
#                         log.s, 
#                         lg.feature.bias, 
#                         lg.p.swap.object){
#     return(nloglik_master(as.list(match.call()), datamat, norep))
#   }
#   start.params = formals(nloglik_0)
#   for(name in names(start.params)){
#     start.params[[name]] = 0
#   }
#   
#   fit <- mle(nloglik_0, start = start.params)
#   return(fit)
# }
# 
# 
# # full - feature bias
# model.fxs[['full-b']] = function(datamat, norep=F){
#   nloglik_0 <- function(lg.p.indep, 
#                         lg.p.feature, 
#                         lg.p.part, 
#                         lg.p.rep, 
#                         log.s.feature, 
#                         log.s.part, 
#                         log.s.object, 
#                         lg.p.swap.object){
#     return(nloglik_master(as.list(match.call()), datamat, norep))
#   }
#   start.params = formals(nloglik_0)
#   for(name in names(start.params)){
#     start.params[[name]] = 0
#   }
#   
#   fit <- mle(nloglik_0, start = start.params)
#   return(fit)
# }
# 
# 
# 
# # full - swap
# model.fxs[['full-2sw']] = function(datamat, norep=F){
#   nloglik_0 <- function(lg.p.indep, 
#                         lg.p.feature, 
#                         lg.p.part, 
#                         lg.p.rep, 
#                         log.s.feature, 
#                         log.s.part, 
#                         log.s.object, 
#                         lg.feature.bias){
#     return(nloglik_master(as.list(match.call()), datamat, norep))
#   }
#   start.params = formals(nloglik_0)
#   for(name in names(start.params)){
#     start.params[[name]] = 0
#   }
#   
#   fit <- mle(nloglik_0, start = start.params)
#   return(fit)
# }
# 
# # full - varying swap
# model.fxs[['full-1sw']] = function(datamat, norep=F){
#   nloglik_0 <- function(lg.p.indep, 
#                         lg.p.feature, 
#                         lg.p.part, 
#                         lg.p.rep, 
#                         log.s.feature, 
#                         log.s.part, 
#                         log.s.object, 
#                         lg.feature.bias, 
#                         lg.p.swap.object){
#     return(nloglik_master(as.list(match.call()), datamat, norep))
#   }
#   start.params = formals(nloglik_0)
#   for(name in names(start.params)){
#     start.params[[name]] = 0
#   }
#   
#   fit <- mle(nloglik_0, start = start.params)
#   return(fit)
# }
# 
# # full - varying sigma
# model.fxs[['full-2s']] = function(datamat, norep=F){
#   nloglik_0 <- function(lg.p.indep, 
#                         lg.p.feature, 
#                         lg.p.part, 
#                         lg.p.rep, 
#                         log.s, 
#                         lg.feature.bias, 
#                         lg.p.swap.object){
#     return(nloglik_master(as.list(match.call()), datamat, norep))
#   }
#   start.params = formals(nloglik_0)
#   for(name in names(start.params)){
#     start.params[[name]] = 0
#   }
#   
#   fit <- mle(nloglik_0, start = start.params)
#   return(fit)
# }
# 
# 
# # everything van vary!
# model.fxs[['full']] = function(datamat, norep=F){
#   nloglik_0 <- function(lg.p.indep, 
#                         lg.p.feature, 
#                         lg.p.part, 
#                         lg.p.rep, 
#                         log.s.feature, 
#                         log.s.part, 
#                         log.s.object, 
#                         lg.feature.bias, 
#                         lg.p.swap.object){
#     return(nloglik_master(as.list(match.call()), datamat, norep))
#   }
#   start.params = formals(nloglik_0)
#   for(name in names(start.params)){
#     start.params[[name]] = 0
#   }
#   
#   fit <- mle(nloglik_0, start = start.params)
#   return(fit)
# }
