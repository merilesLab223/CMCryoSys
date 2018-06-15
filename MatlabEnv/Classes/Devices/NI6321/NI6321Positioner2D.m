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
        totalExecutionTime=0;
    end
    
    properties(SetAccess = protected)
        ChannelVolategeRange=[-10,10];
    end
    
    properties (Access = protected)
        pendingSequence=[];
    end
    

    % device methods
    methods (Access = protected)
        function configureDevice(obj)
            % find the NI devie.
            obj.validateSession();
            s=obj.niSession;
            [cx]=s.addAnalogOutputChannel(obj.niDevID,obj.xchan,'Voltage');
            [cy]=s.addAnalogOutputChannel(obj.niDevID,obj.ychan,'Voltage');
        end
        
        function doResetSingleScan(obj)
            s=obj.niSession;
            obj.clearTirggerTerms();
            obj.clearClockTerms();
            oldRate=obj.Rate;
            s.Rate=1000;
            s.queueOutputData(zeros(100,2));
            s.prepare();
            obj.single();
            s.Rate=oldRate;
        end
    end
    
    methods
        % used to call a position event. 
        % the position event will be called to execute data.
        function prepare(obj)
            % call base class.
%             if(obj.isConfigured)
%                 obj.doResetSingleScan();
%             end
            prepare@NI6321Core(obj,true);
            s=obj.niSession;
            data=obj.compile();
            spath=size(data);
            obj.totalExecutionTime=spath(1)*obj.getTimebase(); % in ms.
            
            % padding with zeros.
            if(obj.totalExecutionTime<=0)
                return;
            end
            
            %totalSec=obj.timebaseToSeconds(obj.totalExecutionTime);
            missing=2;
            missing=missing*obj.Rate;
            if(missing>0)
                mdata=repmat(data(end,:),missing,1);
                data=[data;mdata];
                %s.queueOutputData(repmat(data(end,:),missing,1));
            end
            s.queueOutputData(data);
            % will be stuck unless properly set.
            % WHY THE HELL THIS IS HAPPENING???
            obj.SetMaxReadChunkSize(-1);
            
            % prepare the session.
            s.prepare();
        end
%         
%         function single(obj)
%             %obj.doResetSingleScan();
%             obj.prepare();
%             obj.single();
%         end
        
        function run(obj)
            if(obj.totalExecutionTime<=0)
                return;
            end
            s=obj.niSession;
            if(s.DurationInSeconds<=0)
                disp('Attempting to call run on positioner without prepare. Please call prepare.');
                return;
            end
            
            s.startBackground();
        end
        
        function stop(obj)
            stop@NI6321Core(obj);
        end
    end
    
    %timebase overrides.
    methods
        % overridable set clock rate.
        function setClockRate(obj,r)
            obj.Rate=r;
            % needed since compilation has chaged.
            obj.Invalidate();
        end
    end
    
    % compilation ovveride
    methods
        % dose the sequence compilation.
        function [rslt]=compileSequence(obj,timestamps,data)
            % creating the data vectors according to          
            obj.toRounded();
            t=[];x=[];y=[]; % time vector is to identify duplicates.
            comp=[];
            for i=1:length(timestamps)
                idata=data{i};
                tv=timestamps(i)+idata.t; % current time vector.
                tspan=min(tv):obj.getTimebase():max(tv);
                lt=length(tspan);
                
                if(lt==0)
                    toc;
                    continue;
                end
                if(lt>1)
                    xv=interp1(tv,idata.x,tspan,idata.method);
                    yv=interp1(tv,idata.y,tspan,idata.method);      
                else
                    xv=idata.x;
                    yv=idata.y;
                end
                % starting points (duplicate the first point if needed).
                xv=[xv(1),xv];
                yv=[yv(1),yv];
                tspan=[timestamps(i),tspan];
                if(isempty(t)&&tspan(1)>0)
                    tspan(1)=0;
                end
                lt=lt+1;
                
                % appending
                t(end+1:end+lt)=tspan;
                x(end+1:end+lt)=xv;
                y(end+1:end+lt)=yv;
            end
            
            % appeding current time if needed.
            [maxt,maxti]=max(t);
            if(maxt<obj.curT)
                % need to extend the time.
                t(end+1)=obj.curT;
                x(end+1)=x(maxti);
                y(end+1)=y(maxti);
            end

            % remove duplicates.
            [t,sidx]=unique(t,'last');
            x=x(sidx);
            y=y(sidx);
            
            % remaking the final vector. (In timeunits of seconds.
            if(length(x)>1)
                tspan=0:obj.getTimebase():max(t);
                x=interp1(t,x,tspan,'previous');
                y=interp1(t,y,tspan,'previous');
            end
            
            x=obj.NormalizeVectorToVoltageRange(x,obj.ChannelVolategeRange);
            y=obj.NormalizeVectorToVoltageRange(y,obj.ChannelVolategeRange);
            
            rslt=[x',y'];
        end   
    end    
    
    % static private methods
    methods(Static, Access = private)
        function [v]=NormalizeVectorToVoltageRange(v,range)
            v(v<range(1))=range(1);
            v(v>range(2))=range(2);
        end
    end
end

