classdef Positioner2D < TimeBasedSignalGenerator
    %POSITIONER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % A number or a function that describes the position
        % values to scaling values. 
        % Example: 
        positionScaling=1;
        
        % the interpolation method to be used between the data
        % points. See interp1 for more info.
        interpolationMethod='linear';
        
        % if true then the image scan is multidirectional.
        multidirectional=true;
    end
    
    properties (Access = protected)
        % the path data to execute.
        path=[];
    end
    
    % path methods
    methods
        % adds a path as a matrix to the current path.
        function [path]=addPath(obj,data)
            if(length(size(data))~=2)
                error('Path data must consist of a [[...],[...]] for x,y column vectors. For other data types see GoTo Function.');
            end
            if(isempty(obj.path))
                obj.path=data;
            else
                sdata=size(data);
                lp=length(obj.path(:,1));
                obj.path(lp+1:lp+sdata(1),1)=data(:,1);
                obj.path(lp+1:lp+sdata(1),2)=data(:,2);
            end
        end
        
        % clear the current path.
        function clearPath(obj)
            obj.path=[];
        end
        
        % returns the path vectors
        function [x,y,t]=getPathVectors(obj)
            x=obj.path(:,1);
            y=obj.path(:,2);
            t=(1:length(x))*obj.getTimebase();
        end
        
        % returns the path as a matrix, that can be stored to another
        % location. Allows for the storing of specific paths for specific
        % timepases.
        function [info]=getPathInfo(obj)
            info={};
            info.data=obj.path;
            info.timebase=obj.getTimeBase();
        end
        
        % Sets/Appends the path to execute. If timebase dose not match then
        % the path is translated to the new timebase.
        function setPathInfo(obj,info,append)
            if(~exist('append','var'))append=1;end
            
            % clearing the current.
            if(~append)
                obj.clearPath();
            end
            
            if(info.timebase~=obj.getTimebase())
                % need to change the path to the new timebase.
                x=info.data(:,1);
                y=info.data(:,2);
                t=(1:length(x))*info.timebase;
                obj.GoTo(x,y,t);
            else
                obj.addPath(info.data);
            end
        end
    end
    
    % Position methods
    methods
        % Tells the positioner to perform a path.
        function [x,y,t]=GoTo(obj,x,y,t,method)
            data=[];
            if(~exist('t','var'))
                % only x and y. Minimal timeframe assummed.
                data=[x,y];
                t=([1:length(x)]-1)*obj.getTimebase();
            else
                % need to interpolate.
                if(~exist('method','var'))
                    method=obj.interpolationMethod;
                end
                % spanning t;
                t=t./1000; % source is in miliseconds and timebase is in seconds.
                ti=min(t):obj.getTimebase():max(t);
                x=interp1(t,x,ti,method);
                y=interp1(t,y,ti,method);
                t=ti*1000; % back to ms.
                data=[x',y'];
            end
            obj.addPath(data);            
        end
        
        function [x,y,t]=Hold(obj,dwell)
            t=0:obj.getTimebase()*1000:dwell;
            curpos=obj.path(end,:);
            holdData=repmat(curpos,length(t),1);
            x=holdData(:,1);
            y=holdData(:,2);
            obj.addPath(holdData);
        end
        
        function [x,y,t]=ScanImage(obj,x,y,width,height,nX,nY,dwellTime,varargin)
            % image scanning should be done by x,y
            prs=inputParser;
            prs.addParameter('interpMethod',obj.interpolationMethod);
            prs.addParameter('multidirectional',obj.multidirectional);
            prs.parse(varargin{:});
            
            % generating the image scan vepsctor matrix.
            xv=x:width/nX:x+width;
            yv=y:width/nY:y+height;
            
            % generating the y vector locations.
            y=repmat(yv,length(yv),1); % as matrix.
            y=reshape(y,[length(y(:)),1]); % matrix to vector.
            
            % generating the x vector locations.
            if(prs.Results.multidirectional)
                x=[xv,xv(end:-1:1)]; % splicing.
                x=repmat(x,1,ceil(length(yv)/2))';
                x=x(1:length(y));
            else
                x=repmat(xv,1,length(yv))';
            end

            % creating the time dwell.
            t=(1:length(y)).*dwellTime;
            
            [x,y,t]=obj.GoTo(x,y,t,prs.Results.interpMethod);
        end
    end
end

