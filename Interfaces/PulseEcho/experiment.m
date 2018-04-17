classdef experiment < ExperimentCore
    % parameters that can be set and read.
    properties
    end
    
    % parameters that cannot be set from labview only read.
    properties (SetAccess = private)
        DataCol=[];
        IsConfigured=false;
        IsRunning=false;
    end
    
    methods
        % most of the changes should appear here.
        % called to run the experiment.
        function run(exp)
            % call to prepare the execution.
            exp.Devices.preapre();
            % run all devices but the trigger devices.
            exp.Devices.run();
            % run all triggering devices.
            exp.Devices.trigger();
            % check if is running.
            exp.IsRunning=true;
        end
        
        % calling to config devices.
        function init(exp)
            % call the function to config the devices.

            if(exp.IsConfigured)
                % make sure all roles are configured.
                exp.Devices.configureAllRoles();
                return;
            else
                exp.IsConfigured=true;
            end

            % hard connections.
            % port0/line1 ->USER1 ->PFI0 : Trigger.
            % pfi15->pfi14 : Clock loopback.
            % pfi8 (counter 0)->User2 : counter input)

            % adding devices.
            counter=NI6321Counter('Dev1');
            exp.Devices.set('pulse_echo_counter',counter);
            clock=NI6321Clock('Dev1'); % loopback clock.    
            exp.Devices.set('pulse_echo_clock',counter);
            pulseGen=SpinCoreTTLGenerator();
            exp.Devices.set('pulse_echo_generator',pulseGen);

            %% Configure device connections.
            counter.ctrName='ctr0';
            clock.ctrName='ctr3';
            clockTerm='pfi14';

            pulseGen.setClockRate(300e6);
            pulseGen.IsContinues=false;

            counter.externalClockTerminal=clockTerm;
            counter.IgnoreErrors=true;
            
            %% Configure the data collector.
            exp.DataCol=TimedDataCollector(counter);
            exp.DataCol.addlistener('TimebinComplete',@exp.binComplete);
            exp.DataCol.addlistener('Complete',@exp.finished);
            
            exp.Devices.configureAllDevices();
        end
        
        % called when each measuremed bin is complete.
        function binComplete(exp,s,e)
            
        end
        
        % the measurement has finished.
        function finished(exp,s,e)
            
        end        
    end
end

