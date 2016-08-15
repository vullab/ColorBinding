#!/usr/bin/env python
from __future__ import division

import drawer
import timer
import recorder
import scorer
from configurer import *
import time
import Tkinter
root = Tkinter.Tk()
root.withdraw()
from tkSimpleDialog import askstring
from inputter import *
from numpy import *
from includes import *

datapath = os.path.join('..','data')
confpath = os.path.join('..','conf')
random.seed()

subjectid = ""; sessionid = ""

while subjectid=="" or subjectid==None:
	subjectid = askstring('Subject ID', 'Subject ID:')
	print subjectid
# sessionid = raw_input('Session number: ')
# if sessionid=="":
sessionid=0# 
	# else:
	# 	sessionid = int(sessionid)

drawer = drawer.Drawer()
scorer = scorer.Scorer()

acceptedkeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']

sessionid = 0
exptname = "mbind"
barsize = (0.15, 0.6)
spotsize = (0.45, 0.8)

gensettings = readConfig(os.path.join(confpath,'configuration.txt'))
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
	if gensettings['bars-or-spot']==1:
		if orientation == 0: oname="horizontal bar"
		else: oname="vertical bar"
	else:
		if orientation == 0: oname="outer ring"
		else: oname="inner circle"
		
	
	question = "What color was the %s of the target?" % oname
	
	drawer.fillScreen((0,0,0))
	drawer.writeText(question, (5,100))
	newcol = []
	for i in range(0,len(randorder)): newcol.append(colororder[randorder[i]])
	if gensettings['bars-or-spot']==1:
		drawer.drawBarOptions(newcol, orientation, barsize)
	else:
		drawer.drawSpotOptions(newcol, orientation, spotsize)
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
	import pdb;pdb.set_trace()
	horzcol = []; vertcol = []
	for i in range(0,int(ceil(trialdata['nitems']/len(colidx)*2))): 
		t=random.sample(colidx, 10)
		horzcol.extend(t[0:5])
		vertcol.extend(t[5:10])
		
	cueloc = int(floor(random.random()*trialdata['nitems']))
	trialdata['cue-loc-int'] = cueloc
	cueitems = list(colidx)
	random.shuffle(cueitems)
	
	for i in range(-2,3):
		refi = int(mod(i+cueloc,trialdata['nitems']))
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
	trialtimer.record('cueon')
	time.sleep(trialdata['ms-precue']/1000)
	
	for i in range(0,trialdata['nitems']):
		x,y=locCircle(trialdata['radius'],trialdata['nitems'],i)
		if trialdata['bars-or-spot']==1:
			drawer.drawCross([x,y], colors[horzcol[i]], colors[vertcol[i]], 0, 90, barsize)
		else:
			drawer.drawSpot([x,y], colors[horzcol[i]], colors[vertcol[i]], spotsize)
	drawer.flip()
	
	trialtimer.record('stimon')
	time.sleep(trialdata['ms-stimon']/1000)
	drawer.fillScreen((0,0,0))
	drawer.flip()
	trialtimer.record('stimoff')
	time.sleep(0.250)
	
	if random.random()>0.5:
		idx = range(0,10); random.shuffle(idx)
		responseH = probeMemory(0, colors, idx)# random.shuffle(idx)
		responseV = probeMemory(90, colors, idx)
	else:
		idx = range(0,10); random.shuffle(idx)
		responseV = probeMemory(90, colors, idx)# random.shuffle(idx)
		responseH = probeMemory(0, colors, idx)
	
	idxH = cueitems.index(responseH)
	idxV = cueitems.index(responseV)
	trialdata['resp-h-pos'] = mod(idxH,5)-2
	trialdata['resp-v-pos'] = mod(idxV,5)-2
	points = 0
	if idxH<5: 
		trialdata['resp-h-hv'] = 1
		if trialdata['resp-h-pos']==0: points+=1
	else:
		trialdata['resp-h-hv'] = 2
	if idxV<5: 
		trialdata['resp-v-hv'] = 1
	else:
		trialdata['resp-v-hv'] = 2
		if trialdata['resp-v-pos']==0: points+=1
	
	tpoints = scorer.addview(points)
	
	feedbacktext = ['Points earned this trial: %d'%points, 'Total points: %d'%tpoints,'','Press a key to continue']
	
	showFeedback(feedbacktext, 400, 360)
	
	return trialdata

def runExpt(ntrials):
	filename = '%s-%s_%d.txt' % (exptname, subjectid, sessionid)
	filepath = os.path.join(datapath,filename)
	
	for t in range(0,ntrials):
		trialdata = dict(gensettings)
		print trialdata
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
# actual experiment!



quit()
