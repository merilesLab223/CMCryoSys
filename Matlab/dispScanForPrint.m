function dispScanForPrint(CIs)



figure;
nCols = 3;
nRows = ceil(length(CIs)/nCols);

subplot(nRows,nCols,1);
for index = 1:length(CIs),
    cImage = CIs(index);
    
    figure(floor((index-1)/3)+1);
    set(gcf,'PaperOrientation','landscape',...
	'PaperPosition', [0.25 0.25 10.5 8], ...
	'PaperPositionMode' ,'manual',...
	'PaperSize' ,[11 8.5],...
	'PaperType' ,'usletter');

    a = mod(index-1,3)+1;
    subplot(1,3,a);
    imagesc(cImage.DomainX,cImage.RangeY(end:-1:1),cImage.ImageData);
    axis square;
    colormap(bone);
    title(['Z = ',num2str(cImage.PositionZ),' mm']);
    colorbar('EastOutside');
end