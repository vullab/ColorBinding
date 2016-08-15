import sys

def readConfig(filepath):
	config = dict()
	fid = open(filepath,'r')
	for line in fid:
		x = line.split('\t')
		if len(x)<>2:
			print 'error with configuration file: %s' % filepath
			sys.exit()
		k = x[0].strip()
		v = x[1].strip()
		vs = v.split(',')
		if len(vs)==1:
			vs = float(vs[0])
		else:
			vs = map(float,vs)
		config[k]=vs
	fid.close()
	return config
	
	