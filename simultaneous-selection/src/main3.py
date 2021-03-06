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
while subjectid=="" or subjectid==None:
    #subjectid = askstring('Subject ID', 'Subject ID:')
    subjectid = raw_input("Enter subject ID:")
    print subjectid
while version=="" or version==None:
    #subjectid = askstring('Subject ID', 'Subject ID:')
    version = raw_input("Enter version (1 - 12):")
    if version == '-1':  #crosses
        offset = 0 
        gensettings['bars-or-spot'] = 1
    elif version == '0': #bullseyes
        offset = 0
        gensettings['bars-or-spot'] = 2
    elif version == '1':  #eggs
        offset = 3.75 
    elif version == '2': #moons
        offset = 5
    elif version == '3': #different size moons, bigger difference
        offset = 5.5
        spotsize = (0.4, 0.8)
    elif version == '4':#different size moons, smaller difference
        offset = 4.5
        spotsize = (0.5, 0.8)
    elif version == '5':#T's
        offset = -10.5
        barsize = (0.2, 0.45)
        gensettings['bars-or-spot'] = 0
        T_rotate = True
        T_double = False
    elif version == '6':#stacked boxes
        offset = -9
        barsize = (0.3, 0.3)
        T_rotate = True
        T_double = False
        gensettings['bars-or-spot'] = 0
    elif version == '7':# windows
        offset1 = 9
        offset2 = 13
        offset= offset1
        barsize = (0.25, 0.4)
        gensettings['bars-or-spot'] = 4
    elif version == '8':# dots and boxes
        offset1 = 8 # Width
        offset2 =10 # Height
        offset= offset1
        barsize = (0.2, 0.3)
        spotsize = (.3)
        gensettings['bars-or-spot'] = 5
    elif version == '9':#non rotating T's
        offset = -10.5
        barsize = (0.2, 0.45)
        gensettings['bars-or-spot'] = 0
        T_rotate = False
        T_double = False
    elif version == '10':# stacked T's
        offset = -12
        barsize = (0.4, 0.25)
        gensettings['bars-or-spot'] = 0
        T_rotate = True
        T_double = 1.3
    elif version == '11':# spread boxes
        offset = -12
        barsize = (0.3, 0.3)
        T_rotate = True
        T_double = False
        gensettings['bars-or-spot'] = 0
    elif version == '12':# overlappingcrosses
        offset = 0
        barsize = (0.15, 0.6)
        T_rotate = False
        T_double = False
        fill_middle = True
        gensettings['bars-or-spot'] = 1
    elif version == '13':# outlines
        offset = 0
        barsize = (0.4, 0.3)
        T_rotate = False
        T_double = False
        fill_middle = False
        gensettings['bars-or-spot'] = 1
        fliplabels = True
    else:
        version = ""

print version

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

def showFeedback(fbtext, xstart=5, ystart=100):
    drawer.fillScreen((0,0,0))
    for i in range(0,len(fbtext)):
        drawer.writeText(fbtext[i], (xstart,ystart+30*i))
    drawer.flip()
    waitformouseclick2()
#waitforkey()

def showFeedback2(fbtext, xstart=5, ystart=100):

    for i in range(0,len(fbtext)):
        drawer.writeText(fbtext[i], (xstart,ystart+30*i))
    drawer.flip()


def waitformouseclick2():
    output=None
    while output==None:
        for event in pygame.event.get():
            if event.type==MOUSEBUTTONDOWN:
                output=pygame.mouse.get_pos()

def showInstructions(insfile='instructions.txt'):
    fid = open(insfile,'r')
    insttext = []
    for line in fid:
        insttext.append(line.rstrip('\n'))
    fid.close()
    showFeedback(insttext)

def oneTrial(trialdata):
    # clear events
    trialtimer = timer.Timer()
    found = processEvents(pygame.event.get(), (None,))
    if -999 in found:
        quit()

    # fixation
    drawer.fillScreen((0,0,0))
    drawer.drawFixation((0,0), [255,255,255])
    drawer.flip()
    trialtimer.start()

    # Assign each component a color
    horzcol = []; vertcol = []
    for i in range(0,int(ceil(trialdata['nitems']/len(colidx)*2))):
        # The 0:5 5:10 indexing assures in & out different
        t=random.sample(colidx, 10)
        horzcol.extend(t[0:5])
        vertcol.extend(t[5:10])

    # Select a location for the cued item
    cueloc = int(floor(random.random()*trialdata['nitems']))
    trialdata['cue-loc-int'] = cueloc
    cueitems = list(colidx)
    random.shuffle(cueitems)
    
    # (???)
    # TFL-So I *think* this makes sure that the target and all object +/-2 of the target are all unique colors,
    # minimizing ambiguity about what color people are referring to
    for i in range(-2,3):
        refi = int(mod(i+cueloc,trialdata['nitems']))
        # The cues themselves are items 2 and 7
        horzcol[refi] = cueitems[i+2]
        vertcol[refi] = cueitems[i+2+5]
    
    elapsed = trialdata['ms-st-cue']-trialtimer.saveview('calc', 'start')
    if elapsed>0:
        time.sleep(elapsed/1000)
    
    x,y=locCircle(trialdata['radius'],trialdata['nitems'],cueloc)
    trialdata['cue-loc-x']=x; trialdata['cue-loc-y']=y
    angle = math.atan2(y,x)/math.pi*180
    drawer.drawCue(angle, trialdata['cue-length'], [255,255,255], 0.5)
    drawer.flip()
    trialtimer.record('cueon') # Start timing cue
    time.sleep(trialdata['ms-precue']/1000)
    
    #starts with the bottom most object, goes counter clockwise
    for i in range(0,int(trialdata['nitems'])):
        x,y=locCircle(trialdata['radius'],trialdata['nitems'],i)
        if trialdata['bars-or-spot']==0:
            drawer.drawT([x,y], colors[horzcol[i]], colors[vertcol[i]], 0, 90, barsize,offset,rotate=T_rotate, double = T_double)
        elif trialdata['bars-or-spot']==1:
            drawer.drawCross([x,y], colors[horzcol[i]], colors[vertcol[i]], 0, 90, barsize,fill_middle)
        elif trialdata['bars-or-spot']==2: #here horizcol is the outer color
            drawer.drawSpot([x,y], (colors[horzcol[i]]), (colors[vertcol[i]]), spotsize)
        elif trialdata['bars-or-spot']==3:
            drawer.drawMoon([x,y], colors[horzcol[i]], colors[vertcol[i]], spotsize,offset)
        elif trialdata['bars-or-spot']==4:
            drawer.drawWindow([x,y], colors[horzcol[i]], colors[vertcol[i]], barsize,offset1,offset2)
        elif trialdata['bars-or-spot']==5:
        	drawer.drawDotBar([x,y], colors[horzcol[i]], colors[vertcol[i]], barsize,spotsize,offset1,offset2)
                                    
            
    drawer.flip()
    
    #import pdb;pdb.set_trace()
    
    trialtimer.record('stimon')
    time.sleep(trialdata['ms-stimon']/1000)
    drawer.fillScreen((0,0,0))
    drawer.flip()
    trialtimer.record('stimoff')
    time.sleep(0.250)
    
    #this gets the response for inner and outer in some random ordering
    #responseH and V are the colors responded for each

    # Flip to decide which to present first
    idx1=range(0,10)
    random.shuffle(idx1)

    # Present colors and components in grid form
    showOptions(('What was the color of the target?',''),5,70)
    centerVert=random.random()>.5 # Do the center dots go along the side?
    posinds=showColorOptions(colors,idx1,centerVert,trialdata['bars-or-spot'],spotsize,offset,version)
    
    positions=posinds[0]
    indices=posinds[1]
    choice=waitformouseclick(positions) # Wait for subject to click on shape
    idx2 = positions.index(choice)

    # Isolate selected shape
    drawer.fillScreen((0,0,0))
    drawer.flip()
    newcol = []
    for i in range(0,len(idx1)): newcol.append(colors[idx1[i]])


    drawer.flip()

    responseH=idx1[indices[idx2][0]]
    responseV=idx1[indices[idx2][1]]

    # What were the selected in and outs?
    idxH = cueitems.index(responseH)
    idxV = cueitems.index(responseV)
    
    # Undoes the shift above (labeled ???)
    # Since every color occurs within +/-2 of the target,

    # Get the distance of the selected color from ANY target color
    trialdata['resp-h-pos'] = mod(idxH,5)-2
    trialdata['resp-v-pos'] = mod(idxV,5)-2
    points = 0
    #so idxHV < 5 means a response to a color in Horiz/outer


    if idxH<5:
        # Did you correctly select one of the h colors?
        trialdata['resp-h-hv'] = 1
        if trialdata['resp-h-pos']==0: points+=1
    else:
        trialdata['resp-h-hv'] = 2
    if idxV<5:
        trialdata['resp-v-hv'] = 1
    else:
        # Did you correctly select one of the v colors?
        trialdata['resp-v-hv'] = 2
        if trialdata['resp-v-pos']==0: points+=1
    
    #so a h of 0 when idx < 5 is correct, and a v of v with greater than 5 is correct
    #resp v hv ==2 means that they responded with a color that was verical/inner for the judged vertical/inner judgement. 
    
    tpoints = scorer.addview(points)
    
    trialdata['offset'] = offset
    trialdata['offset2'] = offset2
    trialdata['version'] = version
    trialdata['actualStimOn'] =  trialtimer.getreltime(['stimoff'],'stimon').values()[0]
    
    trialdata['hComp']=horzcol
    trialdata['vComp']=vertcol
    trialdata['refi']=refi
    

    feedbacktext = ['Points earned this trial: %d'%points, 'Total points: %d'%tpoints,'','Press a key to continue']
    
    showFeedback(feedbacktext, 400, 360)
    
    return trialdata

def showOptions(fbtext, xstart=5, ystart=100):
    drawer.fillScreen((0,0,0))
    for i in range(0,len(fbtext)):
        drawer.writeText(fbtext[i], (xstart,ystart+30*i))
    drawer.flip()

def showColorOptions2(colororder,idx1,centerVert,bs,version,offset):
    newcol = []
    for i in range(0,len(idx1)): newcol.append(colororder[idx1[i]])
    if centerVert:
    	if bs==2:
        	drawer.drawSpotOptions2(newcol, 0, spotsize,True)
        	drawer.drawSpotOptions2(newcol, 90, spotsize,False)
        elif bs==1:
        	drawer.drawCrossOptions2(newcol, 0, barsize,True,fill_middle)
        	drawer.drawCrossOptions2(newcol, 90, barsize,False,fill_middle)
        elif version=='5':
			drawer.drawTOptions2(newcol, 0, barsize, True,offset)
			drawer.drawTOptions2(newcol, 90, barsize, False,offset)
	elif version=='6':
		showFeedback2(['Inside'], 220, 450)
		showFeedback2(['Outside'], 600, 70)
        drawer.drawTOptions2(newcol, 0, barsize, True,offset)
        drawer.drawTOptions2(newcol, 90, barsize, False,offset)
		
    else:
    	if bs==2:
        	drawer.drawSpotOptions2(newcol, 90, spotsize,True)
        	drawer.drawSpotOptions2(newcol, 0, spotsize,False)
        elif bs==1:
        	drawer.drawCrossOptions2(newcol, 90, barsize,True,fill_middle)
        	drawer.drawCrossOptions2(newcol, 0, barsize,False,fill_middle)
        elif version=='5':
			drawer.drawTOptions2(newcol, 90, barsize, True,offset)
			drawer.drawTOptions2(newcol, 0, barsize, False,offset)
	elif version=='6':
		showFeedback2(['Outside'], 220, 450)
		showFeedback2(['Inside'], 615, 70)
        drawer.drawTOptions2(newcol, 90, barsize, True,offset)
        drawer.drawTOptions2(newcol, 0, barsize, False,offset)
		
    if bs==2:
    	(posinds)=drawer.drawSpotGrid(newcol,spotsize,centerVert)
    elif bs==1:
    	(posinds)=drawer.drawCrossGrid(newcol,barsize,centerVert)
    elif version=='5' or version=='6':
    	(posinds)=drawer.drawTGrid(newcol,barsize,centerVert,offset)
    	
    positions=posinds[0]
    indices=posinds[1]
    drawer.flip()
    return (positions,indices)

def showColorOptions(colororder,idx1,centerVert,version,spotsize,offset,version2):
	# version is bars vs spots, version2 is actual version due to lazy coding
    newcol = []
    
    for i in range(0,len(idx1)): newcol.append(colororder[idx1[i]])
    
    
    # Draw options on axes
    if centerVert:
    	if version==2:
        	drawer.drawSpotOptions2(newcol, 0, spotsize,True)
        	drawer.drawSpotOptions2(newcol, 90, spotsize,False)
        elif version==1:
        	drawer.drawCrossOptions2(newcol, 0, barsize,True,fill_middle)
        	drawer.drawCrossOptions2(newcol, 90, barsize,False,fill_middle)
        elif version==5:
        	drawer.drawDotBarOptions2(newcol, 1, barsize, spotsize,True,offset1,offset2)
        	drawer.drawDotBarOptions2(newcol, 0, barsize, spotsize,False,offset1,offset2)	
        elif version==3:
        	drawer.drawMoonOptions2(newcol, 0, spotsize,True,offset)
        	drawer.drawMoonOptions2(newcol, 90, spotsize,False,offset)
        elif version==0:
        	if version2=='6': # WHY DID CORY MAKE THIS A STRING????
        		showFeedback2(['Inside'], 220, 450)
        		showFeedback2(['Outside'], 615, 70)
			
        	drawer.drawTOptions2(newcol, 90, barsize,True,offset)
        	drawer.drawTOptions2(newcol, 0, barsize,False,offset)
    else:
    	if version==2:
        	drawer.drawSpotOptions2(newcol, 90, spotsize,True)
        	drawer.drawSpotOptions2(newcol, 0, spotsize,False)
        elif version==5:
        	drawer.drawDotBarOptions2(newcol, 0, barsize, spotsize,True,offset1,offset2)
        	drawer.drawDotBarOptions2(newcol, 1, barsize, spotsize,False,offset1,offset2)	
        elif version==1:
        	drawer.drawCrossOptions2(newcol, 90, barsize,True,fill_middle)
        	drawer.drawCrossOptions2(newcol, 0, barsize,False,fill_middle)
        elif version==3:
        	drawer.drawMoonOptions2(newcol, 90, spotsize,True,offset)
        	drawer.drawMoonOptions2(newcol, 0, spotsize,False,offset)
        elif version==0:

        	if version2=='6':
        		showFeedback2(['Outside'], 220, 450)
        		showFeedback2(['Inside'], 615, 70)
			
        	drawer.drawTOptions2(newcol, 90, barsize,True,offset)
        	drawer.drawTOptions2(newcol, 0, barsize,False,offset)
    
    # Draw actual grid of choices
    if version==2:
    	(posinds)=drawer.drawSpotGrid(newcol,spotsize,centerVert)
    elif version==1:  	
    	(posinds)=drawer.drawCrossGrid(newcol,barsize,centerVert,fill_middle)
    elif version==3:  	
    	(posinds)=drawer.drawMoonGrid(newcol,barsize,centerVert,spotsize,offset)
    elif version==0:  	
    	(posinds)=drawer.drawTGrid(newcol,barsize,centerVert,offset)
    elif version==5:  	
    	(posinds)=drawer.drawDBGrid(newcol, barsize,spotsize,centerVert,offset1,offset2)
		
	
    positions=posinds[0]
    indices=posinds[1]
    drawer.flip()
    return (positions,indices)

def waitformouseclick(positions):
    output=None
    pygame.mouse.set_visible(True)
    while output==None:
        for event in pygame.event.get():
            if event.type==MOUSEBUTTONDOWN:
                mx,my=pygame.mouse.get_pos()
                for pos in positions:
                    dist=pow(pow(mx-pos[0],2)+pow(my-pos[1],2),.5)
                    if not isinstance(spotsize, float):
                    	ringSize=int(spotsize[1]*drawer.deg2pix)
                    else:
                    	ringSize=int(spotsize*drawer.deg2pix)
                    if ringSize>=dist:
                        output=pos
    pygame.mouse.set_visible(False)

    return output

def presentChoice(indices):
    newcol = []
    for i in range(0,len(idx1)): newcol.append(colororder[idx1[i]])
    drawer.drawSpotOptions2(newcol, 0, spotsize,True)
    drawer.drawSpotOptions2(newcol, 90, spotsize,False)
    positions=drawer.drawSpotGrid(newcol,spotsize,centerVert)
    
    drawer.flip()

def runExpt(ntrials):
    ntrials=int(ntrials)
    filename = '%s-%s_%d.txt' % (exptname, subjectid, sessionid)
    filepath = os.path.join(datapath,filename)
    for t in range(0,ntrials):
        trialdata = dict(gensettings)
#        print trialdata
        for k,v in trialdata.iteritems():
            if isinstance(v,(list,tuple)):
                print 'randomly sampling %s from '%k + str(v)
                trialdata[k] = random.sample(v,1)[0]
        trialdata = oneTrial(trialdata)
        if t==0:
            trialwriter = recorder.Recorder(filepath, trialdata)
        trialwriter.write(trialdata)
    
    trialwriter.close()
    print('Total points: %d' % scorer.view()[0])

showInstructions(os.path.join(confpath,'instructions.txt'))
sessionid=0
runExpt(gensettings['npractice'])
sessionid=1
showInstructions(os.path.join(confpath,'instructions2.txt'))
runExpt(gensettings['ntrials'])
showInstructions(os.path.join(confpath,'debrief.txt'))

# actual experiment!



quit()
