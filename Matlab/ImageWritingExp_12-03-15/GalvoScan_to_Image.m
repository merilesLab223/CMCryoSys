dataFolder = uigetdir;
addpath(dataFolder);
fileList = dir(dataFolder);
fileListOrdered = [fileList(3:end).datenum]';
[fileListOrdered,fileListOrdered] = sort(fileListOrdered);
fileListOrdered = {fileList(fileListOrdered+2).name}';

data = zeros(length(fileListOrdered),1);
n = 20;
Result = zeros(n,n);
ResultPost = zeros(n,n);

for i = 1:length(fileListOrdered)
    file = load(fileListOrdered{i});
    data(i,1) = file.Exp.Counter.AveragedData;
end

for row = drange(1:1:n)
    for col = drange(1:1:n)
        Result(row,col)= data(col+(n*(row-1)),1);
    end
end

Result(1:2:end,:) = fliplr(Result(1:2:end,:));

% for row = drange(1:1:n)
%     for col = drange(1:1:n)
%         if Result(row,col)<= 5;
%            ResultPost(row,col)= 0;
%         else
%             ResultPost(row,col)= 1;
%         end
%     end
% end

x = linspace (-0.2, 0.2, n);
y = linspace (-0.2, 0.2, n);

figure (1);
Image = surf(x,y,Result);
colormap copper;
view(2);
colorbar;
grid on;
set(Image,'edgecolor','none');
axis square;
set(gca,'TickDir','out');
box on;

% figure (2);
% Image = surf(x,y,ResultPost);
% colormap copper;
% view(2);
% colorbar;
% grid on;
% set(Image,'edgecolor','none');
% axis square;
% set(gca,'TickDir','out');
% box on;