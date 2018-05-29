%% Converts the strem to time data, adding according to the rslt values.
function [t,strm] = StreamToTimedData(rslts,tbin,dt)
    if(~exist('tbin','var'))
        tbin=0.1; % in seconds.
    end
    if(~exist('dt','var'))
        dt=1;
    end
    
    [rslts,t]=ResultsStreamToVector(rslts,dt);
    
    if(isempty(t))
        return;
    end
    
    strm=rslts(1:end); 
    % according to t bins.
    if(length(t)>1)
        dt=t(2)-t(1);
    else
        dt=1;
    end
    lt=length(t);
    %bin size
    binn=round(tbin/dt);
    
    % if bin time is smaller then 1, 
    if(binn<1)
        binn=1;
    end
    
    %number of ticks
    ticn=floor(lt/binn);
    overmax=lt-ticn*binn-1;
    if(overmax>-1)
        t(end-overmax:end)=[];
        strm(end-overmax:end)=[];
    end
    
    % reshape and sum.
    t=reshape(t,binn,ticn);
    t=t(1,:)'; % first value.
    
    % rehape the stream.
    sstrm=size(strm);
    chann=sstrm(2);
    
    strm=sum(reshape(strm,binn,chann,ticn),1)./binn;
    strm=reshape(strm,ticn,chann);
end

