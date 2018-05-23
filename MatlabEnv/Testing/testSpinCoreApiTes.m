if(~exist('api','var'))
    api=SpinCoreAPI;
    api.Load;
    api.Init;
else
    api.Reset;
end

api.SetClock(100e6); %100Mhz;
uptime=10e-3;
donwtime=10e-3;

%% Pulse loop.
api.StartProgramming;
api.Instruct(0,api.INST_LOOP,10,1e-6);
api.Instruct(0,api.INST_CONTINUE,0,uptime);
api.Instruct(api.ALL_FLAGS_ON,api.INST_CONTINUE,0,donwtime);
api.Instruct(0,api.INST_END_LOOP,0,1e-6);
api.StopProgramming;

%% Done programming. running.
api.Start;
