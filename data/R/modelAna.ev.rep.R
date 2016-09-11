# setwd('/Users/tflew/Google Drive/Vul_Lab/ColorBind/Colorbinding_cory/colorbindingCory/data')

data<-NULL
path = '../data_rep/'
for (file in list.files(path))

  if ("1"==substr(file,nchar(file)-4,nchar(file)-4)){
    subjMain <- read.csv(paste0(path,file))
    if (nrow(subjMain)>=200){

      subjectName <- substr(file,7,nchar(file)-6)
      subjMain$subjectID <- subjectName

      if ("offsett" %in% colnames(subjMain) & !("offset" %in% colnames(subjMain))){
        subjMain$offset <- subjMain$offsett
        subjMain$offset2 <- 0
        subjMain$offsett <- NULL
      }

      if (ncol(subjMain)==17){
        subjMain$offset <- 0
        subjMain$offset2 <- 0
        subjMain$version <- subjMain$bars.or.spot - 2
        subjMain$actualStimOn <- NA
      }
      print(ncol(subjMain))
      if(ncol(subjMain) <= 20 & is.null(subjMain$version)){

        if (subjMain$offset[1] == 3.75){
          subjMain$version = 1
        }else if(subjMain$offset[1] == 5){
          subjMain$version = 2
        }else if(subjMain$offset[1] == 5.5){
          subjMain$version = 3
        }else if(subjMain$offset[1] == 4.5){
          subjMain$version = 4
        }else if(subjMain$offset[1] == -10.5){
          subjMain$version = 5
        }else if(subjMain$offset[1] == -9){
          subjMain$version = 6
        }else if(subjMain$offset[1] == 0){
          print("1")
        }else{
          browser()
          print (subjMain$offset[1])
        }


      }
      #		print (subjMain$offset[1])
      #print (ncol(subjMain) )
      data<-rbind(data,subjMain)
    }

  }

data$resp.v.pos <- as.numeric(data$resp.v.pos)
data$resp.h.pos <- as.numeric(data$resp.h.pos)
data$resp.v.hv <- as.numeric(data$resp.v.hv)
data$resp.h.hv <- as.numeric(data$resp.h.hv)

data$resp.h.idx = data$resp.h.pos+3+(data$resp.h.hv-1)*5
data$resp.v.idx = data$resp.v.pos+3+(data$resp.v.hv-1)*5

table(data$version)
temp<-aggregate(data=data,rep(1,nrow(data))~version+subjectID,min)
table(temp$version)

data <- subset(data, data$version %in% c(-1,0,1,2,5,6,8,9,11,12,13))
data$version = factor(data$version, levels=c('-1','0','1','2','5','6','8','9','11','12','13'))

save('data', file = 'read.data.rep.Rdata')
load(file = 'read.data.rep.Rdata')

source('model.ed.2016-08-30.R')
nLL <- function(p.target, p.whole, p.part, p.color, p.rep, scale, norep){
  p.mat <- predictMat(p.target, p.whole, p.part, p.color, p.rep, scale, norep)
  # for norep only
  if(norep==1){
    diag(p.mat) <- 1
  }
  LL <- sum(log(p.mat)*dat)
  return(-LL+pmax(-5, scale))
}

models = list(
  'all' = list(
    'params' = function(){list(p.target = rnorm(1, -1, 1+attempt/100),
                               p.whole = rnorm(1, -1, 1+attempt/100),
                               p.part=rnorm(1, -1, 1+attempt/100),
                               p.color=rnorm(1, -1, 1+attempt/100),
                               scale=rnorm(1, 0, 1+attempt/100), #,
                               p.rep=rnorm(1, 0, 1+attempt/100)
    )},
    'fixed' = list(norep=0)),
  'nowhole' = list(
    'params' = function(){list(p.target = rnorm(1, -1, 1+attempt/100),
                               p.part=rnorm(1, -1, 1+attempt/100),
                               p.color=rnorm(1, -1, 1+attempt/100),
                               scale=rnorm(1, 0, 1+attempt/100), #,
                               p.rep=rnorm(1, 0, 1+attempt/100)
    )},
    'fixed' = list(norep=0,p.whole = -100)),
  'nopart' = list(
    'params' = function(){list(p.target = rnorm(1, -1, 1+attempt/100),
                               p.whole = rnorm(1, -1, 1+attempt/100),
                               p.color=rnorm(1, -1, 1+attempt/100),
                               scale=rnorm(1, 0, 1+attempt/100), #,
                               p.rep=rnorm(1, 0, 1+attempt/100)
    )},
    'fixed' = list(norep=0,p.part = -100)),
  'nowholepart' = list(
    'params' = function(){list(p.target = rnorm(1, -1, 1+attempt/100),
                               p.color=rnorm(1, -1, 1+attempt/100),
                               scale=rnorm(1, 0, 1+attempt/100), #,
                               p.rep=rnorm(1, 0, 1+attempt/100)
    )},
    'fixed' = list(norep=0,p.whole = -100, p.part=-100))
)

failures = data.frame()
fits = data.frame()
for(v in levels(data$version)){
  tmp <- subset(data, data$version == v)
  for(s in unique(tmp$subjectID)){
    tmp.sub <- subset(tmp, tmp$subjectID==s)
    dat <- as.matrix(table(tmp.sub$resp.h.idx, tmp.sub$resp.v.idx))
    for(model in names(models)){
      res = FALSE
      attempt = 1
      while(class(res)!='mle' & attempt <= 100){
        # print(attempt)
        try(res <- stats4::mle(minuslogl = nLL,
                               start = models[[model]][['params']](), 
                               fixed = models[[model]][['fixed']],
                               nobs = sum(dat)),
            silent=TRUE)
        attempt = attempt+1
      }
      if(class(res)=='mle'){
        C = stats4::coef(res)
        # C = coef(summary(res))[, 'Estimate']
        fits <- rbind(fits, 
                      data.frame(
                        repetition = 'rep',
                        version = v,
                        subject = s,
                        model = model,
                        LL = logLik(res),
                        AIC = AIC(res),
                        BIC = BIC(res),
                        n = sum(dat),
                        p.target = C['p.target'],
                        p.whole = C['p.whole'],
                        p.part = C['p.part'],
                        p.color = C['p.color'],
                        p.rep = C['p.rep'],
                        scale = C['scale'],
                        norep = C['norep'])
        )
      } else {
        print(sprintf('failed on v=%s; s=%s, model=%s', v, s, model))
        failures = rbind(failures, 
                         data.frame('v'=v, 's'=s, 'model'=model))
      }
    }
  }
}
save('data', 'fits', 'failures', file = 'fits.rep.Rdata')
# ggplot(recoded.df, aes(y=Var1, x=Var2, size=Freq))+facet_wrap(~version)+geom_point()+theme_bw()
# 
# fitsummaries = data.frame()
# 
# for(v in levels(data$version)){
#   fits[[v]]$p.part.net = (1-fits[[v]]$p.whole)*fits[[v]]$p.part
#   fits[[v]]$p.color.net = (1-fits[[v]]$p.whole)*(1-fits[[v]]$p.part)*fits[[v]]$p.color
#   fits[[v]]$p.uniform.net = (1-fits[[v]]$p.whole)*(1-fits[[v]]$p.part)*(1-fits[[v]]$p.color)
#   fitsummaries = rbind(fitsummaries, 
#                        data.frame(repetition = 'norep',
#                                   version=v,
#                                   p.whole = mean(fits[[v]]$p.whole, trim = 0.05),
#                                   p.part = ,
#                                   p.color = ,
#                                   scale = ,
#                                   net.p.whole = ,
#                                   net.p.part = ,
#                                   net.p.color = ,
#                                   net.p.uniform = ))
# }
# 

