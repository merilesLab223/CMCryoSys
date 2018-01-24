function testPausedCounting()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NI CONSTANTS %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    DAQmx_Val_Volts =  10348;
    DAQmx_Val_Rising = 10280; % Rising
    DAQmx_Val_Falling =10171; % Falling
    DAQmx_Val_CountUp =10128; % Count Up
    DAQmx_Val_CountDown =10124; % Count Down
    DAQmx_Val_ExtControlled =10326; % Externally Controlled
    DAQmx_Val_Hz = 10373; % Hz
    DAQmx_Val_Low =10214; % Low
    DAQmx_Val_ContSamps =10123; % Continuous Samples
    DAQmx_Val_GroupByChannel = 0;
    DAQmx_Val_Cfg_Default = int32(-1);
    DAQmx_Val_FiniteSamps =10178; % Finite Samples
    DAQmx_Val_Auto = -1;
    DAQmx_Val_WaitInfinitely = -1.0; %*** Value for the Timeout parameter of DAQmxWaitUntilTaskDone
    DAQmx_Val_DigLvl  = 10152 ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LibraryName = 'nidaqmx';
LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';

% load up the ni library
if  ~libisloaded(LibraryName),
    [pOk,warnings] = loadlibrary(LibraryFilePath,HeaderFilePath,'alias',LibraryName);
end

% create a task for counting
th = 0;
[a,b,th] = calllib(LibraryName,'DAQmxCreateTask','CounterTest',th);
th
CheckErrorStatus(a);

% create a counter channel

    [a] = calllib(LibraryName,'DAQmxCreateCICountEdgesChan',th,'/Dev1/Ctr0','',DAQmx_Val_Rising,0,DAQmx_Val_CountUp);
    CheckErrorStatus(a);
    
    % configure Pause channel for counter
    
    % pause on digital level
    [a] = calllib(LibraryName,'DAQmxSetPauseTrigType',th,DAQmx_Val_DigLvl); 
    CheckErrorStatus(a);
        
    % set pause source channel
    [a] = calllib(LibraryName,'DAQmxSetDigLvlPauseTrigSrc',th,'/Dev1/PFI7'); 
    CheckErrorStatus(a);
    
    % set pause ON when LOW
    [a] = calllib(LibraryName,'DAQmxSetDigLvlPauseTrigWhen',th, DAQmx_Val_Low); 
    CheckErrorStatus(a);
    
    % start the task
    [a] = calllib(LibraryName,'DAQmxStartTask',th);
    CheckErrorStatus(a);
    
    M = 100;
    Counts = zeros(M,1);
    for k=1:M,
        M(k) = ReadCounter(LibraryName,th);
    end
 
    hist(M);
    M
    % clean up
        [a] = calllib(LibraryName,'DAQmxClearTask',th);
        CheckErrorStatus(a);
end


function [c] = ReadCounter(LibraryName,th)

        c = 0;
        %count = uint32(0);
        %[status,count] = calllib(LibraryName,'DAQmxGetReadAvailSampPerChan',th,count);
        %CheckErrorStatus(status);
        %count
        TimeOut = 1;
        count = 0;
        pCount = libpointer('uint32Ptr',count);
        [status,count] = calllib(LibraryName,'DAQmxReadCounterScalarU32',th,TimeOut,pCount,[]);
        CheckErrorStatus(status);

        c = count;
        
        
%         if count > 0,
%             BufferData = zeros(1,count);
%             SizeOfBuffer = uint32(count);
%             pBufferData = libpointer('uint32Ptr', BufferData);
%             SampsPerChanRead = 0;
%             pSampsPerChanRead = libpointer('int32Ptr',SampsPerChanRead);
% 
%             % when calling the functions in Matlab, the resultant data is
%             % passed as an output from calllib instead of using a C-like
%             % pointer or passing by reference
%             [status,BufferData] = calllib(LibraryName,'DAQmxReadCounterU32',th,SizeOfBuffer,...
%                 1,BufferData,SizeOfBuffer,pSampsPerChanRead,[]);
%             CheckErrorStatus(status);
%             
%             c = BufferData;
% 
%         end


end
                
          
            
            

        function [BufferData] = ReadCounterBuffer(obj,TaskName,NumSamplesToRead)
            % C-reference
            %
            % int32 DAQmxReadCounterU32 (TaskHandle taskHandle, int32 numSampsPerChan,
            %       float64 timeout, uInt32 readArray[], uInt32 arraySizeInSamps, 
            %       int32 *sampsPerChanRead, bool32 *reserved);
            %
            
            % get task name
            th = obj.Tasks(TaskName);
            
            % allocate buffer memory
            BufferData = zeros(1,NumSamplesToRead);
            
            % size of buffer
            SizeOfBuffer = uint32(NumSamplesToRead);
            pBufferData = libpointer('uint32Ptr', BufferData);
            SampsPerChanRead = 0;
            pSampsPerChanRead = libpointer('int32Ptr',SampsPerChanRead);
            
            % when calling the functions in Matlab, the resultant data is
            % passed as an output from calllib instead of using a C-like
            % pointer or passing by reference
            [status,BufferData] = calllib(obj.LibraryName,'DAQmxReadCounterU32',th,SizeOfBuffer,...
                obj.DAQmx_Val_WaitInfinitely,BufferData,SizeOfBuffer,pSampsPerChanRead,[]);
            
                % Error Check
                obj.CheckErrorStatus(status);
        end

function CheckErrorStatus(ErrorCode)

    if ErrorCode == 0,
        Code = ErrorCode;
        ErrorString  = '';
        return;
    end

    % get the required buffer size
   BufferSize = 0;
   [BufferSize] = calllib('nidaqmx','DAQmxGetErrorString',ErrorCode,[],BufferSize);
   % create a string of spaces
   ErrorString = char(32*ones(1,BufferSize));
   % now get the actual string
   [a,ErrorString] = calllib('nidaqmx','DAQmxGetErrorString',ErrorCode,ErrorString,BufferSize);
   warning(['NIDAQ_Driver Error!! -- ',datestr(now),char(13),num2str(ErrorCode),'::',ErrorString]);
   
end