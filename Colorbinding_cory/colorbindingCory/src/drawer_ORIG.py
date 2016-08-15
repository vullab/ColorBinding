#!/Library/Frameworks/Python.framework/Versions/Current/bin/python
from __future__ import division
import OpenGL.GL as gl
import pygame
from pygame.locals import *
import pygame.image
from numpy import *
import colorsys
pygame.font.init()

def angleOnCircle(center):
    if center[0]==0  and center[1]>0: 
        angle = -pi/2;
    else:    
        angle = arctan(center[1]/(center[0]))
    if center[0] < 0 and center[1] < 0 :
        angle = angle + pi * sign(angle)
    if center[0] > 0 and center[1] > 0 :
        angle = angle + pi * sign(angle)
        
    return(angle)
        
class Drawer(object):
    def __init__(self):
        self.screen = pygame.display.set_mode((1280, 1024))#, pygame.FULLSCREEN)#16)#pygame.FULLSCREEN)#16) # pygame.FULLSCREEN
        pygame.mouse.set_visible(False)
        self.center = (512,368)
        self.deg2pix = 30
        self.xlim = (0, 1024)
        self.ylim = (0,768)
        self.gainmag = 40
        self.font = pygame.font.Font(None, 36)
        self.textDic = {}

    def drawRectFromCenter(self,center,centerToSideDist_x,centerToSideDist_y,angle=0,color=(0,0,0),offset_before_rotation=(0,0),width=0):
        #locations of points
        obj = mat([[-centerToSideDist_x+offset_before_rotation[0], -centerToSideDist_x+offset_before_rotation[0], centerToSideDist_x+offset_before_rotation[0], centerToSideDist_x+offset_before_rotation[0]],[-centerToSideDist_y+offset_before_rotation[1], centerToSideDist_y+offset_before_rotation[1], centerToSideDist_y+offset_before_rotation[1], -centerToSideDist_y+offset_before_rotation[1]]])
        rot_mat = array([[cos(angle), -sin(angle)], [sin(angle), cos(angle)]])

        rot_obj  = rot_mat*obj
        
        cx = center[0]; cy = center[1]

        Z = rot_obj; pointlist = []
        for i in range(0,4): pointlist.append((Z[0,i]+cx,Z[1,i]+cy))
        pygame.draw.polygon(self.screen, color, pointlist,width)
        
    def drawCircFromCenter(self,center,radius,angle=0,color=(0,0,0),offset_before_rotation=(0,0)):
        #locations of points
        center_loc = offset_before_rotation
        rot_mat = array([[cos(angle), -sin(angle)], [sin(angle), cos(angle)]])

        rot_center  = dot(rot_mat,center_loc)
        #import pdb;pdb.set_trace()
        
        pygame.draw.circle(self.screen, (0,0,0), rot_center+array(center), radius)
        pygame.draw.circle(self.screen, color, rot_center+array(center), radius)
        

    def writeText(self, text, pos, col=(255,255,255)):
        if not self.textDic.has_key(text):
            self.textDic[text] = self.font.render(text, 1, col)
        self.screen.blit(self.textDic[text], pos)

    def drawT(self, center=(0,0), col1=[0,0,0], col2=[0,0,0], ang1=0, ang2=90, size=(0.1, 0.5), offset = 0, rotate = True, double = False):
        
        #import pdb;pdb.set_trace()
        #print center
        if rotate:
            if center[0]==0  and center[1]>0:
                offsety = offset
                offsetx = 0
                angle = -pi/2;
            else:    
                angle = arctan(center[1]*self.deg2pix/(center[0]*self.deg2pix))
                offsety = offset*sin(angle)
                offsetx = offset*cos(angle)
                
                if angle < 0 and angle < -pi/2:
                    offsety *= -1
                if sign(center[1])==-1 and sign (center[0])==-1:
                    offsetx *= -1
                    offsety *= -1
                elif sign(center[1])==1 and sign (center[0])==-1:
                    offsety *= -1
                    offsetx *= -1
                    
            center1 = (center[0]*self.deg2pix+self.center[0]+(offsetx), center[1]*self.deg2pix+self.center[1]+(offsety)) 
            center2 = (center[0]*self.deg2pix+self.center[0]-(offsetx), center[1]*self.deg2pix+self.center[1]-(offsety))
            
            th1 = ang1/180*math.pi - angle; th2 = ang2/180*math.pi - angle
            
            R1a = mat([[cos(th1), -sin(th1)],[sin(th1),cos(th1)]])
            R2a = mat([[cos(th2), -sin(th2)],[sin(th2),cos(th2)]])
            #R1b = mat([[cos(th1+math.pi), -sin(th1+math.pi)],[sin(th1+math.pi),cos(th1+math.pi)]])
            #R2b = mat([[cos(th2+math.pi), -sin(th2+math.pi)],[sin(th2+math.pi),cos(th2+math.pi)]])
            
        #import pdb;pdb.set_trace()
        else:
            center1 = (center[0]*self.deg2pix+self.center[0], center[1]*self.deg2pix+self.center[1]-offset) 
            center2 = (center[0]*self.deg2pix+self.center[0], center[1]*self.deg2pix+self.center[1]+offset)
    
            th1 = ang1/180*math.pi+math.pi/2; th2 = ang2/180*math.pi+math.pi/2
            
            R1a = mat([[cos(th1), -sin(th1)],[sin(th1),cos(th1)]])
            R2a = mat([[cos(th2), -sin(th2)],[sin(th2),cos(th2)]])
            
        sz1 = size[0]*self.deg2pix; sz2 = size[1]*self.deg2pix
        cx1 = center1[0]; cy1 = center1[1]
        cx2 = center2[0]; cy2 = center2[1]
        
        #X = mat([[sz1, sz1, sz1+sz2, sz1+sz2],[-sz1, sz1, sz1, -sz1]]); X = X.T
        X = mat([[-sz2, -sz2, sz2, sz2],[-sz1, sz1, sz1, -sz1]]); X = X.T

        
        Z = X*R1a; pointlist = []
        for i in range(0,4): pointlist.append((Z[i,0]+cx1,Z[i,1]+cy1))
        pygame.draw.polygon(self.screen, col2, pointlist)
        
        #Z = X*R1b; pointlist = []
        #for i in range(0,4): pointlist.append((Z[i,0]+cx1,Z[i,1]+cy1))
        #pygame.draw.polygon(self.screen, col1, pointlist)
        
        Z = X*R2a; pointlist = []
        for i in range(0,4): pointlist.append((Z[i,0]+cx2,Z[i,1]+cy2))
        pygame.draw.polygon(self.screen, col1, pointlist)
        
        #Z = X*R2b; pointlist = []
        #for i in range(0,4): pointlist.append((Z[i,0]+cx2,Z[i,1]+cy2))
        #pygame.draw.polygon(self.screen, col2, pointlist)
        #pygame.draw.aalines(self.screen, col1, True, pointlist, blend=1)
        
        if double:
            center2 = (center[0] * double, center[1]*double)
            self.drawT(center2, col1, col2, ang1, ang2, size, offset, rotate, double = False)
        
    def drawWindow(self, center=(0,0), col1=[0,0,0], col2=[0,0,0], size=(0.1, 0.5), offsetx = 0, offsety = 0):
        
        centerScaled = self.center+array([center[0]*self.deg2pix, center[1]*self.deg2pix]) 
        angle = angleOnCircle(center)+pi/2
        
        centerUR =array([center[0]*self.deg2pix, center[1]*self.deg2pix])
        centerUL = array([center[0]*self.deg2pix, center[1]*self.deg2pix])
        centerLR =  array([center[0]*self.deg2pix, center[1]*self.deg2pix])
        centerLL = array([center[0]*self.deg2pix, center[1]*self.deg2pix])
        
        self.drawRectFromCenter(centerUR+self.center, size[0]*self.deg2pix, size[1] * self.deg2pix, angleOnCircle(centerUR) + pi / 2, col1, offset_before_rotation = (-offsetx, offsety))
        self.drawRectFromCenter(centerUL+self.center, size[0]*self.deg2pix, size[1] * self.deg2pix, angleOnCircle(centerUL) + pi / 2, col2, offset_before_rotation = (offsetx, offsety))
        self.drawRectFromCenter(centerLR+self.center, size[0]*self.deg2pix, size[1] * self.deg2pix, angleOnCircle(centerLR) + pi / 2, col2, offset_before_rotation = (-offsetx, -offsety))
        self.drawRectFromCenter(centerLL+self.center, size[0]*self.deg2pix, size[1] * self.deg2pix, angleOnCircle(centerLL) + pi / 2, col1, offset_before_rotation = (offsetx, -offsety))
    
    def drawDotBar(self, center=(0,0), col1=[0,0,0], col2=[0,0,0], size=(0.1, 0.5), spotsize = (.4),offsetx = 0, offsety = 0):
        
        centerScaled = self.center+array([center[0]*self.deg2pix, center[1]*self.deg2pix]) 
        angle = angleOnCircle(center)+pi/2
        
        centerUR =array([center[0]*self.deg2pix, center[1]*self.deg2pix])
        centerUL = array([center[0]*self.deg2pix, center[1]*self.deg2pix])
        centerLR =  array([center[0]*self.deg2pix, center[1]*self.deg2pix])
        centerLL = array([center[0]*self.deg2pix, center[1]*self.deg2pix])
        
        #pygame.draw.circle(self.screen, (0,0,0), centerUR+[-offsetx, offsety]+self.center, spotsize*self.deg2pix+2)
        #pygame.draw.circle(self.screen, col1, centerUR+[-offsetx, offsety]+self.center, spotsize*self.deg2pix)
        
        #self.drawRectFromCenter(centerUR+self.center, size[0]*self.deg2pix, size[1] * self.deg2pix, angleOnCircle(centerUR) + pi / 2, col1, offset_before_rotation = (-offsetx, offsety))
        self.drawCircFromCenter(centerUR + self.center, spotsize * self.deg2pix, angle = angleOnCircle(centerUR)+ pi / 2, color = col1, offset_before_rotation = (-offsetx, offsety))
        
        self.drawRectFromCenter(centerUL+self.center, size[0]*self.deg2pix, size[1] * self.deg2pix, angleOnCircle(centerUL) + pi / 2, col2, offset_before_rotation = (offsetx, offsety))
        self.drawRectFromCenter(centerLR+self.center, size[0]*self.deg2pix, size[1] * self.deg2pix, angleOnCircle(centerLR) + pi / 2, col2, offset_before_rotation = (-offsetx, -offsety))
        
        self.drawCircFromCenter(centerLL + self.center, spotsize * self.deg2pix, angle = angleOnCircle(centerUR)+ pi / 2, color = col1, offset_before_rotation = (offsetx, -offsety))

        #self.drawRectFromCenter(centerLL+self.center, size[0]*self.deg2pix, size[1] * self.deg2pix, angleOnCircle(centerLL) + pi / 2, col1, offset_before_rotation = (offsetx, -offsety))
        
    def drawCross(self, center=(0,0), col1=[0,0,0], col2=[0,0,0], ang1=0, ang2=90, size=(0.1, 0.5), fill_middle = False):
 
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
        
        if fill_middle:
            X = mat([[sz1, sz1, -sz1, -sz1],[-sz1, sz1, sz1, -sz1]]); X = X.T
            Z = X*R1a; pointlist = []
            for i in range(0,4): pointlist.append((Z[i,0]+cx,Z[i,1]+cy))
            pygame.draw.polygon(self.screen, col1, pointlist)
        
        #pygame.draw.aalines(self.screen, col1, True, pointlist, blend=1)
    
    def drawSpot(self, center=(0,0), col1=[0,0,0], col2=[0,0,0], size=(0.1, 0.5)):
        pos = (center[0]*self.deg2pix+self.center[0], center[1]*self.deg2pix+self.center[1])

        pygame.draw.circle(self.screen, (0,0,0), pos, size[1]*self.deg2pix+2)
        pygame.draw.circle(self.screen, col1, pos, size[1]*self.deg2pix)
        pygame.draw.circle(self.screen, (0,0,0), pos, size[0]*self.deg2pix+2)
        pygame.draw.circle(self.screen, col2, pos, size[0]*self.deg2pix)
        #pygame.draw.aalines(self.screen, col1, True, pointlist, blend=1)
                
    def drawMoon(self, center=(0,0), col1=[0,0,0], col2=[0,0,0], size=(0.1, 0.5), offset = 0):
        #import pdb;pdb.set_trace()
        if center[0]==0:
            offsety = offset
            offsetx = 0
        else:    
            angle = arctan(center[1]*self.deg2pix/(center[0]*self.deg2pix))
            offsety = offset*sin(angle)
            offsetx = offset*cos(angle)
            
            if angle < 0 and angle < -pi/2:
                offsety *= -1
            if sign(center[1])==-1 and sign (center[0])==-1:
                offsetx *= -1
                offsety *= -1
            elif sign(center[1])==1 and sign (center[0])==-1:
                offsety *= -1
                offsetx *= -1
                
        center1 = (center[0]*self.deg2pix+self.center[0]+(offsetx), center[1]*self.deg2pix+self.center[1]+(offsety)) 
        center2 = (center[0]*self.deg2pix+self.center[0]-(offsetx), center[1]*self.deg2pix+self.center[1]-(offsety))
        
        pygame.draw.circle(self.screen, (0,0,0), center1, size[1]*self.deg2pix+2)
        pygame.draw.circle(self.screen, col1, center1, size[1]*self.deg2pix)
        pygame.draw.circle(self.screen, (0,0,0), center2, size[0]*self.deg2pix+2)
        pygame.draw.circle(self.screen, col2, center2, size[0]*self.deg2pix)
        #pygame.draw.aalines(self.screen, col1, True, pointlist, blend=1)
    
    def drawSpotPiece(self, center=(0,0), col1=[0,0,0], ang1=0, size=(0.1, 0.5)):
        if ang1==0:
            pygame.draw.circle(self.screen, col1, center, size[1]*self.deg2pix)
            pygame.draw.circle(self.screen, (0,0,0), center, size[0]*self.deg2pix+2)
        else:
            pygame.draw.circle(self.screen, col1, center, size[0]*self.deg2pix)
        #pygame.draw.aalines(self.screen, col1, True, pointlist, blend=1)
            
    def drawMoonPiece(self, center=(0,0), col1=[0,0,0], ang1=0, size=(0.1, 0.5),offset=0):
        #import pdb;pdb.set_trace()
        offsety = offset*2.0
        
        center2 = (center[0], center[1]+offsety)
        
        if ang1==0:
            pygame.draw.circle(self.screen, col1, center, size[1]*self.deg2pix)
            pygame.draw.circle(self.screen, (0,0,0), center2, size[0]*self.deg2pix+2)
        else:
            pygame.draw.circle(self.screen, col1, center, size[0]*self.deg2pix)
        #pygame.draw.aalines(self.screen, col1, True, pointlist, blend=1)
        
    def drawTPiece(self, center=(0,0), col1=[0,0,0], ang1=0, size=(0.1, 0.5),offset=0, double = False):
        offsety = -offset*2.0
        center1= center
        center2 = (center[0], center[1]+offsety)
        
        sz1 = size[0]*self.deg2pix; sz2 = size[1]*self.deg2pix
        cx1 = center1[0]; cy1 = center1[1]
        cx2 = center2[0]; cy2 = center2[1]
        th1 = ang1/180*math.pi; th2 = ang1/180*math.pi + pi/2 #hard coded to be the orthogonal line
        
        #X = mat([[sz1, sz1, sz1+sz2, sz1+sz2],[-sz1, sz1, sz1, -sz1]]); X = X.T
        X = mat([[-sz2, -sz2, sz2, sz2],[-sz1, sz1, sz1, -sz1]]); X = X.T
        
        #R1b = mat([[cos(th1+math.pi), -sin(th1+math.pi)],[sin(th1+math.pi),cos(th1+math.pi)]])
        #R2b = mat([[cos(th2+math.pi), -sin(th2+math.pi)],[sin(th2+math.pi),cos(th2+math.pi)]])
        
        #import pdb;pdb.set_trace()
        if ang1 == 0:
            R1a = mat([[cos(th1), -sin(th1)],[sin(th1),cos(th1)]])
            R2a = mat([[cos(th2), -sin(th2)],[sin(th2),cos(th2)]])
        
            Z = X*R1a; pointlist = []
            for i in range(0,4): pointlist.append((Z[i,0]+cx1,Z[i,1]+cy1))
            pygame.draw.polygon(self.screen, col1, pointlist)
        
        #Z = X*R1b; pointlist = []
        #for i in range(0,4): pointlist.append((Z[i,0]+cx1,Z[i,1]+cy1))
        #pygame.draw.polygon(self.screen, col1, pointlist)
        
            Z = X*R2a; pointlist = []
            for i in range(0,4): pointlist.append((Z[i,0]+cx2,Z[i,1]+cy2))
            pygame.draw.polygon(self.screen, (127,127,127), pointlist,1)
        
        #Z = X*R2b; pointlist = []
        #for i in range(0,4): pointlist.append((Z[i,0]+cx2,Z[i,1]+cy2))
        #pygame.draw.polygon(self.screen, col2, pointlist)
        #pygame.draw.aalines(self.screen, col1, True, pointlist, blend=1)
        
        else:
            R2a = mat([[cos(th1), -sin(th1)],[sin(th1),cos(th1)]])
            R1a = mat([[cos(th2), -sin(th2)],[sin(th2),cos(th2)]])
        
            
            Z = X*R1a; pointlist = []
            for i in range(0,4): pointlist.append((Z[i,0]+cx1,Z[i,1]+cy1))
            pygame.draw.polygon(self.screen, (127,127,127), pointlist,1)
        
        #Z = X*R1b; pointlist = []
        #for i in range(0,4): pointlist.append((Z[i,0]+cx1,Z[i,1]+cy1))
        #pygame.draw.polygon(self.screen, col1, pointlist)
        
            Z = X*R2a; pointlist = []
            for i in range(0,4): pointlist.append((Z[i,0]+cx2,Z[i,1]+cy2))
            pygame.draw.polygon(self.screen, col1, pointlist)
            
            
        if double:
            
           center2= (center[0],center[1]-48) #sorry future cory... 
           self.drawTPiece(center2, col1, ang1, size,offset, double = False)
        
    def drawCue(self, ang, length, col=[0,0,0], mind=0.5):
        endpos = [self.deg2pix*length*cos(ang/180*math.pi)+self.center[0], self.deg2pix*length*sin(ang/180*math.pi)+self.center[1]]
        stapos = [self.deg2pix*mind*cos(ang/180*math.pi)+self.center[0], self.deg2pix*mind*sin(ang/180*math.pi)+self.center[1]]
        pygame.draw.line(self.screen, col, stapos, endpos, 5)
        
    def drawCrossPiece(self, center=(0,0), col1=[0,0,0], ang1=0, size=(0.1, 0.5), fill_middle = False):
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
        
        if fill_middle and ang1 ==0 :
            X = mat([[sz1, sz1, -sz1, -sz1],[-sz1, sz1, sz1, -sz1]]); X = X.T
            Z = X*R1a; pointlist = []
            for i in range(0,4): pointlist.append((Z[i,0]+center[0],Z[i,1]+center[1]))
            pygame.draw.polygon(self.screen, col1, pointlist)
        
    def drawWindowPiece(self, center=(0,0), col1=[0,0,0], size=(0.1, 0.5), draw_quad = 1, offsetx = 0, offsety = 0):
        
        centerScaled = self.center+array([center[0]*self.deg2pix, center[1]*self.deg2pix]) 
        angle = angleOnCircle(center)+pi/2
        #import pdb;pdb.set_trace()
        centerUR =array([center[0], center[1]])
        centerUL = array([center[0], center[1]])
        centerLR =  array([center[0], center[1]])
        centerLL = array([center[0], center[1]])
        
        if draw_quad == 1 :
            self.drawRectFromCenter(centerUR, size[0]*self.deg2pix, size[1] * self.deg2pix, 0, col1, offset_before_rotation = (-offsetx, offsety))
            self.drawRectFromCenter(centerUL, size[0]*self.deg2pix, size[1] * self.deg2pix, 0, (128,128,128), offset_before_rotation = (offsetx, offsety), width = 1)
            self.drawRectFromCenter(centerLR, size[0]*self.deg2pix, size[1] * self.deg2pix, 0, (128,128,128), offset_before_rotation = (-offsetx, -offsety), width = 1)
            self.drawRectFromCenter(centerLL, size[0]*self.deg2pix, size[1] * self.deg2pix, 0, col1, offset_before_rotation = (offsetx, -offsety))
        else:
            self.drawRectFromCenter(centerUR, size[0]*self.deg2pix, size[1] * self.deg2pix, 0, (128,128,128), offset_before_rotation = (-offsetx, offsety), width = 1)
            self.drawRectFromCenter(centerUL, size[0]*self.deg2pix, size[1] * self.deg2pix, 0, col1, offset_before_rotation = (offsetx, offsety))
            self.drawRectFromCenter(centerLR, size[0]*self.deg2pix, size[1] * self.deg2pix, 0, col1, offset_before_rotation = (-offsetx, -offsety))
            self.drawRectFromCenter(centerLL, size[0]*self.deg2pix, size[1] * self.deg2pix, 0, (128,128,128), offset_before_rotation = (offsetx, -offsety), width = 1)
                    
    def drawDotBarPiece(self, center=(0,0), col1=[0,0,0], size=(0.1, 0.5), radius = .3, draw_quad = 1, offsetx = 0, offsety = 0):
        
        centerScaled = self.center+array([center[0]*self.deg2pix, center[1]*self.deg2pix]) 
        angle = angleOnCircle(center)+pi/2
        #import pdb;pdb.set_trace()
        centerUR =array([center[0], center[1]])
        centerUL = array([center[0], center[1]])
        centerLR =  array([center[0], center[1]])
        centerLL = array([center[0], center[1]])
        
        if draw_quad == 1 :
            
            self.drawCircFromCenter(centerUR, radius * self.deg2pix, 0, color = col1, offset_before_rotation = (-offsetx, offsety))
            #self.drawRectFromCenter(centerUL, size[0]*self.deg2pix, size[1] * self.deg2pix, 0, (128,128,128), offset_before_rotation = (offsetx, offsety), width = 1)
            #self.drawRectFromCenter(centerLR, size[0]*self.deg2pix, size[1] * self.deg2pix, 0, (128,128,128), offset_before_rotation = (-offsetx, -offsety), width = 1)
            self.drawCircFromCenter(centerLL, radius * self.deg2pix, 0, color = col1, offset_before_rotation = (offsetx, -offsety))

        else:
            #would need to input outline color
            #self.drawCircFromCenter(centerUR, radius * self.deg2pix, 0, color = (128,128,128), offset_before_rotation = (-offsetx, offsety))
            self.drawRectFromCenter(centerUL, size[0]*self.deg2pix, size[1] * self.deg2pix, 0, col1, offset_before_rotation = (offsetx, offsety))
            self.drawRectFromCenter(centerLR, size[0]*self.deg2pix, size[1] * self.deg2pix, 0, col1, offset_before_rotation = (-offsetx, -offsety))
            #self.drawCircFromCenter(centerLL, radius * self.deg2pix, 0, color = (128,128,128), offset_before_rotation = (offsetx, -offsety))
            
    def drawSpotOptions(self, colororder, orientation, size):
        rangex = self.xlim[1]-self.xlim[0]
        ypos = round((self.ylim[1] - self.center[1])/2)
        peritem = rangex/len(colororder)
        
        for i in range(0,len(colororder)):
            xpos = peritem*i+peritem/2
            self.drawSpotPiece([xpos,ypos], colororder[i], orientation, size)
            self.writeText('%d'%mod(i+1,10), [xpos-10, ypos+50]) 
                   
    def drawMoonOptions(self, colororder, orientation, size, offset):
        rangex = self.xlim[1]-self.xlim[0]
        ypos = round((self.ylim[1] - self.center[1])/2)
        peritem = rangex/len(colororder)
        
        for i in range(0,len(colororder)):
            xpos = peritem*i+peritem/2
            self.drawMoonPiece([xpos,ypos], colororder[i], orientation, size, offset)
            self.writeText('%d'%mod(i+1,10), [xpos-10, ypos+50])

    def drawTOptions(self, colororder, orientation, size, offset, double = False):
        rangex = self.xlim[1]-self.xlim[0]
        ypos = round((self.ylim[1] - self.center[1])/2)
        peritem = rangex/len(colororder)
        
        for i in range(0,len(colororder)):
            xpos = peritem*i+peritem/2
            self.drawTPiece([xpos,ypos], colororder[i], orientation, size, offset, double)
            self.writeText('%d'%mod(i+1,10), [xpos-10, ypos+50])
            
    def drawWindowOptions(self, colororder, draw_quad, size, offset_x,offset_y):
        rangex = self.xlim[1]-self.xlim[0]
        ypos = round((self.ylim[1] - self.center[1])/2)
        peritem = rangex/len(colororder)
        
        for i in range(0,len(colororder)):
            xpos = peritem*i+peritem/2
            self.drawWindowPiece([xpos,ypos], colororder[i], size,draw_quad, offset_x,offset_y)
            self.writeText('%d'%mod(i+1,10), [xpos-10, ypos+50])   
                     
    def drawDotBarOptions(self, colororder, draw_quad, size, radius, offset_x,offset_y):
        rangex = self.xlim[1]-self.xlim[0]
        ypos = round((self.ylim[1] - self.center[1])/2)
        peritem = rangex/len(colororder)
        
        for i in range(0,len(colororder)):
            xpos = peritem*i+peritem/2
            self.drawDotBarPiece([xpos,ypos], colororder[i], size, radius, draw_quad, offset_x,offset_y)
            self.writeText('%d'%mod(i+1,10), [xpos-10, ypos+50])

    def drawBarOptions(self, colororder, orientation, size, fill_middle = False):
        rangex = self.xlim[1]-self.xlim[0]
        ypos = round((self.ylim[1] - self.center[1])/2)
        peritem = rangex/len(colororder)

        for i in range(0,len(colororder)):
            xpos = peritem*i+peritem/2
            self.drawCrossPiece([xpos,ypos], colororder[i], orientation, size, fill_middle)
            self.writeText('%d'%mod(i+1,10), [xpos-10, ypos+50])
            
    def drawFixation(self, fixation, color=(0,0,0)):
        pygame.draw.circle(self.screen, color, (fixation[0]*self.deg2pix+self.center[0], fixation[1]*self.deg2pix+self.center[1]), 5)
        
    def fillScreen(self, col=(255,255,255)):
        self.screen.fill(col)
        
    def flip(self):
        pygame.display.flip()
