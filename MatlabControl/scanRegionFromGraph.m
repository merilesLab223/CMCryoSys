function [x,y,w,h]= scanRegionFromGraph(g)
    if(~exist('g'))
        g=gcf;
    end
    xlm=g.CurrentAxes.XLim;
    ylm=g.CurrentAxes.YLim;
    
    w=xlm(2)-xlm(1);
    h=ylm(2)-ylm(1);
    x=xlm(2)-w/2;
    y=ylm(2)-h/2;
end

