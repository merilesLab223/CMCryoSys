clear;
dev=RhodeSchwarzSMA100TriggeredFG;
dev.addlistener('DataReady',@(s,e)disp(e.Data));
dev.configure;
disp(dev);
dev.NumberOFSweepPoints=11;%uint32(rand()*100);
dev.StartFrequency=2.8e9;
dev.EndFrequency=2.9e9;
disp(['New step: ',num2str((dev.EndFrequency-dev.StartFrequency)./(dev.NumberOFSweepPoints-1))]);
dev.prepare;
dev.run;