classdef TimeBasedSignalGenerator < TimeBasedObject
    %SINGALGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % if true clear data after compile.
        clearDataAfterCompilation=false;
        
    end
    
    properties (Access = private)
        % a collection of timed events to be executed.
        % this collection will contain
        data={};
        timestamps=[];
        lastChanged=-1;
        lastCompiled=-1;
        lastSorted=-1;
        
        lastCompilationResult=[];
    end

    
    % state methods
    methods
        % Updates the last changed timestamp to current time.
        % Current validation state time marker. Use HasChanged(t) to see
        % if time sent is valid.
        function Invalidate(obj)
            obj.lastChanged=now;
        end
        
        % Returns true(1) if the object is valid (has not changed) for the timestamp t. 
        function [rslt]=HasChanged(obj,t)
            rslt=t<=obj.lastChanged;
        end
        
        % returns true of the signal generator needs compilation.
        function [rslt]=NeedsCompilation(obj)
            rslt=obj.HasChanged(obj.lastCompiled);
        end
    end
    
    % internal methods
    methods (Access = protected)
        % validates and updates the timestamp of name tname.
        function [rslt]=validateTimestampChange(obj,tname)
            if(~obj.HasChanged(obj.(tname)))
                rslt=0;
                return;
            end
            obj.(tname)=now;
            rslt=1;
        end

    end
    
    % data methods
    methods
        % called to sort the timed data
        function SortSequence(obj)
            if(~obj.validateTimestampChange('lastSorted'))return; end
            
            % sorting according to time.
            [c,sidx]=sort(obj.timestamps,'ascend');
            obj.timestamps=obj.timestamps(sidx);
            obj.data=obj.data(sidx);
        end
        
        % append data to the execution chain.
        function appendSequence(obj,data,thenWait)
            obj.insertSequence(obj.curT,data);
            if(exist('thenWait','var'))
                obj.wait(thenWait);
            end
        end
        
        function insertSequence(obj,t,data)
            obj.timestamps(end+1)=t;
            obj.data{end+1}=data;
            obj.Invalidate();
        end
        
        % Clear current data sequence.
        function clear(obj)
            obj.curT=0;
            obj.timestamps=[];
            obj.data={};
            obj.lastCompilationResult=[];
            obj.Invalidate();
        end
        
        % returns the minimal time between two positions not including
        % zeros.
        function [mint]=findMinimalTime(obj)
            [t,~]=obj.getRawSequence();
            t=sort(t);
            dt=diff(t);
            dt(dt==0)=[];
            if(isempty(dt))
                mint= obj.getTimebase();
                return;
            end
            mint=min(dt);
        end
    end
    
    % compilation methods
    methods
        % compile the data to make an execuatbale result.
        function [rslt]=compile(obj)
            if(~obj.validateTimestampChange('lastCompiled'))
                rslt=obj.lastCompilationResult;
                return; 
            end
            obj.SortSequence();
            rslt=obj.compileSequence(obj.timestamps,obj.data);
            if(obj.clearDataAfterCompilation)
                this.Clear();
            else
                obj.lastCompilationResult=rslt;
            end
        end
        
        % return the raw sequence for compilation.
        function [t,data]=getRawSequence(obj)
            obj.SortSequence();
            t=obj.timestamps;
            data=obj.data;
        end
    end
    
    % abstract compilation methods
    methods
        % should reutrn the sequence in the execution form.
        % sequence should also have data inside.
        % result is one parameter,cell or struct.
        function [rt]=compileSequence(obj,t,data)
            rt={};
        end
        
    end
    
end

