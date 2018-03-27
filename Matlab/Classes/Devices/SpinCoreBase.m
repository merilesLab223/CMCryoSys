classdef SpinCoreBase < Device & TimeBasedObject
    % Implements a spin core base functionality. Communication with the
    % device and core hardware handles.
    methods
        function obj = SpinCoreBase(LibraryFile,LibraryHeaders,LibraryName)
            if(~exist('LibraryFile','var'))LibraryFile=SpinCoreAPI.DefaultLibFile;end
            if(~exist('LibraryHeader','var'))LibraryHeaders=SpinCoreAPI.DefaultHeaderFiles;end
            if(~exist('LibraryName','var'))LibraryName=SpinCoreAPI.DeafultLibName;end
            
            obj.CoreAPI=SpinCoreAPI(LibraryFile,LibraryHeaders,LibraryName); % redo.
        end
    end
    
    properties (SetAccess = private)
        % to change the spincoreapi functions. Call
        CoreAPI=[];
    end
    
    methods (Access = protected)
        
        % configure the spincore.
        function configureDevice(obj)
            api=obj.CoreAPI;
            api.Load;
            if(api.IsInitialized)
                api.Reset;
            else
                api.Init;
            end
        end
        
    end
    
    methods
        function stop()
            api=obj.CoreAPI;
            api.Stop();            
        end
        
        function run()
            api=obj.CoreAPI;
            api.Start();
        end
        
        function [cflags]=ChannelToFlags(obj,c)
            c=sort(c);
            lc=length(c);
            maxc=max(c);
            ci=1;
            n=0;
            bits=[];
            while(ci<=lc && n<=maxc)
                if(c(ci)==n)
                    % same number
                    ci=ci+1; %next.
                    bits(end+1)=1;
                else
                    bits(end+1)=0;
                end
                n=n+1;
            end
            cflags=bi2de(bits);
        end
    end
        
end

