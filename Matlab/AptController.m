classdef AptController < handle
    % MATLAB object class for interfacing with ThorLabs APT controller
    % series
    %
    % Jonathan Hodges <jhodges@mit.edu>
    % 5 May 2009
    %
    
    properties
        activeXProgIDSystem
        activeXProgIDMotor
        serialNumber
        MaxTravel = 4;
        MinTravel = 0;
        MinMove = 60e-6;
        CurrentPosition
        figureHandles = [1001,1002];
        systemHandle
        motorHandle
        MotorChannel = 0;
        isHomed = 0;
        MoveComplete = 0;
    end
    
    methods
        function obj = AptController()
            
            % activeX ID string can be found by calling
            % actxcontrollist from matlab prompt
            obj.activeXProgIDSystem ='MG17SYSTEM.MG17SystemCtrl.1';
            obj.activeXProgIDMotor = 'MGMOTOR.MGMotorCtrl.1';
            
            obj.serialNumber = 40819122; % from Apt Config app
        end
            
        function obj = Initialize(obj)
            fprintf('Initializing APT ActiveX Control.....');
            % generate two invisible figure windows
            h = figure(obj.figureHandles(1));
            set(h,'Visible','off');
            h = figure(obj.figureHandles(2));
            set(h,'Visible','off');

            % initiate a local server for the controller
            obj.systemHandle = actxcontrol(obj.activeXProgIDSystem,[0 0 0 0],obj.figureHandles(1));
            obj.motorHandle = actxcontrol(obj.activeXProgIDMotor,[0 0 0 0],obj.figureHandles(2));

            %Register an eventHandler for all events so we can capture the
            %MoveComplete event.  
            obj.motorHandle.registerevent(@obj.eventHandler)
            
            % start the server
            obj.systemHandle.StartCtrl;

            % set the serial numbers of the motors
            obj.motorHandle.HWSerialNum = obj.serialNumber;

            % start the motor server communication
            obj.motorHandle.StartCtrl;
            fprintf('Done.\n');
        end
        
        function moveAbsolute(obj,position)
            % sets the position of the stage and moves
            % returns the object with the current position
            %
            % obj:          AptController object
            %
            % position:     Absolute position reference from Home,
            %               specified in mm
            
                        
            %Check whether the move distance is greater than the
            %minimum (60nm) and round if necessary
            %First get the current position
            curpos = obj.getPosition();
            moveDist = position-curpos;
            if(abs(moveDist) < obj.MinMove/2)
                position = curpos;
            elseif( (moveDist < obj.MinMove) && (moveDist > obj.MinMove/2))
                position = curpos + obj.MinMove;
            elseif( (moveDist > -obj.MinMove) && (moveDist < -obj.MinMove/2))
                position = curpos - obj.MinMove;
            end
            
            % make sure the position is within bounds
            if ((position <= obj.MaxTravel) && (position >= obj.MinTravel) && (curpos ~= position))
                %Reset the MoveComplete flag
                obj.MoveComplete = 0;
                
                %Set the position and move
                obj.motorHandle.SetAbsMovePos(obj.MotorChannel,position);
                obj.motorHandle.MoveAbsolute(obj.MotorChannel,0);

                %Wait until the move is complete with a timeout of 2s
                tic;
                while((toc < 2) && (~obj.MoveComplete))
                    pause(0.1)
                end
                if(~obj.MoveComplete)
                    %Try to stop the motor
                    obj.stop();
                    error('Motor did not finish move! Check to make sure motor is stopped!');
                end
                %Update the position
                obj.CurrentPosition = obj.getPosition(); % in mm
            end
        end
        
        function moveHome(obj)
            % home the motor
            % 
            % Function MoveHome(lChanID As Long, bWait As Boolean) As Long
            % 
            % 
            % Parameters
            % 
            % lChanID - the channel identifier
            % bWait - specifies the way in which the MoveHome method returns
            % 
            % 
            % Returns
            % 
            % MG Return Code 
            obj.motorHandle.MoveHome(obj.MotorChannel,0);
            obj.waitUntilJogFinished();
            obj.CurrentPosition = 0;
            obj.isHomed = 1;
        end 
        
       function initJog(obj,stepSize)
           
           obj.motorHandle.SetJogMode(obj.MotorChannel,2,1);
           obj.motorHandle.SetJogStepSize(obj.MotorChannel,stepSize);
       end
       
       function moveJog(obj)
           
           % get current position of motor
           pos = obj.getPosition();
           
           % get jog step size
           step = obj.getJogStepSize();
           
           if ((pos + step) <= obj.MaxTravel)
               obj.motorHandle.MoveJog(obj.MotorChannel,1);
           end
       end
       
       function stop(obj)
           obj.motorHandle.StopImmediate(obj.MotorChannel);
       end
       
       function [p] = getPosition(obj)
           p = obj.motorHandle.GetPosition_Position(obj.MotorChannel);
       end
       
       function [s] = getJogStepSize(obj)
           s = obj.motorHandle.GetJogStepSize_StepSize(obj.MotorChannel);
       end
       
       function [s] = getStatus(obj)
           s = obj.motorHandle.GetStatusBits_Bits(obj.MotorChannel);
       end
       
       function [] = waitUntilJogFinished(obj)
           a = true;
           while a,
               s = obj.getStatus();
               S = int32(-s);
               if rem(s,2^8) == 0,
                   break;
               end
           end
       end
           
       function delete(obj)
            % destructor method
            %
             %Unregister the event listeners
            if(~isempty(obj.motorHandle))
                obj.motorHandle.unregisterallevents;
            end
            % stop communication to Active X servers
            if obj.motorHandle,
            obj.motorHandle.StopCtrl;
            end
            if obj.systemHandle,
            obj.systemHandle.StopCtrl;
            end
            
            % destroy ActiveX windows
            close(obj.figureHandles);       
        end %delete
   
        %Method to handle ActiveX events
        function eventHandler(obj,varargin)
            if(strcmp(varargin{end},'MoveComplete'))
                obj.MoveComplete = 1;
            end
        end
   
    end % methods 
    
        
   
            
        
end %classdef
