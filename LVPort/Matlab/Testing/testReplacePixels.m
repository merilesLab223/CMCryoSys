po=mlvportobj(pID);
nt=1000;
simg=size(po.Image);
curImg=zeros(simg);
lastIdxs=[];
for i=1:nt
    % random select pixel.
    pause(0.01);
    simg=size(po.Image);
    rx=floor(rand()*simg(1))+1;
    ry=floor(rand()*simg(2))+1;

    % updating the image.
    po.Image=zeros(simg);
    po.Image(rx,ry)=1;

    po.update('Image',true);
    [n,~,i]=p.PumpMessages();
    [val,ok,vsize,idxs]=p.GetNamepathValue(i(1),'');
    idxs=idxs+1;
    iterl=1;
    if(exist('lastIdxs','var') && length(lastIdxs)==2)
        iterl=length(intersect(lastIdxs,idxs));
    end
    if(isempty(idxs))
        if(isempty(val))
            disp('Same spot. Ignored.');
            continue;
        end
        curImg=po.Image;
        disp('Updated whole image')
    else
        try
            curImg(idxs)=val;
        catch err
            disp(val);
            disp(idxs);
            warning(err.message);
        end
        disp(['Updated pixels, ',num2str(idxs)])
    end
    imagesc(curImg);
    if(iterl==1)
        continue;
    end
    disp('---------------------------');

    disp(['Expected 1 intersect, got: ',num2str(iterl)]);
    disp(['Last update indexs: ',num2str(idxs)]);
    lastIdxs=idxs;

    disp(['New pixel at: ',num2str(rx),', ',num2str(ry)]);
    disp(['Has value? ',num2str(ok)]);
    disp(['Value size: ',num2str(size(val)),', org: ',num2str(vsize)]);
    disp('Update indexs:');
    disp(idxs);
end
