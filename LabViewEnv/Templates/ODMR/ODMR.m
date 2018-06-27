classdef ODMR<Experiment
    %MyExperiment an example experiment.
    %getExp returns the last created experiment.
    
    methods
        function obj=ODMR(varargin)
        end
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
        function [r]=get.IsReadingAnalog(exp)
            r=isfield(exp.SystemConfig,'UseAnalogInputA0') &&...
                exp.SystemConfig.UseAnalogInputA0;
        end
        
        function [dev]=get.Reader(exp)
            %returns the reader device.
            if(exp.IsReadingAnalog)
                % as analog.
                dev=exp.Devices.getOrCreate('NI6321AnalogReader',...
                    'readchan','ai0','niDevID','Dev1');
            else
                dev=exp.Devices.getOrCreate('NI6321Counter',...
                    'ctrName','ctr0','niDevID','Dev1');   
            end
        end
        
        function [dev]=get.Gate(exp)
            % Gate control (pulse blaster).
            dev=exp.Devices.getOrCreate('SpinCoreTTLGenerator');
        end
        
        function [dev]=get.FGen(exp)
            % function generator for creating the RF.
            dev=exp.Devices.getOrCreate('RhodeSchwarzSMA100TriggeredFG');
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
        SystemConfig=[];
        RFandLaserProperties=[];
    end
    
    properties(SetAccess = private)
        MeasurementCollector=[];
        PendingRepetitionCount=1;
        LastBinIndex=1;
        IsReadingAnalog=false;
    end
    
    % externally called functions must be public.
    methods
        function init(exp)
            disp('Initalizing ODMR requirements...');
            exp.Reader.configure();
            exp.Gate.configure();
            exp.FGen.configure();
            
            exp.MeasurementCollector=StepBinCollector(exp.Reader);
            exp.MeasurementCollector.KeepResultsInMemory=false;
            % configure measurement reader.
            exp.MeasurementCollector.addlistener('BinComplete',@exp.binComplete);
            exp.MeasurementCollector.addlistener('Complete',@exp.measurementComplete);   
            
            disp('Complete ODMR Init.');
        end
        
        function saveToFile(exp,fn)
            if(~exist('fn','var'))
                fn=[mfilename('fullpath'),'.temp.mat'];
            end
            [fpath,name,ext]=fileparts(fn);
            data=exp.Results;
            save([fpath,filesep,name,'.mat'],'data');
        end
        
        function runODMR(exp)
            exp.stop();
            exp.IsWorking=true;
            
            % setting the function generator properties.
            fgen=exp.FGen;
            gate=exp.Gate;
            
            exp.updateFunctionGeneratorProperties(false);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % clearing the scan results if needed.
            exp.resetResultsCollection();
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Configgure devices.
            exp.Reader.externalClockTerminal='pfi0';
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Configuring the measurement
            [crate,chunkn]=exp.configureMeasurement();
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % calcilating the clock rate appropriate for the current
            % sequence and applying to the reader. Since this is a
            % triggered measurement only the reader dose not require a
            % specific clock rate, but rather smt that allows it to read
            % fast enouph.
            
            % setting to the reader.
            gate.setClockRate(300e6);
            exp.Reader.IsContinuous=false;
            exp.Reader.Duration=gate.getTotalDuration();
            exp.Reader.setClockRate(crate);
            exp.Reader.SetMaxReadChunkSize(chunkn);
            
            % updating the display.
            exp.ReadTickTime=exp.ScanProperties.Dwell/exp.ReaderProperties.BinsPerFreq;
            exp.update('ReadTickTime');

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Update the display.
            exp.PendingRepetitionCount=exp.ScanProperties.RepCount;
            if(exp.PendingRepetitionCount<1)
                exp.PendingRepetitionCount=1;
            end
            exp.update({'PendingRepetitionCount','LastBinIndex'});
            exp.updateGateDisplay(false,false);

            %gate.Pulse(0);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % update to current results.
            exp.update('Results');
            mcol=exp.MeasurementCollector;
            % setting the clock rate.
            gate.prepare();
            fgen.prepare();
            mcol.prepare();
            exp.Reader.prepare();
            
            % configuring the measurement reader.
            exp.Reader.run();
            fgen.run();
            mcol.start();
            pause(0.1);
            gate.run();
        end
        
        function stop(exp)
            exp.MeasurementCollector.stop();
            exp.Reader.stop();
            exp.FGen.stop();
            exp.Gate.stop();
            exp.IsWorking=false;
        end
        
        function updateGateDisplay(exp,plotMatlab,doConfigureMeasurement)
            %updateGateDisplay Updates the gate display. 
            %   plotMatlab - if true, plot a matlab graph.
            %   doConfigureMeasurement - configures the measurement.
            if(~exist('plotMatlab','var'))
                plotMatlab=true;
            end
            if(~exist('doConfigureMeasurement','var')||~islogical(doConfigureMeasurement))
                doConfigureMeasurement=true;
            end
            
            if(doConfigureMeasurement)
                exp.configureMeasurement();
            end
            
            [gateVecs,gateT]=exp.Gate.getTTLVectors(false);
            
            sizeGateVecs=size(gateVecs);
            gateVecs=gateVecs+repmat(1.1*(0:sizeGateVecs(2)-1),sizeGateVecs(1),1)+0.1;
            
            dt=max(gateT)/1000;

            exp.GateDisplay=struct();
            exp.GateDisplay.dt=dt;
            exp.GateDisplay.amp=interp1(gateT,gateVecs,0:dt:max(gateT),'linear');
            exp.update('GateDisplay');            
            
            if(plotMatlab)
                stairs(gateT,gateVecs);
            end
        end
        
        function [crate,chunkn,totalTime]=configureMeasurement(exp,dur,nmeasures,npoints)
            %configureMeasurement configure the gate and measurement
            %collector for the measurement.
            %   dur - measurement point duration.
            %   nmeasures - the number of measurements per duration.
            %   npoints - the total number of points to measure.
            if(~exist('dur','var'))
                dur=exp.ScanProperties.Dwell;
            end
            
            if(~exist('nmeasures','var'))
                nmeasures=exp.ReaderProperties.BinsPerFreq;
            end
            
            if(~exist('npoints','var'))
                npoints=exp.ScanProperties.N*exp.ScanProperties.RepCount;
            end
            
            [crate,chunkn]=calculateRates(exp);
            
            % local def.
            gate=exp.Gate;
            gate.ReduceTTLloops=false;
            col=exp.MeasurementCollector;
            c_m=exp.SystemConfig.MTriggerChannel;
            c_fg=exp.SystemConfig.FGTriggerChannel;
            c_l=exp.SystemConfig.LaserChannel;
            c_rf=exp.SystemConfig.RFChannel;
            
            % calculations.
            dur_m=dur/double(nmeasures);
            dur_p=1000/crate; % pulse duration.
            %dur_cleanup=chunkn*dur_p*2; %1 ms.
            dur_rf_n_l=dur*abs(diff(cell2mat(exp.RFandLaserProperties.DutyCycle)))/100;
            offset_rf_n_l=dur*min(cell2mat(exp.RFandLaserProperties.DutyCycle))/100;
            
            gate.defaultPulseWidth=dur_p;
            
            % start measuremnet.
            gate.clear();
            col.clear();
            
            if(~exp.IsReadingAnalog)
                % trigger the counter?
                %gate.Pulse(dur_p,dur_p,c_m);
                
                % first pulse in counter is baseline.
                % so we dont need to skip.
                gate.Pulse(dur_p,dur_p,c_m);
                gate.goBackInTime(dur_p*2);
            end
            
            % measure
            col.collect(nmeasures,[],npoints);
            
            % rf first
            if(exp.SystemConfig.UseRF)
                gate.wait(offset_rf_n_l);
                gate.Pulse(dur_rf_n_l,dur_p,c_rf);
                gate.goBackInTime(dur_rf_n_l+dur_p+offset_rf_n_l);
            end
            % laser first
            if(exp.SystemConfig.UseLaser)
                gate.wait(offset_rf_n_l);
                gate.Pulse(dur_rf_n_l,dur_p,c_l);
                gate.goBackInTime(dur_rf_n_l+dur_p+offset_rf_n_l);
            end
            
            for i=1:nmeasures
                gate.wait(dur_m);
                gate.Pulse(dur_p,dur_p,c_m);
                gate.goBackInTime(dur_p*2);
            end
            
            % Do loop ? 
            if(npoints>1)
                if(exp.SystemConfig.UseFG)
                    gate.Pulse(dur_p,dur_p,c_fg);
                    gate.goBackInTime(dur_p*2);
                end
                
                lstart=gate.StartLoop(npoints-1);
                for i=1:nmeasures
                    gate.wait(dur_m);
                    gate.Pulse(dur_p,dur_p,c_m);
                    gate.goBackInTime(dur_p*2);
                end
                gate.EndLoop();
                
                % rf
                if(exp.SystemConfig.UseRF)
                    gate.curT=lstart;
                    gate.wait(offset_rf_n_l);
                    gate.Pulse(dur_rf_n_l,dur_p,c_rf);
                end
                
                % laser
                if(exp.SystemConfig.UseLaser)
                    gate.curT=lstart;
                    gate.wait(offset_rf_n_l);
                    gate.Pulse(dur_rf_n_l,dur_p,c_l);
                end
                
                % need delay after loop;
                gate.curT=lstart;
                gate.wait(dur+dur_p);
            end
            
            % final cleanup pulse if there is anything in the buffer.
            gate.StartLoop(chunkn*2);
            gate.Pulse(dur_p,dur_p,c_m);
            gate.EndLoop();
            
            % allow the last pulse to happen.
%             gate.wait(dur_p*2);
%             gate.curT=lstart;
%             gate.wait(dur);
%             % cleanup pulses.
%             for i=1:chunkn*2
%                 gate.Pulse(dur_p,dur_p,c_m);
%             end
%             gate.Pulse(dur_p,dur_p,c_m);
        end        
    end
    
    methods(Access = protected)
        function resetResultsCollection(exp)
%             if(exp.Results.StartOffset~=exp.ScanProperties.Start||...
%                 exp.Results.StepSize~=exp.ScanProperties.StepSize)
%                 
%             end
            exp.Results.Freqs=[];
            exp.Results.Amps=[];
            exp.Results.StartOffset=exp.ScanProperties.Start;
            exp.Results.StepSize=exp.ScanProperties.StepSize;
            exp.Results.Freqs=...
                exp.ScanProperties.Start:exp.ScanProperties.StepSize:exp.ScanProperties.End;
            exp.LastBinIndex=1;
        end
        
        function [crate,chunkn]=calculateRates(exp)
            %calculateRates Calculates the clock rate for the ODMR. 
            %this is an approximate value.
            % returns:
            %   crate - the clock rate.
            %   chunkn - read chunk size.
            dt=exp.ScanProperties.Dwell;
            chunkn=double(exp.ReaderProperties.BinsPerFreq*2);
            crate=Inf;
            
            while(crate>exp.ReaderProperties.MaxFreq)
                chunkn=chunkn/2;
                crate=1/(exp.Reader.timebaseToSeconds(dt)/chunkn);
                crate=floor(crate);
                if(crate<=1)
                    crate=1;
                    break;
                end
            end
            
            % 100 times faster then the number of chunks.
            crate=crate*10;
            if(crate>exp.ReaderProperties.MaxFreq)
                crate=exp.ReaderProperties.MaxFreq;
            end
        end
        
        function updateFunctionGeneratorProperties(exp,sendToDevice)
            %updateFunctionGeneratorProperties update the function
            %generator properties
            %   sendToDevice - if true the fg device will be updated to the
            %   new properties.

            if(~exist('sendToDevice','var'))
                sendToDevice=true;
            end
            
            fgen=exp.FGen;
            fgen.StartFrequency=exp.ScanProperties.Start*1e6;
            fgen.EndFrequency=exp.ScanProperties.End*1e6;
            fgen.NumberOFSweepPoints=exp.ScanProperties.N;
            fgen.Amplitude=exp.RFandLaserProperties.Amplitude;
            fgen.TriggerSource='EXT';
            %exp.FGen
            %fgen.R
            
            if(sendToDevice)
                fgen.prepare();
                fgen.run();
            end
        end

        function binComplete(exp,s,e)
            for i=1:e.BinCount
                exp.processNextBin(e.Data{i});
            end
            if(exp.LastBinIndex>exp.ScanProperties.N)
                exp.PendingRepetitionCount=exp.PendingRepetitionCount-1;
                exp.LastBinIndex=1;
            end    
            exp.update({'Stream','Results','PendingRepetitionCount','LastBinIndex'});
        end
        
        function processNextBin(exp,data)
            bidx=exp.LastBinIndex;
            if(bidx>exp.ScanProperties.N)
                exp.PendingRepetitionCount=exp.PendingRepetitionCount-1;
                exp.LastBinIndex=1;
                bidx=1;
            end
            
            repDone=exp.ScanProperties.RepCount-...
                exp.PendingRepetitionCount;
            
            amps=0;
            if(isempty(data))
                exp.Stream=[];
            else
                exp.Stream=data;
                if(exp.IsReadingAnalog)
                    amps=mean(exp.Stream);
                else
                    amps=sum(exp.Stream)/exp.ScanProperties.Dwell;
                end
            end
            
            repDone=double(repDone);
            if(repDone>0 && length(exp.Results.Amps)>=repDone)
                oldAmps=exp.Results.Amps(bidx);
                amps=...
                    oldAmps*repDone./(repDone+1)+amps./(repDone+1);
            end
            
            exp.Results.Amps(bidx)=amps;
            exp.LastBinIndex=exp.LastBinIndex+1;
        end
        
        function measurementComplete(exp,s,e)
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