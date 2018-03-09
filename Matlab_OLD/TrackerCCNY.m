classdef TrackerCCNY < Tracker
    
    properties
        LaserControlLine
        ZTracking = PIControl();
    end
    
   methods
        function [obj] = TrackerMIT()
            addlistener(obj,'TrackerAbort',@(src,evnt)obj.setAbort);
        end
        
        function [counts] = GetCountsCurPos(obj)
            
            % first turn on the laser
            obj.laserOn();
            pause(.5);
            % next do the counter acquisition
           	obj.hCounterAcquisition.GetCountsPerSecond();
            counts = obj.hCounterAcquisition.CountsPerSecond();
            
            
            % turn off the laser
            obj.laserOff();
        end
        
        function [counts] = GetCountsAtPos(obj,Pos)
            counts = 0;
            obj.hImageAcquisition.CursorPosition = Pos;
            obj.hImageAcquisition.SetCursor();
            [counts] = obj.GetCountsCurPos();
        end
        
        function [] = laserOn(obj)
            obj.hwLaserController.stop();
            obj.hwLaserController.setLines(1,1);
            obj.hwLaserController.start();
        end
        
        function [] = laserOff(obj)
            obj.hwLaserController.stop();
            obj.hwLaserController.setLines(0,1);
            obj.hwLaserController.start();
        end
        
        %First Attempt at Z Tracking, iterates through points from -.3 to
        %.3 at .1 steps,
        %gets the counts and position at each
        %point, and finds the maximum counts. It then sets the Z equal to
        %the corresponding position. This doubtfully the most effcient
        %Z Tracking.
        function [] = ZTrack(obj)
           
            obj.ZTracking.initialize();
            ZCounts = zeros(7,2);
            i = 1;
            CurrentPosition = obj.ZTracking.GetCurrentPosition();
            obj.ZTracking.SetPosition(CurrentPosition - .6);
            while(i<=7)
                
                ZCounts(i,1) = obj.GetCountsCurPos();
                ZCounts(i,2) = obj.ZTracking.GetCurrentPosition();
                obj.ZTracking.SetPosition(ZCounts(i,2) +.2);
                i = i + 1;
                
            end
            
            [counts,index] = max(ZCounts(:,1));
            disp(ZCounts);%outputs the Z information to the console
            obj.ZTracking.SetPosition(ZCounts(index,2));%sets the Z position to the optimal value
            
            
            obj.ZTracking.destroy();%closes communication with the PI
        end
        
        function [] = trackCenter(obj)
            
           
                % set up initial step sizes
                obj.CurrentStepSize = obj.InitialStepSize;

                % setup local vars
                iterCounter = 0;

                % get current position from ImageAcquistion
                Pos = obj.hImageAcquisition.CursorPosition;


                StepXMin = obj.MinimumStepSize(1);
                StepYMin = obj.MinimumStepSize(2);
                %StepZMin = obj.MinimumStepSize(3);

                % main while loop for tracking center logic
                % as long as we haven't aborted or iterated too much or took
                % too small of a step, keep taking gradients and maximize the
                % counts

%                 while (~obj.hasAborted && (iterCounter < obj.MaxIterations) && (obj.CurrentStepSize(1) > StepXMin) && ...
%                     (obj.CurrentStepSize(2) > StepYMin) && (obj.CurrentStepSize(3) > StepZMin) &&~obj.hasAborted )
                 while (~obj.hasAborted && (iterCounter < obj.MaxIterations) && (obj.CurrentStepSize(1) > StepXMin) && ...
                        (obj.CurrentStepSize(2) > StepYMin))
                    % define local vars
                    PosX = Pos(1);
                    PosY = Pos(2);
                    %PosZ = Pos(3);

                    %iterate the counter
                    iterCounter = iterCounter + 1;

                    % setup the nearest neighbor points
                    Nearest(1,:) = [PosX,PosY];
                    Nearest(2,:) = [PosX,PosY] + [obj.CurrentStepSize(1),0];
                    Nearest(3,:) = [PosX,PosY] + [-obj.CurrentStepSize(1),0];
                    Nearest(4,:) = [PosX,PosY] + [0,obj.CurrentStepSize(2)];
                    Nearest(5,:) = [PosX,PosY] + [0,-obj.CurrentStepSize(2)];
                    %Nearest(6,:) = [PosX,PosY,PosZ] + [0,0,obj.CurrentStepSize(3)];
                    %Nearest(7,:) = [PosX,PosY,PosZ] + [0,0,-obj.CurrentStepSize(3)];

                    % check to see if any of the nearest points are over max.
                    % allowed positions
                    if (any(Nearest(:,1)>obj.MaxCursorPosition(1)) || any(Nearest(:,2)>obj.MaxCursorPosition(2)))
                        warning('Position over allowed max');
                        break;
                    end
                    if (any(Nearest(:,1)<obj.MinCursorPosition(1)) || any(Nearest(:,2)<obj.MinCursorPosition(2)))
                        warning('Position over allowed min');
                        break;
                    end

                    % iterate though the NN points, getting counts
                    for k=1:5,
                            thisPos = [Nearest(k,:),0];
                        NNCounts(k) =  GetCountsAtPos(obj,thisPos);
                    end

                    % throw event that counts have been updated;
                    notify(obj,'TrackerCountsUpdated',TrackerEventData(NNCounts));

                    % apply a threshold to the obtained NN counts
                    deltaNNCounts = NNCounts - NNCounts(1);
                    [Inds] = find( deltaNNCounts > obj.TrackingThreshold);

                    % create a boolean vector of the points above the threshold
                    % only these are included in the gradient calcualtion
                    bThresh = zeros(1,5);
                    bThresh(Inds) = 1;

                     % 3D deformed to 1D steps
                    stepVec = [1 obj.CurrentStepSize(1),...
                        -obj.CurrentStepSize(1),obj.CurrentStepSize(2),-obj.CurrentStepSize(2)];

                    % calculate the Gradient Directions 
                    gradVec = (deltaNNCounts./stepVec).*bThresh;

                     % If no points greater than threshold, keep orginal reference
                    if  sum(bThresh)==0,
                        % If Ref. Position did not change, reduce the step sizes
                        obj.CurrentStepSize = obj.CurrentStepSize.*obj.StepReductionFactor;
                        notify(obj,'StepSizeReduced',TrackerEventData([obj.CurrentStepSize,0]));
                    else % calculate the new maximum point, climb the hill

                        % Update the reference position
                        G = [gradVec(2) + gradVec(3),gradVec(4)+gradVec(5)];

                        % seems to be a bug with G/norm(G) giving NaN, so check to make
                        % sure the numbers are non-zero
                        if norm(G) < 1e-8

                        else
                           [Pos] = [PosX,PosY] + G/norm(G).* ...
                                [obj.CurrentStepSize(1),obj.CurrentStepSize(2)];
                            notify(obj,'PositionUpdated',TrackerEventData([Pos,0]));
                        end
                    end                

                end % main while loop
                
                
                if obj.hasAborted,
                    obj.hImageAcquisition.CursorPosition = Pos;
                    obj.hImageAcquisition.SetCursor();
                    obj.hasAborted = 0;
                else
                    % update Cursor to final tracked position
                    obj.hImageAcquisition.CursorPosition = [PosX,PosY,0];
                    obj.hImageAcquisition.SetCursor();
                end
                obj.ZTrack();
        end % trackCenter
        
        function setAbort(obj,evnt)
            obj.hasAborted = 1;
        end
        
   end
    
   events
       TrackerCountsUpdated
       StepSizeReduced
       PositionUpdated
       TrackerAbort
   end
end