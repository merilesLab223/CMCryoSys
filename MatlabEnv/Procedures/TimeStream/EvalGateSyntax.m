function [strm] = EvalGateSyntax(gate,code,pmap,channelmap)
    %Evaluates the code for a gate stream syntax.
    % core functions.
    up=@(c)gate.Up(c);
    down=@(c)gate.Down(c);
    startLoop=@(n)gate.StartLoop(n);
    endLoop=@()gate.EndLoop();
    wait=@(ms)gate.wait(ms);
    goBackInTime=@(ms)gate.goBackInTime(ms);
    pulse=@(varargin)gate.Pulse(varargin{:});
    clock=@(varargin)gate.ClockSignal(varargin{:});
    
    % channel mapping. Compose channel values.
    if(exist('channelmap','var'))
        ceval='';
        for key=channelmap.keys
            key=key{1};
            ceval=[ceval,'c_',key,'=',num2str(channelmap(key)),';',newline];
        end
        eval(ceval);
    end
    
    if(exist('pmap','var'))
        ceval='';
        for key=pmap.keys
            key=key{1};
            ceval=[ceval,'p_',key,'=',num2str(channelmap(key)),';',newline];
        end
        eval(ceval);
    end
    
    % store old params.
    oldAutoAdvance=gate.AutoAdvanceTimes;
    
    % set new params;
    gate.AutoAdvanceTimes=false;
    
    % clear the gate.
    gate.clear();
    
    % evaluating the code.
    eval(code);
    
    % set back params.
    gate.AutoAdvanceTimes=oldAutoAdvance;
end

