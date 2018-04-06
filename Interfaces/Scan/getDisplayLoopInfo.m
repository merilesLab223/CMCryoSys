function [newStream,newImage,strm,img] = getDisplayLoopInfo()
    global info;
    if(~isa(info,'globalInfo'))
        return;
    end
    
    newStream=0;
    newImage=0;
    
    strm={};
    strm.dt=0.0001;
    strm.t=[0,0];
    strm.val=[0,0];
    img={};
    img.data=zeros(2,2);
    img.width=2;
    img.height=2;
    img.ratio=1;

    newStream=validateTimestamp(info,'lastStreamResultsTS',...
        info.streamCollector.LastResultsMeasured);
    newImage=validateTimestamp(info,'lastImageResultsTS',...
        info.imageCollector.LastResultsMeasured);
    
    if(newStream)
        timebin=info.getOrAdd('stream_timebin',1);
        [t,d]=StreamToTimedData(info.streamCollector.Results,timebin);

        if(~isempty(t))
            strm.dt=t(2)-t(1);
            strm.t=t;
            strm.val=d;                   
        end
    end
    
    if(newImage && isfield(info,'ImageScanInfo'))
        error('Not implemented.');
    end
end

function [isnew]=validateTimestamp(info,name,compareTo)
    isnew=0;
    last=info.getOrAdd(name,-1);
    if(last<compareTo)
        isnew=1;
        info.(name)=compareTo;
    end
end

