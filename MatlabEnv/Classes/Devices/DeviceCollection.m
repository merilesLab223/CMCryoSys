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
    
    % listing methods
    methods
        function [names,devtypes]=ListLoaded(col)
            names=col.deviceByName.keys;
            devtypes=cell(size(names));
            devs=col.deviceByName.values;
            for i=1:length(names)
                devtypes{i}=class(devs{i});
            end
            %devtypes=class(col.deviceByName.values);
            [names,nidx]=sort(names);
            devtypes=devtypes(nidx);
        end

    end
    
    % display methods
    methods
        function disp(col)
            [names,devtypes]=col.ListLoaded();
            tc=sprintf('\t');
            disp(['Device collection with ',num2str(length(names)),' devices.']);
            [devtypes]=col.ListAvailable();
            disp('Available device types (.ListAvailable())');
            for i=1:length(devtypes)
                disp([tc,devtypes{i}]);
            end           
            if(~isempty(names))
                disp(tc);
                disp('Loaded devices by name (.ListLoaded()):');
                for i=1:length(names)
                    disp([tc,pad(names{i},40),' (',devtypes{i},')']);
                end
            end
        end
    end
    
    % helper methods
    methods (Static)
        function [isok]=ClassRoleFilter(name,dev,classname)
            isok=isa(dev,classname);
        end
        
        function [cnames]=ListAvailable(fpath,packageName)
            if(~exist('packageName','var'))
                packageName='';
            end
            if(~exist('fpath','var'))
                fpath=fileparts(mfilename('fullpath'));
            end
            dirinfo=dir(fpath);
            cnames={};
            for i=1:length(dirinfo)
                fp=dirinfo(i);
                if(strcmp(fp.name,'.') ||strcmp(fp.name,'..'))
                    continue;
                end
                if(fp.isdir)
                    [~,dn,~]=fileparts(fp.folder);
                    if(startsWith(dn,'+'))
                        packageName=[packageName,'.',dn];
                    end
                    icn=DeviceCollection.ListAvailable(...
                        [fp.folder,filesep,fp.name],packageName);
                    cnames(end+1:end+length(icn))=icn;
                else
                    [~,fn,ext]=fileparts(fp.name);
                    if(strcmp(ext,'.m') && ...
                            exist([packageName,fn],'class')>0)
                        % this is a class file.
                        sprc=superclasses([packageName,fn]);
                        if(any(strcmp(sprc,'Device')))
                            cnames{end+1}=[packageName,fn];
                        end
                    end
                end
            end
            if(~iscolumn(cnames))
                cnames=cnames';
            end
            cnames=sort(cnames);
        end        
    end
end

