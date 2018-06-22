classdef RhodeSchwarzSMA100TriggeredFG<RhodeSchwarzSMA100
    %RHODESCHWARZSMA100 Triggered function generation for RhodeSchwarzSMA100
    methods
        function [dev]=RhodeSchwarzSMA100TriggeredFG(varargin)
            dev@RhodeSchwarzSMA100(varargin{:});
        end
    end
    
    properties
        StartFrequency=0;
        EndFrequency=0;
        NumberOFSweepPoints=0;        
    end
    
    methods(Access = protected)
        function configureDevice(dev)
            dev.registerDeviceProperty(...
                ':FREQuency:START?','%f','StartFrequency',...
                ':FREQuency:START %f');
            dev.registerDeviceProperty(...
                ':FREQuency:STOP?','%f','EndFrequency',...
                ':FREQuency:STOP %f');
            dev.registerDeviceProperty(...
                ':SWEEP:POINTS?','%d','NumberOFSweepPoints',...
                ':SWEEP:POINTS %d');
            
            % call base configuration.
            configureDevice@RhodeSchwarzSMA100(dev);
        end
        
    end
    
    methods
        function prepare(dev)
            dev.send('SWE:RES:ALL');
            prepare@RhodeSchwarzSMA100(dev);
            dev.send('SOUR:FREQ:MODE SWE');
            dev.send('SOUR:SWE:MODE STEP');
        end
        
        function run(dev)
            run@RhodeSchwarzSMA100(dev);
            % arm the sweep.
        end
    end
end

