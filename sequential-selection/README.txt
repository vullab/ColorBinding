The data from all of the experiments (including the old ones) is in ./colorbindingCory/data as is the R code I used to loop at it. 

-basicAna.R loads all the data, and looks at the proportion of incorrect trials that were correctly matched to parts. It also fits the model to each experiment. Adding new experiment versions will require changing some for loop ranges, or actually being a good programmer and making a variable at the top. 

-the experiment code is all in ./colorbindingCory/src/, main.py calls the experiment. The type of the experiment is determined by a version number input at the start of the experiment. Adding new objects requires adding a new version, adding calling the new object function for the trial display and responses, and writing the drawer.py functions to handle the new object. 

version descriptions:

-1 - Original Crosses
0 - OG bulls eyes
1- "eggs" - offset bulls eyes
2- "moons" offset bulls eyes with the middle popping out
3 and 4 played with the relative sizes, never went far with these
5 - T's that rotate around the display
6- stacked boxes (I thought this would be really hard to keep straight, since they are the same shape, but no… )
7- "windows" 2x2 boxes with diagonals of the same color… so hard… never really tried
8 - dots and boxes, 2x2 grid of circles and squares. 
9 - non rotating T's
10 - stacked T's , never tried really
11 - boxes with a gap
12 - crosses that overlap in the middle (similar to -1 but with overlap)
13 - box outlines (crosses with flipped aspect ratios)

