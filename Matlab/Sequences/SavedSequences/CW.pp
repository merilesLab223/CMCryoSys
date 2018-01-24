;;Sequence for CW

define delay settleTime
"settleTime = 10m"

define pulse dwellTimeCounter
"dwellTimeCounter = 19m"

define pulse dwellTime
"dwellTime = 20m"

define pulse uwaveEXT
"uwaveEXT = 100u"

;;Send a pulse to the signal generator to move to the next frequency
( uwaveEXT:sp1 ):uwaveSource

;;Wait for signal generator to settle
settleTime

;;Turn everyting on (counter;uwaveSwitch;laser)

( dwellTime:sp1 ):laser ( 1m dwellTimeCounter:sp1):counter ( dwellTime:sp1 ):uwaveSwitch (dwellTime:sp1 ph1):uwaveIQ

10u

ph1 = (4) 0
