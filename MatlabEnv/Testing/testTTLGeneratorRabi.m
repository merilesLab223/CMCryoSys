gate=SpinCoreTTLGenerator;
gate.defaultPulseWidth=gate.getTimebase();
gate.setClockRate(300e6);
gate.clear();
gate.ReduceTTLloops=false;
laserPt=0.003;
dt1=0.001;
rfPtBase=0.001;
hwDelay=0.0002;
detectPt=0.0005;

gate.curT=0;
for i=1:20
    rfPt=rfPtBase+i*rfPtBase/10;
    gate.Pulse(laserPt,[],4);
    gate.wait(dt1);
    gate.Pulse(rfPt,[],3);
    gate.wait(dt1);
    gate.Pulse([],[],1);
    gate.Pulse([],[],1);
    gate.goBackInTime(hwDelay);
    gate.Pulse(laserPt+hwDelay,[],4);
    gate.goBackInTime(laserPt);
    gate.wait(detectPt);
    gate.Pulse([],[],1);
    gate.wait(laserPt-detectPt*2);
    gate.Pulse([],[],1);
    gate.wait(detectPt);
    gate.Pulse([],[],1);
end
%%
[ttl,ti]=gate.getTTLVectors(false);
sttl=size(ttl);
for i=1:sttl(2)
    ttl(:,i)=ttl(:,i)*(1+i*0.1);
end
stairs(ti,ttl);