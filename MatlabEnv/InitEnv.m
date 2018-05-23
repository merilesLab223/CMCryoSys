% call to init the enviroment, start expose and get all the other stuff
% running.
function InitEnv()
    [curdir]=fileparts(mfilename('fullpath'));
    [path]=fileparts(curdir);
    exposePath=[path,'\Expose\Matlab'];
    addpath(exposePath);
    IncludeLib;
    IncludeLib(curdir);
end