#!/Library/Frameworks/Python.framework/Versions/Current/bin/python
from __future__ import division
import OpenGL.GL as gl
import pygame
from pygame.locals import *
import pygame.image
from numpy import *
import colorsys
pygame.font.init()


class Drawer(object):
	def __init__(self):
		self.screen = pygame.display.set_mode((1280, 1024), pygame.FULLSCREEN)#16)#pygame.FULLSCREEN)#16) # pygame.FULLSCREEN
		pygame.mouse.set_visible(False)
		self.center = (512,368)
		self.deg2pix = 30
		self.xlim = (0, 1024)
		self.ylim = (0,768)
		self.gainmag = 40
		self.font = pygame.font.Font(None, 36)
		self.textDic = {}
	
	def writeText(self, text, pos, col=(255,255,255)):
		if not self.textDic.has_key(text):
			self.textDic[text] = self.font.render(text, 1, col)
		self.screen.blit(self.textDic[text], pos)
		
	def drawCross(self, center=(0,0), col1=[0,0,0], col2=[0,0,0], ang1=0, ang2=90, size=(0.1, 0.5)):
		sz1 = size[0]*self.deg2pix; sz2 = size[1]*self.deg2pix
		cx = center[0]*self.deg2pix+self.center[0]; cy = center[1]*self.deg2pix+self.center[1]
		th1 = ang1/180*math.pi; th2 = ang2/180*math.pi
		
		X = mat([[sz1, sz1, sz1+sz2, sz1+sz2],[-sz1, sz1, sz1, -sz1]]); X = X.T
		
		R1a = mat([[cos(th1), -sin(th1)],[sin(th1),cos(th1)]])
		R2a = mat([[cos(th2), -sin(th2)],[sin(th2),cos(th2)]])
		R1b = mat([[cos(th1+math.pi), -sin(th1+math.pi)],[sin(th1+math.pi),cos(th1+math.pi)]])
		R2b = mat([[cos(th2+math.pi), -sin(th2+math.pi)],[sin(th2+math.pi),cos(th2+math.pi)]])
		
		Z = X*R1a; pointlist = []
		for i in range(0,4): pointlist.append((Z[i,0]+cx,Z[i,1]+cy))
		pygame.draw.polygon(self.screen, col1, pointlist)
		
		Z = X*R1b; pointlist = []
		for i in range(0,4): pointlist.append((Z[i,0]+cx,Z[i,1]+cy))
		pygame.draw.polygon(self.screen, col1, pointlist)
		
		Z = X*R2a; pointlist = []
		for i in range(0,4): pointlist.append((Z[i,0]+cx,Z[i,1]+cy))
		pygame.draw.polygon(self.screen, col2, pointlist)
		
		Z = X*R2b; pointlist = []
		for i in range(0,4): pointlist.append((Z[i,0]+cx,Z[i,1]+cy))
		pygame.draw.polygon(self.screen, col2, pointlist)
		#pygame.draw.aalines(self.screen, col1, True, pointlist, blend=1)
	
	def drawSpot(self, center=(0,0), col1=[0,0,0], col2=[0,0,0], size=(0.1, 0.5)):
		pos = (center[0]*self.deg2pix+self.center[0], center[1]*self.deg2pix+self.center[1])
		pygame.draw.circle(self.screen, (0,0,0), pos, size[1]*self.deg2pix+2)
		pygame.draw.circle(self.screen, col1, pos, size[1]*self.deg2pix)
		pygame.draw.circle(self.screen, (0,0,0), pos, size[0]*self.deg2pix+2)
		pygame.draw.circle(self.screen, col2, pos, size[0]*self.deg2pix)
		#pygame.draw.aalines(self.screen, col1, True, pointlist, blend=1)
	
	def drawSpotPiece(self, center=(0,0), col1=[0,0,0], ang1=0, size=(0.1, 0.5)):
		if ang1==0:
			pygame.draw.circle(self.screen, col1, center, size[1]*self.deg2pix)
			pygame.draw.circle(self.screen, (0,0,0), center, size[0]*self.deg2pix+2)
		else:
			pygame.draw.circle(self.screen, col1, center, size[0]*self.deg2pix)
		#pygame.draw.aalines(self.screen, col1, True, pointlist, blend=1)
		
	def drawCue(self, ang, length, col=[0,0,0], mind=0.5):
		endpos = [self.deg2pix*length*cos(ang/180*math.pi)+self.center[0], self.deg2pix*length*sin(ang/180*math.pi)+self.center[1]]
		stapos = [self.deg2pix*mind*cos(ang/180*math.pi)+self.center[0], self.deg2pix*mind*sin(ang/180*math.pi)+self.center[1]]
		pygame.draw.line(self.screen, col, stapos, endpos, 5)
		
	def drawCrossPiece(self, center=(0,0), col1=[0,0,0], ang1=0, size=(0.1, 0.5)):
		sz1 = size[0]*self.deg2pix; sz2 = size[1]*self.deg2pix
		th1 = ang1/180*math.pi
		X = mat([[sz1, sz1, sz1+sz2, sz1+sz2],[-sz1, sz1, sz1, -sz1]]); X = X.T

		R1a = mat([[cos(th1), -sin(th1)],[sin(th1),cos(th1)]])
		R1b = mat([[cos(th1+math.pi), -sin(th1+math.pi)],[sin(th1+math.pi),cos(th1+math.pi)]])

		Z = X*R1a; pointlist = []
		for i in range(0,4): pointlist.append((Z[i,0]+center[0],Z[i,1]+center[1]))
		pygame.draw.polygon(self.screen, col1, pointlist)

		Z = X*R1b; pointlist = []
		for i in range(0,4): pointlist.append((Z[i,0]+center[0],Z[i,1]+center[1]))
		pygame.draw.polygon(self.screen, col1, pointlist)
		
	def drawSpotOptions(self, colororder, orientation, size):
		rangex = self.xlim[1]-self.xlim[0]
		ypos = round((self.ylim[1] - self.center[1])/2)
		peritem = rangex/len(colororder)
		
		for i in range(0,len(colororder)):
			xpos = peritem*i+peritem/2
			self.drawSpotPiece([xpos,ypos], colororder[i], orientation, size)
			self.writeText('%d'%mod(i+1,10), [xpos-10, ypos+50])
	def drawBarOptions(self, colororder, orientation, size):
		rangex = self.xlim[1]-self.xlim[0]
		ypos = round((self.ylim[1] - self.center[1])/2)
		peritem = rangex/len(colororder)

		for i in range(0,len(colororder)):
			xpos = peritem*i+peritem/2
			self.drawCrossPiece([xpos,ypos], colororder[i], orientation, size)
			self.writeText('%d'%mod(i+1,10), [xpos-10, ypos+50])
		
	def drawFixation(self, fixation, color=(0,0,0)):
		pygame.draw.circle(self.screen, color, (fixation[0]*self.deg2pix+self.center[0], fixation[1]*self.deg2pix+self.center[1]), 5)
		
	def fillScreen(self, col=(255,255,255)):
		self.screen.fill(col)
		
	def flip(self):
		pygame.display.flip()
