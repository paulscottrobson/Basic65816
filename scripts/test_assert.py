# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		test_assert.py
#		Purpose :	Create a pile of memory variables, check they return correct values.
#					(generated by script, not by LET instructions)
#		Date :		8th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import re,os,sys,random
from dispvariables import *
from variables import *


if __name__ == "__main__":
	blk = ListableVariableBlock(0x4000,0x8000)
	#
	#		Pick a random seed, but one we can retry if required.
	#
	random.seed()
	seed = random.randint(0,65535)
	#seed = 61564
	print("***** ROOT SEED {0} *****".format(seed))
	random.seed(seed)
	#
	#		Create a pile of variable objects
	#
	variables = []
	for i in range(0,100):
		variables.append(IntegerVariable())
		variables.append(StringVariable())
		variables.append(IntegerArray())
		variables.append(StringArray())
	#
	#		Generate code to check that the variable does equal the value.
	#
	for i in range(0,800):
		var = variables[random.randint(0,len(variables)-1)]
		check = var.pickElement()
		if var.isString:
			line = "assert {0} = \"{1}\"".format(check[0],check[1])
		else:
			line = "assert {0} = {1}".format(check[0],check[1])
		blk.addBASICLine(None,line)
	#
	#		Create variables in memory (done after program)
	#
	for v in variables:
		v.importVariable(blk)
	#
	#blk.listVariables()
	blk.showStatus()
	blk.exportFile("temp/basic.bin")
