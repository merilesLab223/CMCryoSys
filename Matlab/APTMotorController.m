classdef APTMotorController < APTobj
    
    %A subclass to handle things specific to the motor controller
    
    properties
        %Flag to let us know when the move is finished
        moveComplete;
        %Flag to let us know whether we are homed
        isHomed;
        %Restrictions on the travel
        maxTravel = 4;
        minTravel = 0;
        minMove = 60e-6;
        
        currentPosition
        
    end
    
    methods
        %Method to get the current status bits
        function status = getStatus(obj,bits)
            [returnCode,status] = obj.controlHandle.LLGetStatusBits(obj.HWChannel,0);
            %Convert to unsigned unint32
            if(status < 0)
                status = status+2^32;
            end
            status = uint32(status);
            if(nargin>1)
                status = bitget(status,bits);
            end
        end
        
        %Method to home/zero the motor
        %There are many parameters (direction,speed etc) which we should
        %also check
        function moveHome(obj)
            %Reset the flag
            obj.isHomed = 0;
            %Send the command
            obj.controlHandle.MoveHome(obj.HWChannel,0);
            %Wait up to 5 seconds until the event fires letting us know we are homed
            tic;
            while((toc < 5) && (~obj.isHomed))
                pause(0.1)
            end
            if(~obj.isHomed)
                %Try to stop the motor
                obj.stop();
                error('Motor did not finish homing!');
            end
            
            %Update the position and home flag
            obj.currentPosition = obj.getPosition();
            obj.isHomed = obj.getStatus(11);
        end
        
        %Method to setup job parameters
        function initJog(obj,stepSize)
            %SetJogMode(lChanID As Long, lMode As Long, lStopMode) As Long
            %lMode: 1 continuous; 2 single_step
            %StopMode: 1 stop_immediate; 2 stop_profiled
            obj.controlHandle.SetJogMode(obj.HWChannel,2,1);
            obj.controlHandle.SetJogStepSize(obj.HWChannel,stepSize);
        end
        
        %Method to move the motor by a jog
        function moveJog(obj,direction)
            
            %Get current position of motor
            curPos = obj.getPosition();
            
            %Get jog step size
            curStep = obj.getJogStepSize();
            
            %If we aren't going to move too far with the jog then do it
            %MoveJog(lChanID As Long, lJogDir As Long,) As Long
            %lJogDir: 1 forward; 2 reverse
            if(direction == 1)
                if ((curPos + curStep) <= obj.maxTravel)
                    obj.controlHandle.MoveJog(obj.HWChannel,direction);
                end
            elseif(direction == 2)
                if ((curPos - curStep) >= obj.minTravel)
                    obj.controlHandle.MoveJog(obj.HWChannel,direction);
                end
            else
                error('Direction must be defined as 1 or 2.')
            end
        end
        
        %Method to get the current jog step size
        function stepSize = getJogStepSize(obj)
           [returnCode,stepSize] = obj.controlHandle.GetJogStepSize(obj.HWChannel,0);
        end
        
        %Method to move to an absolute position
        function moveAbsolute(obj,position)
            % position:     Absolute position reference from Home,
            %               specified in mm
            
            %Check whether the move distance is greater than the
            %minimum (60nm) and round if necessary
            %First get the current position
            curpos = obj.getPosition();
            moveDist = position-curpos;
            if(abs(moveDist) < obj.minMove/2)
                position = curpos;
            elseif( (moveDist < obj.minMove) && (moveDist > obj.minMove/2))
                position = curpos + obj.minMove;
            elseif( (moveDist > -obj.minMove) && (moveDist < -obj.minMove/2))
                position = curpos - obj.minMove;
            end
            
            % make sure the position is within bounds and that we are
            % actually moving
            if ((position <= obj.maxTravel) && (position >= obj.minTravel) && (curpos ~= position))
                %Reset the MoveComplete flag
                obj.moveComplete = 0;
                
                %Set the position and move
                obj.controlHandle.SetAbsMovePos(obj.HWChannel,position);
                obj.controlHandle.MoveAbsolute(obj.HWChannel,0);
                
                %Wait until the move is complete with a timeout of 5s
                tic;
                while((toc < 5) && (~obj.moveComplete))
                    pause(0.1)
                end
                if(~obj.moveComplete)
                    %Try to stop the motor
                    obj.stop();
                    error('Motor did not finish move! Check to make sure motor is stopped!');
                end
                
                %Update the position
                obj.currentPosition = obj.getPosition(); % in mm
            elseif(curpos == position)
                %Do nothing
            else
                error('Requested position outside of motor range.');
            end
        end
        
        %Method to get the current position
        function curPos = getPosition(obj)
            [returnCode,curPos] = obj.controlHandle.GetPosition(obj.HWChannel,0);
        end
        
        %Method to try and immediately stop the motor
        function stop(obj)
            obj.controlHandle.StopImmediate(obj.HWChannel);
        end
        
        %Method to handle ActiveX events
        function eventHandler(obj,varargin)
            if(strcmp(varargin{end},'MoveComplete'))
                obj.moveComplete = 1;
            elseif(strcmp(varargin{end},'HomeComplete'))
                obj.isHomed = 1;
            elseif(strcmp(varargin{end},'HWResponse'))
                error('APTMotorController fired an HWResponse event which indicates a serious fault.');
            end
        end
        
    end %methods
    
    methods (Access = protected)
        function subInit(obj)
            %Register an eventHandler for all events so we can capture the
            %MoveComplete event.
            obj.controlHandle.registerevent(@obj.eventHandler)
            
            %Check the home status from the status bits
            obj.isHomed = obj.getStatus(11);
            
            %Look for the MaxTravel Preference
            if(isfield(getpref('nv'),'ZMaxTravel'))
                obj.maxTravel = getpref('nv','ZMaxTravel');
            end
            
            
        end
    end
end


