function [img,updatedIdxs] = StreamToImageData(rslt,coln,rown,dwellTime,multidir)
    % splicing according to dwell time.
    if(~exist('multidir','var'))multidir=0;end
    % do not update anything, create zero image.
    img=zeros(coln,rown);
    updatedIdxs=[];
    
    comp=[];
    tlen=0;
    blen=length(rslt);
    tic;
    for i=1:blen
        rdata=rslt{i};
        sdata=size(rdata);   
    	tlen=tlen+sdata(1);
    end
    
    if(tlen==0)
        return;
    end
    comp(end+1)=toc;
    
    tic;
    imgvector=zeros(tlen,2);
    sidx=1;
    for i=1:blen
        rdata=rslt{i};
        sdata=size(rdata);  
        if(sdata(1)==0)
            continue;
        end
        %sidx=r*coln;
        eidx=sidx+sdata(1)-1;
        imgvector(sidx:eidx,:)=rdata;
        sidx=eidx+1;
    end
    comp(end+1)=toc;
    % data collected proecssing the vector.
    tic;
    imgvector(:,1)=imgvector(:,1)-imgvector(1,1); % remove zero.
    lbins=coln*rown;
    comp(end+1)=toc;
    minT=imgvector(1,1);
    deltaT=(imgvector(tlen,1)-imgvector(1,1));
    
    if(deltaT>coln*rown*dwellTime)
        deltaT=coln*rown*dwellTime;
    end
    
    ticksPerPixel=round(tlen*dwellTime/deltaT);
    tic;
    if(ticksPerPixel<1)
        % case we are missing data.
        % case we are missing data.
        ts=imgvector(:,1);
        ts=ts(ts>=minT & ts<deltaT);
        ts=round(ts./dwellTime)+1;
        updatedIdxs=1:(coln*rown);
        img(ts)=imgvector(1:length(ts),2);
    else
        curPixel=floor(tlen/ticksPerPixel);
        if(curPixel>coln*rown)
            curPixel=coln*rown;
        end
        totalPixels=curPixel*ticksPerPixel;
        
        updatedIdxs=1:curPixel;
        
        if(ticksPerPixel==1)
            img(updatedIdxs)=imgvector(1:totalPixels,2);
        else
            img(updatedIdxs)=sum(reshape(imgvector(1:totalPixels,2),ticksPerPixel,curPixel));
        end
    end
    comp(end+1)=toc;
    
    if(multidir)
        img(:,2:2:end)=img(end:-1:1,2:2:end);
    end
end

