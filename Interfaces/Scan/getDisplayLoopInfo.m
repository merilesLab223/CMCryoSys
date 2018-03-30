function [newStream,newImage,strm,img] = getDisplayLoopInfo()
    newStream=0;
    newImage=0;
    strm=[];
    img=[];
    global info;
    if(~isstruct(info))
        return;
    end
    
    newStream=validateTimestamp('lastStreamResultsTS',...
        info.streamCollector.LastResultsMeasured);
    newImage=validateTimestamp('lastImageResultsTS',...
        info.imageCollector.LastResultsMeasured);
    
    if(newStream)
        timebin=info.getOrAdd('stream_timebin',50);
        strm=StreamToTimedData(info.streamCollector.Results,timebin);
    end
    
    if(newImage && isfield(info,'ImageScanInfo'))
        error('Not implemented.');
    end
end

function [isnew]=validateTimestamp(info,name,compareTo)
    isnew=0;
    last=info.getOrAdd(name);
    if(last<compareTo)
        isnew=1;
        info.(name)=compareTo;
    end
end

