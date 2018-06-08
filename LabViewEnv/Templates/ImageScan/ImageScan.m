% Implements an experiment image scan core code.
% this matlab code allows the execution and creation of the image scan.
% can be used as templates.
classdef ImageScan < Experiment
    % properits collection to be copied to matlab.
    % together with events this will provide the main data collection.
    
    % UI Properties
    % Some of these are copied to labview.
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
        IsStreamingReader=[];
        ReaderAmplitude=0;
        PositionTracking=false;
        ScanProgress=0;
        ImageProperties=struct();
        StreamStorageFile='';
        IsSavingStreamToFile=false;
    end
    
    % privately set properties.
    % will not be copied to Labview.
    properties(SetAccess = protected)
        ScanDataCollector=[];
        StreamDataCollector=[];
        HasBeenInitialized=false;
        IsWorking=false;
        StatusFlags=struct();
        
    end
    
    % internal properties, to be used with other parameters.
    properties (Access = private)
        m_has_been_initialzied=false;
        m_is_working=false;
        m_pos_value=struct('X',0,'Y',0);
        m_position_config=struct();
        m_lastUpdateLoopUIUpdate=-1;
    end

    % Getters and setters (advanced property handling).
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
                exp.sendPositionToDevice();
            end
        end
        
        % stream state getter.
        function [rt]=get.IsStreamingReader(exp)
            rt=false;
            if(isstruct(exp.StatusFlags) && isfield(exp.StatusFlags,'IsStreaming'))
                rt=exp.StatusFlags.IsStreaming; 
            end
        end
        
        % stream state setter
        function set.IsStreamingReader(exp,isStreaming)
            if(~exist('isStreaming','var'))
                isStreaming=false;
            end
            if(isStreaming)
                disp('Starting stream..');
            else
                disp('Stopping stream..');
            end
            exp.doStream(isStreaming);
            exp.update('IsStreamingReader');
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

        function set.IsSavingStreamToFile(exp,v)
            exp.IsSavingStreamToFile=v;
            if(v~=true)
                exp.StreamStorageFile='';
            end
        end
    end
    
    % positioning private properties
    properties(Access = private)
        m_positionUpdateCalledWhileUpdatingPosition=false;
        m_positionInvokeUpdateEventDispatch=[];
    end
    
    % Positioner methods
    methods
        function setPosition(exp,x,y)
            exp.Position.X=x;
            exp.Position.Y=y;
            exp.update('Position');
            exp.sendPositionToDevice();
        end
        
        function sendPositionToDevice(exp,delayed)
            if(~exist('delayed','var'))
                delayed=5;
            end
            
            if(isempty(exp.m_positionInvokeUpdateEventDispatch))
                exp.m_positionInvokeUpdateEventDispatch=events.CSDelayedEventDispatch();
                addlistener(exp.m_positionInvokeUpdateEventDispatch,'Ready',...
                    @exp.inv_sendPositionToDevice);
            end
            exp.m_positionInvokeUpdateEventDispatch.trigger(delayed);            
        end
        
        function inv_sendPositionToDevice(exp,s,e)
            if(exp.StatusFlags.IsScanning || exp.StatusFlags.IsSettingPosition)
                % cannot change position while scanning.
                exp.m_positionUpdateCalledWhileUpdatingPosition=true;
                return;
            end
            
            exp.StatusFlags.IsSettingPosition=true;
            exp.update('StatusFlags');
            
            exp.m_positionUpdateCalledWhileUpdatingPosition=false;
            
            exp.Pos.stop();
            exp.Pos.clear();

            % set the single access clock rate.
            exp.Pos.setClockRate(1000);
            exp.Pos.triggerTerm=[];
            exp.Pos.externalClockTerminal=[];
            
            exp.Pos.GoTo(exp.Position.X,exp.Position.Y);
            exp.Pos.prepare();
            exp.Pos.run();
            exp.Pos.stop();
            
            exp.StatusFlags.IsSettingPosition=false;
            exp.update('StatusFlags');
            
            disp(['Updated galvo positions to (x,y) ',num2str(exp.Position.X),...
                ', ',num2str(exp.Position.Y)]);
            
            % redo if needed.
            if(exp.m_positionUpdateCalledWhileUpdatingPosition)
                exp.sendPositionToDevice();
            end
        end
        
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
        
    end
    
    % public methods.
    methods
        % initializes the experiment devices.
        function init(exp)
            exp.resetStatusFlags();
            exp.IsWorking=true;
            
            % main device configurations.
            exp.initDevices('Dev1');
            
            % updating device configs.
            exp.updatePositionConfig();
            
            % marking initialized.
            exp.HasBeenInitialized=true;
            
            % calling the stream (and configuring it).
            exp.doStream(exp.StatusFlags.IsStreaming);
            
            % set is working.
            exp.IsWorking=false;
        end
        
        % call to scan.
        function scan(exp)
            exp.doScan();
        end
        
        % call to stream.
        function stream(exp)
            exp.doStream(true);
        end
        
        function stop(exp)
            % stopping all the devices.
            exp.stopAllDevices();            
        end
        
        % call to load an image as the graph data.
        % any image format that is allowed by matlab imread.
        function LoadImage(exp,fpath)
            img=imread(fpath);
            if(length(size(img))==3)
                img=rgb2gray(img)';
            else
                img=img';
            end
            
            simg=size(img);
            exp.setScanImage(img,[0,0,simg(1),simg(2)],true);         
            
        end
        
        function SaveScanToImage(exp,fpath,saveMatFile)
            if(~exist('saveMatFile','var'))
                saveMatFile=true;
            end
            img=double(exp.ScanImage);
            imgmed=median(img(:));
            mednorm=50;
            img(img>imgmed*mednorm)=imgmed*mednorm;
            img(img<imgmed/mednorm)=imgmed/mednorm;
            img=(img-min(img(:)))./(max(img(:))-min(img(:)));

            imwrite(img,fpath);
            if(saveMatFile)
                img=exp.ScanImage;
                save([fpath,'.mdata.mat'],'img');
            end
        end
        
        function SetStreamSaveFile(exp,fpath)
            [~,~,ext]=fileparts(fpath);
            if(~strcmp(ext,'.mat'))
                fpath=[fpath,'.mat'];
            end
            strm=[];
            try
                if(exist(fpath,'file'))
                    delete(fpath);
                end
                save(fpath,'strm','-v7.3');
                exp.StreamStorageFile=fpath;
                exp.IsSavingStreamToFile=true;
            catch err
                exp.StreamStorageFile='';
                exp.IsSavingStreamToFile=false;
                warning(err.message);
            end
            exp.update('IsSavingStreamToFile');
        end
    end
    
    % protected general methods
    methods(Access = protected)
        function setScanImage(exp,img,reg,fromCenter, doUpdate)
            if(~exist('fromCenter','var'))
                fromCenter=exp.ScanParameters.FromCenter;
            end
            if(~exist('reg','var'))
                reg=[exp.ScanParameters.X,exp.ScanParameters.Y,...
                    exp.ScanParameters.Width,exp.ScanParameters.Height];
            end
            if(~exist('doUpdate','var'))
                doUpdate=true;
            end
            tic;
            exp.ScanImage=img;
            simg=size(exp.ScanImage);
            exp.ImageProperties.Xn=simg(1);
            exp.ImageProperties.Yn=simg(2);
            exp.ImageProperties.X=reg(1);
            exp.ImageProperties.Y=reg(2);
            exp.ImageProperties.Width=reg(3);
            exp.ImageProperties.Height=reg(4);
            exp.ImageProperties.FromCenter=fromCenter;
            cidxs=find(img(:)>0);
            if(~isempty(cidxs))
                exp.ImageProperties.min=min(img(cidxs));
                exp.ImageProperties.max=max(img(cidxs));
                exp.ImageProperties.med=median(img(cidxs));
            else
                exp.ImageProperties.min=0;
                exp.ImageProperties.max=0;
                exp.ImageProperties.med=0;
            end
            %disp(['Update image dt: ',num2str(toc)]);
            if(doUpdate)   
                exp.update('ImageProperties',false);
                exp.update('ScanImage');
            end
        end
        
        function resetStatusFlags(exp)
            exp.StatusFlags=struct(...
                'IsStreaming',exp.IsStreamingReader,...
                'IsScanning',false,...
                'IsSettingPosition',false,...
                'PossibleLossOfData',false...
                );            
        end        
    end
    
    % devics get properties
    properties (SetAccess = protected)
        Pos=[];
        Clock=[];
        Reader=[];
        ScanDevices=[];
    end
    
    % device private values
    properties(Access = private)
        dev_posDevName='ni_analog_pos';
        dev_analogReaderDevName='ni_analog_reader';
        dev_countReaderDevName='ni_counter_reader';
        dev_niClock='ni_clock';
        dev_pbClock='pb_clock';
        m_stopDevicesEvDispatch=[];
    end
    
    % devices getters and setters
    methods
        % returns the poisitioer.
        function [dev]=get.Pos(exp)
            dev=exp.Devices.get(exp.dev_posDevName);
        end
        
        % get the exp.Clock.
        function [dev]=get.Clock(exp)
            if(isfield(exp.SystemConfig,'UseInternalClock') &&...
                    exp.SystemConfig.UseInternalClock)
                dev=exp.Devices.get(exp.dev_niClock);
            else
                dev=exp.Devices.get(exp.dev_pbClock);
            end
        end
        
        % get the reader.
        function [dev]=get.Reader(exp)
            if(isfield(exp.SystemConfig,'UseAnalogInputA0') &&...
                    exp.SystemConfig.UseAnalogInputA0)
                dev=exp.Devices.get(exp.dev_analogReaderDevName);
            else
                dev=exp.Devices.get(exp.dev_countReaderDevName);
            end
        end
        
        function [devList]=get.ScanDevices(exp)
            devList=exp.Devices.get({...
                exp.dev_analogReaderDevName,...
                exp.dev_countReaderDevName,...
                exp.dev_niClock,...
                exp.dev_pbClock,...
                exp.dev_posDevName});
        end
    end

    % Device methods
    methods (Access = protected)
        function initDevices(exp,niDevName)
            if(~exist('niDevName','var'))
                niDevName=[];
            end

            % Hardware connections.
            % port0/line1 ->USER1 ->PFI0 : Trigger.
            % pfi15->pfi14 : Clock loopback.
            % pfi8 (counter 0)->User2 : counter input)
            
            % devices:
%           dev_posDevName='ni_analog_pos';
%           dev_analogReaderDevName='ni_analog_reader';
%           dev_countReaderDevName='ni_counter_reader';
%           dev_niClock='ni_clock';
%           dev_pbClock='pb_clock';

            % configuring analog poisitioner.
            if(~exp.Devices.contains(exp.dev_posDevName))
                dev=NI6321Positioner2D(niDevName);
                exp.Devices.set(exp.dev_posDevName,dev);
                dev.xchan='ao0';
                dev.ychan='ao1';
            end
            
            % configuring analog reader.
            if(~exp.Devices.contains(exp.dev_analogReaderDevName))
                dev=NI6321AnalogReader(niDevName);
                exp.Devices.set(exp.dev_analogReaderDevName,dev);
                dev.readchan='ai0';
            end
            
            % configuring counter reader.
            if(~exp.Devices.contains(exp.dev_countReaderDevName))
                dev=NI6321Counter(niDevName);
                exp.Devices.set(exp.dev_countReaderDevName,dev);
                dev.ctrName='ctr0';
            end
            
            % configuring internal clock (ni).
            if(~exp.Devices.contains(exp.dev_niClock))
                dev=NI6321Clock(niDevName);
                exp.Devices.set(exp.dev_niClock,dev);
                dev.ctrName='ctr3';
            end
            
            % configuring pb clock.
            if(~exp.Devices.contains(exp.dev_pbClock))
                dev=SpinCoreClock();
                exp.Devices.set(exp.dev_pbClock,dev);
                %dev.setClockRate(300e6);
            end
        end

        % async call to stop all devices.
        function doAsyncStopAllDevices(exp,s,e)
            exp.stopAllDevices(false);
        end
        
        % call to stop all devices.
        function stopAllDevices(exp,async)
            % first stop the clock right away.
            if(exist('async','var') && async>0)
                if(isempty(exp.m_stopDevicesEvDispatch))
                    exp.m_stopDevicesEvDispatch=...
                        events.CSDelayedEventDispatch();
                    
                    exp.m_stopDevicesEvDispatch.addlistener(...
                        'Ready',@exp.doAsyncStopAllDevices);
                end
                exp.m_stopDevicesEvDispatch.trigger(double(async));
                return;
            end
            
            exp.Clock.stop();
            exp.Pos.stop();
            exp.Reader.stop();
            
            %disp('Stopped devices.');
            exp.resetStatusFlags();

            if(isa(exp.StreamDataCollector,'StreamCollector'))
                exp.StreamDataCollector.stop();
            end
            
            exp.deleteCollectors();
            
            exp.IsWorking=false;
            exp.update('StatusFlags');
        end 
        
        function deleteCollectors(exp)
            if(isa(exp.StreamDataCollector,'StreamCollector'))
                exp.StreamDataCollector.stop();
            end
            
            if(isa(exp.StreamDataCollector,'TimedDataCollector'))
                exp.StreamDataCollector.stop();
            end
            
            exp.StreamDataCollector=[];
            exp.ScanDataCollector=[];            
        end
    end
    
    % Streaming.
    methods(Access = protected)
        function doStream(exp,isStreaming)
            if(~exp.HasBeenInitialized)
                return;
            end
            
            % first stop all devices.
            exp.stopAllDevices(false);
            
            % update the current status.
            exp.StatusFlags.IsStreaming=isStreaming;
            exp.update('StatusFlags');
            
            if(~isStreaming)
                disp('Stream was stopped.');
                return;
            end
            
            % call to configure if needed.
            exp.Clock.configure();
            exp.Reader.configure();
            
            % Current configuration params.
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
            
            if(exp.SystemConfig.UseInternalClock)
                clockTerm='pfi14';
            else
                clockTerm='pfi0';
            end            
            
            readChunkSize=exp.StreamConfig.UpdateTime/...
                exp.Reader.secondsToTimebase(1/clockrate);
            
            % setting the device parameters.
            if(readChunkSize<100)
                readChunkSize=100;
            elseif(readChunkSize>5000)
                readChunkSize=5000;
            end
            
            % set device operation rate.
            if(exp.SystemConfig.UseInternalClock)
                exp.Clock.setClockRate(clockrate); % the same as the output.
            else
                exp.Clock.setClockRate(300e6); % 300Mhz. 
            end
            
            % setting the clock and reader.
            exp.Clock.clockFreq=clockrate;
            exp.Reader.setClockRate(clockrate);
            
            % setting trigger and external reader clock.
            triggerTerm=clockTerm;
            exp.Reader.externalClockTerminal=clockTerm;
            if(exp.SystemConfig.UseAnalogInputA0)
                exp.Reader.triggerTerm=triggerTerm;
            end
            
            % configuring the data collector.
            exp.ConfigureStreamDataCollector(clockrate);
            
            % preparing the streaming reader chunk size.
            exp.Reader.SetMaxReadChunkSize(readChunkSize);
            
            % Streaming...
            % preparing
            exp.Reader.prepare();
            exp.Clock.prepare();
            exp.StreamDataCollector.start();
            
            % running.
            exp.Reader.run();
            exp.Clock.run();
            
            disp('Streaming data from reader.');
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
            
            exp.ReaderAmplitude=scol.MeanV;
            
            [~,strm]=...
                StreamToTimedData(data,exp.StreamConfig.IntegrationTime,dt);
            exp.StreamTrace=uint16(strm);
            exp.update({'StreamTrace','ReaderAmplitude'});
    
            if(exp.IsSavingStreamToFile && ~isempty(exp.StreamStorageFile))
                strm=[e.TimeStamps,e.Data];
                lt=length(e.TimeStamps);
                mf=matfile(exp.StreamStorageFile,'Writable',true);
                smsize=size(mf,'strm');
                if(sum(smsize)==0)
                    mf.strm=strm;
                else
                    erow=smsize(1);
                    mf.strm(erow+1:erow+lt,:)=strm;                    
                end

                delete(mf);
                %save(exp.StreamStorageFile,'strm','-append');
            end
        end
    end
    
    % Scan internal propeties
    properties (Access = private)
        m_curScanDwellTime=0;
    end
    
    % Scanning methods
    methods(Access = private)
        % scan the x,y plan and get the counter result.
        function doScan(exp)
            % first stop all devices.
            exp.stopAllDevices();
            
            % call to configure (if needed, internal to configure).
            exp.Clock.configure();
            exp.Pos.configure();
            exp.Reader.configure();
            
            % set the flag, to show current is working.
            exp.IsWorking=true;
            
            % Calculating scan params.
            n=exp.ScanParameters.N;
            x0=exp.ScanParameters.X;
            y0=exp.ScanParameters.Y;
            w=exp.ScanParameters.Width;
            h=exp.ScanParameters.Height;
            
            % current image properties for the display.
            exp.ImageProperties.Xn=n;
            exp.ImageProperties.Yn=n;
            exp.ImageProperties.X=x0;
            exp.ImageProperties.Y=y0;
            exp.ImageProperties.Width=w;
            exp.ImageProperties.Height=h;
            exp.ImageProperties.FromCenter=exp.ScanParameters.FromCenter;
            exp.update('ImageProperties');
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % adjusting the scan parameters.
            
            % center?
            if(exp.ScanParameters.FromCenter)
                x0=x0-w/2;
                y0=y0-h/2;
            end
            
            % dewell time.
            dwell=exp.ScanParameters.Time;
            if(~exp.ScanParameters.AsDwellTime)
               dwell=dwell./(n^2);
            end
            
            exp.m_curScanDwellTime=dwell;
            
            % clock rates and configurations.
            % calculated by the position clock rate(niquist);
            measureClockRate=floor(exp.ScanConfig.ClockRate);
            
            % auto adjustmetnds.
            if(exp.ScanConfig.AutoAdjustRates)
                % needs recalculation according to dwell time.
                measureClockRate=round(2./(dwell*exp.Pos.timeUnitsToSecond));
                % validating the rates to limits.
                exp.StatusFlags.PossibleLossOfData=false;
                if(measureClockRate<1)
                    measureClockRate=1;
                elseif(measureClockRate>exp.ScanConfig.MaxClockRate)
                    measureClockRate=floor(exp.ScanConfig.MaxClockRate);
                    exp.StatusFlags.PossibleLossOfData=true;
                end
                exp.ScanConfig.ClockRate=measureClockRate;
                exp.update('ScanConfig');
            end
            
            if(exp.SystemConfig.UseInternalClock)
                clockTerm='pfi14';
            else
                clockTerm='pfi0';
            end
            
            triggerTerm=clockTerm;
                                    
%             readChunkSize=exp.StreamConfig.UpdateTime/...
%                 exp.Reader.secondsToTimebase(1/measureClockRate);
%                         
%             % setting the device parameters.
%             if(readChunkSize<100)
%                 readChunkSize=100;
%             elseif(readChunkSize>5000)
%                 readChunkSize=5000;
%             end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Set info to devices.

            % setting triggers and clock terminals.
            exp.Reader.externalClockTerminal=clockTerm;
            exp.Pos.externalClockTerminal=clockTerm;
            exp.Pos.triggerTerm=triggerTerm;
            % analog clock requries trigger.
            if(exp.SystemConfig.UseAnalogInputA0)
                exp.Reader.triggerTerm=triggerTerm;
            end

            % setting the clock rates.
            exp.Pos.setClockRate(measureClockRate);
            exp.Reader.setClockRate(measureClockRate); 
            
            % setting the clock operation rate.
            if(exp.SystemConfig.UseInternalClock)
                exp.Clock.setClockRate(clockrate);
            else
                exp.Clock.setClockRate(300e6); % 300 Mhz.
            end
            % setting the clock freq.
            exp.Clock.clockFreq=measureClockRate;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Some display texts.
            disp(['Scanning @(',num2str(x0),',',num2str(y0),...
                ') +- (',num2str(w),',',num2str(h),') dt=',num2str(dwell),...
                ' ',num2str(n),' Points']);
            disp(['Measure Clock rate: ',num2str(measureClockRate)]);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % writing the image scan.
            exp.Pos.clear();
            WriteImageScan(exp.Pos,x0,y0,w,h,n,n,dwell,...
                'multidirectional',exp.ScanParameters.MultiDir,...
                'interpMethod','linear');
            
            exp.Pos.GoTo(exp.Position.X,exp.Position.Y,10); % goto X,Y after.
            
            % configuring readers.
            if(exp.ScanConfig.ShowStream)
                exp.ConfigureStreamDataCollector(measureClockRate);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % configuring the measurement.
            mbins=exp.ScanConfig.MeasureBinN;
            bint=(dwell*n^2)/mbins;
            if(bint<exp.ScanConfig.MeasureBinMinT)
                mbins=ceil((dwell*n^2)./exp.ScanConfig.MeasureBinMinT);
                bint=(dwell*n^2)/mbins;
            elseif(bint>exp.ScanConfig.MeasureBinMaxT)
                mbins=ceil((dwell*n^2)./exp.ScanConfig.MeasureBinMaxT);
                bint=(dwell*n^2)/mbins;
            end
            
            mtbins=ones(mbins,1)*bint;
            tickTime=exp.Reader.secondsToTimebase(1/measureClockRate);
            chnkdv=4;
            maxchunk=bint/(chnkdv*tickTime);
            
            while(maxchunk>4000)
                chnkdv=chnkdv+1;
                maxchunk=bint/(chnkdv*tickTime);
            end
            
            if(maxchunk<1)
                maxchunk=1;
            end
            maxchunk=round(maxchunk);

            exp.ScanDataCollector=TimeBinCollector(exp.Reader);
            exp.ScanDataCollector.setClockRate(measureClockRate);
            exp.ScanDataCollector.addlistener('Complete',...
                @exp.OnScanDataComplete);
            if(mbins>1)
            exp.ScanDataCollector.addlistener('BinComplete',...
                @exp.OnScanDataBinComplete);
            end
            exp.ScanDataCollector.Measure(mtbins);
            exp.ScanDataCollector.reset();
            exp.StreamDataCollector.reset();
            
            %%%%%%%%%%%%%%%%%%%%%%%%%
            % prepare and run.
            
            % preparing the streaming reader chunk size.
            exp.Reader.SetMaxReadChunkSize(maxchunk);
            
            % updating flags.
            exp.StatusFlags.IsScanning=true;
            exp.update('StatusFlags');            
            
            exp.Pos.prepare();
            exp.Reader.prepare();
            exp.Clock.prepare();
            exp.ScanDataCollector.prepare();
            exp.StreamDataCollector.prepare();            
            %exp.Pos.SetMaxReadChunkSize(-1);
            
            exp.Pos.run();
            exp.Reader.run();
            exp.ScanDataCollector.start();
            exp.StreamDataCollector.start();            
            
            % run the scan.
            exp.Clock.run();
        end
        
        function OnScanDataComplete(exp,s,e)
            % finalizing.
            if(~isa(exp.ScanDataCollector,'TimeBinCollector'))
                return;
            end   
            wasStreaming=exp.IsStreamingReader;
            rslts=exp.ScanDataCollector.Results;
            comp=exp.ScanDataCollector.CompleatedPercent;
            exp.ScanDataCollector.stop();
            if(isa(exp.StreamDataCollector,'StreamCollector'))
                exp.StreamDataCollector.stop();
            end

            exp.ProcessScanResults(rslts,comp);
            exp.IsWorking=false;
            exp.update('IsWorking');
            
            if(wasStreaming)
                exp.doStream(true);
            else
                exp.stopAllDevices(false);
            end
            exp.sendPositionToDevice(true);
        end
        
        function OnScanDataBinComplete(exp,s,e)
            if(~isa(exp.ScanDataCollector,'TimeBinCollector'))
                return;
            end
            exp.ProcessScanResults(exp.ScanDataCollector.Results,...
                exp.ScanDataCollector.CompleatedPercent);
        end
        
        function ProcessScanResults(exp,rslts,comp)
            n=exp.ScanParameters.N;
            toff=0.19+exp.Pos.secondsToTimebase(1/exp.Pos.Rate);
            img=uint16(StreamToImageData(rslts,n,n,...
                exp.m_curScanDwellTime,exp.ScanParameters.MultiDir,toff));
            exp.setScanImage(img);
%            exp.ScanImage=exp.ScanImage;
            exp.ScanProgress=comp;
            exp.update({'ScanProgress'});
        end
    end

    % cleanup and debug
    methods
        function delete(exp)
            exp.deleteCollectors();
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
        
        function testLoadRandomEye(exp,n,dt)
            if(~exist('n','var'))
                n=250;
            end
            if(~exist('dt','var'))
                dt=0.1;
            end
            
            exp.ImageProperties.Xn=n;
            exp.ImageProperties.Yn=n;
            exp.ImageProperties.X=0;
            exp.ImageProperties.Y=0;
            exp.ImageProperties.Width=n;
            exp.ImageProperties.Height=n;
            exp.ImageProperties.FromCenter=true;  
            exp.update('ImageProperties');
            while(true)
                img=eye(n)+rand(n);
                exp.setScanImage(uint16(img));
                %exp.ScanImage=uint16(img);
                pause(dt);
            end
        end
    end
end















