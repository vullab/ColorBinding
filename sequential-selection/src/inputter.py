
import pygame
from pygame.locals import *
import sys

def waitforkey(acceptedKeys=[]):
	notpressed = True
	pressedkey = []
	while notpressed:
		for event in pygame.event.get():
			if event.type == KEYDOWN:
				notpressed = False
				if event.key == K_ESCAPE:
					pressedkey = -999
				elif event.unicode in acceptedKeys:
					pressedkey = acceptedKeys.index(event.unicode)
	return pressedkey

def processEvents(events, acceptedKeys):
	found = [-1000, ]
	for event in events:
		if event.type == MOUSEBUTTONDOWN:
			found.append(-1)
		elif event.type == QUIT:
			found.append(-999)
		elif event.type == KEYDOWN:
			if event.key == K_ESCAPE:
				found.append(-999)
			elif event.unicode in acceptedKeys:
				found.append(acceptedKeys.index(event.unicode))
	return found


def quit():
	# try:
	#	 thisexpt.saver.write(thistrial)
	# except:
	#	 thisexpt.saver = TrialWriter(thisexpt.datafile, thistrial)
	#	 thisexpt.saver.write(thistrial)
	# 
	# try:
	#	 thisexpt.timer.write(thistrial)
	# except:
	#	 thisexpt.timer = TimeWriter(thisexpt.timefile, thistrial)
	#	 thisexpt.timer.write(thistrial)
	sys.exit()