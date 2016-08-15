#!/usr/bin/env python
from __future__ import division

import drawer
import timer
import recorder
import scorer
from configurer import *
import time
#import Tkinter
#root = Tkinter.Tk()
#root.withdraw()
#from tkSimpleDialog import askstring
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
        offset1 = 8
        offset2 =10
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
    waitforkey()
    
def showInstructions(insfile='instructions.txt'):
    fid = open(insfile,'r')
    insttext = []
    for line in fid:
        insttext.append(line.rstrip('\n'))
    fid.close()
    showFeedback(insttext)

def probeMemory(orientation, colororder, randorder):
    # Returns the color selected
    if gensettings['bars-or-spot']==1:
        if fliplabels == False:
            if orientation == 0: oname="horizontal bar"
            else: oname="vertical bar"
        else:
            if orientation == 0: oname="vertical bar"
            else: oname="horizontal bar"
    elif gensettings['bars-or-spot']==2:
        if orientation == 0: oname="outer ring"
        else: oname="inner circle"
    elif gensettings['bars-or-spot']==3:
        if orientation == 0: oname="outer object"
        else: oname="inner object"
    elif gensettings['bars-or-spot']==0:
        if orientation == 0: oname="outer box"
        else: oname="inner box"
    elif gensettings['bars-or-spot']==4:
        oname="designated part"
    elif gensettings['bars-or-spot']==5:
        if orientation == 0: oname="box"
        else: oname="circle"
        
    question = "What color was the %s of the target?" % oname
    
    drawer.fillScreen((0,0,0))
    drawer.writeText(question, (5,100))
    newcol = []
    for i in range(0,len(randorder)): newcol.append(colororder[randorder[i]])
    if gensettings['bars-or-spot']==0:
        drawer.drawTOptions(newcol, orientation, barsize,offset, double  =T_double)
    elif gensettings['bars-or-spot']==1:
        drawer.drawBarOptions(newcol, orientation, barsize,fill_middle)
    elif gensettings['bars-or-spot']==2:
        drawer.drawSpotOptions(newcol, orientation, spotsize)
    elif gensettings['bars-or-spot']==3:
        drawer.drawMoonOptions(newcol, orientation, spotsize,offset)
    elif gensettings['bars-or-spot']==4:
        drawer.drawWindowOptions(newcol, orientation==0, barsize,offset1,offset2)
    elif gensettings['bars-or-spot']==5:
        drawer.drawDotBarOptions(newcol, orientation==0, barsize,spotsize,offset1,offset2)
    drawer.flip()
    
    response = []
    while response == []:
        response = waitforkey(acceptedkeys)
        if response == -999: quit()
        
    return randorder[response]
    
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
    if random.random()>0.5:
        idx = range(0,10); random.shuffle(idx)
        responseH = probeMemory(0, colors, idx)# random.shuffle(idx)
        responseV = probeMemory(90, colors, idx)
    else:
        idx = range(0,10); random.shuffle(idx)
        responseV = probeMemory(90, colors, idx)# random.shuffle(idx)
        responseH = probeMemory(0, colors, idx)

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
    
    feedbacktext = ['Points earned this trial: %d'%points, 'Total points: %d'%tpoints,'','Press a key to continue']
    
    showFeedback(feedbacktext, 400, 360)
    
    return trialdata

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
