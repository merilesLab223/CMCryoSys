%% Initialize all devices in the system.
function init(alwaysReset)
    if(~exist('alwaysReset','var'))alwaysReset=1;end
    global info;
    global devices;
    
    % Reset the daq since we are recreating all objects.
    daq.reset();
    
    if(~isempty(info) && info.get('scan_initialized',false))
        if(alwaysReset)
            delete(info);
            delete(devices);
            info=[];
            devices=[];
        else
            return;
        end
    end

    if(isempty(devices))
        devices=DeviceCollection;
    end
    
    if(isempty(info))
        info=globalInfo;
        info.set('scan_initialized',false);
    end

    info.set('scan_initialized',true);
    
    pos=NI6321Positioner2D('Dev1');
    counter=NI6321Counter('Dev1');
    clock=NI6321Clock('Dev1'); % loopback clock.

    % hard connections.
    % port0/line1 ->USER1 ->PFI0 : Trigger.
    % pfi15->pfi14 : Clock loopback.
    % pfi8 (counter 0)->User2 : counter input)

    devices.setDevice('ni2dposition',pos);
    devices.setDevice('nicounter',counter);
    devices.setDevice('niclock',clock);

    devices.setRole('scan_pos','ni2dposition');
    devices.setRole('scan_clock','niclock');
    devices.setRole('scan_reader','nicounter');
    devices.setRole('scan_trigger','niclock');

    %% Configure device connections.
    pos.xchan='ao0';
    pos.ychan='ao1';
    counter.ctrName='ctr0';
    clock.ctrName='ctr3';
    clockTerm='pfi14';
    triggerTerm=clockTerm;

    pos.triggerTerm=triggerTerm;
    counter.externalClockTerminal=clockTerm;
    
    counter.IgnoreErrors=true;

    %% configuring the data collector.
    info.streamCollector=StreamCollector(devices.get('scan_reader'));
    info.streamCollector.CollectDT=3000;
    info.streamCollector.IntegrateDT=1;

    info.imageCollector=TimedDataCollector(devices.get('scan_reader'));
    info.imageCollector.stop();
    
    %% adding events.
    info.imageCollector.addlistener('TimebinComplete',@updateImageScanData);
    info.imageCollector.addlistener('Complete',@imageComplete);

    %% call configure on devices.
    devices.configureAllRoles();
end

function updateImageScanData(s,e)
    global info;
    try    
        scaninfo=info.get('imageScanInfo',[]);
        if(isempty(scaninfo))
            return;
        end
        info.set('ImageData',StreamToImageData(info.imageCollector.Results,...
            scaninfo.xn,scaninfo.yn,scaninfo.dwellTime));
        info.set('ImageDataLastUpdateTS',now);
    catch err
    end
end

function imageComplete(s,e)
    global info;
    global devices;
    info.imageCollector.stop();
    info.streamCollector.stop();
    info.set('ImageDataLastCompleatedTS',now);
    
    info.streamCollector.stop();
    clock=devices.get('scan_clock');
    reader=devices.get('scan_reader');
    pos=devices.get('scan_pos');
    
    reader.stop();
    clock.stop();
    pos.stop();
    
    disp('Image completed.'); 
end

