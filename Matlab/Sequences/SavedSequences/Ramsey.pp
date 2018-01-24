;;Sequence for Ramsey fringes

define pulse polarize
"polarize = 3u"

define pulse measure
"measure = 1.5u"

define pulse reference1
"reference1 = 1.5u"

define pulse reference2
"reference2 = 3u"

define pulse counterGate
"counterGate = 350n"

define pulse e90
"e90 = 40n"

define pulse e180
"e180 = 80n"

;;Send a laser pulse to polarize the spin system
( polarize:sp1 ):laser

;;A delay to let everything settle down
2u

;;Take a reference of this state
( reference1:sp1 ):laser ( 1.1u counterGate:sp1 ):counter

;;A delay to let everything settle again
2u

;; 180 pulse
( e180:sp1 ph1 ):uwaveIQ ( e180:sp1 ):uwaveSwitch

;;Take a reference of this state and repolarize
( reference2:sp1 ):laser ( 1.1u counterGate:sp1 ):counter

;;A delay to let everything settle again
2u

;;90 degree pulse
( e90:sp2 ph1 ):uwaveIQ ( e90:sp1 ):uwaveSwitch

;;Variable delay
d1

;;90 degree pulse
( e90:sp2 ph1 ):uwaveIQ ( e90:sp1 ):uwaveSwitch

;;Turn on the laser and the counter gates
( measure:sp1 ):laser  ( 1.1u counterGate:sp1 ):counter


ph1 = (4) 0
ph2 = (4) 2
