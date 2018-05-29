classdef DeviceCollection < handle
    %DEVICECOLLECTION Summary of this class goes here
    %   A collection of devices and rolles where each device may have its
    %   current role. 
    
    methods
        function obj = DeviceCollection()
            obj.deviceByName=containers.Map;
            obj.roleFiltersByName=containers.Map;
            
            obj.addRole('Positioner2D',...
                @(n,d)DeviceCollection.ClassRoleFilter(n,d,'Positioner2D'));
            obj.addRole('TTLGenerator',...
                @(n,d)DeviceCollection.ClassRoleFilter(n,d,'TTLGenerator'));  
            obj.addRole('Clock',...
                @(n,d)DeviceCollection.ClassRoleFilter(n,d,'Clock'));            
        end
    end
    
    properties (Access = protected)
        deviceByName=[];
        roleFiltersByName=[];
    end
    
    % collection methods
    methods
        % returns true if the current contains a device 
        % with the specified name.
        function [rt]=contains(col,name)
            rt=col.deviceByName.isKey(name);
        end
        
        % returns the device.
        function [dev]=get(col,name)
            dev=[];
            if(~col.contains(name))
                return;
            end
            if(ischar(name))
                dev=col.deviceByName(name);
            elseif(iscell(name))
                dev={};
                for i=1:length(name)
                    if(~ischar(name{i}))
                        continue;
                    end
                    dev{end+1}=col.get(name{i});
                end
            end
        end
        
        % sets the device by the name.
        function set(col,name,dev)
            col.deviceByName(name)=dev;
            if(isempty(dev.name))
                dev.name=name;
            end
        end
        
        % removes the device by the name.
        function remove(col,name)
            if(~col.contains(name))
                return;
            end
            col.deviceByName.remove(name);
        end
        
        % collection get.
        function varargout = subsref(col,id)
            switch(id(1).type)
                case '.'
                    [varargout{1:nargout}]=builtin('subsref',col,id);
                case '{}'
                   error('DeviceCollection:subsref',...
                      'Not a supported subscripted reference');
                otherwise
                    did=id.subs{1};                     
                    varargout{1}=col.get(did);
            end
        end        
    end
    
    %roles methods
    methods
        function addRole(col,name,roleFilter)
            col.roleFiltersByName(name)=roleFilter;
        end
        
        function removeRole(col,name)
            if(~col.roleFiltersByName.isKey(name))
                return;
            end
            col.roleFiltersByName.remove(name);
        end
        
        function [devlist]=getByRole(col,name)
            devlist={};
            if(~col.roleFiltersByName.isKey(name))
                return;
            end
            devs=col.deviceByName.values;
            names=col.deviceByName.keys;
            roleFilter=col.roleFiltersByName(name);
            for i=1:length(devs)
                if(~roleFilter(names{i},devs{i}))
                    continue;
                end
                devlist{end+1}=devs{i};
            end
        end
    end
    
    % helper methods
    methods (Static)
        function [isok]=ClassRoleFilter(name,dev,classname)
            isok=isa(dev,classname);
        end
    end
end
%     
%     methods
%         function []=configureAllDevices(obj)
%             fnames=fieldnames(obj.devices);
%             for i=1:length(fnames)
%                 dn=fnames{i};
%                 disp(['Configuring dev ',dn]);
%                 if(~obj.hasDevice(dn))disp('NOT FOUND!');continue;end
%                 obj.getDevice(dn).configure();
%                 disp('OK');
%             end
%         end
%         
%         function []=configureAllRoles(obj)
%             % call all devices to configure.
%             fnames=fieldnames(obj.roles);
%             for i=1:length(fnames)
%                 rn=fnames{i};
%                 disp(['Configuring role ',rn]);
%                 if(~obj.hasRoleDevice(rn))disp('NOT FOUND!');continue;end
%                 obj.getByRole(rn).configure();
%                 disp('OK');                
%             end
%         end
%     end
%     
%     methods
%         function []=set(obj,name,dev,role)
%            if(~ischar(name))
%                error('a device must have a name which is string.  Param "name"');
%            end
%            if(exist('role','var')) % case of [name, role, dev].
%                dump=dev;
%                dev=role;
%                role=dump;
%            else
%                role=[];
%            end
%            if(~isobject(dev)) 
%                error('Device not found. Please provide a device object. Param "dev"');
%            end
%            obj.setDevice(name,dev);
%            if(~isempty(role))
%                obj.setRole(role,name);
%            end
%         end
%         function []=setDevice(obj,name,dev)
%            if(~ischar(name))
%                error('a device must have a name which is string.  Param "name"');
%            end
%            if(~isobject(dev)) 
%                error('Device not found. Please provide a device object. Param "dev"');
%            end
%            dev.name=name;
%            obj.devices.(name)=dev;
%            obj.devices=obj.devices;
%            
%         end
%         
%         function [dev]=getDevice(obj,name)
%            if(~ischar(name))
%                error('a device must have a name which is string.  Param "name"');
%            end
%            dev=obj.devices.(name);
%            if(~isobject(dev))
%                 error(['Device not found for name :',name]);
%            end
%         end
%         
%         function []=setRole(obj,role,devname)
%            if(~ischar(devname))
%                error('a device must have a name which is string.  Param "devname"');
%            end
%            
%            if(~ischar(role))
%                error('a role must be a string.  Param "role"');
%            end
%            obj.roles.(role)=devname;
%            obj.roles=obj.roles;
%         end
%         
%         function [devname]=getRoleDevice(obj,role)
%             if(~ischar(role))
%                error('a role must be a string.  Param "role"');
%             end
%             devname=obj.roles.(role);
%             if(~ischar(devname))
%                error(['Role "',role,'" not found.  Param "role"']);
%                return;
%             end
%         end
%         
%         function [dev]=getByRole(obj,role)
%             dev=obj.getDevice(obj.getRoleDevice(role));
%             if(~isobject(dev))
%                 error(['Device not found for role :',role]);
%             end
%         end
%         
%         function [rslt]=hasDevice(obj,name)
%            if(~ischar(name))
%                error('a device must have a name which is string.  Param "name"');
%            end     
%            rslt=isfield(obj.devices,name);
%         end
%         
%         function [rslt]=hasRole(obj,name)
%            if(~ischar(name))
%                error('a device must have a name which is string.  Param "name"');
%            end           
%            rslt=isfield(obj.roles,name);
%         end
%         
%         function [rslt]=hasRoleDevice(obj,name)
%             if(~obj.hasRole(name))rslt=false;return;end
%             devname=obj.getRoleDevice(name);
%             rslt=obj.hasDevice(devname);
%         end
%         
%         function [rslt]=hasDeviceOrRole(obj,name)
%            if(~ischar(name))
%                error('a device must have a name which is string.  Param "name"');
%            end
%            rslt = obj.hasDevice(name) || obj.hasRole(name);            
%         end
%         
%         function [rslt]=contains(obj,name)
%             rslt=obj.hasDeviceOrRole(name);
%         end
%         
%         function [dev]=getDeviceByRoleOrName(obj,name)
%            if(~ischar(name))
%                error('a device must have a name which is string.  Param "name"');
%            end
%            
%            if(obj.hasRole(name))
%                dev=obj.getByRole(name);
%                return;
%            end
%            
%            if(obj.hasDevice(name))
%                dev=obj.getDevice(name);
%                return;
%            end
%            
%            error(['device or role not found, "',name,'"']);
%         end
%         
%         function [dev]=get(obj,name)
%             dev=obj.getDeviceByRoleOrName(name);
%         end
%         
%         function delete(obj)
%             try
%                 dvs=fieldnames(obj.devices);
%                 for i=1:length(dvs)
%                     dev=obj.devices.(dvs{i});
%                     if(ismethod(dev,'stop'))
%                         dev.stop();
%                     end
%                 end
%             catch err
%             end
%         end
%     end


