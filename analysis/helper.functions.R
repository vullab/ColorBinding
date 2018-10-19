# helper functions

name.matrix <- function(X){
  rownames(X) <- r.labels
  colnames(X) <- r.labels
  return(X)
}

remove.norep <- function(X){
  diag(X) = 0
  if(sum(X)<=0){
    X = matrix(1, ncol=10, nrow=10)
    diag(X) = 0
  }
  X = X/sum(X)
  
  if(!is.probability(X)){stop(X)}
  return(X)
}

is.probability <- function(X){
  !any(is.na(X)) & !any(is.nan(X)) & !any(X<0) & round(sum(X),8)==1
}

getMatrix = function(subdat, random=F){
  m <- subdat %>% 
    select(resp.A, resp.B, n) %>% 
    spread(key = resp.B, value=n)
  
  a.val = m$resp.A
  m$resp.A <- NULL
  m <- as.matrix(m)
  rownames(m) <- a.val
  if(random){
    o <- sample(1:10, 10, replace=F)
    m <- m[o,o]
  }
  
  rownames(m) <- r.labels
  colnames(m) <- r.labels
  return(m)
}

logistic = function(x){1/(1+exp(-x))}

dlaplace <- function(x, m, s){1/(2*s)*exp(-abs(x-m)/s)}

prob.loc <- function(s){
  s = pmin(pmax(s, 1e-10), 1e10)
  p = dlaplace(-2:2, 0, s)
  p = p/sum(p)
  if(!is.probability(p)){stop(p)}
  return(p)
}

sem = function(x){sd(x)/sqrt(length(x))}


sem_ellipse <- function(X,Y){
  center = c(mean(X), mean(Y))
  npoints = 100
  t <- seq(0, 2*pi, len=npoints)
  Sigma <- cov(cbind(X,Y))/length(X)
  e.sig = eigen(Sigma)
  x <- cos(t)
  y <- sin(t)
  x <- x*sqrt(e.sig$values[1])
  y <- y*sqrt(e.sig$values[2])
  S <- cbind(x, y)
  R <- e.sig$vectors
  data.frame(S%*%t(R)) %>% mutate(X1 = X1+center[1],
                                  X2 = X2+center[2])
}

debugPrint = function(x){
  if(DEBUG) print(x)
}