import csv

class Recorder:
	def __init__(self, filename, trialdata):
		self.filename = filename
		self.file = open(filename, 'a')
		self.data = csv.writer(self.file)
		self.keys = []
		for k in trialdata:
			self.keys.append(k)
		self.data.writerow(self.keys)
	
	def write(self, trialdata):
		outpt = []
		
		for k in self.keys:
			try:
				outpt.append(trialdata[k])
			except:
				outpt.append(None)
		self.data.writerow(outpt)
	
	def close(self):
		self.file.close()

