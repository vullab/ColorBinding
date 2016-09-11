# setwd('/Users/tflew/Google Drive/Vul_Lab/ColorBind/Colorbinding_cory/colorbindingCory/data')

data<-NULL

for (file in list.files('..'))
  
  if ("1"==substr(file,nchar(file)-4,nchar(file)-4)){
    subjMain <- read.csv(paste0('../',file))
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
      count[subjMain$version[1]+2]=count[subjMain$version[1]+2]+1
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

require(ggplot2)
require(dplyr)
recode = function(df){
  tmp <- table(df$resp.h.idx, df$resp.v.idx)
  return(tmp)
}

recoded.df= data.frame()
for(v in unique(data$version)){
  tmp <- subset(data, data$version == v)
  tmp <- recode(tmp)
  
  tmp <- data.frame(tmp)
  tmp$version = v
  tmp$Freq = tmp$Freq / sum(tmp$Freq)
  recoded.df <- rbind(recoded.df, tmp)
}

# ggplot(recoded.df, aes(y=Var1, x=Var2, size=Freq))+facet_wrap(~version)+geom_point()+theme_bw()
