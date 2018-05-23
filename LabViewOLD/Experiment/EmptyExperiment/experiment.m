% EXAMPLE EXPERIMENT FILE. (Class must have the same name as file).
% Parameters are auto updated if the types are:
% (string,real,complex,1D array (real/complex),2D array(real/complex),path)
% All functions should have at least one parameter (exp). 
classdef experiment < ExperimentCore
    % propeties that may be synced. 
	properties
		SomeProperty=0;
		SomeStringProp='';
		SomeArrayProp=[];
    end

	methods
		function run(exp)
            % called to run the experiment.
		end

		function loop(exp)
            % called when the experiment is running for the experiment
            % loop.
			exp.SomeProperty=rand()*100;
        end
        
        function update(exp)
            % called when on update events (used to update to display)
            % and/or any other parameters.
            fprintf('parameters updated.');
        end
        
        function init(exp)
          % called to initialize the factorization.
        end
    end
    
    % properties that may not tbe synced.
    properties (Access = private)
    end
    
end