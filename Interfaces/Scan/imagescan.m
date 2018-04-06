% configures and executes an image scan.
% the image scan will be called and executed.
function imagescan(x0,y0,width,height,xn,yn,totalTime,asDwell)
    global devices;
    global info;
    
    fprintf('Starting imagescan @(%f,%f)+(%f,%f) (%d x %d pix)\n',x0,y0,width,height,xn,yn);
    
    if(~exist('asDwell','var'))asDwell=0;end
    
    clock=devices.get('scan_clock');
    reader=devices.get('scan_reader');
    pos=devices.get('scan_pos');
    
    imgcol=info.imageCollector;
    imgcol.clearEvents();
    
    %% reset the collectors.
    info.imageCollector.stop();
    info.streamCollector.stop();
    
    reader.stop();
    pos.stop();
    clock.stop();
    
    %% configuring the image read.
    pos.clear();
    if(asDwell)
        dwellTime=totalTime;
        totalTime=xn*yn*dwellTime;
    else
        dwellTime=totalTime/(xn*yn);
    end
    [xvec,yvec]=ImageScan(pos,x0,y0,width,height,xn,yn,dwellTime);
    
    mtbin=500;
    mbins=floor(totalTime/mtbin);
    if(mbins<2)
        mbins=2;
    end
    imgcol.clear();
    
    % measure by bins.
    mtdt=totalTime/mbins;
    imgcol.Measure(ones(mbins,1)*mtdt);
    
    %% Setting the current scan.
    info.set('imageScanInfo',struct('x0',x0,'y0',y0,'width',width,...
        'height',height,'xn',xn,'yn',yn,'dwellTime',dwellTime));    
    
    %% adjusting clocks.
    mint=pos.timebaseToSeconds(pos.findMinimalTime());
    % seeting clocks according to mint.
    rate=2./mint;
    if(rate>info.MaxImageScanRate)
        disp(['Clock rate ',num2str(rate),' is larger then max rate (',...
            num2str(info.MaxImageScanRate),').Using max rate.',...
            ' Possible data loss!']);
        rate=info.MaxImageScanRate;
    end
    clockFreq=rate*2;
    
    %% prepare rates and definitions.
    pos.setClockRate(rate);
    reader.setClockRate(clockFreq);
    clock.clockFreq=clockFreq;
    clock.setClockRate(rate);
    
    %% Run.
    % preparing.
    reader.prepare;
    clock.prepare;
    pos.prepare;
    
    % start/restart the collectors.
    info.imageCollector.start();
    info.streamCollector.start();
    
    % executing.
    reader.run;
    pos.run;
    clock.run;
end

