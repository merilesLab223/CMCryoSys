classdef APTobj < handle
    
    %A simple class to super-class the APT devices which will also work for
    %the APT server
    
    properties
        %The ActiveX Program ID.  This can be obtained from actxcontrollist
        progID
        %The handle to the ActiveX control 
        controlHandle 
        %The window to hide the control in
        figureHandle
        %Serial number to identify the device.  Get from APT User
        serialNum
        %Channel 0 selects channel 1 (default to 1 channel devices)
        HWChannel = 0;
    end
    
    
    methods
        %Constructor
        function obj = APTobj()
        end
        
        %Method to setup the control window and start the control
        function initialize(obj,progID,serialNum,figureHandle)
            
            obj.progID = progID;
            obj.figureHandle = figureHandle;
            obj.serialNum = serialNum;
            
            fprintf('Initializing APT ActiveX component %s....',progID);
         
            %Generate an invisible figure window
            figure(obj.figureHandle);
            set(obj.figureHandle,'Visible','off');

            %Initiate the activeX control
            obj.controlHandle = actxcontrol(obj.progID,[0 0 0 0],obj.figureHandle);
            
            %If we need to label it with the serial number
            if(~isempty(obj.serialNum))
                obj.controlHandle.HWSerialNum = obj.serialNum;
            end
            
            %Start the server
            obj.startCtrl;
            
            %Do any special initialization
            obj.subInit()
            
            fprintf('Done.\n');
        end
        
        %Method to call the StartCtrl method
        function startCtrl(obj)
            obj.controlHandle.StartCtrl();
        end
        
        %Method to call the StopCtrl method
        function stopCtrl(obj)
            obj.controlHandle.StopCtrl();
        end
        
        %Method to get the current status bits.  This works with most APT
        %objects but not all 
        function status = getStatus(obj,bits)
            [returnCode,status] = obj.controlHandle.LLGetStatusBits(obj.motorChannel,0);
            %Convert to unsigned unint32
            if(status < 0)
                status = status+2^32;
            end
            status = uint32(status);
            if(nargin>1)
                status = bitget(status,bits);
            end
        end
        
        %Destructor
        function delete(obj)
            
            %Stop control
            obj.stopCtrl();
            
            %Delete the ActiveX control
            delete(obj.controlHandle);
            
            %Close the hidden window
            close(obj.figureHandle);
        end
       
    end
    
    methods (Access = protected)
      function subInit(obj)
          %Nothing for the superclass
      end
    end
    
end

