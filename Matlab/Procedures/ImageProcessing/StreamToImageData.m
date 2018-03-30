function [img] = StreamToImageData(rslt,coln,rown,dwellTime,preview)
    % splicing according to dwell time.
    if(~exist('preview','var'))preview=0;end
    
    img=zeros(coln,rown);
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
    if(ticksPerPixel<1 || preview)
        % case we are missing data.
        % case we are missing data.
        ts=imgvector(:,1);
        ts=ts(ts>=minT & ts<deltaT);
        ts=round(ts./dwellTime)+1;
%         if(length(ts)>coln*rown)
%             [ts,uidxs]=unique(ts);
%             ts=ts(1:coln*rown);
%             uidxs=uidxs(1:coln*rown);
%         end
        % finding the nearest.
        img(ts)=imgvector(1:length(ts),2);
        
    else
        curPixel=floor(tlen/ticksPerPixel);
        if(curPixel>coln*rown)
            curPixel=coln*rown;
        end
        totalPixels=curPixel*ticksPerPixel;
        
        img(1:curPixel)=sum(reshape(imgvector(1:totalPixels,2),ticksPerPixel,curPixel));
%     else
%         data=imgvector(:,2);
%         tbins=(1:(coln*rown))*dwellTime;        
%         % case we have more or eual data.
%         ts=floor(imgvector(:,1)./dwellTime)+1;
%         lt=length(ts);
%         tsi=1;
%         ltsi=1;
%         
%         for i=1:length(tbins)
%             if(tsi>lt)break;end
%             while(ts(tsi)<tbins(i))
%                 tsi=tsi+1;
%                 if(tsi>lt)break;end
%             end
%             dat=data(ltsi:tsi);
%             img(i)=sum(dat);
%             tsi=tsi+1;
%             ltsi=tsi;
%         end
    end
    comp(end+1)=toc;
end

