classdef ANC350API < DllAPI

    methods
        % Spincore library config.
		function [obj] = ANC350API(varargin)
            obj@DllAPI(varargin{:});
        end
    end
    
    % lib methods.
    properties (SetAccess = protected)
        LibraryHeaders={...
            ...'C:\Code\Attocube\Matlab\C\ANC350.config.h',...
            ...'C:\Code\Attocube\Matlab\include\ANC350\ancdecl.h',...
            'C:\Code\Attocube\Matlab\include\ANC350\anc350num.h',...
            'C:\Code\Attocube\Matlab\include\ANC350\anc350res.h',...
            };
        LibraryFile='C:\Code\Attocube\ANC350_Library\Win64\anc350v4.dll';
        LibraryName='ATTOCUBEANC350';
    end
    
    % initialization.
    methods (Access = protected)
        function [rt]=init(api)
            
            rt=true;
        end
    end
    
    % core methods
    methods
% 
% /** @brief Discover Devices
%  *
%  *  The function searches for connected ANC350RES devices on USB and LAN and
%  *  initializes internal data structures per device. Devices that are in use
%  *  by another application or PC are not found.
%  *  The function must be called before connecting to a device and must not be
%  *  called as long as any devices are connected.
%  *
%  *  The number of devices found is returned. In subsequent functions, devices
%  *  are identified by a sequence number that must be less than the number returned.
%  *  @param  ifaces    Interfaces where devices are to be searched
%  *  @param  devCount  Output: number of devices found
%  *  @return           Error code
%  */
% ANC_API Int32 WINCC ANC_discover( AttoCubeDeviceInterfaceType ifaces,
%                                   Uit32           * devCount );
        function [devnum]=discover(api)
            nptr=libpointer('uint32Ptr',0);
            err=api.Invoke('ANC_discover',...
                uint8(AttoCubeDeviceInterfaceType.IfAll),nptr);
            api.assert(err);
            devnum=nptr.Value;
        end
% 
% 
% /** @brief Device Information
%  *
%  *  Returns available information about a device. The function can not be
%  *  called before @ref ANC_discover but the devices don't have to be
%  *  @ref ANC_connect "connected" . All Pointers to output parameters may
%  *  be zero to ignore the respective value.
%  *  @param  devNo     Sequence number of the device. Must be smaller than
%  *                    the devCount from the last @ref ANC_discover call.
%  *  @param  devType   Output: Type of the ANC350 device
%  *  @param  id        Output: programmed hardware ID of the device
%  *  @param  serialNo  Output: The device's serial number. The string buffer
%  *                    should be NULL or at least 16 bytes long.
%  *  @param  address   Output: The device's interface address if applicable.
%  *                    Returns the IP address in dotted-decimal notation or the
%  *                    string "USB", respectively. The string buffer should be
%  *                    NULL or at least 16 bytes long.
%  *  @param  connected Output: If the device is already connected
%  *  @return           Error code
%  */
% ANC_API Int32 WINCC ANC_getDeviceInfo( Uit32            devNo,
%                                        ANC_DeviceType * devType,
%                                        Int32          * id,
%                                        Int8           * serialNo,
%                                        Int8           * address,
%                                        Bln32          * connected );
        function [devInfo]=getDeviceInfo(api,n)
            if(~exist('n','var'))n=0;end
            n=uint32(n);
            devInfo=struct();
            devInfo.devType=AttoCubeDeviceType.Anc350None;
            devInfo.id=int32(0);
            devInfo.serialNo=char(zeros(1,30));
            devInfo.address=char(zeros(1,30));
            devInfo.connected=int32(0);
            [devInfo,alst]=api.MakePointerStruct(devInfo);
            err=api.Invoke('ANC_getDeviceInfo',n,alst{:});
            api.assert(err);
            devInfo=api.FromPointerStruct(devInfo);
        end
% 
% 
% /** @brief Register IP Device in external Network
%  *
%  *  @ref ANC_discover is able to find devices connected via TCP/IP
%  *  in the same network segment, but it can't "look through" routers.
%  *  To connect devices in external networks, reachable by routing,
%  *  the IP addresses of those devices have to be registered prior to
%  *  calling @ref ANC_discover. The function registers one device and can
%  *  be called several times.
%  *
%  *  The function will return ANC_Ok if the name resolution succeeds
%  *  (ANC_NoDevice otherwise); it doesn't test if the device is reachable.
%  *  Registered and reachable devices will be found by @ref ANC_discover.
%  *  @param    hostname  Hostname or IP Address in dotted decimal notation
%  *                      of the device to register.
%  *  @return             Error code. ANC_NoDevice means here that the
%  *                      hostname could not be resolved. A return code of 0
%  *                      doesn't guarantee that the device is reachable.
%  */
% ANC_API Int32 WINCC ANC_registerExternalIp( const char * hostname );
        function registerExternalIp(api,hostname)
            hostname=DllAPI.MakePointerInfo(hostname);
            err=api.Invoke('ANC_registerExternalIp',hostname);
            delete(hostname);
            api.assert(err);
        end 
% 
% 
% /** @brief Connect Device
%  *
%  *  Initializes and connects the selected device.
%  *  This has to be done before any access to control variables or measured data.
%  *  @param  devNo      Sequence number of the device. Must be smaller than
%  *                     the devCount from the last @ref ANC_discover call.
%  *  @param  device     Output: Handle to the opened device, NULL on error
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_connect( Uit32        devNo,
%                                  ANC_Handle * device );
        function [devHndl]=connect(api,devnum)
            devHndl=libpointer('voidPtr');
            err=api.Invoke('ANC_connect',uint32(devnum),devHndl);
            api.assert(err);
        end
% 
% 
% /** @brief Disconnect Device
%  *
%  *  Closes the connection to the device. The device handle becomes invalid.
%  *  @param  device     Handle of the device to close
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_disconnect( ANC_Handle device );
        function disconnect(api,devHndl)
            err=api.Invoke('ANC_disconnect',devHndl);
            api.assert(err);
        end
% 
% 
% /** @brief Read Device Configuration
%  *
%  *  Reads static device configuration data
%  *  @param  device     Handle of the device to access
%  *  @param  features   Output: Bitfield of enabled features,
%  *                     see @ref FFlags "Feature Flags"
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_getDeviceConfig( ANC_Handle device,
%                                          Uit32    * features );
        function [fflags]=getDeviceConfig(api,devHndl)
            fflags=DllAPI.MakePointerInfo(AttoCubeDeviceFeature.App);
            err=api.Invoke('ANC_getDeviceConfig',devHndl,fflags.ptr);
            api.assert(err);
            fflags=DllAPI.FromPointerInfo(fflags);
        end   
% 
% 
% /** @brief Read Axis Status
%  *
%  *  Reads status information about an axis of the device.
%  *  All pointers to output values may be NULL to ignore the information.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  connected  Output: If the axis is connected to a sensor.
%  *  @param  enabled    Output: If the axis voltage output is enabled.
%  *  @param  moving     Output: If the axis is moving.
%  *  @param  target     Output: If the target is reached in automatic positioning
%  *  @param  eotFwd     Output: If end of travel detected in forward direction.
%  *  @param  eotBwd     Output: If end of travel detected in backward direction.
%  *  @param  error      Output: If the axis' sensor is in error state.
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_getAxisStatus( ANC_Handle device,
%                                        Uit32      axisNo,
%                                        Bln32    * connected,
%                                        Bln32    * enabled,
%                                        Bln32    * moving,
%                                        Bln32    * target,
%                                        Bln32    * eotFwd,
%                                        Bln32    * eotBwd,
%                                        Bln32    * error  );
        function [astatus]=getAxisStatus(api,devHndl, axis)
            astatus=struct();
            astatus.connected=int32(0);
            astatus.enabled=int32(0);
            astatus.moving=int32(0);
            astatus.target=int32(0);
            astatus.eotFwd=int32(0);
            astatus.eotBwd=int32(0);
            astatus.error=int32(0);
            
            [astatus,args]=DllAPI.MakePointerStruct(astatus);
            err=api.Invoke('ANC_getAxisStatus',devHndl,uint32(axis),args{:});
            api.assert(err);
            astatus=DllAPI.FromPointerStruct(astatus);
        end   
% 
% 
% /** @brief Enable Axis Output
%  *
%  *  Enables or disables the voltage output of an axis.
%  *  @param  device      Handle of the device to access
%  *  @param  axisNo      Axis number (0 ... 2)
%  *  @param  enable      Enables (1) or disables (0) the voltage output.
%  *  @param  autoDisable If the voltage output is to be deactivated automatically
%  *                      when end of travel is detected.
%  *  @return             Error code
%  */
% ANC_API Int32 WINCC ANC_setAxisOutput( ANC_Handle device,
%                                        Uit32      axisNo,
%                                        Bln32      enable,
%                                        Bln32      autoDisable );
        function setAxisOutput(api,hndl,axis,enabled,autoDisable)
            if(~exist('autoDisable','var'))
                autoDisable=true;
            end
            err=api.Invoke('ANC_setAxisOutput',hndl,uint32(axis),...
                int32(enabled),int32(autoDisable));
            api.assert(err);
        end
% 
% 
% /** @brief Set Amplitude
%  *
%  *  Sets the amplitude parameter for an axis
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  amplitude  Amplitude in V, internal resolution is 1 mV
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_setAmplitude( ANC_Handle device,
%                                       Uit32      axisNo,
%                                       double     amplitude );
       function setAmplitude(api,hndl,axis,amp)
            err=api.Invoke('ANC_setAmplitude',hndl,uint32(axis),...
                amp);
            api.assert(err);
       end
% 
% 
% /** @brief Set Frequency
%  *
%  *  Sets the frequency parameter for an axis
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  frequency  Frequency in Hz, internal resolution is 1 Hz
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_setFrequency( ANC_Handle device,
%                                       Uit32      axisNo,
%                                       double     frequency );
       function setFrequency(api,hndl,axis,freq)
            err=api.Invoke('ANC_setFrequency',hndl,uint32(axis),...
                freq);
            api.assert(err);
       end
% 
% 
% /** @brief Set DC Output Voltage
%  *
%  *  Sets the DC level on the voltage output when no sawtooth based
%  *  motion is active.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  voltage    DC output voltage [V], internal resolution is 1 mV
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_setDcVoltage( ANC_Handle device,
%                                       Uit32      axisNo,
%                                       double     voltage );
       function setDcVoltage(api,hndl,axis,v)
            err=api.Invoke('ANC_setDcVoltage',hndl,uint32(axis),...
                v);
            api.assert(err);
       end
% 
% 
% /** @brief Read back Amplitude
%  *
%  *  Reads back the amplitude parameter of an axis.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  amplitude  Output: Amplitude V
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_getAmplitude( ANC_Handle device,
%                                       Uit32      axisNo,
%                                       double   * amplitude );
       function [amp]=getAmplitude(api,hndl,axis)
            amp=DllAPI.MakePointerInfo(double(0));
            err=api.Invoke('ANC_getAmplitude',hndl,uint32(axis),...
                amp);
            api.assert(err);
            amp=DllAPI.FromPointerInfo(amp);
       end
% 
% 
% /** @brief Read back Frequency
%  *
%  *  Reads back the frequency parameter of an axis.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  frequency  Output: Frequency in Hz
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_getFrequency( ANC_Handle device,
%                                       Uit32      axisNo,
%                                       double   * frequency );
       function [freq]=getFrequency(api,hndl,axis)
            freq=DllAPI.MakePointerInfo(double(0));
            err=api.Invoke('ANC_getFrequency',hndl,uint32(axis),...
                freq);
            api.assert(err);
            freq=DllAPI.FromPointerInfo(freq);
       end
% 
% 
% /** @brief Single Step
%  *
%  *  Triggers a single step in desired direction.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  backward   If the step direction is forward (0) or backward (1)
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_startSingleStep( ANC_Handle device,
%                                          Uit32      axisNo,
%                                          Bln32      backward );
       function startSingleStep(api,hndl,axis,backward)
            err=api.Invoke('ANC_startSingleStep',hndl,uint32(axis),...
                int32(backward));
            api.assert(err);
       end
% 
% 
% /** @brief Continous Motion
%  *
%  *  Starts or stops continous motion in forward direction.
%  *  Other kinds of motions are stopped.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  start      Starts (1) or stops (0) the motion
%  *  @param  backward   If the move direction is forward (0) or backward (1)
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_startContinousMove( ANC_Handle device,
%                                             Uit32      axisNo,
%                                             Bln32      start,
%                                             Bln32      backward );
       function startContinousMove(api,hndl,axis,start,mvback)
            err=api.Invoke('ANC_startContinousMove',hndl,uint32(axis),...
                int32(start),int32(mvback));
            api.assert(err);
       end
% 
% 
% /** @brief Set Automatic Motion
%  *
%  *  Switches automatic moving (i.e. following the target position) on or off
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  enable     Enables (1) or disables (0) automatic motion
%  *  @param  relative   If the target position is to be interpreted
%  *                     absolute (0) or relative to the current position (1)
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_startAutoMove( ANC_Handle device,
%                                        Uit32      axisNo,
%                                        Bln32      enable,
%                                        Bln32      relative );
       function startAutoMove(api,hndl,axis,enable,relative)
            err=api.Invoke('ANC_startAutoMove',hndl,uint32(axis),...
                int32(enable),int32(relative));
            api.assert(err);
       end
% 
% 
% /** @brief Set Target Position
%  *
%  *  Sets the target position for automatic motion, see @ref ANC_startAutoMove.
%  *  For linear type actuators the position unit is m, for goniometers and
%  *  rotators it is degree.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  target     Target position [m] or [°]. Internal resulution is
%  *                     1 nm or 1 µ°.
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_setTargetPosition( ANC_Handle device,
%                                            Uit32      axisNo,
%                                            double     target );
       function setTargetPosition(api,hndl,axis,target)
            err=api.Invoke('ANC_setTargetPosition',hndl,uint32(axis),...
                double(target));
            api.assert(err);
       end
% 
% 
% /** @brief Set Target Range
%  *
%  *  Defines the range around the target position where the target is
%  *  considered to be reached.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  targetRg   Target range [m] or [°]. Internal resulution is
%  *                     1 nm or 1 µ°.
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_setTargetRange( ANC_Handle device,
%                                         Uit32      axisNo,
%                                         double     targetRg );
       function setTargetRange(api,hndl,axis,targetRg)
            err=api.Invoke('ANC_setTargetRange',hndl,uint32(axis),...
                double(targetRg));
            api.assert(err);
       end
% 
% 
% /** @brief Set Target Ground Flag
%  *
%  *  Sets or clears the Target GND Flag. It determines the action performed
%  *  in automatic positioning mode when the target position is reached.
%  *  If set, the DC output is set to 0V and the position control feedback
%  *  loop is stopped.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  targetGnd  Target GND Flag
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_setTargetGround( ANC_Handle device,
%                                          Uit32      axisNo,
%                                          Bln32      targetGnd );
       function setTargetGround(api,hndl,axis,targetGnd)
            err=api.Invoke('ANC_setTargetGround',hndl,uint32(axis),...
                int32(targetGnd));
            api.assert(err);
       end
% 
% 
% /** @brief Read Current Position
%  *
%  *  Retrieves the current actuator position.
%  *  For linear type actuators the position unit is m; for goniometers and
%  *  rotators it is degree.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  position   Output: Current position [m] or [°]
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_getPosition( ANC_Handle device,
%                                      Uit32      axisNo,
%                                      double   * position );
       function [pos]=getPosition(api,hndl,axis)
            pos=api.MakePointerInfo(double(0));
            err=api.Invoke('ANC_getPosition',hndl,uint32(axis),...
                pos);
            api.assert(err);
            pos=api.FromPointerInfo(pos);
       end
% 
% 
% /** @brief Firmware version
%  *
%  *  Retrieves the version of currently loaded firmware.
%  *  @param  device     Handle of the device to access
%  *  @param  version    Output: Version number
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_getFirmwareVersion( ANC_Handle device,
%                                             Int32    * version );
       function [ver]=getFirmwareVersion(api,hndl,axis)
            ver=api.MakePointerInfo(int32(0));
            err=api.Invoke('ANC_getFirmwareVersion',hndl,uint32(axis),...
                ver);
            api.assert(err);
            ver=api.FromPointerInfo(ver);
       end
% 
% 
% /** @brief Configure Trigger Input
%  *
%  *  Enables the input trigger for steps.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  mode       Disable (0), Quadratur (1), Trigger(2) for external triggering
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_configureExtTrigger( ANC_Handle device,
%                                              Uit32      axisNo,
%                                              Uit32      mode );
       function configureExtTrigger(api,hndl,mode)
            if(~exist('mode','var') || ~isa(mode,'AttoCubeTriggerType'))
                error('mode must be defined and of type AttoCubeTriggerType');
            end
            trig=api.MakePointerInfo(uint32(mode));
            err=api.Invoke('ANC_configureExtTrigger',hndl,uint32(axis),...
                trig);
            api.assert(err);
       end
% 
% 
% /** @brief Configure A-Quad-B Input
%  *
%  *  Enables and configures the A-Quad-B (quadrature) input
%  *  for the target position.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  enable     Enable (1) or disable (0) A-Quad-B input
%  *  @param  resolution A-Quad-B step width in m. Internal resolution
%  *                     is 1 nm.
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_configureAQuadBIn( ANC_Handle device,
%                                            Uit32      axisNo,
%                                            Bln32      enable,
%                                            double     resolution );
       function configureAQuadBIn(api,hndl,axis,enable,resolution)
            err=api.Invoke('ANC_configureAQuadBIn',hndl,uint32(axis),...
                int32(enable),double(resolution));
            api.assert(err);
       end
% 
% 
% /** @brief Configure A-Quad-B output
%  *
%  *  Enables and configures the A-Quad-B output of the current position.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  enable     Enable (1) or disable (0) A-Quad-B output
%  *  @param  resolution A-Quad-B step width in m; internal resolution is 1 nm
%  *  @param  clock      Clock of the A-Quad-B output [s]. Allowed range is
%  *                     40ns ... 1.3ms; internal resulution is 20ns.
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_configureAQuadBOut( ANC_Handle device,
%                                             Uit32      axisNo,
%                                             Bln32      enable,
%                                             double     resolution,
%                                             double     clock );
       function configureAQuadBOut(api,hndl,axis,enable,resolution,clock)
            err=api.Invoke('ANC_configureAQuadBOut',hndl,uint32(axis),...
                int32(enable),double(resolution),double(clock));
            api.assert(err);
       end
% 
% 
% /** @brief Configure Polarity of Range Trigger
%  *
%  *  Configure lower position for range Trigger.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  polarity   Polarity of trigger signal when position is
%  *                     between lower and upper Low(0) and High(1)
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_configureRngTriggerPol( ANC_Handle device,
%                                                 Uit32      axisNo,
%                                                 Uit32      polarity);
       function configureRngTriggerPol(api,hndl,axis,polarity)
            if(~exist('polarity','var') || ~isa(polarity,'AttoCubeTriggerPolarity'))
                error('polarity must be defined and of type AttoCubeTriggerPolarity');
            end
            err=api.Invoke('configureRngTriggerPol',hndl,uint32(axis),...
                int32(polarity));
            api.assert(err);
       end
% 
% /** @brief Configure Range Trigger
%  *
%  *  Configure lower position for range Trigger.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  lower	     Lower position for range trigger
%  *  @param  upper	     Upper position for range trigger
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_configureRngTrigger( ANC_Handle device,
%                                              Uit32      axisNo,
%                                              Uit32      lower,
%                                              Uit32      upper);
       function configureRngTrigger(api,hndl,axis,lower,upper)
            err=api.Invoke('ANC_configureRngTrigger',hndl,uint32(axis),...
                uint32(lower),uint32(upper));
            api.assert(err);
       end
% 
% /** @brief Configure Epsilon of Range Trigger
%  *
%  *  Configure hysteresis for range Trigger.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  epsilon    hysteresis in nm / mdeg
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_configureRngTriggerEps( ANC_Handle device,
%                                                 Uit32      axisNo,
%                                                 Uit32      epsilon);
       function configureRngTriggerEps(api,hndl,axis,epsilon)
            err=api.Invoke('ANC_configureRngTriggerEps',hndl,uint32(axis),...
                uint32(epsilon));
            api.assert(err);
       end
% 
% /** @brief Configure NSL Trigger
%  *
%  *  Enables NSL Input as Trigger Source.
%  *  @param  device     Handle of the device to access
%  *  @param  enable     disable(0), enable(1)
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_configureNslTrigger( ANC_Handle device,
%                                              Bln32      enable);
       function configureNslTrigger(api,hndl,enable)
            err=api.Invoke('ANC_configureNslTrigger',hndl,...
                int32(enable));
            api.assert(err);
       end
% 
% /** @brief Configure NSL Trigger Axis
%  *
%  *  Selects Axis for NSL Trigger.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo	   Axis number (0 ... 2)
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_configureNslTriggerAxis( ANC_Handle device,
%                                                  Uit32      axisNo);
       function configureNslTriggerAxis(api,hndl,axis)
            err=api.Invoke('configureNslTriggerAxis',hndl,uint32(axis));
            api.assert(err);
       end
% 
% 
% /** @brief Select Actuator
%  *
%  *  Selects the actuator to be used for the axis from actuator presets.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  actuator   Actuator selection (0 ... 255)
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_selectActuator( ANC_Handle device,
%                                         Uit32      axisNo,
%                                         Uit32      actuator );
       function selectActuator(api,hndl,axis,actuator)
            err=api.Invoke('ANC_selectActuator',hndl,uint32(axis)...
                ,uint32(actuator));
            api.assert(err);
       end
% 
% 
% /** @brief Get Actuator Name
%  *
%  *  Get the name of the currently selected actuator
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  name       Output: Name of the actuator as NULL-terminated c-string.
%  *                     The string buffer should be at least 20 bytes long.
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_getActuatorName( ANC_Handle device,
%                                          Uit32      axisNo,
%                                          Int8     * name );
       function [name]=getActuatorName(api,hndl,axis)
            name=api.MakePointerInfo(char(zeros(0,30)));
            err=api.Invoke('ANC_getActuatorName',hndl,uint32(axis)...
                ,name);
            api.assert(err);
            name=api.FromPointerInfo(name);
       end
% 
% 
% /** @brief Get Actuator Type
%  *
%  *  Get the type of the currently selected actuator
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  type       Output: Type of the actuator
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_getActuatorType( ANC_Handle         device, 
%                                          Uit32              axisNo,
%                                          ANC_ActuatorType * type );
       function [t]=getActuatorType(api,hndl,axis)
            t=api.MakePointerInfo(AttoCubeActuatorType.ActLinear);
            err=api.Invoke('getActuatorType',hndl,uint32(axis)...
                ,t);
            api.assert(err);
            t=api.FromPointerInfo(t);
       end
% 
% 
% /** @brief Measure Motor Capacitance
%  *
%  *  Performs a measurement of the capacitance of the piezo motor and
%  *  returns the result. If no motor is connected, the result will be 0.
%  *  The function doesn't return before the measurement is complete;
%  *  this will take a few seconds of time.
%  *  @param  device     Handle of the device to access
%  *  @param  axisNo     Axis number (0 ... 2)
%  *  @param  cap        Output: Capacitance [F]
%  *  @return            Error code
%  */
% ANC_API Int32 WINCC ANC_measureCapacitance( ANC_Handle   device,
%                                             Uit32        axisNo,
%                                             double     * cap );
       function [cap]=measureCapacitance(api,hndl,axis)
            cap=api.MakePointerInfo(double(0));
            err=api.Invoke('ANC_measureCapacitance',hndl,uint32(axis)...
                ,cap);
            api.assert(err);
            cap=api.FromPointerInfo(cap);
       end
    end
    
    methods
        function [msg]=translateError(err)
            msg='';
        end
        function assert(err,msg)
            if(~exist('msg','var'))msg='';end;
            if(err>0)
                error(['AttocubeAPI Found error on function call.',...
                    translateError(err),msg]);
            end
        end
        function delete(api)
            api.Unload();
        end
    end
end