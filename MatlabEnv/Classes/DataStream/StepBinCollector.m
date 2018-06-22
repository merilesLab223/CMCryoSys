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
        
        function repeate(col,n)
            % repeate the current sequence n time.
            col.CollectBins=repmat(col.CollectBins,1,n);
        end
        
        function merge(col,startIdx,endIdx,invokeEvent,loopn)
            % combines the data collections into a single collection value.
            % the combined collection data will behave as a single data
            % bin.
            
            if(~exist('startIdx','var') || isempty(startIdx))
                startIdx=1;
            end
            if(~exist('loopn','var') || isempty(loopn))
                loopn=1;
            end
            % end index.
            if(~exist('endIdx','var') || isempty(endIdx))
                endIdx=length(col.CollectBins);
            end
            
            if(startIdx>length(col.CollectBins))
                error('Start index out of bounds.');
            end
            
            binsToMerge=col.CollectBins(startIdx:endIdx);
            
            flags=[];
            invokeEvents=[];
            for i=1:length(binsToMerge)
                bi=binsToMerge{i};
                bf=repmat(bi.flags,1,bi.n);
                flags(end+1:end+length(bf))=bf;
                invokeEvents(end+1)=bi.invoke;
            end
            
            if(~exist('invokeEvent','var'))
                invokeEvent=any(logical(invokeEvents));
            end
            
            nbin=StepBinCollector.makeBinDataFromFlags(invokeEvent,flags,loopn);
            col.CollectBins{startIdx}=nbin;
            col.CollectBins(startIdx+1:endIdx)=[];
        end
        
        function clear(col)
            % clear all the meausurement bins.
            col.CollectBins={};
            col.reset();
        end
        
        function reset(col)
            col.m_CurBinInfoIndex=0;
            col.m_RepetitionsLeft=0;
            col.CurBinIndex=1;
            col.PendingData=[];
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
            b=StepBinCollector.makeBinDataFromFlags(invokeEvent,flags,loopn);
        end
        
        function [b]=makeBinDataFromFlags(invokeEvent,flags,loopn)
            b=struct('invoke',logical(invokeEvent),'flags',logical(flags),'total',...
                length(flags),'n',double(loopn));            
        end
    end
    
    properties(Access = private)
        % current pending data.
        PendingData=[];
        % the number of repetitions left for the current bin info.
        m_RepetitionsLeft=0;
        % current bin info index.
        m_CurBinInfoIndex=1;
    end
    
    methods (Access = protected)
        
        function dataBatchAvailableFromDevice(col,s,e)
            % pushing the data into the pending.
            col.PendingData(end+1:end+length(e.RawData))=e.RawData;
%             tic;
            [cidxs,cdata]=col.processData();
%             disp(['Processed ',num2str(lpending-length(col.PendingData)),' in [ms] ',...
%                 num2str(toc)]);
            
            if(~isempty(cidxs))
                ev=BinEventStruct(cidxs,cdata);
                col.notify('BinComplete',ev);              
            end
            
            if(col.m_CurBinInfoIndex>length(col.CollectBins) ||...
                (col.m_CurBinInfoIndex==length(col.CollectBins) && col.m_RepetitionsLeft==0))
                col.stop(); % stop the collector.
                col.notify('Complete',EventStruct());
            end               
        end
        
        % call to proces the current data.
        function [cidxs,cdata]=processData(col)
            
            % current bin index (always counts up, the number of bins read).
            bidx=col.CurBinIndex;
            
            % all available bins.
            binInfos=col.CollectBins;
            
            % the max number of bins.
            maxBins=length(binInfos);
            
            % the current pending data.
            pendingData=col.PendingData;
            maxPendingIndex=length(pendingData);
            
            % reverting to last position.
            bInfoIdx=col.m_CurBinInfoIndex;
            repLeft=col.m_RepetitionsLeft;
            % is first bin.
            if(bInfoIdx<1)
                bInfoIdx=bInfoIdx+1;
                binfo=binInfos{bInfoIdx};
                repLeft=binfo.n;
            else
                binfo=binInfos{bInfoIdx};
            end
            
            % the current data index.
            didx=1;
            cidxs=[];
            cdata={};
            
            while(didx<=maxPendingIndex)
                if(bInfoIdx>maxBins)
                    % no more bins were done. Yey!.
                    break;
                end
                
                % move to next?
                if(repLeft<1)
                    bInfoIdx=bInfoIdx+1;
                    if(bInfoIdx>maxBins)
                        % no more bins were done. Yey!.
                        break;
                    end
                    binfo=binInfos{bInfoIdx};
                    repLeft=binfo.n;
                end
                
                % check if there is enouph to read the next bin.
                if(binfo.total>(maxPendingIndex-didx+1))
                    % not enouph data. Wait for data.
                    break;
                end
                
                endIndex=didx+binfo.total-1;
                data=pendingData(didx:endIndex);
                data=data(binfo.flags)';
                didx=endIndex+1; % next batch.
                if(binfo.invoke)
                    % need to add to data.
                    cidxs(end+1)=bidx;
                    cdata{end+1}=data;
                end
                
                % move to next.
                repLeft=repLeft-1;    
                bidx=bidx+1;                
            end
            
            % update back to original.
            col.CurBinIndex=bidx;
            col.m_RepetitionsLeft=repLeft;
            col.m_CurBinInfoIndex=bInfoIdx;
            
            % slice done.
            col.PendingData=col.PendingData(didx:end);
 
        end
        
        function processBinData2(col)
            % completed Bins;
            maxdidx=length(col.PendingData);
            cidxs=zeros(1,maxdidx);
            cdata=cell(1,maxdidx);
            ridx=1;
            iidx=1;
            didx=1;
            
            bidx=col.m_CurBinInfoIndex;
            cbinIndex=col.CurBinIndex;
            maxBins=length(col.CollectBins);
            allBins=col.CollectBins;
            pendingData=col.PendingData;
            
            binfo=col.m_CurBinInfo;
            if(isempty(binfo))
                repLeft=0;
            else
                repLeft=col.m_RepetitionsLeft;
            end
            
            while(didx<maxdidx)
                if(bidx>maxBins)
                    break;
                end
                
                % getting the current bin information.
                if(isempty(binfo))
                    binfo=allBins{bidx};
                    repLeft=binfo.n;
                elseif(repLeft<1)
                    % move to next.
                    binfo=[];
                    bidx=bidx+1;
                    repLeft=0;
                    continue;                   
                end
                
                % check if there is enouph to read the next bin.
                if(binfo.total>(maxdidx-didx))
                    % not enouph data. Wait for data.
                    break;
                end
                
                % process the bin.
                [data,didx]=col.processNextBin(pendingData,didx,binfo);
                didx=didx+1;
                if(binfo.invoke)
                    cidxs(ridx)=cbinIndex;
                    cdata{ridx}=data;
                    ridx=ridx+1;
                else
                    iidx=iidx+1;
                end
                % move to next.
                repLeft=repLeft-1;    
                cbinIndex=cbinIndex+1;
            end
            
            col.m_CurBinInfoIndex=bidx;
            col.m_CurBinInfo=binfo;
            col.CurBinIndex=cbinIndex;
            col.m_RepetitionsLeft=repLeft;
            
            if(col.KeepResultsInMemory)
                col.Results{cidxs}=cdata;
            end
            % splice data down.
            col.PendingData=col.PendingData(didx+1:end);
            cidxs=cidxs(1:ridx-1);
            %cdata=cdata(1:ridx-1);
            if(~isempty(cidxs))
                ev=BinEventStruct(cidxs,cdata);
                col.notify('BinComplete',ev);              
            end
            
            if(col.m_CurBinInfoIndex>length(col.CollectBins))
                col.stop(); % stop the collector.
                col.notify('Complete',EventStruct());
            end             
        end

    end
end

