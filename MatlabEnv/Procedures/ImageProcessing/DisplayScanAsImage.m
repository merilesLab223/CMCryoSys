function [img,uidxs] = DisplayScanAsImage(rslt,coln,rown,dwellTime,multidir,toff,lastImg,ranges,useLogScale)
    % splicing according to dwell time.
    if(~exist('lastImg','var'))lastImg=[];end
    if(~exist('multidir','var'))multidir=0;end
    if(~exist('ranges','var'))ranges=[-0.5,-0.5,1/coln,1/rown];end
    if(~exist('useLogScale','var'))useLogScale=0;end
    tic;
    img=[];
    [img,uidxs]=StreamToImageData(rslt,coln,rown,dwellTime,multidir,toff);
    if(isempty(img))
        disp('Empty image at update round');
        img=lastImg;
        uidxs=[];
        return;
    end
    if(isempty(uidxs))
        disp('Empty indexs at update round.');
        img=lastImg;
        uidxs=[];
        return;
    end
    %img=log(abs(img)+1);
    %img=img-min(img);
    hasLastImg=0;
    if(all(size(img)==size(lastImg)))
        lastImg(uidxs)=img(uidxs);
        img=lastImg;
    end
    
    minimg=min(img(:));
    maximg=max(img(:)-minimg);
    if(maximg<=0)
        return;
    end
    %img=img';
    simg=size(img);
    x=ranges(1)+ranges(3)*([1:simg(1)]);
    y=ranges(2)+ranges(4)*([1:simg(2)]);
    
    dimg=img-minimg;
    if(useLogScale)
        dimg=log(dimg+min(dimg(:))+2);
    end
    imagesc(x,y,dimg);
    colormap('jet');
    axis equal;
    colorbar;
    drawnow;
    comp=toc;
    if(comp>0.1)
        disp(['Slow convert image data. ',num2str(comp*1000),' [ms]']);
    end
    %disp(['Updated ',num2str(length(uidxs)),' pixels']);
end

