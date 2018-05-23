function [img,updatedIdxs] = StreamToImageData(rslt,coln,rown,dwellTime,multidir)
    % splicing according to dwell time.
    if(~exist('multidir','var'))
        multidir=0;
    end
    
    % do not update anything, create zero image.
    updatedIdxs=[];
    img=zeros(coln,rown);
    tlen=numel(img);
    
    % get the data vectorl
    [imgvector,ts]=ResultsStreamToVector(rslt);
    
    % just nothing here.
    if(length(imgvector)<2)
        return;
    end
    
    minT=ts(1);
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
    
    if(ticksPerPixel<1)
        % case we are missing data.
        % that is the total number of pxiels is
        % larger then the number of tbins.
%         keepIdxs=ts>=minT & ts<deltaT;
%         ts=ts(keepIdxs);
%         imgvector=(keepIdxs);
%         
        updatedIdxs=floor(ts./dwellTime)+1; % find appropriate indexs.
        rmvidxs=updatedIdxs>numel(img) | updatedIdxs<1;
        updatedIdxs(rmvidxs)=[];
        imgvector(rmvidxs)=[];
        
        img(updatedIdxs)=imgvector;
    else
        % case where we need to match 
        % pixels to appropriate arrays.
        
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
        img(updatedIdxs)=dsum./dnorm;
%         
%         % build the index copy matrix.
%         totalPixels=curPixel*ticksPerPixel;
%         if(totalPixels>0)
%             
% 
%             if(ticksPerPixel==1)
%                 img(updatedIdxs)=imgvector(1:totalPixels,1);
%             else
%                 img(updatedIdxs)=sum(reshape(imgvector(1:totalPixels,1),ticksPerPixel,curPixel));
%             end
%         else
%             updatedIdxs=[];
%         end
    end
    
    if(multidir)
        img(:,2:2:end)=img(end:-1:1,2:2:end);
    end
end

