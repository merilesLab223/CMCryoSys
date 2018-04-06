function []=streamCounts(rate)
    if(~exist('rate','var'))
        rate=50000;
    end
    disp('Starting scanner...');
    global devices;
    global info;
    
    reader=devices.get('scan_reader');
    clock=devices.get('scan_clock');
    
    % stopping the current.
    reader.stop;
    clock.stop;

    clock.setClockRate(rate);
    clock.clockFreq=rate;
    reader.setClockRate(clock.clockFreq);

    % prepare and run.
    disp('Prepare and run.');
    reader.prepare();
    clock.prepare();
    
    info.streamCollector.start();
    
    reader.run;
    clock.run;
    disp('ready.');
end

