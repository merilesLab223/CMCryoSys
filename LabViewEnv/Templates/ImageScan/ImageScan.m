% Implements an experiment image scan core code.
% this matlab code allows the execution and creation of the image scan.
% can be used as templates.
classdef ImageScan < Experiment
    
    % properits collection to be copied to matlab.
    % together with events this will provide the main data collection.
    properties
        Position=[];
        ScanConfig=struct();
        SystemConfig=struct('UseAnalogInputA0',true);
        PositionConfig=[];
        ScanParameters=struct();
        StreamConfig=struct('ClockRate',5000,'AutoAdjustRates',true,...
            'IntegrationTime',1,'UpdateTime',50,'CollectionWindow',5000,...
            'PadWithZeros',true);
        StreamTrace=[]; % A value to update.
        ScanImage=[];
        StreamingCounterState=[];
        ReaderAmplitude=0;
        PositionTracking=false;
        ScanProgress=0;
    end
    
    % privately set properties.
    % will not be copied to Labview.
    properties(SetAccess = protected)
        Devices=DeviceCollection();
        Pos=[];
        Clock=[];
        Reader=[];
        ScanDataCollector=[];
        StreamDataCollector=[];
        HasBeenInitialized=false;
        IsWorking=false;
        StatusFlags=struct();
    end
    
    properties (Access = private)
        m_has_been_initialzied=false;
        m_is_working=false;
        m_positionUpdateCalledWhileUpdatingPosition=false;
        m_pos_value=struct('X',0,'Y',0);
        m_position_config=struct();
        m_lastUpdateLoopUIUpdate=-1;
        m_curScanDwellTime=0;
    end
    
    % Getters and setters.
    methods
        % get the current position value.
        function [rt]=get.PositionConfig(exp)
            rt=exp.m_position_config;
        end
        
        % set the current position value.
        function set.PositionConfig(exp,v)
            if(~exist('v','var'))
                v=struct();
            end
            exp.m_position_config=v; % to allow auto update.
            if(exp.HasBeenInitialized)
                exp.updatePositionConfig();
            end
        end
        
        % get the current position value.
        function [rt]=get.Position(exp)
            rt=exp.m_pos_value;
        end
        
        % set the current position value.
        function set.Position(exp,v)
            if(~exist('v','var'))
                v=struct('X',0,'Y',0);
            end
            exp.m_pos_value=v; % to allow auto update.
            if(exp.PositionTracking)
                exp.updateGalvoPositionVoltges();
            end
        end   
        
        % stream state getter.
        function [rt]=get.StreamingCounterState(exp)
            rt=false;
            if(isstruct(exp.StatusFlags) && isfield(exp.StatusFlags,'IsStreaming'))
                rt=exp.StatusFlags.IsStreaming; 
            end
        end
        
        % stream state setter
        function set.StreamingCounterState(exp,isStreaming)
            if(~exist('isStreaming','var'))
                isStreaming=false;
            end
            if(isStreaming)
                disp('Starting stream..');
            else
                disp('Stopping stream..');
            end
            exp.doStream(isStreaming);
            exp.update('StreamingCounterState');
        end   
        
        % get the current operational state.
        function [rt]=get.HasBeenInitialized(exp)
            rt=exp.m_has_been_initialzied;
        end
        
        % set the current operational state.
        function set.HasBeenInitialized(exp,v)
            if(~exist('v','var'))
                v=false;
            end
            exp.m_has_been_initialzied=v; % to allow auto update.
            exp.update('HasBeenInitialized');
        end          
        
                % get the current operational state.
        function [rt]=get.IsWorking(exp)
            rt=exp.m_is_working;
        end
        
        % set the current operational state.
        function set.IsWorking(exp,v)
            if(~exist('v','var'))
                v=false;
            end
            exp.m_is_working=v; % to allow auto update.
            exp.update('IsWorking');
        end      
        
        % returns the poisitioer.
        function [dev]=get.Pos(exp)
            dev=exp.Devices.get('positioner');
        end
        
        % get the exp.Clock.
        function [dev]=get.Clock(exp)
            dev=exp.Devices.get('clock');
        end
        
        % get the reader.
        function [dev]=get.Reader(exp)
            dev=exp.Devices.get('reader');
        end
        
    end
    
    % Positioning
    
    methods
        function setPosition(exp,x,y)
            exp.Position.X=x;
            exp.Position.Y=y;
            exp.update('Position');
            exp.updateGalvoPositionVoltges();
        end
        
        function updateGalvoPositionVoltges(exp,pos)
            if(exp.StatusFlags.IsScanning || exp.StatusFlags.IsSettingPosition)
                % cannot change position while scanning.
                exp.m_positionUpdateCalledWhileUpdatingPosition=true;
                return;
            end
            
            exp.StatusFlags.IsSettingPosition=true;
            exp.update('StatusFlags');
            
            exp.m_positionUpdateCalledWhileUpdatingPosition=false;
            
            % reset the positioner and clock.
            wasRunning=exp.Clock.IsRunning;
            
            exp.Pos.stop();
            exp.Pos.clear();

            % set the single access clock rate.
            exp.Pos.setClockRate(1000);
            
            exp.Pos.GoTo(exp.Position.X,exp.Position.Y);
            exp.Pos.prepare();
            exp.Clock.prepare();
            
            exp.Pos.run();
            if(~wasRunning)
                exp.Clock.run();
            end
            exp.StatusFlags.IsSettingPosition=false;

            exp.update('StatusFlags');
            
            % callback.
            if(exp.m_positionUpdateCalledWhileUpdatingPosition)
                exp.updateGalvoPositionVoltges();
            end
        end
    end
    
    % public methods accessable from labview.
    methods
        
        function updatePositionConfig(exp)
            if(~isfield(exp.PositionConfig,'UnitsToVolts')||...
               ~isfield(exp.PositionConfig,'XToYRatio'))
                return;
            end            
            scale=[exp.PositionConfig.UnitsToVolts*exp.PositionConfig.XToYRatio,...
                exp.PositionConfig.UnitsToVolts];
            
            exp.Pos.InvertXY=exp.PositionConfig.InvertXY;
            exp.Pos.PositionTOVoltageUnits=scale;
        end
        
        % initializes the experiment devices.
        function init(exp)
            exp.resetStatusFlags();
            exp.IsWorking=true;
            
            % main device configurations.
            exp.initDevices('Dev1');
            
            % updating device configs.
            exp.updatePositionConfig();
            
            % call to configure roles.
            exp.Devices.configureAllDevices();
            
            % marking initialized.
            exp.HasBeenInitialized=true;
            
            % calling the stream (and configuring it).
            exp.doStream(exp.StatusFlags.IsStreaming);
            
            exp.IsWorking=false;
        end
        
        function scan(exp)
            exp.doScan();
        end
        
        function stream(exp)
            exp.doStream(true);
        end
        
        % prepare for measurement.
        function prepare(exp)
            %exp.ScanCollector=TimedDataCollector(exp.Reader);
        end
        
        function stop(exp)
            % stopping all the devices.
            exp.stopAllDevices();            
        end
    end
    
    methods (Access = protected)
        % called on exp info update loop.
        function OnUpdateLoop(exp,s,e)
            % if the clock is running.
            curt=now*24*60*60*1000; % in ms.
            disp('Update loop');
            if(exp.Clock.IsRunning)
                isCurrentlyScanning=exp.StatusFlags.IsScanning && exp.Pos.IsRunning;
                isCurrentlyStreaming=exp.StatusFlags.IsStreaming && exp.Reader.IsRunning;
                
                doStopDevices=~(isCurrentlyScanning || isCurrentlyStreaming);
                if(doStopDevices)
                    exp.stopAllDevices();
                    disp('Devices stopped by update loop.');
                end
            end
            
            if(curt-exp.m_lastUpdateLoopUIUpdate>50)
                exp.m_lastUpdateLoopUIUpdate=curt;
                scanProgress=0;
                if(exp.StatusFlags.IsScanning && ...
                        isa(exp.ScanDataCollector,'TimedDataCollector'))
                    scanProgress=round(exp.ScanDataCollector.MeasurementCompletedTimePrecentage);
                end
                if(scanProgress~=exp.ScanProgress)
                    exp.ScanProgress=scanProgress;
                    exp.update('ScanProgress');
                end
            end
        end
        
        function initDevices(exp,niDevName)
            if(~exist('niDevName','var'))niDevName=[];end

            % Hardware connections.
            % port0/line1 ->USER1 ->PFI0 : Trigger.
            % pfi15->pfi14 : Clock loopback.
            % pfi8 (counter 0)->User2 : counter input)      
            
            % configuring poisitioner.
            exp.Devices.set('ni_analog_pos','positioner',NI6321Positioner2D(niDevName));
            exp.Pos.xchan='ao0';
            exp.Pos.ychan='ao1';
            
            % configuring reader.
            if(exp.SystemConfig.UseAnalogInputA0)
                exp.Devices.set('n_analog_input','reader',NI6321AnalogReader(niDevName));
                exp.Reader.readchan='ai0';
            else
                exp.Devices.set('ni_counter','reader',NI6321Counter(niDevName));
                exp.Reader.ctrName='ctr0';
            end
            
            % configuring clock.
            if(exp.SystemConfig.UseInternalClock)
                exp.Devices.set('ni_clock','clock',NI6321Clock(niDevName));
                exp.Clock.ctrName='ctr3';
                clockTerm='pfi14';
            else
                
            end

            
            triggerTerm=clockTerm;

            exp.Pos.triggerTerm=triggerTerm;
            exp.Reader.externalClockTerminal=clockTerm;
            
            if(exp.SystemConfig.UseAnalogInputA0)
                exp.Reader.triggerTerm=triggerTerm;
            end
        end
        
        function resetStatusFlags(exp)
            exp.StatusFlags=struct(...
                'IsStreaming',false,...
                'IsScanning',false,...
                'IsSettingPosition',false,...
                'PossibleLossOfData',false...
                );            
        end
        
        function stopAllDevices(exp)
            disp('Stopping all devices and deleting flags');

            exp.resetStatusFlags();

            if(isa(exp.StreamDataCollector,'StreamCollector'))
                exp.StreamDataCollector.stop();
            end
            
            if(isa(exp.StreamDataCollector,'TimedDataCollector'))
                exp.StreamDataCollector.stop();
            end
            
            exp.StreamDataCollector=[];
            exp.ScanDataCollector=[];
            
            exp.IsWorking=false;
            
            exp.update('StatusFlags');
            
            disp('Deleted all dependencies now stopping sessions');
            
            % stopping sessions.
            try                
                exp.Clock.stop();
                exp.Reader.stop();
                exp.Pos.stop();         
            catch err
                disp(err.message);
            end
        end
        
    end
    
    % streaming.
    methods(Access = protected)
        function doStream(exp,isStreaming)
            if(~exp.HasBeenInitialized)
                return;
            end
            
            exp.stopAllDevices();
            exp.StatusFlags.IsStreaming=isStreaming;
            exp.update('StatusFlags');
            
            if(~isStreaming)
                disp('Stream was stopped');
                return;
            end
            
            % delete the scan collector.
            disp('Configuring stream');
            clockrate=exp.StreamConfig.ClockRate;
            
            if(exp.StreamConfig.AutoAdjustRates)
                clockrate=2.0/(exp.StreamConfig.IntegrationTime/1000);
                exp.StreamConfig.ClockRate=clockrate;
                exp.update('StreamConfig');
            end
            
            if(~isnumeric(clockrate) || clockrate<0)
                clockrate=1e4;
            elseif(clockrate>2e5)
                clockrate=2e5;
            elseif(clockrate<1)
                clockrate=1;
            end
 
            exp.Clock.setClockRate(clockrate);
            exp.Clock.clockFreq=clockrate*2;
            exp.Reader.setClockRate(clockrate*2);
            
            disp('Configuring data collector.');
            
            % configuring the data collector.
            exp.ConfigureStreamDataCollector(clockrate);
            
            disp('Prepare stream');
            
            % preparing
            exp.Reader.prepare();
            exp.Clock.prepare();
            
            disp('start collector');
            exp.StreamDataCollector.start();
            
            disp('Run stream');
            
            % running.
            exp.Reader.run();
            exp.Clock.run();
        end
        
        function ConfigureStreamDataCollector(exp,clockrate)
            exp.StreamDataCollector=StreamCollector(exp.Reader);
            %exp.StreamDataCollector.IntegrateDT=exp.StreamConfig.IntegrationTime;
            exp.StreamDataCollector.UpdateDT=exp.StreamConfig.UpdateTime;
            exp.StreamDataCollector.CollectDT=exp.StreamConfig.CollectionWindow;
            exp.StreamDataCollector.PadZeros=exp.StreamConfig.PadWithZeros;
            
            % adding callback.
            exp.StreamDataCollector.addlistener('DataReady',@exp.OnStreamDataReady);
            exp.StreamDataCollector.setClockRate(clockrate);            
        end
        
        % ccalled when the stream has ready data.
        function OnStreamDataReady(exp,s,e)
            if(~isa(exp.StreamDataCollector,'StreamCollector'))
                return;
            end
            scol=exp.StreamDataCollector;
            [data,dt]=scol.getData();
            if(isempty(data))
                return;
            end
            
            exp.ReaderAmplitude=...
                scol.CountsPerTimebase/...
                scol.timeUnitsToSecond;         
            [~,exp.StreamTrace]=StreamToTimedData(data,exp.StreamConfig.IntegrationTime,dt);
            exp.update({'StreamTrace','ReaderAmplitude'});
        end
    end
    
    % scanning
    methods(Access = private)
        % scan the x,y plan and get the counter result.
        function doScan(exp)
            % stop everything.
            isStreaming=exp.StatusFlags.IsStreaming;
            exp.stopAllDevices();
            
            exp.StatusFlags.IsStreaming=isStreaming;
            
            disp('Starting scan. Was streaming:');
            disp(isStreaming);
            exp.IsWorking=true;
            
            % Calculating scan params.
            n=exp.ScanParameters.N;
            x0=exp.ScanParameters.X;
            y0=exp.ScanParameters.Y;
            w=exp.ScanParameters.Width;
            h=exp.ScanParameters.Height;
            
            if(exp.ScanParameters.FromCenter)
                x0=x0-w/2;
                y0=y0-h/2;
            end
            
            dwell=exp.ScanParameters.Time;
            if(~exp.ScanParameters.AsDwellTime)
               dwell=dwell./(n^2);
            end
            
            exp.m_curScanDwellTime=dwell;
            
            % clock rates and configurations.
            % calculated by the position clock rate(niquist);
            posClockRate=floor(exp.ScanConfig.ClockRate);
            
            if(exp.ScanConfig.AutoAdjustRates)
                % needs recalculation according to dwell time.
                posClockRate=round(2./(dwell*exp.Pos.timeUnitsToSecond));
                % validating the rates to limits.
                exp.StatusFlags.PossibleLossOfData=false;
                if(posClockRate<1)
                    posClockRate=1;
                elseif(posClockRate*2>exp.ScanConfig.MaxClockRate)
                    posClockRate=floor(exp.ScanConfig.MaxClockRate);
                    exp.StatusFlags.PossibleLossOfData=true;
                end
                exp.ScanConfig.ClockRate=posClockRate;
                exp.update('ScanConfig');
            end
            
            measureClockRate=posClockRate*2;

            % updating paramteters.
            exp.StatusFlags.IsScanning=true;
            exp.update('StatusFlags');
            
            % uses external clock.
            exp.Pos.setClockRate(posClockRate);
            exp.Reader.setClockRate(measureClockRate); 
            exp.Clock.setClockRate(measureClockRate); % niquist.
            exp.Clock.clockFreq=measureClockRate;
            
            exp.Pos.clear();
            disp('Scanning:');
            disp(['@(',num2str(x0),',',num2str(y0),...
                ') +- (',num2str(w),',',num2str(h),') dt=',num2str(dwell),...
                ' ',num2str(n),' Points']);
            disp(['Measure Clock rate: ',num2str(measureClockRate),' Pos Clock Rate: ',posClockRate]);
            
            WriteImageScan(exp.Pos,x0,y0,w,h,n,n,dwell);
            exp.Pos.GoTo(exp.Position.X,exp.Position.Y); % go and wait 10ms.
            
            % configuring readers.
            if(exp.ScanConfig.ShowStream)
                exp.ConfigureStreamDataCollector(measureClockRate);
                exp.StreamDataCollector.start();
            end
            
            % configuring the timed bin collector.
            mbins=exp.ScanConfig.MeasureBinN;
            bint=(dwell*n^2)/mbins;
            if(bint<exp.ScanConfig.MeasureBinMinT)
                mbins=ceil((dwell*n^2)./exp.ScanConfig.MeasureBinMinT);
                bint=(dwell*n^2)/mbins;
            end
            
            mtbins=ones(mbins,1)*bint;
            disp(['Configured measurement timebins, sum: ',num2str(sum(mtbins)),...
                ' ?= ',num2str(dwell*n^2)]);
            
            disp(mtbins);
            
            exp.ScanDataCollector=TimedDataCollector(exp.Reader);
            exp.ScanDataCollector.setClockRate(measureClockRate);
            exp.ScanDataCollector.addlistener('Complete',...
                @exp.OnScanDataComplete);
            if(mbins>1)
            exp.ScanDataCollector.addlistener('TimebinComplete',...
                @exp.OnScanDataBinComplete);
            end
            exp.ScanDataCollector.Measure(mtbins);
            exp.ScanDataCollector.start();
            
            exp.Pos.prepare();
            exp.Reader.prepare();
            exp.Clock.prepare();
            
            exp.Pos.run();
            exp.Reader.run();
            exp.Clock.run();
        end
        
        function OnScanDataComplete(exp,s,e)
            % finalizing.
            if(~isa(exp.ScanDataCollector,'TimedDataCollector'))
                return;
            end            
            wasStreaming=exp.StreamingCounterState;
            rslts=exp.ScanDataCollector.Results;
            exp.ScanDataCollector.stop();
            if(isa(exp.StreamDataCollector,'StreamCollector'))
                exp.StreamDataCollector.stop();
            end
            exp.stopAllDevices();
            exp.ProcessScanResults(rslts);

            exp.IsWorking=false;
            exp.update('IsWorking');
            if(wasStreaming)
                exp.doStream(true);
            end
        end
        
        function OnScanDataBinComplete(exp,s,e)
            if(~isa(exp.ScanDataCollector,'TimedDataCollector'))
                return;
            end
            exp.ProcessScanResults(exp.ScanDataCollector.Results);
        end
        
        function ProcessScanResults(exp,rslts)
            n=exp.ScanParameters.N;
            exp.ScanImage=StreamToImageData(rslts,n,n,exp.m_curScanDwellTime);
            exp.update('ScanImage');            
        end
    end

    % cleanup and debug
    methods
        function delete(exp)
            try
                exp.stopAllDevices();
            catch err
            end
        end
        
        function debugStoreCurrentStateToDisk(exp,ignoreList)
            if(~exist('ignoreList','var'))
                ignoreList={'ScanDataCollector','StreamDataCollector',...
                    'Devices','ExpInfo','Clock','Pos','Reader'};
            end
            debugStoreCurrentStateToDisk@ExperimentCore(exp,ignoreList);
        end
    end
    
    % testing
    
    methods
        
        function tester(exp)
            exp.OnStreamDataReady([],[]);
        end
        
        function testLoop(exp)
            exp.OnUpdateLoop();
        end
    end
    
end















