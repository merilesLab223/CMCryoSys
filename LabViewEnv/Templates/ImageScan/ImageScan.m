% Implements an experiment image scan core code.
% this matlab code allows the execution and creation of the image scan.
% can be used as templates.
classdef ImageScan < Experiment
    % properits collection to be copied to matlab.
    % together with events this will provide the main data collection.
    
    % Property collections for the image scanner.
    properties
        % Current position info.
        Position=[];
        % The scan configuration. parameters shared to all scans.
        ScanConfig=[];
        % System general configuration.
        SystemConfig=[];
        % The positioner configuration. parameters shared to all positions.
        PositionConfig=[];
        % The current scan paramters.
        ScanParameters=[];
        % The current stream parameters.
        StreamConfig=[];
    end
    
    % Read only property collections
    properties(SetAccess = protected)
        % The last scanned/loaded image properties.
        ImageProperties=struct(); 
        % Information about temp files and loaded file.
        FileInfo=struct();
    end
    
    % Indicators.
    properties
        % The last stream trace collected.
        StreamTrace=[]; 
        % A mterix representing the last scan image.
        ScanImage=[]; 
        % If true, then updates the current state of the stream reading.
        IsStreamingReader=false;
        % Mean indication of the last read reader avg amplitude. 
        ReaderAmplitude=0;
        % If true when the position value changes then the position is 
        % automatically set to the output positioner.
        PositionTracking=false;
        % The scan progress in precentage.
        ScanProgress=0;
        % True if currently saving the stream to file.
        IsSavingStreamToFile=false;
        % True if currently the RF channel is set top open(up,1)
        IsRFChanOpen=false;
        % True if currently the Laser channel is set top open(up,1)
        IsLaserChanOpen=false;
    end
    
    % Read only indicators.
    properties(SetAccess = protected)
        % if true the image scan has been initialized.
        HasBeenInitialized=false;
        % if true then currenly working (scanning, initializing etc..).
        IsWorking=false;
        % helper status flag collection (can be any flag).
        StatusFlags=struct();
    end
    
    % Stream operation values
    properties
        StreamStorageFile='';   
    end
    
    % Helper classes
    properties(SetAccess = protected)
        % the data collector to be used when scanning.
        ScanDataCollector=[];
        % the data collector to be used to for the stream.
        StreamDataCollector=[];
    end
    
    properties(Access = private)
        m_ScanDataCollector=[];
        m_StreamDataCollector=[];
    end
    
    % Helper classes getters and setters.
    methods
        function [col]=get.StreamDataCollector(exp)
            % returns the stream data colletctor.
            if(isempty(exp.m_StreamDataCollector))
                exp.m_StreamDataCollector=StreamCollector(exp.Reader);
                exp.m_StreamDataCollector.addlistener('DataReady',@exp.OnStreamDataReady);
            end
            col=exp.m_StreamDataCollector;
        end
        function [col]=get.ScanDataCollector(exp)
            % returns the scan data colletctor.
            if(isempty(exp.m_ScanDataCollector))
                exp.m_ScanDataCollector=TimeBinCollector(exp.Reader);
                exp.m_ScanDataCollector.addlistener('BinComplete',@exp.OnScanDataBinComplete);
                exp.m_ScanDataCollector.addlistener('Complete',@exp.OnScanDataComplete);
            end
            col=exp.m_ScanDataCollector;
        end        
    end
    
    % Devices
    properties(SetAccess = private)
        Pos;
        Gate;
        Reader;
        Clock;
    end
        
    % Devices (Getters and initializers)
    methods
        % returns the poisitioer.
        function [dev]=get.Pos(exp)
            dev=exp.Devices.getOrCreate('NI6321Positioner2D',...
                'xchan','ao0','ychan','ao1','niDevID','Dev1');
        end
        
        function [dev]=get.Gate(exp)
            if(~isfield(exp.SystemConfig,'UseInternalClock') ||...
                    ~exp.SystemConfig.UseInternalClock)
                dev=exp.Clock;
                return;
            end
            dev=exp.Devices.getOrCreate('SpinCoreClock');
        end
        
        % get the exp.Clock.
        function [dev]=get.Clock(exp)
            dev=exp.Devices.getOrCreate('SpinCoreClock');
        end
        
        function [dev]=get.Reader(exp)
            %returns the reader device.
            if(isfield(exp.SystemConfig,'UseAnalogInputA0') &&...
                exp.SystemConfig.UseAnalogInputA0)
                % as analog.
                dev=exp.Devices.getOrCreate('NI6321AnalogReader',...
                    'readchan','ai0','niDevID','Dev1');
            else
                dev=exp.Devices.getOrCreate('NI6321Counter',...
                    'ctrName','ctr0','niDevID','Dev1');   
            end
        end
    end

    % internal properties, to be used with other properties getters and setters.
    properties (Access = private)
        m_has_been_initialzied=false;
        m_is_working=false;
        m_pos_value=struct('X',0,'Y',0);
        m_position_config=struct();
        m_lastUpdateLoopUIUpdate=-1;
        m_isRFChanOpen=true;
        m_isLaserChanOpen=true;
    end

    % Getters and setters (advanced property handling).
    methods
        function [rt]=get.PositionConfig(exp)
            % get the current position value.
            rt=exp.m_position_config;
        end
        
        function set.PositionConfig(exp,v)
            % set the current position value. Updates the device.
            if(~exist('v','var'))
                v=struct();
            end
            exp.m_position_config=v; % to allow auto update.
            if(exp.HasBeenInitialized)
                exp.updatePositionConfig();
            end
        end
        
        function [rt]=get.Position(exp)
            % get the current position value.
            rt=exp.m_pos_value;
        end
        
        function set.Position(exp,v)
            % set the current position value. If PositionTracking, then
            % sends the position to the device.
            if(~exist('v','var'))
                v=struct('X',0,'Y',0);
            end
            exp.m_pos_value=v; % to allow auto update.
            if(exp.PositionTracking)
                exp.updatePosition();
            end
        end
        
        function [rt]=get.IsStreamingReader(exp)
            % If true then we are currently streaming.
            rt=getFieldOrDefault(exp.StatusFlags,'IsStreaming',false);
        end
        
        
        function set.IsStreamingReader(exp,isStreaming)
            % Sets the current stream states and updates the output
            % for the stream, clocks and gates (if changed).
            if(~exist('isStreaming','var'))
                isStreaming=false;
            end
            if(exp.IsStreamingReader==isStreaming)
                return;
            end
            exp.StatusFlags.IsStreaming=isStreaming;
            exp.updateStreamAndGates();
            exp.update('IsStreamingReader');
        end
        
        function [rt]=get.HasBeenInitialized(exp)
            % get the current operational state.
            rt=exp.m_has_been_initialzied;
        end
        
        function set.HasBeenInitialized(exp,v)
             % set the current operational state.
            if(~exist('v','var'))
                v=false;
            end
            exp.m_has_been_initialzied=v; % to allow auto update.
            exp.update('HasBeenInitialized');
        end          
        
        function [rt]=get.IsWorking(exp)
            % True if working. (Initializing, scanning etc...
            rt=exp.m_is_working;
        end
        
        function set.IsWorking(exp,v)
            % set the current working state.
            if(~exist('v','var'))
                v=false;
            end
            exp.m_is_working=v; % to allow auto update.
            exp.update('IsWorking');
        end    

        function set.IsSavingStreamToFile(exp,v)
            % if true, tells that the current stream is being saved to
            % file.
            exp.IsSavingStreamToFile=v;
            if(v~=true)
                exp.StreamStorageFile='';
            end
        end
        
        function set.IsRFChanOpen(exp,val)
            % if true, then sets the current RF channel to open (rf switch
            % open).
            if(exp.m_isRFChanOpen==val)
                return;
            end
            exp.m_isRFChanOpen=val;
            if(~isempty(exp.Gate))
                exp.updateStreamAndGates();
            end
        end
        
        function [rt]=get.IsRFChanOpen(exp)
            % if true, then the current RF channel to open (rf switch
            % open).            
            rt=exp.m_isRFChanOpen;
        end
        
        function set.IsLaserChanOpen(exp,val)
            % if true, then the current Laser channel to open (laser switch
            % open).              
            if(exp.m_isLaserChanOpen==val)
                return;
            end
            exp.m_isLaserChanOpen=val;
            if(~isempty(exp.Gate))
                exp.updateStreamAndGates();
            end
        end
        
        function [rt]=get.IsLaserChanOpen(exp)
            % if true, then the current Laser channel to open (laser switch
            % open).               
            rt=exp.m_isLaserChanOpen;
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
            % set the current position and update the device.
            exp.Position.X=x;
            exp.Position.Y=y;
            %exp.update('Position');
            exp.updatePosition(false);
        end
        
        function updatePosition(exp,delayed)
            % send the current position to device. (Update the position)
            if(~exist('delayed','var') || ~isnumeric(delayed))
                delayed=1;
            end            
            if(delayed==0)
                exp.inv_updatePosition();
            end
            if(isempty(exp.m_positionInvokeUpdateEventDispatch))
                exp.m_positionInvokeUpdateEventDispatch=events.CSDelayedEventDispatch();
                addlistener(exp.m_positionInvokeUpdateEventDispatch,'Ready',...
                    @exp.inv_updatePosition);
            end
            exp.m_positionInvokeUpdateEventDispatch.trigger(delayed);            
        end

        function updatePositionConfig(exp)
            % call to update the position config into the device.
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
    
    methods (Access = private)
        function inv_updatePosition(exp,s,e)
            if(~exp.HasBeenInitialized)
                return;
            end            
            % call to update the position.
            if(exp.StatusFlags.IsScanning || exp.StatusFlags.IsSettingPosition)
                % cannot change position while scanning.
                exp.m_positionUpdateCalledWhileUpdatingPosition=true;
                return;
            end
            
            exp.StatusFlags.IsSettingPosition=true;
            exp.m_positionUpdateCalledWhileUpdatingPosition=false;
            exp.update('StatusFlags')
            
            exp.Pos.stop();
            exp.Pos.clear();

            % set the single access clock rate.
            exp.Pos.setClockRate(1000);
            exp.Pos.triggerTerm=[];
            exp.Pos.externalClockTerminal=[];

            exp.Pos.GoTo(exp.Position.X,exp.Position.Y);
            exp.Pos.prepare();
            exp.Pos.run();
            %exp.Pos.run();
            pause(0.1);
            exp.Pos.stop();
            
            exp.StatusFlags.IsSettingPosition=false;
            exp.update('StatusFlags');
            
            disp(['Updated galvo positions to (x,y) ',num2str(exp.Position.X),...
                ', ',num2str(exp.Position.Y)]);
            
            % redo if needed.
            if(exp.m_positionUpdateCalledWhileUpdatingPosition)
                exp.updatePosition();
            end
        end        
    end
    
    % stream, status and gate methods
    methods
        function updateStreamAndGates(exp)
            if(~exp.HasBeenInitialized)
                return;
            end
            % call to update the current state of the action flags
            % i.e. Stream, Laser, RF.
            if(~exp.IsStreamingReader)
                exp.stop();
            end
            exp.updateClockFlags(~exp.IsStreamingReader);
            if(exp.IsStreamingReader)
                exp.doStream(true);
            end
        end
        
        function updateClockFlags(exp,sendToDevice)
            if(~exp.HasBeenInitialized)
                return;
            end            
            if(~exist('sendToDevice','var'))
                sendToDevice=true;
            end
            exp.Clock.SetOutput([3,5],[exp.IsLaserChanOpen,exp.IsRFChanOpen]...
                ,sendToDevice,exp.SystemConfig.MaxStaticLaserOnTime);
        end
    end
    
    % public methods.
    methods
        function init(exp)
            disp('Initialzing image scanner..');
            % initializes the experiment.
            exp.resetStatusFlags();
            exp.IsWorking=true;
            
            % updating device configs.
            exp.updatePositionConfig();
            
            % marking initialized.
            exp.HasBeenInitialized=true;
            
            % calling the stream (and configuring it).
            exp.doStream(exp.StatusFlags.IsStreaming);
            
            % set is working.
            exp.IsWorking=false;
            
            % update the rf channels if needed.
            exp.IsRFChanOpen=exp.IsRFChanOpen;
            exp.IsLaserChanOpen=exp.IsLaserChanOpen;
            disp('Image scanner initialization complete.');
        end

        function scan(exp)
            % Start the scan with current configuration.
            exp.doScan();
        end
        
        function stream(exp)
            % Set the stream to true and start streaming.
            exp.IsStreamingReader=true;
        end
        
        function stop(exp)
            % stopping all the devices.
            exp.stopAllDevices();            
        end
        
        function LoadImage(exp,fpath)
            % call to load an image as the graph data.
            % any image format that is allowed by matlab imread.            
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
            % save the current scan result to an image.
            if(~exist('saveMatFile','var') || ~islogical(saveMatFile))
                saveMatFile=true;
            end
            img=double(exp.ScanImage);
            medMul=20;
            imgmax=max(img(:));
            imgmin=min(img(:));
            img=(img-imgmin)./(imgmax-imgmin);
            medVal=median(img(img(:)~=0));
            if(medVal==0)
                medVal=mean(img(:));
            end
            if(medVal==0)
                startMaxIdx=0;
                endMinIdx=65001;
            else
                startMaxIdx=floor(65000*medVal/medMul);
                endMinIdx=ceil(65000*medVal*medMul);
                if(endMinIdx>65000)
                    endMinIdx=65001;
                end                
            end
            %startMaxIdx=0;
            %endMinIdx=60000;
            cmap=jet(endMinIdx-startMaxIdx);
            startmap=zeros(startMaxIdx,3);
            endmap=zeros(65000-endMinIdx,3);
            endmap(:,1)=1;
            cmap=[startmap;cmap;endmap];
            
            img=ind2rgb(uint16(img*65000),cmap);
            imwrite(img,fpath);
            if(saveMatFile)
                img=exp.ScanImage;
                save([fpath,'.mdata.mat'],'img');
            end
        end
        
        function SetStreamSaveFile(exp,fpath)
            % Starts saving the stream to file.
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
                exp.update({'ScanImage','ImageProperties'});
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
    % device private values
    properties(Access = private)
        m_stopDevicesEvDispatch=[];
    end

    % Device protected methods
    methods (Access = protected)
        function doAsyncStopAllDevices(exp,s,e)
            % async call to stop all devices.
            exp.stopAllDevices(false);
        end
        
        function stopAllDevices(exp,async)
            % call to stop all devices.
            
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
            exp.StreamDataCollector.stop();
            exp.ScanDataCollector.stop();
            exp.resetStatusFlags();
            exp.IsWorking=false;
            exp.update('StatusFlags');
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
            exp.Reader.IsContinuous=true;
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
            % configuring options.
            exp.StreamDataCollector.UpdateDT=exp.StreamConfig.UpdateTime;
            exp.StreamDataCollector.CollectDT=exp.StreamConfig.CollectionWindow;
            exp.StreamDataCollector.PadZeros=exp.StreamConfig.PadWithZeros;
            exp.StreamDataCollector.IntegrationTime=exp.StreamConfig.IntegrationTime;
            
            % adding callback.
            exp.StreamDataCollector.setClockRate(clockrate);            
        end
        
        % ccalled when the stream has ready data.
        function OnStreamDataReady(exp,s,e)
            if(~isvalid(exp))
                return;
            end
            
            if(~isa(exp.StreamDataCollector,'StreamCollector'))
                return;
            end
            
            scol=exp.StreamDataCollector;
            exp.ReaderAmplitude=scol.MeanV;
            [strm,dt]=scol.getData();
%             if(isempty(data))
%                 return;
%             end            
%             [~,strm]=...
%                 StreamToTimedData(data,exp.StreamConfig.IntegrationTime,dt);
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
            end
        end
    end
    
    % Scan internal propeties
    properties (Access = private)
        m_curScanDwellTime=0;
        m_activeTempFile=[];
        m_lastRawImg=[];
    end
    
    % Scanning methods
    methods(Access = private)
        % scan the x,y plan and get the counter result.
        function doScan(exp)
            % first stop all devices.
            exp.stopAllDevices();
            exp.updateClockFlags(false);
            
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
                totalTime=dwell;
                dwell=dwell./(n^2);
            else
                totalTime=(n^2)*dwell;
            end
            totalTime=totalTime+dwell*10;
            
            exp.m_curScanDwellTime=dwell;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% checking for temp file.
            if(exp.ScanConfig.SaveTempFiles)
                % need to save temp files while scanning.
                tmpname=['(',num2str(x0,5),',',num2str(y0,5),')+',...
                    '(',num2str(w),'x',num2str(h),') ',num2str(dwell,5),'[ms]'];
                exp.m_activeTempFile=exp.getNextScanTempFile(tmpname);
            else
                tmpname=[];
                exp.m_activeTempFile=[];
            end
            
            exp.updateTempFileList();
            exp.FileInfo.DisplayedFile=tmpname;
            
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
            exp.ImageProperties.startOffset=0.21+exp.Pos.secondsToTimebase(1/exp.Pos.Rate);
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

            exp.ScanDataCollector.clear();
            exp.ScanDataCollector.setClockRate(measureClockRate);
            exp.ScanDataCollector.Measure(mtbins);

            %%%%%%%%%%%%%%%%%%%%%%%%%
            % prepare and run.
            exp.m_lastRawImg=[];
            
            % preparing the streaming reader chunk size.
            exp.Reader.IsContinuous=false;
            exp.Reader.Duration=totalTime*2;
            exp.Reader.SetMaxReadChunkSize(maxchunk);
            exp.ScanDataCollector.reset();
            exp.StreamDataCollector.reset();
            
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
        
        
        function OnScanDataBinComplete(exp,s,e)
            if(~isvalid(exp))
                return;
            end
            if(~isa(exp.ScanDataCollector,'TimeBinCollector'))
                return;
            end
            exp.ProcessScanResults(e.Data,...
               exp.ScanDataCollector.CompleatedPercent);
        end
        
        function ProcessScanResults(exp,rslts,comp)
            n=exp.ScanParameters.N;
            
            img=StreamToImageData(rslts,n,n,...
                exp.m_curScanDwellTime,exp.ScanParameters.MultiDir,...
                exp.ImageProperties.startOffset,exp.m_lastRawImg);
            
            exp.m_lastRawImg=img;
            img=uint16(img);
            exp.setScanImage(img);
            exp.ScanProgress=comp;
            exp.update({'ScanProgress'});
%             if(~isempty(exp.m_activeTempFile))
%                 
%             end
        end
        
        function OnScanDataComplete(exp,s,e)
            if(~isvalid(exp))
                return;
            end
            % finalizing.
            if(~isa(exp.ScanDataCollector,'TimeBinCollector'))
                return;
            end
            wasStreaming=exp.IsStreamingReader;
            exp.ScanDataCollector.stop();
            if(isa(exp.StreamDataCollector,'StreamCollector'))
                exp.StreamDataCollector.stop();
            end

            exp.IsWorking=false;
            exp.update('IsWorking');
            
            % call to stop;
            exp.stopAllDevices(false);
            
            if(wasStreaming)
                exp.doStream(true);
            end
            exp.updatePosition(true);
            exp.IsLaserChanOpen=exp.IsLaserChanOpen;
            exp.IsRFChanOpen=exp.IsLaserChanOpen;
        end
        
        function [fn]=getNextScanTempFile(exp,name)
            [tempdir]=fileparts(mfilename('fullpath'));
            tempdir=[tempdir,filesep,'TempImages'];
            if(~exist(tempdir,'dir'))
                mkdir(tempdir);
            end
            % cleaning old files if needed.
            exp.cleanupTempAndLeaveN(tempdir,exp.ScanConfig.MaxNumberOfTempFiles);
            % making the new temp file name.
            fn=[datestr(now,'yymmdd.HHMMSS'),'.',name,'.mat'];
            % make the file.
            img=struct();
            save([tempdir,filesep,fn],'img','-v7.3');
        end
        
        function updateTempFileList(exp)
%             [tempdir]=fileparts(mfilename('fullpath'));
%             tempdir=[tempdir,filesep,'TempImages'];
%             exp.DisplayInfo.TempFileList={};
%             if(exist(tempdir,'dir'))
%                 tinfo=dir(tempdir);
%                 names=tinfo(:).name(:);
%                 isdirs=tinfo(:).isdir(:);
%                 exp.DisplayInfo.TempFileList=names(~isdirs);
%             else
%                 exp.DisplayInfo.TempFileList={};
%             end
        end
    end
    
    methods(Static)
        % cleanup the files in the directory and leave last n.
        function cleanupTempAndLeaveN(fpath,N)
            if(~exist(fpath,'dir'))
                error(['Path not found or is not a folder: ',fpath]);
            end
            dinfo=dir(fpath);
            names=dinfo(:).name;
            mtimes=dinfo(:).datenum;
            isdir=dinfo(:).isdir;
            
            names=names(~isdir);
            mtimes=mtimes(~isdir);
            nf=length(mtimes);
            if(nf>N)
                [~,idxs]=sort(mtimes);
                names=names(idxs);
                for i=1:(nf-N)
                    % delete the file.
                    delete([fpath,filesep,names{i}]);
                end
            end
        end        
    end

    % cleanup and debug
    methods
        function delete(exp)
            exp.stop();
        end
        
        function debugStoreCurrentStateToDisk(exp,ignoreList)
            if(~exist('ignoreList','var'))
                ignoreList={'ScanDataCollector','StreamDataCollector',...
                    'Devices','ExpInfo','Clock','Pos','Reader'};
            end
            debugStoreCurrentStateToDisk@ExperimentCore(exp,ignoreList);
        end
        
        function testReloadImage(exp)
            %[img,updatedIndex]=StreamToI
            tic;
            exp.m_lastRawImg=[];
            exp.ProcessScanResults(exp.ScanDataCollector.Results,...
               exp.ScanDataCollector.CompleatedPercent);
            toc;
        end
        
        function testReloadReadBatch(exp,idx)
            if(~exist('idx','var'))
                idx=length(exp.ScanDataCollector.Results);
            end
            tic;
            exp.ProcessScanResults(exp.ScanDataCollector.Results{idx},...
               exp.ScanDataCollector.CompleatedPercent);
            toc;
        end
    end
end















