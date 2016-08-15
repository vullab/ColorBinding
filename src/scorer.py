
class Scorer:
	def __init__(self):
		self.total = 0.0
		self.delta = 0.0
	
	def add(self, some):
		self.delta = some
		self.total = self.total + self.delta
	
	def view(self):
		return (self.total, self.delta)
	
	def addview(self, some):
		self.delta = some
		self.total = self.total + self.delta
		return self.total

