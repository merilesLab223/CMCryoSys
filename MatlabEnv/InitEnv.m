% call to init the enviroment, start expose and get all the other stuff
% running.
function InitEnv(configpath)
    [curdir]=fileparts(mfilename('fullpath'));
    [path]=fileparts(curdir);
    exposePath=[path,'\Expose\Matlab'];
    addpath(exposePath);
    IncludeLib;
    IncludeLib(curdir);
    if(~exist('configpath','var'))
        configpath=[curdir,'/Config/configure_system.m'];
    end
    
    addpath(fileparts(configpath));
    run(configpath);
end