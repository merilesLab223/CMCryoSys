classdef Positioner2D < TimedDataStream & TimeBasedObject
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
    
    properties(SetAccess = private)
        m_p2dStreamT=[];
        m_p2dStream=[];
    end
    
    % compiled data helper methods
    methods     
        % returns the path vectors
        % !!requires compilation if anything changed!!
        function [x,y,t]=getPathVectors(obj)
            [st,strm]=obj.getTimedStream();
            % colecting all x,y,t;
            x=[];
            y=[];
            t=[];
            for i=1:length(strm)
                si=strm{i};
                to=st(i);
                if(isstruct(si))
                    continue;
                end
                
                li=length(si(:,1));
                ti=to+cumsum(si(:,1));
                xi=si(:,2);
                yi=si(:,3);
                
                t(end+1:end+li)=ti;
                x(end+1:end+li)=xi;
                y(end+1:end+li)=yi;
            end
            
            x=x';
            y=y';
            t=t';
        end
        
        function [t,strm]=getTimedStream(obj)
            % returns the timed stream as was compiled by the positioner2D.
            if(obj.IsTimedDataStreamValid)
                t=obj.m_p2dStreamT;
                strm=obj.m_p2dStream;
                return;
            else
                obj.m_p2dStreamT=[];
                obj.m_p2dStream={};
            end
            
            try
                [t,strm]=getTimedStream@TimedDataStream(obj);
                [t,strm]=obj.compilePath(t,strm);
            catch err
                obj.InvalidateTimedStream;
                rethrow(err);
            end
            
            % interpolating if needed.
            obj.m_p2dStreamT=t;
            obj.m_p2dStream=strm;
        end
    end
    
    methods(Access = protected)
        function [t,strm]=compilePath(obj,t,strm)
            % compiles the path and interpolates according to the
            % interpolation method.
            
            % compiling the path and adjusting it to the rate.
            method=obj.interpolationMethod;
            for i=1:length(t)
                ti=t(i);
                si=strm{i};
                if(isstruct(si))
                   % this is an instruction.
                   itype='[No type]';
                   if(isfield(si,'type'))
                       itype=si.type;
                   end
                   switch(itype)
                       case 'interp'
                           method=si.method;
                       otherwise
                           warning(['Unknown instruction type: ',type]);
                   end
                   % nothing else to do.
                   continue;
                end
                if(~ismatrix(si))
                    error(['Unuseable type when translating stream, ',class(si)]);
                end
                
                % compiling the path according to the time vectors.
                trem=rem(ti,obj.getTimebase());
                tv=[0;cumsum(si(1:end-1,1))]+ti;
                xv=si(:,2);
                yv=si(:,3);
                
                itv=(tv(1)-trem):obj.getTimebase():tv(end);
                if(length(xv)==1)
                    itv=tv(1)-trem;
                else
                    xv=interp1(tv,xv,itv,method,'extrap');
                    yv=interp1(tv,yv,itv,method,'extrap');                    
                end
                si=zeros(length(itv),3);
                si(:,1)=[0,diff(itv)];
                si(:,2)=xv;
                si(:,3)=yv;
                strm{i}=si;
            end
        end
    end
    
    % Position methods
    methods
        function [x,y,t]=GoTo(obj,x,y,t,method)
            % Inserts a path into the positioner queue.
            
            if(~exist('method','var'))
                method=obj.interpolationMethod;
            end
            
            % appnding sequence.
            if(~exist('t','var'))
                % only x and y. Minimal timeframe assummed.
                t=obj.curT+([0:length(x)-1])*obj.getTimebase();
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
            
            if(~iscolumn(x))
                x=x';
            end
            if(~iscolumn(y))
                y=y';
            end
            
            if(~iscolumn(t))
                t=t';
            end
            
            obj.SetTimedEvent(obj.curT,struct('type','interp','method',method));
            obj.SetTimedData(t+obj.curT,[x,y]);
            obj.wait(max(t)-min(t));
        end
    end

end

