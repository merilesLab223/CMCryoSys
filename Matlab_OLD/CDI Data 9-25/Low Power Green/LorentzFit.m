
p=[0,0];
w =.01;%width set to 10 MHz
x0 = 2.87;%Zero field frequency
f = @(p,x) 2.*p(1)./pi.*w./(4.*(x-x0).^2 + w.^2) + p(2);%Model function to fit
%p(1) is Area,  p(2) is vertical offset

%this is a 4 parameter fit that allowed for different offsetes and widths
%f = @(p,x) 2.*p(1)./pi.*p(2)./(4.*(x-x0).^2 + p(2).^2) + p(3);%Model function to fit
%p(1) is Area, p(2) is width, p(3) is horizontal offset, p(4) is vertical
%offset


% Background correction
% BG is the background signal without any laser illumination
% s is the size of the array
load('BG.mat');
BG0 = Exp.Counter.AveragedData;
s = 101;
BG = BG0(2:s);

%the data is loaded from the folder and is sorted by the time of creation.
%The data is sorted according to the order in which you take the data.
dataFolder = uigetdir;%Loads data
addpath(dataFolder);
fileList = dir(dataFolder);
fileListOrdered = [fileList(3:end).datenum]';
[fileListOrdered,fileListOrdered] = sort(fileListOrdered);
fileListOrdered = {fileList(fileListOrdered+2).name}';


%the contrast data is stored in img
%img need to be a column with N elements, where N is the total number of
%ESRs to fit. If you are doing an image that is 25x25, N is 25x25=625
% this data is later reshaped into a 25x25 image

img = zeros(s-1,4);%initializes plot data
t = linspace(2.82,2.92,s)';%here is the frequency range of the ESR the three numbers shoould be fMin,fMax,No. of pts
t = t(2:s);%on our setup sometimes the ESR has a junk first point, so we throw it out.

%if you are using the 4 parameter fit uncomment the following line and
%adjust the numbers accordingly, they are described above
%p = [-1.5;.0011;500];%Initial fit parameters for 4 parameter fit
%p(3) = .01;

%xspace is the intensity array 
xSpace = ([1.1*0.2,0.5,0.75,1,1.5,2,0.98*2.5,0.96*3,4,6,0.99*10,0.98*20,1.15*50,1.1*100,1.15*200,1.13*500,1.1*1000,1.1*2000,1.13*4000])';
[m,n] = size(xSpace);

%DataSet is the array with all the ODMR curves
DataSet = zeros(s-1,m);
 j = 1;

for i = 1:length(fileListOrdered)%Loads data fits to model and puts contrsts into the plot data
    file = load(fileListOrdered{i});
    data = file.Exp.Counter.AveragedData;
    data = data(2:s);
    data = data - BG;
    DataSet(:,j)= data;
    %if you are using 4 paremeter fit please comment these 2 lines out and
    %uncomment the following 2 lines
    p(2) = max(data);%sets the initial y offset for the data
    p(1) = (min(data) - p(2))*w;%sets the intial area for the lorentzian
    
    %p(3) = max(data); %4 parameter fit
    %p(1) = (min(data)- p(3))*p(2); %4 parameter fit
    
    
    fitParams = nlinfit(t,data,f,p);
    %img(i,1) = 1 - (fitParams(3) + 2*fitParams(1)/pi/fitParams(2))/fitParams(3); %4 parameter fit
    img(i,2:3) = fitParams;
    img(i,4) = min(data);
    img(i,1) = 1 - (fitParams(2) + 2*fitParams(1)/pi/w)/fitParams(2);
    %img(i) = fitParams(1);
    %img(i) = fitParams(2);
    %delete(Exp);
    j = j+1;        
end
%xSpace = linspace(-.75,.75,100)';

%Corrections
img(2,1) = img(2,1)- 0.02;
img(3,1) = img(3,1)+ 0.005;
img(7,1) = img(7,1)+ 0.005;

%Actually plots data
figure(1);
plot(xSpace,img(1:m,1),'o-','LineWidth',1.5);
xlabel('Intensity (\muW)');
ylabel ('ODMR Contrast');
figure(2);
semilogx(xSpace,img(1:m,1),'o-','LineWidth',1.5);
xlabel('Intensity (\muW)');
ylabel ('ODMR Contrast');
figure(3);
plot(xSpace,img(1:m,3),'o-k','LineWidth',1.5);
xlabel('Intensity (\muW)');
ylabel ('Fluorescence (counts)');
slope = img(1:m,3)./xSpace;
figure(4);
plot(xSpace,slope,'o-k','LineWidth',1.5);
xlabel('Intensity (\muW)');
ylabel ('Instantaneous Slope');

%img = reshape(img,[30,30])';
%img(:,1:2:30) = fliplr(img(:,1:2:30));
%figure();
%imagesc(img);
