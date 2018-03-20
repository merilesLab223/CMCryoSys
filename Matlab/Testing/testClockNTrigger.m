% make the counter.ctr
if(exist('trigger','var'))
    trigger.stop();
    clear clock;
    clear trigger;
end
trigger=NI6321TTLGenerator('Dev1');
clock=NI6321Clock('Dev1');

clock.ctrName='ctr3'; % no counter
clock.triggerTerm='PFI0';
trigger.ttlchan='port0/line1';

%% configure and run.
clock.configure();
trigger.configure();

disp('Configured');

%% Make trigger output.
trigger.clear(); % Make the trigger output info.
trigger.Pulse(10,10);

%% prepare the counters.
clock.prepare();
trigger.prepare();
disp('Prepared');

%% run.
clock.run();
disp('Running clock running. Waiting for tigger.');
pause(1);
trigger.run();
disp('Trigged.');

pause(2);

clock.stop();
trigger.stop();
disp('Complete');