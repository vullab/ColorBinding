model.fxs = list()

# Uniform, with repetition
model.fxs[['U']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}


model.fxs[['UT']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# Uniform, Feature (no bias), with repetition
model.fxs[['UTF']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target, lg.p.feature, log.s){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UTFP']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target, lg.p.part, lg.p.feature, log.s){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UTFE']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target, lg.p.ensemble, lg.p.feature, log.s){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UTFO']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target, lg.p.object, lg.p.feature, log.s){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}


# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UTFPE']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target, lg.p.part, lg.p.ensemble, lg.p.feature, log.s){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}


# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UTFPO']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target, lg.p.part, lg.p.object, lg.p.feature, log.s){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UTFEO']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target, lg.p.ensemble, lg.p.object, lg.p.feature, log.s){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}


# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UTFPEO']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target, lg.p.part, lg.p.object, lg.p.ensemble, lg.p.feature, log.s){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UTFP-u']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target, lg.p.part, lg.p.feature, 
                        log.s.feature, log.s.part){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UTFE-u']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target, lg.p.ensemble, lg.p.feature, 
                        log.s.feature, log.s.ensemble){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UTFO-u']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target, lg.p.object, lg.p.feature, 
                        log.s.feature, log.s.object){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}


# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UTFPE-u']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target, lg.p.part, lg.p.ensemble, lg.p.feature, 
                        log.s.feature, log.s.part, log.s.ensemble){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}


# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UTFPO-u']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target, lg.p.part, lg.p.object, lg.p.feature, 
                        log.s.feature, log.s.part, log.s.object){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UTFEO-u']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target, lg.p.ensemble, lg.p.object, lg.p.feature, 
                        log.s.feature, log.s.ensemble, log.s.object){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}


# Uniform, Feature (no bias), Parts (no swap), 1s, with repetition
model.fxs[['UTFPEO-u']] = function(datamat, norep=F){
  nloglik_0 <- function(lg.p.rep, lg.p.target, lg.p.part, lg.p.object, lg.p.ensemble, lg.p.feature, log.s.feature, log.s.part, log.s.ensemble, log.s.object){
    return(nloglik_master(as.list(match.call()), datamat, norep))
  }
  return(mle(nloglik_0, start = make.param.list(nloglik_0)))
}

