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
        self.screen = pygame.display.set_mode((1280, 1024))#16)#pygame.FULLSCREEN)#16) # pygame.FULLSCREEN
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

### DRAW SPOT

    def drawSpot(self, center=(0,0), col1=[0,0,0], col2=[0,0,0], size=(0.1, 0.5)):
        pos = (int(center[0]*self.deg2pix+self.center[0]), int(center[1]*self.deg2pix+self.center[1]))

        pygame.draw.circle(self.screen, (0,0,0), pos, int(size[1]*self.deg2pix+2))
        pygame.draw.circle(self.screen, col1, pos, int(size[1]*self.deg2pix))
        pygame.draw.circle(self.screen, (0,0,0), pos, int(size[0]*self.deg2pix+2))
        pygame.draw.circle(self.screen, col2, pos, int(size[0]*self.deg2pix))
        #pygame.draw.aalines(self.screen, col1, True, pointlist, blend=1)
        
    def drawSpotOptions(self, colororder, orientation, size):
        rangex = self.xlim[1]-self.xlim[0]
        ypos = round((self.ylim[1] - self.center[1])/2)
        peritem = rangex/len(colororder)
        
        for i in range(0,len(colororder)):
            xpos = peritem*i+peritem/2
            self.drawSpotPiece([int(xpos),int(ypos)], colororder[i], orientation, size)
            self.writeText('%d'%mod(i+1,10), [xpos-10, ypos+50])
    

    def drawSpotOptions2(self, colororder, orientation, size,horiz):
        rangex = (self.xlim[1]-self.xlim[0])/(1.75)
        rangey=(self.ylim[1]-self.ylim[0])/(1.75)
        rangexy=max((rangex,rangey))
        if horiz:
            rangex = (self.xlim[1]-self.xlim[0])/(1.5)
            ypos = round((self.ylim[1] - self.center[1])/2)-rangexy/len(colororder)
            peritem = rangexy/len(colororder)
            
            for i in range(0,len(colororder)):
                xpos = round((self.xlim[1] - self.center[1])/2)+peritem*i+rangexy/len(colororder)
                self.drawSpotPiece([int(xpos),int(ypos)], colororder[i], orientation, size)
                        
        else:
            rangey=(self.ylim[1]-self.ylim[0])/(1.5)
            xpos=round((self.xlim[1] - self.center[1])/2)
            peritem = rangexy/len(colororder)
            for i in range(0,len(colororder)):
                ypos=round((self.ylim[1] - self.center[1])/2)+peritem*i
                self.drawSpotPiece([int(xpos),int(ypos)], colororder[i], orientation, size)

    def drawSpotGrid(self,colororder,size,centerVert):
        rangex = (self.xlim[1]-self.xlim[0])/(1.75)
        rangey=(self.ylim[1]-self.ylim[0])/(1.75)
        rangexy=max((rangex,rangey))
        peritem = rangexy/len(colororder)
        positions=[]
        indices=[]
        for hi in range(0,len(colororder)):
            for vi in range(0,len(colororder)):
                xpos = round((self.xlim[1] - self.center[1])/2)+peritem*hi+rangexy/len(colororder)
                ypos=round((self.ylim[1] - self.center[1])/2)+peritem*vi

                if hi!=vi:
                    positions.append((xpos,ypos))
                    if centerVert:
                        indices.append((hi,vi))
                        self.drawSpotPiece([int(xpos),int(ypos)], colororder[hi], 0, size)
                        self.drawSpotPiece([int(xpos),int(ypos)], colororder[vi], 90, size)
                    else:
                        indices.append((vi,hi))
                        self.drawSpotPiece([int(xpos),int(ypos)], colororder[vi], 0, size)
                        self.drawSpotPiece([int(xpos),int(ypos)], colororder[hi], 90, size)

        stax=round((self.xlim[1] - self.center[1])/2)
        stay=round((self.ylim[1] - self.center[1])/2)
        endx=stax+peritem*len(colororder)
        endy=stay+peritem*len(colororder)
        self.drawLine((stax+peritem/2.0,stay-peritem*1.5),(stax+peritem/2.0,endy),5,(255,255,255))
        self.drawLine((stax-peritem/2.5,stay-peritem/2),(endx+peritem/2.5,stay-peritem/2),5,(255,255,255))
        return (positions,indices)

    def drawSpotGridChoice(self,colororder,size,choice,centerVert):
        rangex = (self.xlim[1]-self.xlim[0])/(1.75)
        rangey=(self.ylim[1]-self.ylim[0])/(1.75)
        rangexy=max((rangex,rangey))
        peritem = rangexy/len(colororder)
        positions=[]
        for hi in range(0,len(colororder)):
            for vi in range(0,len(colororder)):
                if hi==choice[0] and vi==choice[1]:
                    xpos = round((self.xlim[1] - self.center[1])/2)+peritem*hi+rangexy/len(colororder)
                    ypos=round((self.ylim[1] - self.center[1])/2)+peritem*vi
                    positions.append((xpos,ypos))
                    if centerVert:
                        self.drawSpotPiece([int(xpos),int(ypos)], colororder[hi], 0, size)
                        self.drawSpotPiece([int(xpos),int(ypos)], colororder[vi], 90, size)
                    else:
                        self.drawSpotPiece([int(xpos),int(ypos)], colororder[vi], 0, size)
                        self.drawSpotPiece([int(xpos),int(ypos)], colororder[hi], 90, size)


        stax=round((self.xlim[1] - self.center[1])/2)
        stay=round((self.ylim[1] - self.center[1])/2)
        endx=stax+peritem*len(colororder)
        endy=stay+peritem*len(colororder)
        self.drawLine((stax+peritem/2.5,stay-peritem*1.5),(stax+peritem/2.5,endy),5,(255,255,255))
        self.drawLine((stax-peritem/2.5,stay-peritem/2),(endx+peritem/2.5,stay-peritem/2),5,(255,255,255))
        return positions

    def drawSpotPiece(self, center=(0,0), col1=[0,0,0], ang1=0, size=(0.1, 0.5)):
        if ang1==0:
            pygame.draw.circle(self.screen, col1, center, int(size[1]*self.deg2pix))
            pygame.draw.circle(self.screen, (0,0,0), center, int(size[0]*self.deg2pix+2))
        else:
            pygame.draw.circle(self.screen, col1, center, int(size[0]*self.deg2pix))

# CROSS DRAWING CODE

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

    def drawCrossOptions2(self, colororder, orientation, size,horiz):
        rangex = (self.xlim[1]-self.xlim[0])/(1.75)
        rangey=(self.ylim[1]-self.ylim[0])/(1.75)
        rangexy=max((rangex,rangey))
        if horiz:
            rangex = (self.xlim[1]-self.xlim[0])/(1.5)
            ypos = round((self.ylim[1] - self.center[1])/2)-rangexy/len(colororder)
            peritem = rangexy/len(colororder)
            
            for i in range(0,len(colororder)):
                xpos = round((self.xlim[1] - self.center[1])/2)+peritem*i+rangexy/len(colororder)
                self.drawCrossPiece([int(xpos),int(ypos)], colororder[i], orientation, size)
                        
        else:
            rangey=(self.ylim[1]-self.ylim[0])/(1.5)
            xpos=round((self.xlim[1] - self.center[1])/2)
            peritem = rangexy/len(colororder)
            for i in range(0,len(colororder)):
                ypos=round((self.ylim[1] - self.center[1])/2)+peritem*i
                self.drawCrossPiece([int(xpos),int(ypos)], colororder[i], orientation, size)

    def drawCrossGrid(self,colororder,size,centerVert):
        rangex = (self.xlim[1]-self.xlim[0])/(1.75)
        rangey=(self.ylim[1]-self.ylim[0])/(1.75)
        rangexy=max((rangex,rangey))
        peritem = rangexy/len(colororder)
        positions=[]
        indices=[]
        for hi in range(0,len(colororder)):
            for vi in range(0,len(colororder)):
                xpos = round((self.xlim[1] - self.center[1])/2)+peritem*hi+rangexy/len(colororder)
                ypos=round((self.ylim[1] - self.center[1])/2)+peritem*vi

                if hi!=vi:
                    positions.append((xpos,ypos))
                    if centerVert:
                        indices.append((hi,vi))
                        self.drawCrossPiece([int(xpos),int(ypos)], colororder[hi], 0, size)
                        self.drawCrossPiece([int(xpos),int(ypos)], colororder[vi], 90, size)
                    else:
                        indices.append((vi,hi))
                        self.drawCrossPiece([int(xpos),int(ypos)], colororder[vi], 0, size)
                        self.drawCrossPiece([int(xpos),int(ypos)], colororder[hi], 90, size)

        stax=round((self.xlim[1] - self.center[1])/2)
        stay=round((self.ylim[1] - self.center[1])/2)
        endx=stax+peritem*len(colororder)
        endy=stay+peritem*len(colororder)
        self.drawLine((stax+peritem/2.0,stay-peritem*1.5),(stax+peritem/2.0,endy),5,(255,255,255))
        self.drawLine((stax-peritem/2.5,stay-peritem/2),(endx+peritem/2.5,stay-peritem/2),5,(255,255,255))
        return (positions,indices)

    def drawCrossGridChoice(self,colororder,size,choice,centerVert):
        rangex = (self.xlim[1]-self.xlim[0])/(1.75)
        rangey=(self.ylim[1]-self.ylim[0])/(1.75)
        rangexy=max((rangex,rangey))
        peritem = rangexy/len(colororder)
        positions=[]
        for hi in range(0,len(colororder)):
            for vi in range(0,len(colororder)):
                if hi==choice[0] and vi==choice[1]:
                    xpos = round((self.xlim[1] - self.center[1])/2)+peritem*hi+rangexy/len(colororder)
                    ypos=round((self.ylim[1] - self.center[1])/2)+peritem*vi
                    positions.append((xpos,ypos))
                    if centerVert:
                        self.drawCrossPiece([int(xpos),int(ypos)], colororder[hi], 0, size)
                        self.drawCrossPiece([int(xpos),int(ypos)], colororder[vi], 90, size)
                    else:
                        self.drawCrossPiece([int(xpos),int(ypos)], colororder[vi], 0, size)
                        self.drawCrossPiece([int(xpos),int(ypos)], colororder[hi], 90, size)


        stax=round((self.xlim[1] - self.center[1])/2)
        stay=round((self.ylim[1] - self.center[1])/2)
        endx=stax+peritem*len(colororder)
        endy=stay+peritem*len(colororder)
        self.drawLine((stax+peritem/2.5,stay-peritem*1.5),(stax+peritem/2.5,endy),5,(255,255,255))
        self.drawLine((stax-peritem/2.5,stay-peritem/2),(endx+peritem/2.5,stay-peritem/2),5,(255,255,255))
        return positions

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

### T DRAWING CODE

# DRAW T

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
 

    def drawTGrid(self,colororder,size,centerVert,offset):
        rangex = (self.xlim[1]-self.xlim[0])/(1.75)
        rangey=(self.ylim[1]-self.ylim[0])/(1.75)
        rangexy=max((rangex,rangey))
        peritem = rangexy/len(colororder)
        positions=[]
        indices=[]
        for hi in range(0,len(colororder)):
            for vi in range(0,len(colororder)):
                xpos = round((self.xlim[1] - self.center[1])/2)+peritem*hi+rangexy/len(colororder)
                ypos=round((self.ylim[1] - self.center[1])/2)+peritem*vi

                if hi!=vi:
                    positions.append((xpos,ypos))
                    if centerVert:
                        indices.append((hi,vi))
                        self.drawTPiece([int(xpos),int(ypos)], colororder[hi], 0, size,offset)
                        self.drawTPiece([int(xpos),int(ypos)], colororder[vi], 90, size,offset)
                    else:
                        indices.append((vi,hi))
                        self.drawTPiece([int(xpos),int(ypos)], colororder[vi], 0, size,offset)
                        self.drawTPiece([int(xpos),int(ypos)], colororder[hi], 90, size,offset)

        stax=round((self.xlim[1] - self.center[1])/2)
        stay=round((self.ylim[1] - self.center[1])/2)
        endx=stax+peritem*len(colororder)
        endy=stay+peritem*len(colororder)
        self.drawLine((stax+peritem/2.0,stay-peritem*1.5),(stax+peritem/2.0,endy),5,(255,255,255))
        self.drawLine((stax-peritem/2.5,stay-peritem/2),(endx+peritem/2.5,stay-peritem/2),5,(255,255,255))
        return (positions,indices)

    def drawTOptions2(self, colororder, orientation, size,horiz,offset):
        rangex = (self.xlim[1]-self.xlim[0])/(1.75)
        rangey=(self.ylim[1]-self.ylim[0])/(1.75)
        rangexy=max((rangex,rangey))
        if horiz:
            rangex = (self.xlim[1]-self.xlim[0])/(1.5)
            ypos = round((self.ylim[1] - self.center[1])/2)-rangexy/len(colororder)-20 # MAY NEED TO ADJUST SHIFT 3/5/2014
            peritem = rangexy/len(colororder)
            
            for i in range(0,len(colororder)):
                xpos = round((self.xlim[1] - self.center[1])/2)+peritem*i+rangexy/len(colororder)
                self.drawTPiece([int(xpos),int(ypos)], colororder[i], orientation, size,offset)
                        
        else:
            rangey=(self.ylim[1]-self.ylim[0])/(1.5)
            xpos=round((self.xlim[1] - self.center[1])/2)
            peritem = rangexy/len(colororder)
            for i in range(0,len(colororder)):
                ypos=round((self.ylim[1] - self.center[1])/2)+peritem*i
                self.drawTPiece([int(xpos),int(ypos)], colororder[i], orientation, size,offset)

    def drawTGridChoice(self,colororder,size,choice,centerVert):
        rangex = (self.xlim[1]-self.xlim[0])/(1.75)
        rangey=(self.ylim[1]-self.ylim[0])/(1.75)
        rangexy=max((rangex,rangey))
        peritem = rangexy/len(colororder)
        positions=[]
        for hi in range(0,len(colororder)):
            for vi in range(0,len(colororder)):
                if hi==choice[0] and vi==choice[1]:
                    xpos = round((self.xlim[1] - self.center[1])/2)+peritem*hi+rangexy/len(colororder)
                    ypos=round((self.ylim[1] - self.center[1])/2)+peritem*vi
                    positions.append((xpos,ypos))
                    if centerVert:
                        self.drawTPiece([int(xpos),int(ypos)], colororder[hi], 0, size)
                        self.drawTPiece([int(xpos),int(ypos)], colororder[vi], 90, size)
                    else:
                        self.drawTPiece([int(xpos),int(ypos)], colororder[vi], 0, size)
                        self.drawTPiece([int(xpos),int(ypos)], colororder[hi], 90, size)


        stax=round((self.xlim[1] - self.center[1])/2)
        stay=round((self.ylim[1] - self.center[1])/2)
        endx=stax+peritem*len(colororder)
        endy=stay+peritem*len(colororder)
        self.drawLine((stax+peritem/2.5,stay-peritem*1.5),(stax+peritem/2.5,endy),5,(255,255,255))
        self.drawLine((stax-peritem/2.5,stay-peritem/2),(endx+peritem/2.5,stay-peritem/2),5,(255,255,255))
        return positions

          

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

    def drawLine(self,stapos,endpos,width,col):
        pygame.draw.line(self.screen, col, stapos, endpos, 5)


    def drawFixation(self, fixation, color=(0,0,0)):
        pygame.draw.circle(self.screen, color, (fixation[0]*self.deg2pix+self.center[0], fixation[1]*self.deg2pix+self.center[1]), 5)
        
    def fillScreen(self, col=(255,255,255)):
        self.screen.fill(col)
        
    def flip(self):
        pygame.display.flip()

