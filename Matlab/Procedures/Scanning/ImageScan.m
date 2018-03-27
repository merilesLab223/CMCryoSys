function [x,y,t] = ImageScan(pos,x,y,width,height,nX,nY,dwellTime,varargin)
    % image scanning should be done by x,y
    prs=inputParser;
    prs.addParameter('interpMethod',pos.interpolationMethod);
    prs.addParameter('multidirectional',1);
    prs.addParameter('weights',1);
    prs.parse(varargin{:});

    % generating the image scan vepsctor matrix.
    xv=x:width/(nX-1):x+width; % -1 spaces inside diffrence.
    yv=y:width/(nY-1):y+height;

    % generating the y vector locations.
    y=repmat(yv,length(yv),1); % as matrix.
    y=reshape(y,[length(y(:)),1]); % matrix to vector.

    % generating the x vector locations.
    if(prs.Results.multidirectional)
        x=[xv,xv(end:-1:1)]; % splicing.
        x=repmat(x,1,ceil(length(yv)/2))';
        x=x(1:length(y));
    else
        x=repmat(xv,1,length(yv))';
    end

    % creating the time dwell.
    t=(0:length(y)-1).*prs.Results.weights.*dwellTime;

    [x,y,t]=pos.GoTo(x,y,t,prs.Results.interpMethod);
end

