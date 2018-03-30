%% Converts the strem to time data, adding according to the rslt values.
function [t,strm] = StreamToTimedData(rslts,tbin)
    if(~exist('tbin','var'))
        tbin=0.1; % in seconds.
    end
    strmt=[];
    strmb={};
    l=length(rslts);
    for i=1:l
        ri=rslts{i};
        if(~ismatrix(ri) || isempty(ri))
            continue;
        end
        strmt(end+1)=ri(1,1);
        strmb(end+1)={ri};
    end
    
    [~,sidx]=sort(strmt);
    strmb=strmb(sidx);
    
    t=[];
    strm=[];
    l=length(strmb);
    for i=1:l
        ri=strmb{i};
        sri=size(ri);
        ld=sri(1);
        
        t(end+1:end+ld)=ri(:,1);
        strm(end+1:end+ld,:)=ri(:,2:end);
    end
    t=t';
    if(length(t)==0)
        return;
    end
    
    % according to t bins.
    dt=t(2)-t(1);
    lt=length(t);
    %bin size
    binn=round(tbin/dt);
    %number of ticks
    ticn=ceil(lt/binn);
    missing=ticn*binn-lt;
    t(end+1:end+missing)=0;
    strm(end+1:end+missing,:)=0;
    % reshape and sum.
    t=reshape(t,binn,ticn);
    t=t(1,:)'; % first value.
    
    % rehape the stream.
    sstrm=size(strm);
    chann=sstrm(2);
    
    strm=sum(reshape(strm,binn,chann,ticn),1);
    strm=reshape(strm,ticn,chann);
end

