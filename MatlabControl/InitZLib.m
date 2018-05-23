% Calls to include all the code in the associated libreries of Zav\Code
% in the dropbox.
function InitZLib()
    libpath=[fileparts(fileparts(mfilename('fullpath'))),'\MatlabEnv'];
    addpath(libpath);
    InitEnv();
end