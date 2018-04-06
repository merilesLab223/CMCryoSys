%% starting stream reader.. (is default)
global devices;
global info;

if(isempty(devices))
    disp('Initializing system...');
    init();
    info.imageCollector.addlistener('Complete',@(s,e)disp('measure.complete.'));
end

info.streamCollector.IntegrateDT=10;
info.imageCollector.clear();
info.imageCollector.Measure(1000);

%%
% streaming.
streamCounts();

while(true)
    pause(0.01);
    li=getLabViewDisplayLoopInfo(true);
    if(li.stream.wasRead)
        subplot(2,1,1);
        plot(info.streamCollector.Timestamps,info.streamCollector.Data);
        drawnow;
    else
        % skipped.
        x=1;
    end
end
% 
% %% Configuration
% if(exist('reader','var'))
%     reader.stop();
%     clock.stop();
% end
% 
% disp('Configuring devs for read.');
% reader=devices.get('scan_reader');
% clock=devices.get('scan_clock');
% 
% % clock.setClockRate(10000);
% % clock.clockFreq=50000;
% % reader.setClockRate(clock.clockFreq);
% 
% %% prepare and run.
% disp('Prepare and run.');
% reader.prepare();
% clock.prepare();
% 
% reader.run;
% clock.run;
% disp('ready.');