%% Codefile to start the matlab labview enviroment.
% this file should be called on the funtion init.

global LabViewSYSTEMAPIStartTime;
LabViewSYSTEMAPIStartTime=now;

% VERY IMPORTANT, Pause in labview will cause access violation
% between the diffrent running threads. DO NOT USE PAUSE.
pause off;