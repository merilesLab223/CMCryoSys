classdef DummySignalGenerator < SignalGenerator
    
    methods
        
        function  obj = SignalGenerator()
        end
        
        function [obj] = armSweep(obj)
        end
        
        function  [obj] = setFrequency(obj)
            obj.Frequency = obj.Frequency;
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function  [obj] = setAmplitude(obj)
            obj.Amplitude = obj.Amplitude;
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function  [obj] = setSweepStart(obj)
            obj.SweepStart = obj.SweepStart;
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function  [obj] = setSweepStop(obj)
            obj.SweepStop = obj.SweepStart;
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function  [obj] = setSweepStep(obj)
        end
        
        function  [obj] = setSweepPoints(obj)
            obj.SweepPoints = obj.SweepPoints;
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function  [obj] = setFrequencyMode(obj)
            obj.FrequencyMode = obj.FrequencyMode;
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function  [obj] = setSweepMode(obj)
            obj.SweepMode = obj.SweepMode;
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function  [obj] = setSweepTrigger(obj)
            obj.SweepTrigger = obj.SweepTrigger;
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function  [obj] = setSweepPointTrigger(obj)
            obj.SweepPointTrigger = obj.SweepPointTrigger;
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function  [obj] = setSweepDirection(obj)
            obj.SweepDirection = obj.SweepDirection;
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function  [obj] = setRFOn(obj)
            obj.RFState = 1;
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function  [obj] = setRFOff(obj)
            obj.RFState = 0;
            notify(obj,'SignalGeneratorChangedState');
        end
        
        function [obj] = setSweepContinuous(obj)
        end
        
        function [obj] = setModulationOff(obj);
        end
        %Macro function to set all the sweeping parameters at once
        function  [obj] = setSweepAll(obj)
            obj.setSweepStart();
            obj.setSweepStop();
            obj.setSweepPoints();
            obj.setSweepMode();
            obj.setSweepTrigger();
            obj.setSweepPointTrigger();
            obj.setSweepDirection();
            obj.setSweepContinuous();
        end
        
        % get functions
        
        function  [obj] = getFrequency(obj)
            obj.Frequency = 2.87E+9;
        end
        
        function  [obj] = getAmplitude(obj)
            obj.Amplitude = -3;
        end
        
        function  [obj] = getSweepStart(obj)
            obj.SweepStart = 1.2e+9;
        end
        
        function  [obj] = getSweepStop(obj)
            obj.SweepStop = 1.6e+9;
        end
        
         function [obj] = getSweepDirection(obj)
            s = '';
            obj.SweepDirection = deblank(s);
        end 
        
        function  [obj] = getSweepPoints(obj)
            obj.SweepPoints = 5001;
        end
        
        function  [obj] = getSweepMode(obj)
            obj.SweepMode = 'STEP';
        end
        
        function  [obj] = getFrequencyMode(obj)
            obj.FrequencyMode = 'CW';
        end
        
        function  [obj] = getSweepTrigger(obj)
            obj.SweepTrigger = 'EXT';
        end
        
        function [obj] = open(obj)
        end
        
        function [obj] = close(obj)
        end
        
    end
    
end
