function goto(x0,y0,vtm)

    if(~exist('vtm','var'))
        vtm=172;
    end
    
    x0=x0/vtm;
    y0=y0/vtm;
    
    % Initialize the library
    InitZLib;
    clear pos;
    clear reader;
    clear clock;
    daq.reset();

    %% Device preparation.
    % devices - time based.
    useAnalog=1;

    pos=NI6321Positioner2D('Dev1');
    clock=NI6321Clock('Dev1'); % loopback clock.

    pos.xchan='ao0';
    pos.ychan='ao1';
    clock.ctrName='ctr3';
    clockTerm='pfi14';
    triggerTerm=clockTerm;

    pos.triggerTerm=triggerTerm;

    crate=2000;
    clockfreqToRate=2;
    cfreq=crate*clockfreqToRate;

    % adjusted to clock.
    pos.setClockRate(crate);
    clock.setClockRate(crate); % clock output can be slower since freq.
    clock.clockFreq=cfreq;

    pos.GoTo(x0,y0,100);
    pos.prepare();
    clock.prepare();
    pos.run();
    clock.run();
end

