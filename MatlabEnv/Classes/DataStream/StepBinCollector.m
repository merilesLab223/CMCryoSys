classdef StepBinCollector < DataStream
    %STEPBINCOLLECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function [obj]=StepBinCollector(reader)
            obj@DataStream(reader);
        end
    end
    
    events
        BinComplete;
        Complete;
    end
    
    properties
        KeepResultsInMemory=false;
    end
    
    properties (SetAccess = protected)
        CollectBins={};
        CurBinIndex=0;
        
        Results=[];
    end
    
    methods
        function collect(col,cnt,isdata,loopn)
            % call to collect the number of data values in cnt,where isdata
            % will determine if to include the data in the collected
            % values. The loopn will determine how many repetitions.
            if(~iscolumn(cnt))
                cnt=cnt';
            end
            if(~exist('isdata','var') || isempty(isdata))
                isdata=ones(size(cnt));
            end
            if(length(cnt)==1 && length(isdata>1))
                cnt=ones(size(isdata))*cnt;
            end
            if(~exist('loopn','var'))
                loopn=1;
            end
            if(loopn<1)
                error('loopn must be >1');
            end
            
            col.CollectBins{end+1}=StepBinCollector.makeBinData(true,cnt,isdata,loopn);
        end
        
        function skip(col,n)
            % skip n measurements (same as wait for a timed stream).
            col.CollectBins{end+1}=StepBinCollector.makeBinData(false,n,false,1);
        end
        
        function clear(col)
            % clear all the meausurement bins.
            col.CollectBins={};
            col.reset();
        end
        
        function reset(col)
            col.m_CurBinInfoIndex=1;
            col.CurBinIndex=1;
            col.PendingData=[];
            col.CurBinInfo=[];
        end
        
        function prepare(col)
            prepare@DataStream(col);
            col.reset();
        end
    end
    
    methods(Static, Access = protected)
        function [b]=makeBinData(invokeEvent,cnt,isdata,loopn)
            % making the src flags.
            flags=[];
            for i=1:length(cnt)
                if(isdata(i))
                    flags(end+1:end+cnt(i))=ones(cnt(i),1);
                else
                    flags(end+1:end+cnt(i))=zeros(cnt(i),1);
                end
            end
            b=struct('invoke',invokeEvent,'flags',flags,'total',...
                length(flags),'n',loopn);
        end
    end
    
    properties(Access = private)
        % current pending data.
        PendingData=[];
        % the number of repetitions left for each bin.
        RepetitionsLeft=0;
        % the current bin info.
        CurBinInfo=[];
        % current bin info index.
        m_CurBinInfoIndex=1;
    end
    
    methods (Access = protected)
        
        function dataBatchAvailableFromDevice(col,s,e)
            % pushing the data into the pending.
            data=e.RawData;
            col.PendingData(end+1:end+length(data))=data;
            col.processNextBin();
        end
        
        function processNextBin(col)
            if(col.m_CurBinInfoIndex>length(col.CollectBins))
                col.stop(); % stop the collector.
                col.notify('Complete',EventStruct());
                return;
            end
            
            % getting the current bin information.
            if(isempty(col.CurBinInfo))
                col.CurBinInfo=col.CollectBins{col.m_CurBinInfoIndex};
                col.RepetitionsLeft=col.CurBinInfo.n;
            end
            
            if(col.RepetitionsLeft<1)
                % move to next.
                col.CurBinInfo=[];
                col.m_CurBinInfoIndex=col.m_CurBinInfoIndex+1;
                col.RepetitionsLeft=0;
                col.processNextBin();
                return;
            end
                
            binfo=col.CurBinInfo;
            
            % check if there is enouph to read the next bin.
            if(binfo.total>length(col.PendingData))
                % nothing to.
                return;
            end
            
            % get the bin data.
            data=col.PendingData(1:binfo.total);
            col.PendingData=col.PendingData(binfo.total+1:end);
            
            % processing the bin.
            data=data(logical(binfo.flags))';
            if(col.KeepResultsInMemory)
                col.Results{col.m_CurBinInfoIndex}=data;
            end
            
            if(binfo.invoke)
                ev=BinEventStruct(col.CurBinIndex,data);
                col.notify('BinComplete',ev);
            end
            
            % process the next one.
            col.RepetitionsLeft=col.RepetitionsLeft-1;
            col.CurBinIndex=col.CurBinIndex+1;
            col.processNextBin();
        end
    end
end

