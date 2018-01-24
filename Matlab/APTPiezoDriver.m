classdef APTPiezoDriver < APTobj
    
    %A subclass to handle things specific to the piezo driver
    properties
        %Control Mode enumeration: 1 open; 2 closed (needs strain gauge)
        controlMode = 0;
        
        %Strain gauge associated with this driver
        strainGauge
        
        %Current position in microns
        currentPosition;
        
        %Max and min travel (microns)
        maxTravel;
        minTravel = 0;
        
        %Correction table function handle and inverse
        corrTab
        invCorrTab
        
        
        %Maximum distance (microns) from asked one before spitting out error
        maxPosError = 0.05; 
        
        % Other Variables
        jogStepSize   % jog step size
        loopPropConst % PID Proportional constnat
        loopIntConst  % PID Integral constant
        displayInt    % T-Cube display intensity
        analogInMode  % Input mode for analog, open loop control
        hubAnalogInput % 1 = paired, 2 = through all (for APT Cube Hub only)
        
    end
    
    methods
        %Method to change between open and closed loop control
        %
        % valid values
        %  1	OPEN_LOOP               No feedback
        %
        %  2	CLOSED_LOOP             Position feedback
        %
        %  3	OPEN_LOOP_SMOOTH        No feedback. Transition from closed
        %                               to open loop is achieved over a longer period 
        %                               in order to minimize voltage transients (spikes).
        %
        %  4	CLOSED_LOOP_SMOOTH      Position feedback. Transition from closed to 
        %                               open loop is achieved over a longer period in 
        %                               order to minimize voltage transients (spikes).
        function setControlMode(obj,mode)
            obj.controlHandle.SetControlMode(obj.HWChannel,mode);
        end
        
        %Method to get the current control mode
        function curMode = getControlMode(obj)
            [returnCode,curMode] = obj.controlHandle.GetControlMode(obj.HWChannel,0);
        end
        
        %Method to set the current position
        function setPosOutput(obj,newPos)
            if( (newPos <= obj.maxTravel) && (newPos >= obj.minTravel))
                
                %Use the corrTab to correct the newPos and
                %Convert the position to a percentage of maxTravel
                correctedPos = 100*obj.corrTab(newPos)/obj.maxTravel;
                
                %Set it 
                obj.controlHandle.SetPosOutput(obj.HWChannel,correctedPos);
                
            else
                error('Trying to reach position with Piezo Driver outside allowed range.')
            end
            %Wait for it to reach it with a 5 second timeout 
            tic;
            pause(0.1);
            while (( toc < 10) && (abs(obj.getPosition() - newPos) > obj.maxPosError))
                pause(1);
            end
            if(toc > 10)
                warning('Unable to reach specified position with piezo to within tolerance.\n Requested position: %f; actual position: %f',newPos,obj.getPosition());
            end
            %Update the current position
            obj.currentPosition = obj.getPosition();
         end
        
        %Method to get the current position from the strainGauge
        function curPos = getPosition(obj)
            %Go back through corrtab
            [resultCode,curPos] = obj.controlHandle.GetPosOutput(obj.HWChannel,0);
            curPos = obj.invCorrTab(obj.maxTravel*curPos/100);
            
            %More accurate to get it from strain gauge
            %But Strain gauge is a piece of junk and crashes all the time
            %curPos = obj.strainGauge.getReading();
        end
        
        function setJogStepSize(obj)
        end
        
        function setAnalogInputSource(obj)
            % valid arguments
            %
            % 1	INPUT_SWONLY        Unit responds only to software inputs and 
            %                       the HV amp output is that set using the SetVoltOutput method.
            %
            % 2	INPUT_POSEXTBNC     Unit sums the positive analog signal on the
            %                       rear panel BNC connector with the voltage set using the SetVoltOutput method
            %
            % 3	INPUT_NEGEXTBNC     Unit sums the negative analog signal on the 
            %                       rear panel BNC connector with the voltage set using the SetVoltOutput method
            
            if ~isempty(intersect(obj.analogInMode,[1,2,3])), % check for valid mode
                obj.controlHandle.SetIPSource(obj.HWChannel,obj.analogInMode);
            end
        end
        
        function setHubAnalogInput(obj,mode)
            % valid values
            %
            %  1	HUB_ANALOGUEIN_1	Feedback signals run between adjacent 
            %                           pairs of T-Cube bays(i.e. 1&2, 3&4, 5&6)
            %
            %  2	HUB_ANALOGUEIN_2	Feedback signals run through all T-Cube bays.
            
            if ~isempty(intersect(mode,[1,2])), % check for valid mode
                obj.hubAnalogInput = mode;
                %obj.controlHandle.SetHubAnalogueChanIn(obj.HWChannel,obj.hubAnalogInput);
                % GRRR! Apt Server Help file says SetHubAnalogueChanIn
                % exists, but MATLAB denies it
                
                % try SetExtAnalogueInput
                obj.controlHandle.SetExtAnalogueInput(obj.HWChannel,obj.hubAnalogInput);

            end
        end
        
        function setVoltageOutputLimit(obj)
        end
        
        function zeroPosition(obj)
            obj.controlHandle.ZeroPosition(0);
        end
        
        function setDisplayIntensity(obj)
        end
        
        %Method to handle ActiveX events
        function eventHandler(obj,varargin)
            if(strcmp(varargin{end},'HWResponse'))
                error('APTPiezoDriver fired an HWResponse event which indicates a serious fault.');
            end
        end
        
        
    end %methods
    
    methods (Access = protected)
        function subInit(obj)
            %Register an eventHandler for all events so we can capture the
            %MoveComplete event.
            obj.controlHandle.registerevent(@obj.eventHandler)
            
            %Check the current control mode status
            obj.controlMode = obj.getControlMode;
            
            %Check the maximum travel allowed
            obj.maxTravel = obj.strainGauge.getMaxTravel();
            
            %Try to load the corrtab
            if(isfield(getpref('nv'),'ZPiezoCorrTab'))
                obj.corrTab = getpref('nv','ZPiezoCorrTab');
                obj.invCorrTab = getpref('nv','ZPiezoInvCorrTab');
            else
                obj.corrTab = @(x)(x);
                obj.invCorrTab = @(x)(x);
            end
        end
    end
    
end
