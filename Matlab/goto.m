function goto(x0,y0,vtm)
    if(~exist('vtm','var'))
        vtm=172;
    end
    
    x0=x0/vtm;
    y0=y0/vtm;
    
    % Initialize the library
    init;

    %% Device preparation.
    % devices - time based;
    pos=ExpCore.GetDevice('ni_analog_pos');
    
    % remove any clock terminals.
    pos.triggerTerm='';
    pos.externalClockTerminal='';
    pos.PositionTOVoltageUnits=172;
    
    pos.setClockRate(1000); % just to get the output fast
    pos.GoTo(x0,y0,100);
    pos.prepare();pos.run();
end

