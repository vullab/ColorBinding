#!/usr/bin/env python
from __future__ import division

# For running 32 bit python from Terminal
# arch -i386 /usr/bin/python

import drawer
import timer
import recorder
import scorer
from configurer import *
import time

from inputter import *
from numpy import *
from includes import *

datapath = os.path.join('..','data')
confpath = os.path.join('..','conf')
random.seed()

exptname = "mbind"
barsize = (0.15, 0.6)
spotsize = (0.45, 0.8)
gensettings = readConfig(os.path.join(confpath,'configuration.txt'))

offset2=0
T_double = False
fill_middle = False
subjectid = ""; sessionid = ""
version = ""
fliplabels = False


# sessionid = raw_input('Session number: ')
# if sessionid=="":
sessionid=0#
# else:
#     sessionid = int(sessionid)

drawer = drawer.Drawer()
scorer = scorer.Scorer()

acceptedkeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']

sessionid = 0


colort = readConfig(os.path.join(confpath,'colors.txt'))
colors = []
for k,v in colort.iteritems():
    colors.append(map(int, v))

colidx = range(0,10)

def locCircle(r, n, i):
    x = (r * math.sin(i/n*2*math.pi))
    y = (r * math.cos(i/n*2*math.pi))
    return (x, y)

def showOptions(fbtext, xstart=5, ystart=100):
    drawer.fillScreen((0,0,0))
    for i in range(0,len(fbtext)):
        drawer.writeText(fbtext[i], (xstart,ystart+30*i))
    drawer.flip()


def showColorOptions(colororder,idx1):
    newcol = []
    for i in range(0,len(idx1)): newcol.append(colororder[idx1[i]])
    drawer.drawSpotOptions2(newcol, 0, spotsize,True)
    drawer.drawSpotOptions2(newcol, 90, spotsize,False)
    positions=drawer.drawSpotGrid(newcol,spotsize)
    
    drawer.flip()
    return positions

def waitformouseclick(positions):
    output=None
    pygame.mouse.set_visible(True)
    while output==None:
        for event in pygame.event.get():
            if event.type==MOUSEBUTTONDOWN:
                mx,my=pygame.mouse.get_pos()
                for pos in positions:
                    dist=pow(pow(mx-pos[0],2)+pow(mx-pos[1],2),.5)
                    ringSize=int(spotsize[1]*drawer.deg2pix)
                    if ringSize>=dist:
                        output=pos
    pygame.mouse.set_visible(False)
    return output


showOptions(('What was the color of the target?',''),5,70)
idx1=range(0,10)
positions=showColorOptions(colors,idx1)
report=waitformouseclick(positions)





# actual experiment!









waitforkey()
quit()
