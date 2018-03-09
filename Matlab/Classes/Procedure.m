classdef Procedure < handle
    %PROCEDURE Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function obj = Procedure(obj)
        end
    end
    
    properties
        devices=DeviceCollection();
        curT=0;
        validateDevicesExist=true;
    end
    
    properties 
        event_data={};
        event_deviceNames={};
        event_times={};
        preprocess_calls={};
        postprocess_calls={};
        curDev=''; % no device throw error. Device must be set.        
    end
    
    % processing methods
    methods (Access = private)
        function SortTimedEvents(obj)
            % sorts the timed events.
        end
        
        % Compiles the data into command batches.
        function Compile(obj)
        end
        
        % runs the compile batches.
        function Run(obj)
        end
        
        function validateDevice(obj,devname)
            if(~ischar(devname))
                error('Device must be a char array. i.e. the name of the device or role.');
            end
            if(isempty(devname))
                error('Device not set. Please send a device name or set the current device (setCurDev)');
            end
            if(obj.validateDevicesExist && ~obj.devices.hasDeviceOrRole(devname))
                error(['Device not found, "',devname,'"']);
            end
        end
    end
    
    % operation methods.
    methods
        function clear(obj)
            obj.event_data={};
            obj.event_times={};
            obj.event_deviceNames={};
            obj.curT=0;
            obj.preprocess_calls={};
            obj.postprocess_calls={};
        end
        
        % sets the current device or role.
        function setCurRole(obj,devname)
            obj.setCurDev(devname);
        end
        function setCurDev(obj,devname)
            if(~ischar(devname))
                error('device name/role must be a string');
            end
            
            obj.validateDevice(devname);
            obj.curDev=devname;
        end
        
        function [dev]=getCurDev(obj)
            if(isempty(obj.curDev))
                error('Please set the current device. call setCurDev');
                return;
            end
            if(~obj.devices.hasDeviceOrRole(obj.curDev))
                error(['Device "',obj.curDev,'" not found.']);
            end
            dev=obj.devices.getDeviceByRoleOrName(obj.curDev);
        end

        % can have negative walues.
        function wait(obj,t)
            obj.curT=obj.curT+t;
        end

        % can have negative values.
        function goBackInTime(obj,t)
            obj.wait(-t);
        end

        function addEventAt(obj,t,f,dev)
            % adding execution to the timed array.
            if(~exist('dev','var'))dev=obj.curDev;end
            obj.validateDevice(dev);
            obj.event_times{end+1}=t;
            obj.event_data{end+1}=f;
            obj.event_deviceNames{end+1}=dev;
        end
        
        function addEvent(obj,f,dev)
            if(~exist('dev','var'))dev=obj.curDev;end
            obj.validateDevice(dev);
            obj.addEventAt(obj.curT,f,dev);
        end
        
        function addPreProcess(obj,f)
            obj.preprocess_calls{end+1}=f;
        end
        
        function addPostProcess(obj,f)
            obj.postprocess_calls{end+1}=f;
        end
    end
end

