%% definitions testing.
global devices;
global info;

warning on;

if(isempty(devices))
    disp('Initializing system...');
    init();
end

%% do image scan.
n=100;
T=50;
imagescan(-1,-1,2,2,n,n,T);

started=now;
info.streamCollector.start();
warning off;
% show image scan.
while(true)
    [rslt]=getLabViewDisplayLoopInfo(true);
    if(rslt.newStream)
        subplot(2,1,1);
        plot(rslt.stream.t,rslt.stream.d);
    end
    
    if(rslt.newImage)
        subplot(2,1,2);
        xv=rslt.image.xrange(1):rslt.image.dx:rslt.image.xrange(2);
        yv=rslt.image.yrange(1):rslt.image.dy:rslt.image.yrange(2);
        imagesc(xv,yv,rslt.image.d);
    end
    
    pause(0.1);
    
    if(info.get('ImageDataLastCompleatedTS',-1)>started)
        break;
    end
end

% draw again.
[rslt]=getLabViewDisplayLoopInfo();
subplot(2,1,1);
plot(rslt.stream.t,rslt.stream.d);
subplot(2,1,2);
xv=rslt.image.xrange(1):rslt.image.dx:rslt.image.xrange(2);
yv=rslt.image.yrange(1):rslt.image.dy:rslt.image.yrange(2);
imagesc(xv,yv,rslt.image.d);

info.streamCollector.stop();
devices.get('scan_reader').stop();
disp('Image test complete.');
