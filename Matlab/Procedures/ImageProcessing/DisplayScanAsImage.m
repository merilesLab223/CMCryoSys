function [img] = DisplayScanAsImage(rslt,coln,rown,dwellTime,preview)
    % splicing according to dwell time.
    if(~exist('preview','var'))preview=0;end
    tic;
    img=RowScanToImageData(rslt,coln,rown,dwellTime,preview);
    imagesc(img);
    comp=toc;
    if(comp>0.1)
        disp(['Slow convert image data. ',num2str(comp*1000),' [ms]']);
    end
end

