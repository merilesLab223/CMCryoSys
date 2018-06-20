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

    % adding devices. 
    % positioner.
    devs.getOrCreate('NI6321Positioner2D',...
        'xchan','ao0','ychan','ao1','niDevID',niDevName);
    % analog reader.
    NI6321AnalogReader
    devs.getOrCreate('NI6321AnalogReader',...
        'readchan','ai0','niDevID',niDevName);
    % input counter.
    devs.getOrCreate('NI6321Counter',...
        'ctrName','ctr0','niDevID',niDevName);   
    % Ni clock.
    devs.getOrCreate('NI6321Clock',...
        'ctrName','ctr3','niDevID',niDevName);       
    % Pulse blaster clock.
    devs.getOrCreate('SpinCoreClock');  
    % Pulse blaster ttl generator.
    devs.getOrCreate('SpinCoreTTLGenerator');  
end