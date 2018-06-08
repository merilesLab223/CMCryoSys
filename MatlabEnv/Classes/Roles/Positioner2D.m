classdef Positioner2D < TimeBasedSignalGenerator
    %POSITIONER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % A number or a function that describes the position
        % values to scaling values. 
        % Example: 
        PositionTOVoltageUnits=1;
        
        % if true invers the x and y positions.
        InvertXY=false;
        
        % the interpolation method to be used between the data
        % points. See interp1 for more info.
        interpolationMethod='linear';
        
        % if true then the image scan is multidirectional.
        multidirectional=true;
    end
    
    % compiled data helper methods
    methods     
        % returns the path vectors
        % !!requires compilation if anything changed!!
        function [x,y,t]=getCompiledPathVectors(obj)
            rslt=obj.compile();
            x=rslt(:,1);
            y=rslt(:,2);
            t=(0:(length(x)-1))*obj.getTimebase();
        end
    end
    
    % Position methods
    methods
        % Tells the positioner to perform a path.
        function [x,y,t]=GoTo(obj,x,y,t,method)
            if(~exist('method','var'))method=obj.interpolationMethod;end
            % appnding sequence.
            if(~exist('t','var'))
                % only x and y. Minimal timeframe assummed.
                t=([0:length(x)-1])*obj.getTimebase();
            end
            obj.toRounded();
            
            ptvx=obj.PositionTOVoltageUnits(1);
            
            if(length(obj.PositionTOVoltageUnits)>1)
                ptvy=obj.PositionTOVoltageUnits(2);
            else
                ptvy=ptvx;
            end
            x=x.*ptvx;
            y=y.*ptvy;
            
            if(obj.InvertXY)
                dump=x;
                x=y;
                y=dump;
            end
            
            data=struct('x',x,'y',y,'t',t,'method',method);
            obj.appendSequence(data,max(t)-t(1));
        end
        % returns the minimal time between two positions not including
        % zeros. (Overriden)
        
        function [mint]=findMinimalTime(obj)
            [~,data]=obj.getRawSequence();
            t=[];
            for i=1:length(data)
                d=data{i};
                lt=length(d.t);
                t(end+1:end+lt)=d.t;
            end
            t=sort(t);
            dt=diff(t);
            dt(dt==0)=[];
            if(isempty(dt))
                mint= obj.getTimebase();
                return;
            end
            mint=min(dt);
        end
    end

end

