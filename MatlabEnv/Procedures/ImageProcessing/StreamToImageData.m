function [img,updatedIdxs] = StreamToImageData(rslt,coln,rown,dwellTime,multidir,toff,img)
    % splicing according to dwell time.
    if(~exist('multidir','var'))
        multidir=0;
    end
    
    if(~exist('toff','var'))
        toff=0;
    end
    
    % do not update anything, create zero image.
    updatedIdxs=[];
    if(~exist('img','var') || ~isnumeric(img) || any(size(img)~=[coln,rown]))
        img=zeros(coln,rown);
    end
        
    tlen=numel(img);
    
    % get the data vectorl
    [imgvector,ts]=ResultsStreamToVector(rslt);
    
    % just nothing here.
    if(length(imgvector)<2)
        return;
    end
    
    minT=ts(1)+toff;
    deltaT=(ts(end)-minT);
    totalTime=coln*rown*dwellTime;
    maxIndex=find(ts>totalTime,1);
    if(isempty(maxIndex))
        maxIndex=length(ts);
    end
    
    % check if not over the total time.
    % if so chop.
    if(maxIndex<length(ts))
        % chop.
        imgvector(maxIndex:end,:)=[];
        ts(maxIndex:end)=[];
    end
    % maxIndex./deltaT; t per timebin.
    % tlen./dwellTime
    timePerDataBin=deltaT/maxIndex;
    ticksPerPixel=dwellTime./timePerDataBin;

    % maximal pixel.
    curPixel=floor(maxIndex/ticksPerPixel);
    if(curPixel>coln*rown)
        curPixel=coln*rown;
    end

    atImgIdxs=floor((ts-minT)./dwellTime)+1;
    removeIdxs=atImgIdxs>curPixel | atImgIdxs<1;
    atImgIdxs(removeIdxs)=[];
    imgvector(removeIdxs)=[];

    %=unique(atImgIdxs);
    dnorm=accumarray(atImgIdxs,ones(size(atImgIdxs)));
    dsum=accumarray(atImgIdxs,imgvector);
    updatedIdxs=min(atImgIdxs)+(1:length(dnorm))-1;
    img(updatedIdxs)=dsum;
    dnormidxs=find(dnorm>0);
    img(dnormidxs)=img(dnormidxs)./dnorm(dnormidxs);
    
    % filling the toffset;
    offsetidxs=1:ceil(toff/dwellTime);
    if(~isempty(offsetidxs)&&numel(img)>numel(offsetidxs))
        if(toff>0)
            offsetidxs=numel(img)-offsetidxs+1;
            firstval=img(offsetidxs(end)-1);
        else
            firstval=img(offsetidxs(end)+1);
        end
        
        img(offsetidxs)=firstval;
    end
    if(multidir)
        img(:,2:2:end)=img(end:-1:1,2:2:end);
    end
end

