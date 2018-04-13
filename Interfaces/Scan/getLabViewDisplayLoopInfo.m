function [rt]=getLabViewDisplayLoopInfo(onlyNew)
    if(~exist('onlyNew','var'))onlyNew=0;end
    global info;
    rt={};
    if(isempty(info))
        error('Found info collection empty. Init not called or other error.');
    end
    getImageData=0;
    getStreamData=0;
    if(onlyNew)
        if(info.get('streamLastUpdate',-1)<info.streamCollector.LastReadTimestamp)
            info.set('streamLastUpdate',info.streamCollector.LastReadTimestamp);
            getStreamData=1;
        end
        
        if(info.get('imageLastUpdate',-1)<info.imageCollector.LastResultsMeasured)
            info.set('imageLastUpdate',info.imageCollector.LastResultsMeasured);
            getImageData=1;
        end
    else
        getImageData=1;
        getStreamData=1;
    end
    
    rt.newImage=getImageData;
    rt.newStream=getStreamData;
    rt.stream=readStreamData(getStreamData);
    rt.image=readImageData(getImageData);
    rt.ImageComplete=0;
    
    if(info.get('lastImageCompleteUpdate',-1)<info.get('ImageDataLastCompleatedTS',-1))
        info.set('lastImageCompleteUpdate',info.get('ImageDataLastCompleatedTS'));
        rt.ImageComplete=1;
    end
end

function [rt]=readImageData(loadData)
    global info;
    rt.d=[];%getDefaultImageData();
    rt.wasRead=loadData;
    scaninfo=[];
    if(loadData && ~isempty(info.imageCollector.Results))
        scaninfo=info.get('imageScanInfo',[]);
        ld=info.get('ImageData',zeros(2,2));
        if(~isempty(ld))
            rt.d=ld;
        end
    end
    if(isempty(rt.d))
        rt.d=rand(100,100)+eye(100)*3;
    end
    ds=size(rt.d);
    xl=ds(1);
    yl=ds(2);
    if(~isempty(scaninfo))
        minx=scaninfo.x0;
        maxx=scaninfo.x0+scaninfo.width;
        
        miny=scaninfo.y0;
        maxy=scaninfo.y0+scaninfo.height;
    else
        minx=-0.5;
        maxx=0.5;
        miny=-0.5;
        maxy=0.5;
    end
    
    rt.xl=xl;
    rt.yl=yl;
    rt.width=abs(maxx-minx);
    rt.height=abs(maxy-miny); 
    rt.xrange=[minx,maxx];
    rt.yrange=[miny,maxy];
    rt.xOffset=minx;
    rt.yOffset=miny;
    rt.dx=rt.width/xl;
    rt.dy=rt.height/yl;
end

function [rt]=readStreamData(loadData)
    global info;
    rt.d=[0,0];
    rt.t=[0,0];
    rt.dt=1;
    rt.t0=0;
    rt.wasRead=loadData;
    rt.meanV=0;
    if(~loadData || isempty(info.streamCollector.Timestamps))
        return;
    end
    
    rt.t=info.streamCollector.Timestamps';
    rt.d=info.streamCollector.Data';
    rt.meanV=info.streamCollector.MeanV(1); % only first value.
    rt.t0=rt.t(1);
    if(length(rt.t)>1)
        rt.dt=abs(rt.t(2)-rt.t(1));
        if(rt.dt==0)
            rt.dt=mean(diff(rt.t));
        end
    end
end
