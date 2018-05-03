classdef DeviceCollection < handle
    %DEVICECOLLECTION Summary of this class goes here
    %   A collection of devices and rolles where each device may have its
    %   current role. 
    
    methods
        function obj = DeviceCollection()
        end
    end
    
    properties
        % all devices by name.
        devices=struct;
        roles=struct;
        allowedRoles=struct;
    end
    
    methods
        function []=configureAllDevices(obj)
            fnames=fieldnames(obj.devices);
            for i=1:length(fnames)
                dn=fnames{i};
                disp(['Configuring dev ',dn]);
                if(~obj.hasDevice(dn))disp('NOT FOUND!');continue;end
                obj.getDevice(dn).configure();
                disp('OK');
            end
        end
        
        function []=configureAllRoles(obj)
            % call all devices to configure.
            fnames=fieldnames(obj.roles);
            for i=1:length(fnames)
                rn=fnames{i};
                disp(['Configuring role ',rn]);
                if(~obj.hasRoleDevice(rn))disp('NOT FOUND!');continue;end
                obj.getByRole(rn).configure();
                disp('OK');                
            end
        end
    end
    
    methods
        function []=set(obj,name,dev,role)
           if(~ischar(name))
               error('a device must have a name which is string.  Param "name"');
           end
           if(exist('role','var')) % case of [name, role, dev].
               dump=dev;
               dev=role;
               role=dump;
           else
               role=[];
           end
           if(~isobject(dev)) 
               error('Device not found. Please provide a device object. Param "dev"');
           end
           obj.setDevice(name,dev);
           if(~isempty(role))
               obj.setRole(role,name);
           end
        end
        function []=setDevice(obj,name,dev)
           if(~ischar(name))
               error('a device must have a name which is string.  Param "name"');
           end
           if(~isobject(dev)) 
               error('Device not found. Please provide a device object. Param "dev"');
           end
           dev.name=name;
           obj.devices.(name)=dev;
           obj.devices=obj.devices;
           
        end
        
        function [dev]=getDevice(obj,name)
           if(~ischar(name))
               error('a device must have a name which is string.  Param "name"');
           end
           dev=obj.devices.(name);
           if(~isobject(dev))
                error(['Device not found for name :',name]);
           end
        end
        
        function []=setRole(obj,role,devname)
           if(~ischar(devname))
               error('a device must have a name which is string.  Param "devname"');
           end
           
           if(~ischar(role))
               error('a role must be a string.  Param "role"');
           end
           obj.roles.(role)=devname;
           obj.roles=obj.roles;
        end
        
        function [devname]=getRoleDevice(obj,role)
            if(~ischar(role))
               error('a role must be a string.  Param "role"');
            end
            devname=obj.roles.(role);
            if(~ischar(devname))
               error(['Role "',role,'" not found.  Param "role"']);
               return;
            end
        end
        
        function [dev]=getByRole(obj,role)
            dev=obj.getDevice(obj.getRoleDevice(role));
            if(~isobject(dev))
                error(['Device not found for role :',role]);
            end
        end
        
        function [rslt]=hasDevice(obj,name)
           if(~ischar(name))
               error('a device must have a name which is string.  Param "name"');
           end     
           rslt=isfield(obj.devices,name);
        end
        
        function [rslt]=hasRole(obj,name)
           if(~ischar(name))
               error('a device must have a name which is string.  Param "name"');
           end           
           rslt=isfield(obj.roles,name);
        end
        
        function [rslt]=hasRoleDevice(obj,name)
            if(~obj.hasRole(name))rslt=false;return;end
            devname=obj.getRoleDevice(name);
            rslt=obj.hasDevice(devname);
        end
        
        function [rslt]=hasDeviceOrRole(obj,name)
           if(~ischar(name))
               error('a device must have a name which is string.  Param "name"');
           end
           rslt = obj.hasDevice(name) || obj.hasRole(name);            
        end
        
        function [rslt]=contains(obj,name)
            rslt=obj.hasDeviceOrRole(name);
        end
        
        function [dev]=getDeviceByRoleOrName(obj,name)
           if(~ischar(name))
               error('a device must have a name which is string.  Param "name"');
           end
           
           if(obj.hasRole(name))
               dev=obj.getByRole(name);
               return;
           end
           
           if(obj.hasDevice(name))
               dev=obj.getDevice(name);
               return;
           end
           
           error(['device or role not found, "',name,'"']);
        end
        
        function [dev]=get(obj,name)
            dev=obj.getDeviceByRoleOrName(name);
        end
        
        function delete(obj)
            try
                dvs=fieldnames(obj.devices);
                for i=1:length(dvs)
                    dev=obj.devices.(dvs{i});
                    if(ismethod(dev,'stop'))
                        dev.stop();
                    end
                end
            catch err
            end
        end
    end
end

