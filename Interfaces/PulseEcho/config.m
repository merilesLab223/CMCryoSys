% configs the devices and the general info. Exp is sent to allow for 
% the config to know what sent it.
function config(exp)
    if(~exist('exp','var')||~isa(exp,'ExperimentCore'))
        error('To run config you must use an Experiment implementation');
    end
    
    %% Configuring data colector;
    
end

