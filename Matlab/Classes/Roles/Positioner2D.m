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
            data=struct('x',x,'y',y,'t',t,'method',method);
            obj.appendSequence(data,max(t)-t(1));
        end
%         
%         function [x,y,t]=ScanImage(obj,x,y,width,height,nX,nY,dwellTime,varargin)
%             % image scanning should be done by x,y
%             prs=inputParser;
%             prs.addParameter('interpMethod',obj.interpolationMethod);
%             prs.addParameter('multidirectional',obj.multidirectional);
%             prs.parse(varargin{:});
%             
%             % generating the image scan vepsctor matrix.
%             xv=x:width/nX:x+width;
%             yv=y:width/nY:y+height;
%             
%             % generating the y vector locations.
%             y=repmat(yv,length(yv),1); % as matrix.
%             y=reshape(y,[length(y(:)),1]); % matrix to vector.
%             
%             % generating the x vector locations.
%             if(prs.Results.multidirectional)
%                 x=[xv,xv(end:-1:1)]; % splicing.
%                 x=repmat(x,1,ceil(length(yv)/2))';
%                 x=x(1:length(y));
%             else
%                 x=repmat(xv,1,length(yv))';
%             end
% 
%             % creating the time dwell.
%             t=(0:length(y)-1).*dwellTime;
%             
%             [x,y,t]=obj.GoTo(x,y,t,prs.Results.interpMethod);
%         end
    end

end

