setwd('/Users/crieth/Documents/projects/ColorBinding/colorbindingCory/data')

data<-NULL

showPlot<-function(matrix_to_show){image(sqrt(matrix(rev(matrix_to_show),nrow=10,byrow=TRUE)[(10:1),] ),col=gray((0:128)/128))}

for (file in list.files())

if ("1"==substr(file,nchar(file)-4,nchar(file)-4)){
	subjMain <- read.csv(file)
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

table(data$version)
temp<-aggregate(data=data,rep(1,nrow(data))~version+subjectID,min)
table(temp$version)	

data$resp.v.pos <- as.numeric(data$resp.v.pos)
data$resp.h.pos <- as.numeric(data$resp.h.pos)
data$resp.v.hv <- as.numeric(data$resp.v.hv)
data$resp.h.hv <- as.numeric(data$resp.h.hv)

data <- subset(data, data$version %in% c(-1,0,1,2,5,6,8,9,11,12,13))

data$outerCorrect <- data$resp.h.pos==0 & data$resp.h.hv==1
data$innerCorrect <- data$resp.v.pos==0 & data$resp.v.hv==2

data$anyCorrect <- data$outerCorrect | data$innerCorrect
data$allCorrect <- data$outerCorrect & data$innerCorrect

data$outerResp.outer.minus2 <- data$resp.h.pos==-2 & data$resp.h.hv==1
data$outerResp.outer.minus1 <- data$resp.h.pos==-1 & data$resp.h.hv==1
data$outerResp.outer.0 <- data$resp.h.pos==0 & data$resp.h.hv==1 #correct
data$outerResp.outer.plus1 <- data$resp.h.pos==1 & data$resp.h.hv==1
data$outerResp.outer.plus2 <- data$resp.h.pos==2 & data$resp.h.hv==1

data$outerResp.inner.minus2 <- data$resp.h.pos==-2 & data$resp.h.hv==2
data$outerResp.inner.minus1 <- data$resp.h.pos==-1 & data$resp.h.hv==2
data$outerResp.inner.0 <- data$resp.h.pos==0 & data$resp.h.hv==2
data$outerResp.inner.plus1 <- data$resp.h.pos==1 & data$resp.h.hv==2
data$outerResp.inner.plus2 <- data$resp.h.pos==2 & data$resp.h.hv==2

data$innerResp.outer.minus2 <- data$resp.v.pos==-2 & data$resp.v.hv==1
data$innerResp.outer.minus1 <- data$resp.v.pos==-1 & data$resp.v.hv==1
data$innerResp.outer.0 <- data$resp.v.pos==0 & data$resp.v.hv==1
data$innerResp.outer.plus1 <- data$resp.v.pos==1 & data$resp.v.hv==1
data$innerResp.outer.plus2 <- data$resp.v.pos==2 & data$resp.v.hv==1

data$innerResp.inner.minus2 <- data$resp.v.pos==-2 & data$resp.v.hv==2
data$innerResp.inner.minus1 <- data$resp.v.pos==-1 & data$resp.v.hv==2
data$innerResp.inner.0 <- data$resp.v.pos==0 & data$resp.v.hv==2 #correct
data$innerResp.inner.plus1 <- data$resp.v.pos==1 & data$resp.v.hv==2
data$innerResp.inner.plus2 <- data$resp.v.pos==2 & data$resp.v.hv==2

#matching objects at each position

data$CorrectObjectMatching.minus2 <- data$outerResp.outer.minus2 & data$innerResp.inner.minus2
data$CorrectObjectMatching.minus1 <- data$outerResp.outer.minus1 & data$innerResp.inner.minus1
data$CorrectObjectMatching.0 <- data$outerResp.outer.0 & data$innerResp.inner.0
data$CorrectObjectMatching.plus1 <- data$outerResp.outer.plus1 & data$innerResp.inner.plus1
data$CorrectObjectMatching.plus2 <- data$outerResp.outer.plus2 & data$innerResp.inner.plus2

data$FlippedObjectMatching.minus2 <- data$outerResp.inner.minus2 & data$innerResp.outer.minus2
data$FlippedObjectMatching.minus1 <- data$outerResp.inner.minus1 & data$innerResp.outer.minus1
data$FlippedObjectMatching.0 <- data$outerResp.inner.0 & data$innerResp.outer.0
data$FlippedObjectMatching.plus1 <- data$outerResp.inner.plus1 & data$innerResp.outer.plus1
data$FlippedObjectMatching.plus2 <- data$outerResp.inner.plus2 & data$innerResp.outer.plus2

#how often do they correctly match objects at incorrect positions

data$CorrectMatchingOnIncorrectTrials <- data$CorrectObjectMatching.minus2 | data$CorrectObjectMatching.minus1| data$CorrectObjectMatching.plus1 | data$CorrectObjectMatching.plus2

data$FlippedMatchingOnIncorrectTrials <- data$FlippedObjectMatching.minus2 | data$FlippedObjectMatching.minus1 | data$FlippedObjectMatching.plus1 | data$FlippedObjectMatching.plus2

#matched at all on incorrect trials

data$AnyMatchingOnIncorrectTrials <- data$FlippedMatchingOnIncorrectTrials | data$CorrectMatchingOnIncorrectTrials

require(ggplot2)

tapply(data$CorrectMatchingOnIncorrectTrials,data$version,sum)/tapply(data$AnyMatchingOnIncorrectTrials,data$version,sum)

tapply(data$AnyMatchingOnIncorrectTrials,data$version,sum)/tapply(data$offset,data$version,length)

dataAggr<-aggregate(data=data, cbind(AnyMatchingOnIncorrectTrials,FlippedMatchingOnIncorrectTrials,CorrectMatchingOnIncorrectTrials)~subjectID+version,sum)

#PLOT HISTOGRAMS
qplot(data = dataAggr, x = CorrectMatchingOnIncorrectTrials/AnyMatchingOnIncorrectTrials,geom='histogram')+facet_grid(.~version)
dataAggr$propCorrectMatchingOnIncorrectTrials<- dataAggr$CorrectMatchingOnIncorrectTrials / dataAggr$AnyMatchingOnIncorrectTrials

#TTEST FOR EACH 
for (versionNum in -1:13){
	print(versionNum)
	try(
	print(t.test(subset(dataAggr,dataAggr$version==versionNum)$propCorrectMatchingOnIncorrectTrials,mu = .5))
	)
}

aggrData <- aggregate(data= data, cbind(outerResp.outer.minus2,outerResp.outer.minus1,
outerResp.outer.0,outerResp.outer.plus1,outerResp.outer.plus2,
outerResp.inner.minus2,outerResp.inner.minus1,outerResp.inner.0,
outerResp.inner.plus1,outerResp.inner.plus2,innerResp.outer.minus2,
innerResp.outer.minus1,innerResp.outer.0,innerResp.outer.plus1,
innerResp.outer.plus2,innerResp.inner.minus2,innerResp.inner.minus1,
innerResp.inner.0,innerResp.inner.plus1,innerResp.inner.plus2) ~ version,mean)

varyingNames <- outer(outer(c("innerResp","outerResp"),c("inner","outer"),paste,sep="."),c("minus2","minus1","0","plus1","plus2"),paste,sep=".")

aggrDataRes <- reshape(aggrData,direction="long",varying = varyingNames,v.names = c("innerResp","outerResp"),times =as.vector(outer(c("inner","outer"),c("minus2","minus1","0","plus1","plus2"),paste,sep=".")))

aggrDataRes$outerOrInner <- substring(aggrDataRes$time,1,5)
aggrDataRes$position <- factor(substring(aggrDataRes$time,7,100),levels = c("minus2","minus1","0","plus1","plus2"), ordered = TRUE)
aggrDataRes$positionNum <- unclass (aggrDataRes$position)-3

#PLOT RESPONSE CURVES
quartz()
qplot(data = aggrDataRes, x = positionNum, y = innerResp, color = outerOrInner, geom = c("line"))+facet_wrap("version")+coord_cartesian(ylim = c(0,.5))
quartz()
qplot(data = aggrDataRes, x = positionNum, y = outerResp, color = outerOrInner, geom = c("line"))+facet_wrap("version")+coord_cartesian(ylim = c(0,.5))
		
#table(data$subjectID)
#data$totalTrials = 1
#totalTrials <-aggregate(data=data,totalTrials~subjectID,sum)
#data$totalTrials = NULL
#data <- merge(data,totalTrials,all=TRUE)

source('model_4.R')
results <- NULL

for (versionNum in c(-1,0,1,2,5,6,8,9,11,12,13)){
	
	dataVersion <- subset(data,data$version == versionNum)
	imageMatrix <- matrix(0,10,10)
	for (rowNum in 1:nrow(dataVersion)){

		horizRespIdx <- dataVersion[rowNum,"resp.h.pos"]+3 + (dataVersion[rowNum,"resp.h.hv"]-1)*5
		vertRespIdx <- dataVersion[rowNum,"resp.v.pos"]+3 + (dataVersion[rowNum,"resp.v.hv"]-1)*5
		imageMatrix[horizRespIdx,vertRespIdx] = imageMatrix[horizRespIdx,vertRespIdx] + 1/nrow(dataVersion)		
	}
	
	quartz()
	image(sqrt(matrix(rev(imageMatrix),nrow=10,byrow=TRUE)[(10:1),] ),col=gray((0:128)/128))
	result <- optim(par = c(0.1,.15,.3,.5,.8,1.5), fn = fitBindingModel, data = imageMatrix)
#	print(result$par)
#	print(result$value)
	results <- rbind(results,c(result$par,result$value))
#	fitBindingModel(result$par,data = imageMatrix, plot = TRUE)
}

colMeans(results)
round(results,2)

if (FALSE){
#for each subject... 
for (versionNum in c(-1,0,1,2,5,6,8,9)){
for (sub in unique(data$subjectID)){#,1,2,5,6,8,9)){	
	dataVersion <- subset(data,data$version == versionNum & data$subjectID == sub)
	imageMatrix <- matrix(0,10,10)
	print(sub)
	for (rowNum in 1:nrow(dataVersion)){

		horizRespIdx <- dataVersion[rowNum,"resp.h.pos"]+3 + (dataVersion[rowNum,"resp.h.hv"]-1)*5
		vertRespIdx <- dataVersion[rowNum,"resp.v.pos"]+3 + (dataVersion[rowNum,"resp.v.hv"]-1)*5
		imageMatrix[horizRespIdx,vertRespIdx] = imageMatrix[horizRespIdx,vertRespIdx] + 1	
	}
	
	print(imageMatrix)
	
}
}
}


#ok, generally ok. Only off for doubled subject, leaving them out makes it match. 

#read old paper
#get everything I have into a ppt
#then get distributions of overall accuracy, horiz acc, vert acc
#mindful of individual differences


#object, colored shaped parts, color and shape are the features

#model with uniform guess parameter
#probability of percieving whole object
#independent part binding of color to feature - spatial dist
#independent part binding of color to object - spatial dist
#probability of getting color correct
#probabiity of double report
#need extra uncertainty of cue location?

#story about heirarchical binding - can misbind within an object, dependent not on shape-feature similarity, but shape-feature spatial confusion




