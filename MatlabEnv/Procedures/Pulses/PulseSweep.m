function PulseSweep(ttl,duration,startf,endf,dutyCycle)
    % generates a pulse sweep from the function generator to allow 
    % a ttl pulse sweep.
    
    if(~isa(ttl,'TTLGenerator'))
        error('Object ttl must be of class type TTLGenerator.');
    end
    if(dutyCycle<0 || dutyCycle>1)
        error('Duty cycle is a number between 0 and 1.');
    end
    if(duration<0 || startf<0 || endf<0)
        error('All values must be positive.');
    end
    % generating the pulse sweep.
    % seep is assumed to be linear.
    tfs=1/(startf*ttl.timeUnitsToSecond);
    tfe=1/(endf*ttl.timeUnitsToSecond);
    
    mint=tfs;
    tratio=tfs/tfe;
    if(mint>tfe)
        mint=tfe;
        tratio=1/tratio;
    end
    
    t=0:mint*tratio/100:duration;
    % twice the freqnce since we have both 0 and 1s.
    crp=chirp(t*ttl.timeUnitsToSecond,startf,duration*ttl.timeUnitsToSecond,endf);
    
    % offset to create the duty cycle.
    crp=crp+dutyCycle-0.5;
    crp(crp<0)=-1;
    crp(crp>0)=1;
    [~,ti]=find([0,diff(crp)]>0);
    t=t(ti);
    bi=zeros(size(ti));
    bi(1:2:end)=1;
    bi(2:2:end)=0;
    
    ttl.Set(bi,diff([0,t]));
end

