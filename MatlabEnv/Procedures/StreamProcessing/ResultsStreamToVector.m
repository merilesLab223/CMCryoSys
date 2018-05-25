function [vec,t] = ResultsStreamToVector(rslts,dt)
    if(isempty(rslts))
        vec=[];
        t=[];
        return;
    end
    if(~iscell(rslts))
        vec=rslts;
        srslt=size(rslts);
        if(~exist('dt','var'))
            dt=1;
        end
        t=[1:srslt(1)].*dt;
        return;
    end

    % find total length,
    tlen=0;
    blen=length(rslts);
    vidxs=[];
    for i=1:blen
        if(~ismatrix(rslts{i}))
            continue;
        end
        sdata=size(rslts{i});   
    	tlen=tlen+sdata(1);
        vidxs(end+1)=i;
    end
    
    if(tlen==0)
        return;
    end
    
    vec=zeros(tlen,1);
    t=zeros(tlen,1);
    sidx=1;
    for i=vidxs
        rdata=rslts{i};
        sdata=size(rdata);  
        if(sdata(1)==0)
            continue;
        end
        %sidx=r*coln;
        eidx=sidx+sdata(1)-1;
        t(sidx:eidx,1)=rdata(:,1);
        vec(sidx:eidx,:)=rdata(:,2:end);
        sidx=eidx+1;
    end
    
    igc=3;
    if(tlen>igc)
        for i=1:igc
            vec(i,:)=vec(igc+1,:);
        end            
    end
    %t=median(diff(t)).*[0:tlen-1]';
end

