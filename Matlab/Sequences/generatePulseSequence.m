% function PSeq = generatePulseSequence()
% %    [GH_Time,GL_Time,R_Duartion,R_Time,N_Counter,C_Duration,C_Pause] = generateParameters();
%     Channels = generateChannels();
%     Sweeps = generateSweeps(2,'Rise','Duration',1,0,0,1,2,1);
%     PSeq = PulseSequence(Channels,[],Sweeps,0,'');
% end
% function [GH_Time,GL_Time,R_Duration,N_Readout,N_Counter,C_Duration,C_Pause] = generateParameters()
%     GH_Time = 10e-6;        % High Power green duration
%     GL_Time = 2.01e-3;        % Low Power green duration, can be used for any single park
%     R_Duration = 200e-6;    % Red readout pulse duration
%     N_Readout = 10;         % Number of counter pulses during readout   
%     N_Counter = 10;        % Number of counter pulses during park
%     C_Duration = 200e-6;    % Counter pulse duration
%     C_Pause = (GL_Time/N_Counter)-C_Duration;   % Pause between consecutive counter pulses
% end
% 
% function[Channels] = generateChannels()
%     [GH_Time,GL_Time,R_Duration,N_Readout,N_Counter,C_Duration,C_Pause] = generateParameters();
% 
%     % Initialize channels
%     Channels = [PulseChannel(),PulseChannel()];
% %     Channels = [PulseChannel(),PulseChannel(),PulseChannel()];
%     
%     
%     % Set hw channels
%     Channels(1).setHWChannel(2);        % Counter
%     % Channels(2).setHWChannel(13);       % Low Green
%     Channels(2).setHWChannel(3);        % Red
%     % Channels(4).setHWChannel(1);        % High Green
%    
%     % Configure Counter Pulses
%     C_Time = 0;
%     T_Readout = 0;
%     T_Delay = 1e-6;
% 
%     while Channels(1).NumberOfRises < N_Counter + 0
%         Channels(1).addRise();
%     end
%     
%     % Readout during green
%     for C_Loop = 1:N_Counter
%         Channels(1).setRiseParams(C_Loop,C_Time,C_Duration,'Counter',0,0);
%         C_Time = C_Time + C_Duration + C_Pause;
%     end    
%     
%     % Readout during red, pause between the pulses is 100 ns
% %     for C_Loop2 = 1:N_Readout
% %         Channels(1).setRiseParams(N_Counter + C_Loop2,GL_Time + T_Delay + T_Readout,R_Duration,'Counter',0,0);
% %         T_Readout = T_Readout + R_Duration + 1e-7;
% %     end 
%     
%     % Configure Green AOM Pulses
%     Channels(2).addRise();
%     Channels(2).setRiseParams(1,0,GL_Time,'',0,0);
%     
%     % Configure Red AOM Pulses
% %     Channels(3).addRise();
% %     Channels(3).setRiseParams(3,GL_Time + T_Delay,T_Readout,'',0,0);
%     
% end
% 
% 
% function [Sweeps] = generateSweeps(Channel,Class,Type,Rise,StartValue,StopValue,Points,Shifts,Add)
%     Sweeps = PulseSweep();
%     Sweeps.setSweepParams(Channel,Class,Type,Rise,StartValue,StopValue,Points,Shifts,Add);
% end
% 
% function [Groups] = generateGroups()
%         Groups = PulseGroup();
% end

function PSeq = generatePulseSequence()
%    [GH_Time,GL_Time,R_Duartion,R_Time,N_Counter,C_Duration,C_Pause] = generateParameters();
    Channels = generateChannels();
    Sweeps = generateSweeps(2,'Rise','Duration',1,0,0,1,2,1);
    PSeq = PulseSequence(Channels,[],Sweeps,0,'');
end
function [GH_Time,GL_Time,R_Duration,N_Readout,N_Counter,C_Duration,C_Pause,Pulse_Pause] = generateParameters()
    GH_Time = 10e-6;        % High Power green duration
    GL_Time = 2.01e-3;        % Low Power green duration, can be used for any single park
    R_Duration = 200e-6;    % Red readout pulse duration
    N_Readout = 1;         % Number of counter pulses during readout   
    N_Counter = 5;        % Number of counter pulses during park
    C_Duration = 200e-6;    % Counter pulse duration
    C_Pause = 1e-6;   % Pause between consecutive counter pulses
    Pulse_Pause = 1e-6; % Pause between counter pulse trains
end

function[Channels] = generateChannels()
    [GH_Time,GL_Time,R_Duration,N_Readout,N_Counter,C_Duration,C_Pause,Pulse_Pause] = generateParameters();

    % Initialize channels
    Channels = [PulseChannel(),PulseChannel()];
%     Channels = [PulseChannel(),PulseChannel(),PulseChannel()];
    
    
    % Set hw channels
    Channels(1).setHWChannel(2);        % Counter
    % Channels(2).setHWChannel(13);       % Low Green
    Channels(2).setHWChannel(3);        % Red
    % Channels(4).setHWChannel(1);        % High Green
   
    % Configure Counter Pulses
    C_Time = 0;
    T_Readout = 0;
    T_Delay = 1e-6;

    while Channels(1).NumberOfRises < N_Counter*N_Readout
        Channels(1).addRise();
        Channels(2).addRise();
    end
    
    % Readout during green
    for Pulse_Loop = 1:N_Readout
    for C_Loop = 1:N_Counter
        Channels(1).setRiseParams(C_Loop+N_Counter*(Pulse_Loop-1),C_Time,C_Duration,'Counter',0,0);
        Channels(2).setRiseParams(C_Loop+N_Counter*(Pulse_Loop-1),C_Time,C_Duration,'',0,0);
        C_Time = C_Time + C_Duration + C_Pause;
    end 
    C_Time = C_Time - C_Pause + Pulse_Pause;
    end
    
    % Readout during red, pause between the pulses is 100 ns
%     for C_Loop2 = 1:N_Readout
%         Channels(1).setRiseParams(N_Counter + C_Loop2,GL_Time + T_Delay + T_Readout,R_Duration,'Counter',0,0);
%         T_Readout = T_Readout + R_Duration + 1e-7;
%     end 
    
    % Configure Green AOM Pulses
%     Channels(2).addRise();
%     Channels(2).setRiseParams(1,0,GL_Time,'',0,0);
    
    % Configure Red AOM Pulses
%     Channels(3).addRise();
%     Channels(3).setRiseParams(3,GL_Time + T_Delay,T_Readout,'',0,0);
    
end


function [Sweeps] = generateSweeps(Channel,Class,Type,Rise,StartValue,StopValue,Points,Shifts,Add)
    Sweeps = PulseSweep();
    Sweeps.setSweepParams(Channel,Class,Type,Rise,StartValue,StopValue,Points,Shifts,Add);
end

function [Groups] = generateGroups()
        Groups = PulseGroup();
end




