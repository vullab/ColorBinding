# setwd('/Users/tflew/Google Drive/Vul_Lab/ColorBind/Colorbinding_cory/colorbindingCory/data')

# data<-NULL
# 
# for (file in list.files('..'))
#   
#   if ("1"==substr(file,nchar(file)-4,nchar(file)-4)){
#     subjMain <- read.csv(paste0('../',file))
#     if (nrow(subjMain)>=200){
#       
#       subjectName <- substr(file,7,nchar(file)-6)
#       subjMain$subjectID <- subjectName
#       
#       if ("offsett" %in% colnames(subjMain) & !("offset" %in% colnames(subjMain))){
#         subjMain$offset <- subjMain$offsett
#         subjMain$offset2 <- 0
#         subjMain$offsett <- NULL
#       }
#       
#       if (ncol(subjMain)==17){
#         subjMain$offset <- 0
#         subjMain$offset2 <- 0
#         subjMain$version <- subjMain$bars.or.spot - 2
#         subjMain$actualStimOn <- NA
#       }
#       print(ncol(subjMain))
#       if(ncol(subjMain) <= 20 & is.null(subjMain$version)){
#         
#         if (subjMain$offset[1] == 3.75){
#           subjMain$version = 1 
#         }else if(subjMain$offset[1] == 5){
#           subjMain$version = 2
#         }else if(subjMain$offset[1] == 5.5){
#           subjMain$version = 3
#         }else if(subjMain$offset[1] == 4.5){
#           subjMain$version = 4
#         }else if(subjMain$offset[1] == -10.5){
#           subjMain$version = 5
#         }else if(subjMain$offset[1] == -9){
#           subjMain$version = 6
#         }else if(subjMain$offset[1] == 0){
#           print("1")
#         }else{
#           browser()
#           print (subjMain$offset[1])
#         }
#         
#         
#       }
#       #		print (subjMain$offset[1])
#       #print (ncol(subjMain) )
#       data<-rbind(data,subjMain)		
#     }
#     
#   }
# 
# data$resp.v.pos <- as.numeric(data$resp.v.pos)
# data$resp.h.pos <- as.numeric(data$resp.h.pos)
# data$resp.v.hv <- as.numeric(data$resp.v.hv)
# data$resp.h.hv <- as.numeric(data$resp.h.hv)
# 
# data$resp.h.idx = data$resp.h.pos+3+(data$resp.h.hv-1)*5
# data$resp.v.idx = data$resp.v.pos+3+(data$resp.v.hv-1)*5
# 
# table(data$version)
# temp<-aggregate(data=data,rep(1,nrow(data))~version+subjectID,min)
# table(temp$version)	
# 
# data <- subset(data, data$version %in% c(-1,0,1,2,5,6,8,9,11,12,13))
# data$version = factor(data$version, levels=c('-1','0','1','2','5','6','8','9','11','12','13'))
# 
# save('data', file = 'read.data.Rdata')
load(file = 'read.data.Rdata')

source('model.ed.2016-08-30.R')
nLL <- function(p.whole, p.part, p.color, p.rep, scale){
  p.mat <- predictMat(p.whole, p.part, p.color, p.rep, scale, norep=0)
  LL <- sum(log(p.mat)*dat)
  return(-LL)
}

fits = list()
for(v in levels(data$version)){
  tmp <- subset(data, data$version == v)
  fits[[v]] = list()
  fits[[v]] = data.frame()
  for(s in unique(tmp$subjectID)){
    tmp.sub <- subset(tmp, tmp$subjectID==s)
    dat <- as.matrix(table(tmp.sub$resp.h.idx, tmp.sub$resp.v.idx))
    res = FALSE
    attempt = 1
    while(is.logical(res) & attempt <= 100){
      print(attempt)
      try(res <- stats4::mle(nLL,
                     list(p.whole = rnorm(1, 0, 1+attempt/100),
                          p.part=rnorm(1, 0, 1+attempt/100),
                          p.color=rnorm(1, 0, 1+attempt/100),
                          scale=rnorm(1, 0, 1+attempt/100),
                          p.rep=rnorm(1, 0, 1+attempt/100))))
      attempt = attempt+1
    }
    if(!is.logical(res)){
      C = res@coef
      # C = coef(summary(res))[, 'Estimate']
      fits[[v]] <- rbind(fits[[v]], data.frame(
        subject = s,
        p.whole = logistic(C['p.rep']),
        p.part = logistic(C['p.rep']),
        p.color = logistic(C['p.rep']),
        p.rep = logistic(C['p.rep']),
        scale = exp(C['scale'])
      ))
    } else {
      print(sprintf('failed on v=%s; s=%s', v, s))
    }
  }
}

save('data', 'fits', file = 'fits.Rdata')
# ggplot(recoded.df, aes(y=Var1, x=Var2, size=Freq))+facet_wrap(~version)+geom_point()+theme_bw()

for(v in levels(data$version)){
  fits[[v]]$p.part.net = (1-fits[[v]]$p.whole)*fits[[v]]$p.part
  fits[[v]]$p.color.net = (1-fits[[v]]$p.whole)*(1-fits[[v]]$p.part)*fits[[v]]$p.color
  fits[[v]]$p.uniform.net = (1-fits[[v]]$p.whole)*(1-fits[[v]]$p.part)*(1-fits[[v]]$p.color)
  print(apply(fits[[v]][,2:9], 2, function(x){mean(x, trim=0.05)}))
}

  
