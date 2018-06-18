clear;
dev=ANC300Control;
dev.addlistener('DataReady',@(s,e)disp(e.Data));
dev.configure;
dev.setPosition(5,5);