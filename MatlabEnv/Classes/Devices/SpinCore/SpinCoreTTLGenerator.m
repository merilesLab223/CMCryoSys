classdef SpinCoreTTLGenerator < SpinCoreBase & TTLGenerator
    %SPINCORETTLGENERATOR Implements a spincore class that can be both a
    %clock and a pulse generator.
    
    properties
        % The maximal loop lenth to send to device.
        MaxLoopLength   = 1000000;
    end
    
    % general methods.
    methods
        function prepare(obj)
            prepare@SpinCoreBase(obj);
            
            % getting the stream.
            [t,strm]=obj.getTimedStream();
            
            % programming the instructions.
            obj.StartInstructions;
            
            % new version.
            lastT=0;
            
            pendingLoopIndexs=[];
            
            for i=1:length(strm)
                % processing instruction si.
                si=strm{i};
                ti=t(i);

                % getting the instructions...
                if(isstruct(si))

                    % this is an instruction struct
                    if(~isfield(si,'type'))
                        continue;
                    end

                    switch(si.type)
                        case TTLGenerator.LOOPStartStruct.type
                            pendingLoopIndexs(end+1)=...
                                obj.InstructStartLoop(si.n);
                        case TTLGenerator.LOOPEndStruct.type
                            if(isempty(pendingLoopIndexs))
                                error('Reached loop end but no loop was started.');
                            end
                            obj.InstructEndLoop(pendingLoopIndexs(end));
                            pendingLoopIndexs(end)=[];
                    end
                    % adding delay if needed.
                    if(ti>lastT)
%                         obj.InstructDelay(ti-lastT);
                        lastT=ti;
                    end 
                    % nothing else here.
                    continue;
                end
                
                % need to add the data.
                data=si(:,2:end);
                durs=si(:,1);
                sdata=size(data);
                
                for j=1:sdata(1)
                    % adding the rows.
                    obj.InstructBinary(1:sdata(2),data(j,:)>0,durs(j));
                end
                lastT=lastT+sum(durs);
                
                % adding delay if needed.
                if(ti>lastT)
%                     obj.InstructDelay(ti-lastT);
                    lastT=ti; 
                end     
            end
            
            obj.EndInstructions;
            
            if(~isempty(pendingLoopIndexs))
                error('Reached end of instructions but loop is still open.');
            end
        end
    end
    
        
end

