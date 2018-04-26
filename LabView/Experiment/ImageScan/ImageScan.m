% Implements an experiment image scan core code.
% this matlab code allows the execution and creation of the image scan.
% can be used as templates.
classdef ImageScan < ExperimentCore
    
    % properits collection to be copied to matlab.
    % together with events this will provide the main data collection.
    properties
        Position=struct();
        ScanConfig=struct();
        StreamConfig=struct();
        StreamTrace=[]; % A value to update.
        ScanImage=[];
        TestControl='';
        SomeAr=[];
    end
    
    % privately set properties.
    % will not be copied to Labview.
    properties (SetAccess = private)
        PosDev=[];
        Devices=DeviceCollection();
    end
    
    % public methods accessable from labview.
    methods
        % initializes the experiment devices.
        function init(exp)
            
        end
    end
end