20 	x = 0
50 	repeat
100	if (x & 1) = 0
110		print x,"Even",
112 	if x > 5
118			print ">5"
119 	else
120 		print "<=5"
129 	endif
130 else
134 	print x,"odd",
135 	y = x
136 	repeat:print y;" ";:y = y-1:until y = 0:print
140	endif
150 x = x + 1
160 until x > 10
170 for i = 1 to 5 step 2:print i:next i
180 stop	