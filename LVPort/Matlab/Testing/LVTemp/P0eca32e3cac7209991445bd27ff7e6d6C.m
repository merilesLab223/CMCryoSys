classdef P0eca32e3cac7209991445bd27ff7e6d6C < LVPortObject
    %GRAPHTESTING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Image=[];
        Waveform=[];
        ImageWidth=100;
        ImageHeight=100;
        LastUpdatedImage=-1;
        LastUpdatedWaveform=-1;
        UpdateImageDelay=3;
        UpdateWaveFormDelay=1.5;
        DoUpdateImage=0;
        DoUpdateStream=0;
    end
    
    methods
        function loop(obj)
            curT=now*24*60*60; % in secs.
            if(obj.DoUpdateImage && curT-obj.LastUpdatedImage>obj.UpdateImageDelay)
                % needs update image.
                obj.LastUpdatedImage=curT;
                obj.UpdateImage();
            end
            if(obj.DoUpdateStream && curT-obj.LastUpdatedWaveform>obj.UpdateWaveFormDelay)
                % needs update image.
                obj.LastUpdatedWaveform=curT;
                obj.UpdateWaveform();
            end
        end
        
        function UpdateImage(obj)
            obj.Image=zeros(obj.ImageWidth,obj.ImageHeight);
            simg=size(obj.Image);
%             w=floor(simg(1)*rand());
%             h=floor(simg(2)*rand());
%             


            w=floor(rand()*simg(1)/2);
            h=floor(rand()*simg(2)/2); 
            x=floor(rand()*(simg(1)-w));
            y=floor(rand()*(simg(2)-h));
            
            if(x>=simg(1) || x<=0)
                return;
            elseif(y>=simg(2) || y<=0)
                return;
            end
            
            rmat=ones(w,h);
            ridx=x+1:x+w;
            cidx=y+1:y+h;
            obj.Image(ridx,cidx)=obj.Image(ridx,cidx)+rmat+0.5;
            obj.Image(eye(obj.ImageWidth,obj.ImageHeight)>0)=2;
%             n=numel(obj.Image);
%             startIdx=floor(n/2*rand());
%             endIdx=floor(n/2*rand()+n/2);
%             idxs=startIdx:endIdx;
%             obj.Image(idxs)=obj.Image(idxs)+rand(1,length(idxs));
            obj.update('Image',true);
        end
        
        function UpdateWaveform(obj)
            obj.Waveform=rand(1,1000);
            obj.update('Waveform');
        end
    end
end

