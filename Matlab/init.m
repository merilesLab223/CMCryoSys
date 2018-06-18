% Calls to include all the code in the associated libreries of Zav\Code
% in the dropbox.
function init()
    % validating the and the experiment systemn.
    initializeExperimentControl();
    niDevName='Dev1';
    devs=ExpCore.GetDevices();
    
    % Hardware connections.
    % port0/line1 ->USER1 ->PFI0 : Trigger.
    % pfi15->pfi14 : Clock loopback.
    % pfi8 (counter 0)->User2 : counter input)
    dev_posDevName='ni_analog_pos';
    dev_analogReaderDevName='ni_analog_reader';
    dev_countReaderDevName='ni_counter_reader';
    dev_niClock='ni_clock';
    dev_pbClock='pb_clock';
    dev_pbFunctionGen='pb_fg';
        
    % adding devices. 
    if(~devs.contains(dev_posDevName))
        dev=NI6321Positioner2D(niDevName);
        devs.set(dev_posDevName,dev);
        dev.xchan='ao0';
        dev.ychan='ao1';
    end

    % configuring analog reader.
    if(~devs.contains(dev_analogReaderDevName))
        dev=NI6321AnalogReader(niDevName);
        devs.set(dev_analogReaderDevName,dev);
        dev.readchan='ai0';
    end

    % configuring counter reader.
    if(~devs.contains(dev_countReaderDevName))
        dev=NI6321Counter(niDevName);
        devs.set(dev_countReaderDevName,dev);
        dev.ctrName='ctr0';
    end

    % configuring internal clock (ni).
    if(~devs.contains(dev_niClock))
        dev=NI6321Clock(niDevName);
        devs.set(dev_niClock,dev);
        dev.ctrName='ctr3';
    end

    % configuring pb clock.
    if(~devs.contains(dev_pbClock))
        dev=SpinCoreClock();
        devs.set(dev_pbClock,dev);
        %dev.setClockRate(300e6);
    end
    
    if(~devs.contains(dev_pbFunctionGen))
        dev=SpinCoreTTLGenerator();
        devs.set(dev_pbFunctionGen,dev);
        %dev.setClockRate(300e6);
    end
end