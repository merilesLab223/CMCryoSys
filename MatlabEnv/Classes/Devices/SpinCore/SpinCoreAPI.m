classdef SpinCoreAPI < handle

    methods
        % Spincore library config.
		function [obj] = SpinCoreAPI(LibraryFile,LibraryHeaders,LibraryName)
            if(~exist('LibraryFile','var'))LibraryFile=SpinCoreAPI.DefaultLibFile;end
            if(~exist('LibraryHeader','var'))LibraryHeaders=SpinCoreAPI.DefaultHeaderFiles;end
            if(~exist('LibraryName','var'))LibraryName=SpinCoreAPI.DeafultLibName;end
            
            if(ischar(LibraryHeaders))
                LibraryHeaders={LibraryHeaders};
            end
            obj.LibraryFile = LibraryFile;
            obj.LibraryHeaders = LibraryHeaders;
            obj.LibraryName = LibraryName;
        end
    end
    
    properties (Constant)
        DefaultHeaderFiles={...
            'C:\SpinCore\SpinAPI\include\spinapi.h',...
            %'C:\SpinCore\SpinAPI\include\spinpts.h',...
            };
        DefaultLibFile='C:\SpinCore\SpinAPI\lib\spinapi64.dll';
        DeafultLibName='SPINCOREAPILIB';
    end
    
	properties (SetAccess = protected)
		LibraryFile % spinapi.dll file
		LibraryHeaders % path to spinapi.h file (and others)
		LibraryName % alias of loaded library
        IsInitialized=false;
        InstructionsCount=0;
    end
	
    properties (Constant = true)
        INST_CONTINUE    = 0
        INST_STOP        = 1
        INST_LOOP        = 2
        INST_END_LOOP    = 3
        INST_JSR         = 4
        INST_RTS         = 5
        INST_BRANCH      = 6
        INST_LONG_DELAY  = 7
        INST_WAIT        = 8
        PULSE_PROGRAM    = 0

        %flag_option map. string-to-bits
        ALL_FLAGS_ON	= hex2dec('1FFFFF');
        ONE_PERIOD		= hex2dec('200000');
        TWO_PERIOD		= hex2dec('400000');
        THREE_PERIOD	= hex2dec('600000');
        FOUR_PERIOD		= hex2dec('800000');
        FIVE_PERIOD		= hex2dec('A00000');
        SIX_PERIOD      = hex2dec('C00000');
        ON				= hex2dec('E00000');
    end

	methods
		function Load(obj)
			if ~libisloaded(obj.LibraryName)
                arglst={...
                    obj.LibraryFile,...
                    obj.LibraryHeaders{1},...
                    'alias',obj.LibraryName};
                if(length(obj.LibraryHeaders)>1)
                    for i=2:length(obj.LibraryHeaders)
                        hdr=obj.LibraryHeaders{i};
                        arglst{end+1}='addheader';
                        arglst{end+1}=hdr;
                    end
                end
                loadlibrary(arglst{:});
			end
        end
        
        function Unload(obj)
            if ~libisloaded(obj.LibraryName)return;end
            unloadlibrary(obj.LibraryName);
        end
		
        function Init(obj)
            obj.InstructionsCount=0;
            [err] = calllib(obj.LibraryName,'pb_init');
            if err ~= 0
                error(['Error Loading PulseBlaster Board: ',num2str(err)]);
            else
                obj.IsInitialized=1;
            end
        end
        
        function Close(obj)
            obj.InstructionsCount=0;
            [err] = calllib(obj.LibraryName,'pb_close');
            if err < 0
               warning('Spin Core Pulse Blaster Error: Code %d',err);
            else
                obj.IsInitialized=0;
            end
        end
        
        % Set clock freqncy in hz.
        function SetClock(obj,ClockRate) % hz

            % NOTE!!!
            % Spin Core sets the clock in units of MHz, but controlling
            % software gives the clock in Hz, so must convert
            ClockRate = double(ClockRate/1e6);
            calllib(obj.LibraryName,'pb_core_clock',ClockRate);
        end
        
		function Start(obj)
			[err] = calllib(obj.LibraryName,'pb_start');
			%obj.CheckError();
		end
		
		function Stop(obj)
            [err] = calllib(obj.LibraryName,'pb_stop');
            if err < 0
               warning('Spin Core Pulse Blaster Error: Code %d',err);
            end            
        end
		
        function StartProgramming(obj)
            obj.InstructionsCount=0;
            [err] = calllib(obj.LibraryName,'pb_start_programming',obj.PULSE_PROGRAM);
            if err < 0
               warning('Spin Core Pulse Blaster Error: Code %d',err);
            end            
        end

        
        function StopProgramming(obj)
            [err] = calllib(obj.LibraryName,'pb_stop_programming');
            if err < 0
               warning('Spin Core Pulse Blaster Error: Code %d',err);
            end            
        end

        function Instruct(varargin)
            if nargin == 5
                obj = varargin{1};
                flags = varargin{2};
                inst = varargin{3};
                inst_data = varargin{4};
                length = varargin{5};
                flagopt = obj.ON;
            elseif nargin == 6
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
            length = double(length*1e9); 
            obj.InstructionsCount=obj.InstructionsCount+1;
            [err] = calllib(obj.LibraryName,'pb_inst_pbonly',flags,inst,inst_data,length);
            if err < 0
               warning('Spin Core Pulse Blaster Error: Code %d',err);
            end
        end
        
		function Reset(obj)
            [err]=calllib(obj.LibraryName,'pb_reset');
            if err < 0
                error('Spin Core Pulse Blaster Error on reset: Code %d',err);
            end
        end
		
		function [err] = getLastError(obj)
            err=calllib(obj.LibraryName,'spinpts_get_error');
        end
        
        function [ver]=getVerstion(obj)
            ver=calllib(obj.LibraryName,'pb_get_version');
            
        end
        
        function [bcount]=getBoardCount(obj)%pb_count_boards
            bcount=calllib(obj.LibraryName,'pb_count_boards');
        end
        
        function SelectBoard(obj,bnum)
            if(bnum<1)
                error('Board number must be larger then 1.');
            end
            cbc=obj.getBoardCount();
            if(bnum>cbc)
                error('Board number must be lower then %d, which is the total number of boards.',cbc);
            end
            %pb_select_board            
            err=calllib(obj.LibraryName,'pb_select_board',bnum-1);
            if err < 0
                switch err
                    case -91
                        err= [num2str(err),...
                            'Instruction below minimal execution time. Change clock rate if needed.'];
                    otherwise
                        err=num2str(err);
                end
                error(['Spin Core Pulse Blaster Error on reset: ',err]);
            end
        end
		
        function delete(obj)
            try
                obj.Close();
            catch err
            end
        end
	end

end