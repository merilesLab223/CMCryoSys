classdef ODMR<Experiment
    %MyExperiment an example experiment.
    %getExp returns the last created experiment.
    
    methods
    end

    %defining new devices.
    properties(SetAccess = private)
        Reader;
        FGen;
        Gate;
        IsWorking;
        Results=struct('StepSize',0,'Amps',[],'StartOffset',0);
        Stream;
        ReadTickTime=0;
        
    end
    
    properties (Access = private)
        m_isworking=false;
    end
    
    methods
        function [r]=get.Reader(exp)
            % configuring counter reader.
            if(~exp.Devices.contains('ni_counter_reader'))
                dev=NI6321Counter('Dev1');
                exp.Devices.set('ni_counter_reader',dev);
                dev.ctrName='ctr0';
            end
            r=exp.Devices('ni_counter_reader');
        end
        function [r]=get.Gate(exp)
            if(~exp.Devices.contains('pb_fg'))
                exp.Devices.set('pb_fg',SpinCoreTTLGenerator());
            end
            r=exp.Devices.get('pb_fg');
        end
        function [r]=get.FGen(exp)
            if(~exp.Devices.contains('rs_tfg'))
                exp.Devices.set('rs_tfg',RhodeSchwarzSMA100TriggeredFG());
            end
            r=exp.Devices.get('rs_tfg');
        end
        
        function [r]=get.IsWorking(exp)
            r=exp.m_isworking;
        end
        
        function set.IsWorking(exp,v)
            exp.m_isworking=v;
            exp.update('IsWorking');
        end
    end
        
    properties
        ScanProperties=[];
        ReaderProperties=[];
        GateDisplay={};
    end
    
    properties(SetAccess = private)
        MeasurementCollector=[];
        PendingRepetitionCount=1;
        LastBinIndex=0;
    end
    
    % externally called functions must be public.
    methods
        function init(exp)
            disp('Initalizing ODMR requirements...');
            exp.Reader.configure();
            exp.Gate.configure();
            exp.FGen.configure();
            
            exp.MeasurementCollector=TimeBinCollector(exp.Reader);
            exp.MeasurementCollector.KeepResultsInMemory=false;
            % configure measurement reader.
            exp.MeasurementCollector.addlistener('BinComplete',@exp.binComplete);
            exp.MeasurementCollector.addlistener('Complete',@exp.measurementComplete);   
            
            disp('Complete ODMR Init.');
        end
        
        function runODMR(exp)
            exp.IsWorking=true;
            
            % setting the function generator properties.
            fgen=exp.FGen;
            mcol=exp.MeasurementCollector;
            mcol.clear();
            gate=exp.Gate;
            gate.Channel=[1,2];
            mcol.clear();
            gate.clear();
            gate.ReduceTTLloops=false;
            
            fgen.StartFrequency=exp.ScanProperties.Start*1e6;
            fgen.EndFrequency=exp.ScanProperties.End*1e6;
            fgen.NumberOFSweepPoints=exp.ScanProperties.N;
            fgen.Amplitude=exp.ScanProperties.Amplitude;
            fgen.TriggerSource='EXT';
            
            if(exp.Results.StartOffset~=exp.ScanProperties.Start||...
                exp.Results.StepSize~=exp.ScanProperties.StepSize)
                exp.Results.Freqs=[];
                exp.Results.Amps=[];
            end
            
            exp.Results.StartOffset=exp.ScanProperties.Start;
            exp.Results.StepSize=exp.ScanProperties.StepSize;
            exp.Results.Freqs=...
                exp.ScanProperties.Start:exp.ScanProperties.StepSize:exp.ScanProperties.End;
            
            % calcilating the clock rate.
            dt=exp.ScanProperties.Dwell;
            fn=double(exp.ReaderProperties.BinsPerFreq*4);
            crate=Inf;
            
            while(crate>exp.ReaderProperties.MaxFreq)
                fn=fn/2;
                crate=1/(exp.Reader.timebaseToSeconds(dt)/fn);
                crate=floor(crate);
                if(crate<=1)
                    crate=1;
                    break;
                end
            end
            
            % assing to reader/col.
            
            clockTerm='pfi0';
            gate.setClockRate(300e6);
            exp.Reader.setClockRate(crate);
            exp.Reader.SetMaxReadChunkSize(fn);
            mcol.setClockRate(crate);
            exp.Reader.externalClockTerminal=clockTerm;
            exp.ReadTickTime=exp.Reader.getTimebase();
            exp.update('ReadTickTime');
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% setting up the measurement...
            % adding the measurement collection       
            bufferCleanupRounds=fn+1;
            if(bufferCleanupRounds<3)
                bufferCleanupRounds=3;
            end
            bufferCleanupTime=exp.Reader.secondsToTimebase(bufferCleanupRounds/crate);
            mtimes=(1:double(exp.ScanProperties.N))'*dt;
            mdurations=diff([0;mtimes]);

            % setting up the measurement.
            mcol.curT=0;
            mcol.wait(bufferCleanupTime);
            
            % making measurement repetitions;
            mdurations=repmat(mdurations,exp.ScanProperties.RepCount,1);
            
            % check for repetitions.
            mcol.Measure(mdurations);
            if(length(exp.Results.Amps)~=length(mdurations))
                exp.Results.Amps=[];
            end
            totalRep=length(mdurations);
            
            %%% configure gate modes.
            gate.PersistValuesWhenInsertingTimes=true;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% The gate and triggers.
            gate.curT=0;
            
            % configure clock.
            gate.curT=0;
            gate.ClockSignal(bufferCleanupTime,crate,1);
            firstPulseTime=gate.curT;
            gate.ClockSignal(dt*(totalRep+2),crate,1); % cleaup set.
            
            % Laser config.
            gate.curT=firstPulseTime;
            gate.Up(dt*totalRep,4);
            

%             % first loop is without a pulse.
%             gate.curT=0;
%             gate.ClockSignal(bufferCleanupTime,crate,1);
%             
%             loopt=gate.curT;
%             gate.Up([],4);
%             gate.curT=loopt;
%             
%             gate.curT=loopt;
%             gate.ClockSignal(dt,crate,1);
%             
%             % now loop de loop.
%             if(totalRep-1>0)
%                 loopt=gate.StartLoop(totalRep-1);
% 
%                 % sequence.
%                 gate.curT=loopt;
%                 gate.Pulse(dt/2,dt/2,[2,3]);
%                 gate.curT=loopt;
%                 gate.ClockSignal(dt,crate,1);
%                 % go to the right time.
%                 gate.curT=loopt;
%                 gate.wait(dt);
%                 % stop the external loop.
%                 gate.EndLoop();
%             end
%             
%             curT=gate.curT;
%             % reset the clock
%             gate.Pulse(dt/5,2);
%             curT=gate.curT;
%             gate.Down(dt*2,4);
%             %cleanup.
%             gate.curT=curT;
%             gate.ClockSignal(dt*2,crate,1);
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Update the display.
            exp.PendingRepetitionCount=exp.ScanProperties.RepCount;
            if(exp.PendingRepetitionCount<1)
                exp.PendingRepetitionCount=1;
            end
            exp.LastBinIndex=0;
            exp.update({'PendingRepetitionCount','LastBinIndex'});
            
            [gateVecs,gateT]=gate.getTTLVectors(true);
            sizeGateVecs=size(gateVecs);
            gateVecs=gateVecs+repmat(0:sizeGateVecs(2)-1,sizeGateVecs(1),1);
            stairs(gateT,gateVecs);
            dt=max(gateT)/1000;
            gateVecs=interp1(gateT,gateVecs,0:dt:max(gateT),'linear');
            exp.GateDisplay=struct();
            exp.GateDisplay.dt=dt;
            exp.GateDisplay.amp=gateVecs;
            exp.update('GateDisplay');
            %gate.Pulse(0);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % update to current results.
            exp.update('Results');
            
            % setting the clock rate.
            gate.prepare();
            fgen.prepare();
            mcol.prepare();
            exp.Reader.prepare();
            
            % configuring the measurement reader.
            exp.Reader.run();
            fgen.run();
            mcol.start();
            
            gate.run();
        end
        
        function stop(exp)
            exp.MeasurementCollector.stop();
            exp.Reader.stop();
            exp.FGen.stop();
            exp.Gate.stop();
            exp.IsWorking=false;
        end
    end
    
    methods(Access = protected)
        function binComplete(exp,s,e)
            binsDone=exp.ScanProperties.RepCount-...
                exp.PendingRepetitionCount;
            binIndexOffset=binsDone*exp.ScanProperties.N;
            
            bidx=e.BinIndex-binIndexOffset;
            while(bidx>exp.ScanProperties.N)
                exp.PendingRepetitionCount=exp.PendingRepetitionCount-1;
                bidx=bidx-exp.ScanProperties.N;
            end
            
            amps=0;
            if(isempty(e.Data))
                exp.Stream=[];
            else
                exp.Stream=e.Data(:,2);
                amps=mean(exp.Stream);
            end
            
            binsDone=double(binsDone);
            if(binsDone>0 && length(exp.Results.Amps)>=binsDone)
                oldAmps=exp.Results.Amps(bidx);
                amps=...
                    oldAmps*binsDone./(binsDone+1)+amps./(binsDone+1);
            end
            
            exp.Results.Amps(bidx)=amps;
            
            exp.LastBinIndex=bidx;
            exp.update({'Stream','Results','PendingRepetitionCount','LastBinIndex'});
        end
        
        function measurementComplete(exp,s,e)
            exp.PendingRepetitionCount=exp.PendingRepetitionCount-1;
            exp.update({'Stream','Results','PendingRepetitionCount','LastBinIndex'});
            exp.stop();
        end
    end
    
    methods
        function delete(exp)
            exp.stop();
            delete(exp.MeasurementCollector);
        end
    end
end