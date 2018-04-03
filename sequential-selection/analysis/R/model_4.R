library("VGAM")
library(R.basic)

#looking good, debatable whether or not should do the whole color or flipping - whole color should not rely on part maybe? 
#need seperate colors for asymetrical bars

fitBindingModel <- function(x,data,plot = FALSE){
	if (all(x>=0) & all(x[0:3] <=1)){
		#fill out paramters
		# p_whole_item = x[1]
		
		# p_part_A = x[2]
		# p_part_B = x[3]
		# p_color_A = x[4]
		# p_color_B = x[5]
		
		# sd_whole = x[6]
		# sd_part_A = x[7]
		# sd_part_B = x[8]
		# sd_color_A = x[9]
		# sd_color_B = x[10]
		
		# p_whole_item = x[1]
		
		# p_part_A = x[2]
		# p_part_B = x[2]
		# p_color_A = x[3]
		# p_color_B = x[3]
		
		# sd_whole = x[4]
		# sd_part_A = x[5]
		# sd_part_B = x[5]
		# sd_color_A = x[6]
		# sd_color_B = x[6]
		
		p_whole_item = x[1]
		
		p_part_A = x[2]
		p_part_B = x[2]
		p_color_A = x[3]
		p_color_B = x[3]
		
		sd_whole = x[4]
		sd_part_A = x[5]
		sd_part_B = x[5]
		sd_color_A = x[6]
		sd_color_B = x[6]
		
		prob_flip = 0
		
		# (p_part_A + p_part_B) <= 1 &
		if ( (p_color_A + p_color_B) <= 1){
		
			#get the model fit
			fit <- runBindingModel(p_whole_item,
									p_part_A,
									p_part_B,
									p_color_A,
									p_color_B,
									sd_whole,
									sd_part_A,
									sd_part_B,
									sd_color_A,
									sd_color_B,
									prob_flip)
			
			#find the residual
			residual = fit - data
			
			if (plot){
				quartz()
				image(sqrt(matrix(rev(fit),nrow=10,byrow=TRUE)[(10:1),] ),col=gray((0:128)/128))
				quartz()
				image(matrix(rev(residual),nrow=10,byrow=TRUE)[(10:1),] ,col=gray((0:128)/128))
			}
		}else{
			residual = 10000
		}
	}else{
		residual = 10000
	}
	return(sum(residual^2))
}

runBindingModel <- function(p_whole_item,
		p_part_A,
		p_part_B,
		p_color_A,
		p_color_B,
		sd_whole,
		sd_part_A,
		sd_part_B,
		sd_color_A,
		sd_color_B,
		prob_flip){

	prob_norm <- function(x){ return(x/sum(x))}
	#browser()
	#laplace for each level
	whole_prob<- prob_norm(dlaplace(-2:2,0,sd_whole))
	partA_prob<- prob_norm(dlaplace(-2:2,0,sd_part_A))
	partB_prob<- prob_norm(dlaplace(-2:2,0,sd_part_B))
	colorA_prob<- prob_norm(dlaplace(-2:2,0,sd_color_A))
	colorB_prob<- prob_norm(dlaplace(-2:2,0,sd_color_B))
	guess_prob<- rep(1/10,10)
	#set up individual matricies
	whole_matrix <- matrix(0, nrow = 10, ncol = 10)
	whole_swap_matrix <- matrix(0, nrow = 10, ncol = 10)
		
	Apart_Bpart_matrix <- matrix(0, nrow = 10, ncol = 10)
	Apart_Acolor_matrix <- matrix(0, nrow = 10, ncol = 10)
	Apart_Bcolor_matrix <- matrix(0, nrow = 10, ncol = 10)
	Apart_G_matrix <- matrix(0, nrow = 10, ncol = 10)
	
	Acolor_Bpart_matrix <- matrix(0, nrow = 10, ncol = 10)
	Acolor_Acolor_matrix <- matrix(0, nrow = 10, ncol = 10)
	Acolor_Bcolor_matrix <- matrix(0, nrow = 10, ncol = 10)
	Acolor_DR_matrix <- matrix(0, nrow = 10, ncol = 10)

	Bcolor_Bpart_matrix <- matrix(0, nrow = 10, ncol = 10)
	Bcolor_Acolor_matrix <- matrix(0, nrow = 10, ncol = 10)
	Bcolor_Bcolor_matrix <- matrix(0, nrow = 10, ncol = 10)
	Bcolor_DR_matrix <- matrix(0, nrow = 10, ncol = 10)

	G_Bpart_matrix <- matrix(0, nrow = 10, ncol = 10)
	#Acolor_DR_matrix <- matrix(0, nrow = 10, ncol = 10)
	#Bcolor_DR_matrix <- matrix(0, nrow = 10, ncol = 10)
	GG_matrix <- matrix(0, nrow = 10, ncol = 10)
	
	Aoptions<- 1:5
	Boptions<- 6:10
	#A is rows, B is columns
	whole_matrix[Aoptions,Boptions] <- diag(whole_prob)

	Apart_Bpart_matrix[Aoptions,Boptions] <- partA_prob %*% t(partB_prob)
	Apart_Acolor_matrix[Aoptions,Aoptions] <- partA_prob %*% t(colorA_prob)
	Apart_Bcolor_matrix[Aoptions,Boptions] <- partA_prob %*% t(colorB_prob)
	Apart_G_matrix[Aoptions,1:10] <- partA_prob %*% t(guess_prob)
	
	Acolor_Bpart_matrix[Aoptions,Boptions] <- colorA_prob %*% t(partB_prob)
	Acolor_Acolor_matrix[Aoptions,Aoptions] <- colorA_prob %*% t(colorA_prob)
	Acolor_Bcolor_matrix[Aoptions,Boptions] <- colorA_prob %*% t(colorB_prob)
	Acolor_DR_matrix[Aoptions,Aoptions] <- diag(colorA_prob)	
	
	Bcolor_Bpart_matrix[Boptions,Boptions] <- colorB_prob %*% t(partB_prob)
	Bcolor_Acolor_matrix[Boptions,Aoptions] <- colorB_prob %*% t(colorA_prob)
	Bcolor_Bcolor_matrix[Boptions,Boptions] <- colorB_prob %*% t(colorB_prob)
	Bcolor_DR_matrix[Boptions,Boptions] <- diag(colorB_prob)

	G_Bpart_matrix[1:10,Boptions]<- guess_prob %*% t(partB_prob)
	GG_matrix[1:10,1:10]<- guess_prob %*% t(guess_prob)
	

	#only used if considering the possiblity of whole with no parts
	whole_swap_matrix[Boptions,Aoptions] <- diag(whole_prob)


	#browser()	
	#if you want to allow whole colors only. 

	#browser()
	#putting everything together
					#get the whole thing
	finalMatrix <- p_whole_item * whole_matrix + 
			#p_whole_item * (1 - (1 - p_part_A) * (1 - p_part_B)) * whole_matrix +
			#p_whole_item * ((1 - p_part_A) * (1 - p_part_B)) * whole_swap_matrix +
		#dont get the whole thing
		(1 - p_whole_item) * (
		
			#get part A
			(p_part_A * p_part_B) * Apart_Bpart_matrix + 
				(1-p_part_B) * (
				(p_part_A *  p_color_A) * Apart_Acolor_matrix +
				(p_part_A * p_color_B) * Apart_Bcolor_matrix +
				(p_part_A *  (1 - p_color_A - p_color_B)) * Apart_G_matrix ) +
				
			#dont get part A
			(1-p_part_A) * (
				
				(p_color_A * p_part_B) * Acolor_Bpart_matrix + 
				(1-p_part_B) * (
					(p_color_A *  p_color_B) * Acolor_Acolor_matrix +
					(p_color_A * p_color_B) * Acolor_Bcolor_matrix +
					(p_color_A * (1 - p_color_A - p_color_B)) * Acolor_DR_matrix ) +
					
				(p_color_B * p_part_B) * Bcolor_Bpart_matrix + 
				(1-p_part_B) * (
					(p_color_B *  p_color_A) * Bcolor_Acolor_matrix +
					(p_color_B * p_color_B) * Bcolor_Bcolor_matrix +
					(p_color_B * (1 - p_color_A - p_color_B)) * Bcolor_DR_matrix ) +
					
				((1 - p_color_A - p_color_B) * p_part_B) * G_Bpart_matrix + 
				(1-p_part_B) * (
					((1 - p_color_A - p_color_B) *  p_color_A) * Acolor_DR_matrix +
					((1 - p_color_A - p_color_B) * p_color_B) * Bcolor_DR_matrix +
					((1 - p_color_A - p_color_B) * (1 - p_color_A - p_color_B)) * GG_matrix )))
				
	
				
				
	return((1-prob_flip) * finalMatrix + prob_flip * rotate180(t(rotate180(finalMatrix))) )
}

#image(sqrt(matrix(rev(finalMatrix),nrow=10,byrow=TRUE)[(10:1),] ),col=gray((0:128)/128))