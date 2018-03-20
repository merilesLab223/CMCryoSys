classdef NI6321Positioner2D < NI6321Core & Positioner2D
    %NI6321POSITIONER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        % constructor, and send info to parent.
        function obj = NI6321Positioner2D(varargin)
            obj=obj@NI6321Core(varargin);
        end
    end
    
    properties
        xchan='ao0';
        ychan='ao1';

        niXChannel=[];
        niYChannel=[];
        
        totalExecutionTime=0;
    end
    
    properties (Access = protected)
        pendingSequence=[];
    end
    

    % device methods
    methods
        function configureDevice(obj)
            % find the NI devie.
            obj.validateSession();
            s=obj.niSession;
            
            % adding channels.
            obj.niXChannel=s.addAnalogOutputChannel(obj.niDevID,obj.xchan,'Voltage');
            obj.niYChannel=s.addAnalogOutputChannel(obj.niDevID,obj.ychan,'Voltage');
            
        end

        % used to call a position event. 
        % the position event will be called to execute data.
        function prepare(obj)
            % call base class.
            prepare@NI6321Core(obj);
            s=obj.niSession;
            data=obj.compile();
            spath=size(data);
            obj.totalExecutionTime=spath(1)*obj.getTimebase(); % in ms.
            
            % pushing data.
            s.queueOutputData(data);
            
            % prepare the session.
            s.prepare();
        end
        
        function run(obj)
            if(obj.totalExecutionTime<=0)
                return;
            end
            obj.niSession.startBackground();
        end        
    end
    
    
    % compilation ovveride
    methods
        % dose the sequence compilation.
        function [rslt]=compileSequence(obj,timestamps,data)
            % creating the data vectors according to 
            t=[];x=[];y=[]; % time vector is to identify duplicates.
            for i=1:length(timestamps)
                idata=data{i};
                tv=timestamps(i)+idata.t; % current time vector.
                tspan=min(tv):obj.getTimebase():max(tv);
                lt=length(tspan);
                % interpolating
                if(lt==0)continue;end
                if(lt>1)
                    xv=interp1(tv,idata.x,tspan,idata.method);
                    yv=interp1(tv,idata.y,tspan,idata.method);                    
                else
                    xv=idata.x;
                    yv=idata.y;
                end
                
                % appending
                t(end+1:end+lt)=tspan;
                x(end+1:end+lt)=xv;
                y(end+1:end+lt)=yv;
            end
            
            % removing doplicates and sorting.
            [t,sidx]=unique(t,'last');
            x=x(sidx);
            y=y(sidx);
            
            % remaking the final vector. (In timeunits of seconds.
            tspan=0:obj.getTimebase():max(t);
            x=interp1(t,x,tspan,'previous');
            y=interp1(t,y,tspan,'previous');
            rslt=[x',y'];
        end        
    end    
end

