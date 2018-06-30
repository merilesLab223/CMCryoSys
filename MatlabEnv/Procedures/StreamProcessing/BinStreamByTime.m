function [bt,bdata,tidxs] = BinStreamByTime(t,data,dt)
    % bins a data stream given a specific dt to indexed values.
    % the t0 is always 0.
    
    if(~isvector(t))
        error('T must be a vector (one column or row).');
    end
    
    if(~isvector(t))
        error('Data must be a vector (one column or row).');
    end
    
    if(~iscolumn(data))
        data=data';
    end
    
    if(~iscolumn(t))
        t=t';
    end
    
    if(length(data)~=length(t))
        error('The number of rows in data must be equalt to the length of t.');
    end
    
    %sort the data.
    [t,idxs]=sort(t);
    data=data(idxs);
    
    idxs=floor(t./dt); % convert time to index.
    idxs=idxs+1; % convert to vector index.
    toffset=(idxs(1)-1)*dt;
    idxs=idxs-idxs(1)+1;
    
    bdata=accumarray(idxs,data);
    bnorm=accumarray(idxs,ones(size(idxs)));
    tidxs=min(idxs)+(1:length(bnorm))-1;    
    bnorm(bnorm<1)=1;
    bdata=bdata./bnorm;
    bt=(tidxs-1)*dt+toffset;
end

