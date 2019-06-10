# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		test_creation.py
#		Purpose :	Create lots of variables/arrays and check contents.
#		Date :		10th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random
from variables import *

if __name__ == "__main__":
	print("Creation test code.")
	eb = EntityBucket(100,300,300,50,50)
	#
	bs = BasicSource()
	bs.append(eb.setupCode())
	bs.append(eb.assignCode())
	bs.append(eb.checkCode())
	bs.save()
	#
	blk = BasicBlock(0x4000,0x8000)
	blk.loadProgram()
	blk.exportFile("temp/basic.bin")	