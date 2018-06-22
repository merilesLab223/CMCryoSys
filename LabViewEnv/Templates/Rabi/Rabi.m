classdef Rabi<Experiment
    %MyExperiment an example experiment.
    %getExp returns the last created experiment.
    
    methods
        % no constructor.
%         function obj=Rabi(varargin)
%             obj@Experiment(varargin{:});
%         end
    end
    
    % indication.
    properties
        % Data for the gate graph.
        GateDisplay={};
        % Indicates of currently doing something.
        IsWorking;
        % the current results.
        Results=struct('StepSize',0,'Amps',[],'StartOffset',0,'N',0);
        % lsat data read.
        Stream;
        % read tick dt. For display purpuse. (Graph x).
        ReadTickTime=0;
        % the mean read stream value.
        MeanStreamVal=0;
    end
        
    % property collections.
    properties
        % All the time properties of rabi without scan.
        TimeProperties=[];
        % PI scan parameters.
        ScanProperties=[];
        % Reader configuration info.
        ReaderProperties=[];
        % The rf info.
        RFProperties=[];
        % All the diffrent channels and on/off.
        SystemConfig=[];
    end
    
    properties (Access = private)
        m_isworking=false;
    end
    
    methods
        function [r]=get.IsWorking(exp)
            % true if currently excecutiong.
            r=exp.m_isworking;
        end
        
        function set.IsWorking(exp,v)
            % true if currently excecutiong.
            exp.m_isworking=v;
            exp.update('IsWorking');
        end
    end
    
    %defining new devices.
    properties(SetAccess = private)
        % the reader.
        Reader;
        % the function generator that creates the RF.
        FGen;
        % the gate.
        Gate;
        % True if reading analog.
        IsReadingAnalog=false;
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
            dev=exp.Devices.getOrCreate('RhodeSchwarzSMA100');
        end

    end

    properties(SetAccess = private)
        % the measurement collector, can be changed between types.
        MeasurementCollector=[];
        % The currently executing repetiotion count.
        PendingRepetitionCount=1;
        % the last read bin (scan point) measured.
        LastBinIndex=1;
    end
    
    % externally called functions must be public.
    methods
        function init(exp)
            % initialzers the Rabi definitions.
            disp('Initalizing RABI requirements...');
            
            % init devices.
            exp.Reader.configure();
            exp.Gate.configure();
            exp.FGen.configure();
            
            % define the collector.
            exp.MeasurementCollector=StepBinCollector(exp.Reader);
            % there is no need, each bin is processed on it own in the
            % event handler.
            exp.MeasurementCollector.KeepResultsInMemory=false;
            
            % Configure collector events.
            exp.MeasurementCollector.addlistener('BinComplete',@exp.binComplete);
            exp.MeasurementCollector.addlistener('Complete',@exp.measurementComplete);
            
            disp('Complete RABI Init.');
        end
        
        function runRABI(exp)
            exp.stop();
            exp.IsWorking=true;

            % setting the function generator properties.
            exp.updateFunctionGeneratorProperties(false);
            
            fgen=exp.FGen;
            gate=exp.Gate;


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Configgure devices.
            exp.Reader.externalClockTerminal='pfi0';
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Configuring the measurement
            [crate,chunkn,durs]=exp.configureMeasurement();
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % clearing the scan results if needed.
            exp.resetResultsCollection(durs);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % calcilating the clock rate appropriate for the current
            % sequence and applying to the reader. Since this is a
            % triggered measurement only the reader dose not require a
            % specific clock rate, but rather smt that allows it to read
            % fast enouph.
            
            % setting to the reader.
            gate.setClockRate(300e6);
            exp.Reader.setClockRate(crate);
            exp.Reader.IsContinuous=false;
            exp.Reader.Duration=gate.getTotalDuration()+100;
            exp.Reader.SetMaxReadChunkSize(chunkn);
            
            % updating the display.
            exp.ReadTickTime=1;
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
            
            gate.run();
        end
        
        function stop(exp)
            if(~isempty( exp.MeasurementCollector))
                exp.MeasurementCollector.stop();
            end
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
        
        function [crate,chunkn,durs]=configureMeasurement(exp)
            %configureMeasurement configure the gate and measurement
            %collector for the measurement.
            %   dur - measurement point duration.
            %   nmeasures - the number of measurements per duration.
            %   npoints - the total number of points to measure.
            
            col=exp.MeasurementCollector;
            
            % local def.
            gate=exp.Gate;
            % optional, dont do extrap proecessing.
            gate.ReduceTTLloops=false;
            
            c_m=exp.SystemConfig.MTriggerChannel;
            c_fg=exp.SystemConfig.FGTriggerChannel;
            c_l=exp.SystemConfig.LaserChannel;
            c_rf=exp.SystemConfig.RFChannel;
            
            % calulcations;
            dt=(exp.ScanProperties.PiEndT-exp.ScanProperties.PiStartT)/...
               (double(exp.ScanProperties.N)-1);
            durs=exp.ScanProperties.PiStartT:dt:exp.ScanProperties.PiEndT;
            durs=durs*1e-3;
            
            [crate,dur_p,dur_m]=exp.calculateRates(); % dur_p is pulse time.
            dur_init=exp.TimeProperties.InitT*1e-3;
            dur_waitForPi=exp.TimeProperties.WaitForPI*1e-3;
            dur_waitAfterPi=exp.TimeProperties.WaitAfterPI*1e-3;
            dur_readLaserT=exp.TimeProperties.ReadLaserT*1e-3;
            dur_readT=exp.TimeProperties.ReadT*1e-3;
            dur_waitReferenceT=exp.TimeProperties.WaitForReferenceT*1e-3;
            dur_afterMEasurement=exp.TimeProperties.WaitAfterMeasurement*1e-3;
            dur_mdelay=exp.TimeProperties.LaserDelay*1e-3;
            dur_readPulse=dur_m/2;
            
            % start sequence.
            gate.clear(); % remove all previous instructions. cutT=0;
            col.clear(); % clear instruction to the collector.
            gate.Down([c_fg,c_rf,c_l,c_m]);
            
            % start the counter measure (the dummy idle count).
            gate.Pulse(dur_p,dur_p,c_m);
            gate.curT=0;
            
            % wait a bit to allow for
            gate.wait(dur_init);
            gate.StartLoop(exp.ScanProperties.RepCount);
            
            % turn laser on and off. 
            for i=1:exp.ScanProperties.N
                % can i properties.
                idur=durs(i);
                
                %init
                if(exp.SystemConfig.UseLaser)
                    gate.Up(c_l);
                end
                gate.wait(dur_init);
                if(exp.SystemConfig.UseLaser)
                    gate.Down(c_l);
                end
                
                % pi pulse.
                gate.wait(dur_waitForPi);
                if(exp.SystemConfig.UseRF)
                    gate.Up(c_rf);
                end
                
                gate.wait(idur);
                if(exp.SystemConfig.UseRF)
                    gate.Down(c_rf);
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % doing the read + refrence
                for wdt=[dur_waitAfterPi,dur_waitReferenceT]
                    gate.wait(wdt);
                    if(exp.SystemConfig.UseLaser)
                        gate.Pulse(dur_readLaserT,dur_p,c_l);
                        gate.goBackInTime(dur_readLaserT+dur_p);
                    end
                    
                    gate.wait(dur_mdelay);
                    
                    % cleanup for counter.
                    if(~exp.IsReadingAnalog)
                        col.skip(1);
                        gate.Pulse(dur_readPulse,dur_p,c_m);
                        gate.goBackInTime(dur_readPulse+dur_p);
                    end

                    % measuring data.
                    col.collect(exp.ReaderProperties.BinsPerFreq);
                    for j=1:exp.ReaderProperties.BinsPerFreq
                        gate.wait(dur_m);
                        gate.Pulse(dur_readPulse,dur_p,c_m);
                        gate.goBackInTime(dur_readPulse+dur_p);
                    end

                    if(dur_readLaserT>dur_readT)
                        gate.wait(dur_readLaserT-dur_readT-dur_mdelay);
                    end
                end
                
                gate.wait(dur_afterMEasurement);
            end
            
            gate.EndLoop();
            col.merge(1,[],true,exp.ScanProperties.RepCount);
            %col.repeate(exp.ScanProperties.RepCount);
            
            % rf off.
            if(exp.SystemConfig.UseRF)
                gate.Down(c_rf); % turn rf on. No time added.
            end
            
            % adjust chunkn to read the total number of needed reads.
            % in good time.
            totalReadsPerRound=(exp.ReaderProperties.BinsPerFreq+1)*2*exp.ScanProperties.N;
            totalReads=totalReadsPerRound*double(exp.ScanProperties.RepCount);
            singleReadTime=gate.curT./double(totalReadsPerRound);

            chunkn=ceil(100/singleReadTime); % read at leaset 20 ms before return value.
            if(chunkn>totalReads/2)
                chunkn=totalReads/2;
            end
            if(chunkn<1)
                chunkn=1;
            end
            
            % give it one more chunk n.
            gate.wait(dur_p);
            gate.StartLoop(100);
            gate.Pulse(dur_p,dur_p,c_m);
            gate.EndLoop();
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
            fgen.Frequency=exp.RFProperties.Frequency*1e6;
            fgen.Amplitude=exp.RFProperties.Amplitude;
            fgen.TriggerSource='EXT';
            fgen.RFState=1; % always on.
            
            if(sendToDevice)
                fgen.prepare();
                fgen.run();
            end
        end        
    end
    
    methods(Access = protected)
        
        function resetResultsCollection(exp,durs)
            dt=(exp.ScanProperties.PiEndT-exp.ScanProperties.PiStartT)/...
                (exp.ScanProperties.N-1);

            exp.Results.Amps=[];
            exp.Results.Reference=[];
            exp.Results.StartOffset=exp.ScanProperties.PiStartT;
            exp.Results.N=exp.ScanProperties.N;
            exp.Results.StepSize=dt;
            exp.Results.Times=exp.Results.StartOffset+(0:exp.ScanProperties.N-1)*dt;
            exp.LastBinIndex=1;
        end
        
        function [crate,pulseT,singleReadT]=calculateRates(exp)
            %calculateRates Calculates the clock rate for the ODMR. 
            %this is an approximate value.
            % returns:
            %   crate - the clock rate.
            %   chunkn - read chunk size.
            singleReadT=exp.TimeProperties.ReadT*1e-3/double(exp.ReaderProperties.BinsPerFreq);
            crate=1000./singleReadT;
            if(crate>exp.ReaderProperties.MaxFreq)
                if(exp.ReaderProperties.BinsPerFreq>1)
                    error('Maximal read rate reached, please reduce # of reads per point to 1 or increase max read freq.');
                end
                crate=exp.ReaderProperties.MaxFreq;
            end
            pulseT=singleReadT/100;
            if(pulseT<exp.Gate.getTimebase())
                pulseT=exp.Gate.getTimebase();
            end
        end
    end
    
    % process data results.
    methods (Access = protected)
        function binComplete(exp,s,e)
            
            totalCount=exp.ScanProperties.RepCount;
            curPending=exp.PendingRepetitionCount;

            % all the results.
            rslts=exp.Results;
            isavg=exp.ScanProperties.DoAvg;
            isana=exp.IsReadingAnalog;
            
            % each bin is a full rabi scan (over all points)
            % therefore...
            
            for i=1:e.BinCount
                doneCount=double(totalCount-curPending);
                data=e.Data{i};
                amps=data(1:2:end-1);
                refs=data(2:2:end);
                
                % reshaping to the number of measurement per data
                % value.
                amps=reshape(amps,...
                    floor(length(amps)./exp.ReaderProperties.BinsPerFreq)...
                    ,exp.ReaderProperties.BinsPerFreq);
                refs=reshape(refs,...
                    floor(length(refs)./exp.ReaderProperties.BinsPerFreq)...
                    ,exp.ReaderProperties.BinsPerFreq);                
                if(isana)
                    refs=mean(refs,2);
                    amps=mean(amps,2);
                else
                    refs=sum(refs,2);
                    amps=sum(amps,2);
                end
                
                if(isavg && length(rslts.Amps)==length(amps))
                    amps=...
                        (rslts.Amps*doneCount)./(doneCount+1)+amps./(doneCount+1);
                    rslts.Amps=amps;
                    refs=...
                        rslts.Reference.*doneCount./(doneCount+1)+refs./(doneCount+1);
                    rslts.Reference=refs;                    
                else
                    rslts.Amps=amps;
                    rslts.Reference=refs;
                end
                
                curPending=curPending-1;
            end
            exp.PendingRepetitionCount=curPending;
            exp.Results=rslts;
            
            exp.update({'MeanStreamVal','Stream',...
                'Results','PendingRepetitionCount','LastBinIndex'});
        end
        
        function measurementComplete(exp,s,e)
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