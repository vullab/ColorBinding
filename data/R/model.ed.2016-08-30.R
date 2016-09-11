logistic = function(x){1/(1+exp(-x))}

predictMat <- function(p.target=-1000, p.whole=-1000, p.part=-1000, p.color=-1000, p.rep=-1000, scale=0, norep){
  # params = list(p.whole = 0.3, p.part=0.5, p.color=0.2, scale=1, p.rep=0.5)
  p.target = logistic(p.target)
  p.whole = logistic(p.whole)
  p.part = logistic(p.part)
  p.color = logistic(p.color)
  p.rep = logistic(p.rep)
  scale = exp(scale)
  positions = -2:2
  
  idx.CC.i = 1:5
  idx.CC.j = 6:10
  
  p.positions = VGAM::dlaplace(-2:2, 0, scale)
  p.positions = p.positions / sum(p.positions)
  
  mat.target = matrix(0, nrow=10, ncol=10)
  mat.target[3,8] = 1
  
  mat.whole = matrix(rep(0, 100), nrow=10)
  diag(mat.whole[idx.CC.i, idx.CC.j]) <- p.positions
  
  v.part.i = p.part*c(p.positions, rep(0, 5)) + (1-p.part)*p.color*c(p.positions, p.positions)/2 + (1-p.part)*(1-p.color)*1/10
  v.part.j = p.part*c(rep(0, 5), p.positions) + (1-p.part)*p.color*c(p.positions, p.positions)/2 + (1-p.part)*(1-p.color)*1/10
  
  mat.rep = matrix(0, nrow=10, ncol=10)
  diag(mat.rep) <- (v.part.i*0.5+v.part.j*0.5)
  mat.rep <- mat.rep / sum(mat.rep)
  
  mat.indep <- outer(v.part.i, v.part.j, function(a,b)(a*b))
  mat.indep <- mat.indep / sum(mat.indep)
  
  mat.norep <- mat.indep
  diag(mat.norep) <- 0
  mat.norep <- mat.norep / sum(mat.norep)
  mat.final <- p.target*mat.target +
    (1-p.target)*p.whole*mat.whole + 
    (1-p.target)*(1-p.whole)*(norep*mat.norep +
                          (1-norep)*(p.rep*mat.rep + (1-p.rep)*mat.indep))
  # mat.final <- mat.final/sum(mat.final)
  return(mat.final)
}

