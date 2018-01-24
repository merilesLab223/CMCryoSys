;;Test sequence 

define pulse e90
"e90 = 200n"

( e90:sp2 ph3 ):f1
3, 100n
( e90:sp3 ph1    d1 ):f1 ( p1:sp1   ph3 ):laser
lo to 3 times l1

ph1 = (4) 1
ph3 = (4) 2
