function img = LoadImageFromDiskAsCounts(path)
    img=sum(double(imread(path)),3);
    img=img./max(img(:));
    img=img(end:-1:1,:);
end

