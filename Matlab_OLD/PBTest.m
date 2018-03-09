%Simple example of spincore. Spincore is primarily ran through a DLL file
%that is loaded at the startup of NV Command Ceneter and Image Acquire.
LibraryFile = 'C:\SpinCore\SpinAPI\lib\spinapi64.dll';
HeaderFile = 'C:\SpinCore\SpinAPI\include\spinapi.h';
LibraryName = 'pb';
PG = SpinCorePulseGenerator2();
%initialize and open headers and dll's        
PG.Initialize(LibraryFile,HeaderFile,LibraryName);

% set PG clock rate to 1MHz
% for SpinCore, clock rate is in units of MHZ
PG.setClockRate(3e8);
        
% init the pg
PG.init();
% set PG clock rate to 1MHz
% for SpinCore, clock rate is in units of MHZ
%the simplest sequenc you can do is simply turning a bit high and then low
%This is done in our matlab by using a command setLines
for i = 1:100
PG.stop();%make sure the PB isnt doing anything already
PG.setLines(1,1);%Set channel 1 to high in PB script
PG.start();%Turn on PB
PG.stop();
PG.setLines(0,1);%Same as before but turn off Channel 1
PG.start();
end
%see setlines code at the bottom for discussion

function [obj] = SpinCorePulseBlaster2(LibraryFile,LibraryHeader,LibraryName)
            obj.LibraryFile = LibraryFile;
            obj.LibraryHeader = LibraryHeader;
            obj.LibraryName = LibraryName;
end
		
function [obj] = Initialize(obj)
		if ~libisloaded(obj.LibraryName)
			loadlibrary(obj.LibraryFile,obj.LibraryHeader,'alias',obj.LibraryName);
		end
end

function [obj] = SetClock(obj,ClockRate)

     % NOTE!!!
     % Spin Core sets the clock in units of MHz, but controlling
     % software gives the clock in Hz, so must convert
     ClockRate = double(ClockRate/1e6);
     calllib(obj.LibraryName,'pb_core_clock',ClockRate);
end

function [obj] = setLines(obj,bHigh,controlLine)
            % setLines(bHigh,controlLine)
            %
            % bHigh = boolean value for line (0/1)
            % controlLine = line to set
            
            
            FlagInstr = bHigh*(2.^controlLine);
            %any sequence or script in written to the PB is started by the
            %Start programming command, this function simply calls a
            %command in the DLL that starts programming
            obj.hwHandle.StartProgramming();
            
            % A command consists of using the PBInstruction command
            % included below, the command takes a 24-bit binary number, and
            % opcode, a data field, and a duration. The 24-bit corresponds
            % to which channles will be high and low. The opcode is
            % decribed in the PB manual, we only ever useContinue, Long
            % Delay, branch, loop, and end loop. The data does different
            % things depending on the opcode, for continue it does nothing,
            % for branch it goes to the instruction at that position in
            % queue, in this case zero, or the first instruction. the
            % durration is in terms of clock cycle for the PB.
            
            % SET LINE FOR 500ns
            % instruction 0
            obj.hwHandle.PBInstruction(FlagInstr,obj.hwHandle.INST_CONTINUE,0,500);
            % BRANCH FOR 500ns
            % instrunction 1
            obj.hwHandle.PBInstruction(FlagInstr,obj.hwHandle.INST_BRANCH,0,500);
            
            %when you are finsihed, you use the command stop prgramming
            obj.hwHandle.StopProgramming();
end

 function [obj] = StartProgramming(obj)
            [err] = calllib(obj.LibraryName,'pb_start_programming',obj.PULSE_PROGRAM);
 end

 function [obj] = StopProgramming(obj)
            [err] = calllib(obj.LibraryName,'pb_stop_programming');
 end

 function [obj] = PBInstruction(varargin)
            if nargin == 5,
                obj = varargin{1};
                flags = varargin{2};
                inst = varargin{3};
                inst_data = varargin{4};
                length = varargin{5};
                flagopt = obj.ON;
            elseif nargin == 6,
                obj = varargin{1};
                flags = varargin{2};
                inst = varargin{3};
                inst_data = varargin{4};
                length = varargin{5};
                flagopt = varargin{6};
            end
            flags = int32(bitor(flags,flagopt));
            inst = int32(inst);
            inst_data = int32(inst_data);
            length = double(length);
           [err] = calllib(obj.LibraryName,'pb_inst_pbonly',flags,inst,inst_data,length);
           if err < 0,
               warning('Spin Core Pulse Blaster Error: Code %d',err);
           end
end