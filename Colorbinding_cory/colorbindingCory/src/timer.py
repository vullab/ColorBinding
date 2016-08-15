from __future__ import division

import time

class Timer:
	def __init__(self):
		self.init = time.time();
		
		self.events = dict();
		self.events['init'] = self.init
		
	def start(self):
		self.events['start'] = time.time()
		
	def end(self):
		self.events['end'] = time.time()
		
	def record(self, event):
		self.events[event] = time.time()
	
	def gettime(self, eventnames):
		outpt = dict()
		for v in eventnames:
			outpt[v] = self.events[v]
		return outpt
	
	def getreltime(self, eventnames, relativeto):
		outpt = dict()
		for v in eventnames:
			outpt[v] = self.events[v] - self.events[relativeto]
		return outpt
	
	def saveview(self, event, relativeto):
		self.events[event] = time.time()
		return (self.events[event] - self.events[relativeto])
