function gotoPosition(x,y)
    global devices;
    pos=devices.get('scan_pos');
    if(pos.niSession.IsRunning)
        warning('Aborted current position run.');
    end
    
    [x,cng]=toLim(x,10);
    if(cng)warning('X position out of bounds.');end
    [y,cng]=toLim(y,10);
    if(cng)warning('Y position out of bounds.');end
    
    pos.stop();
    pos.clear();
    pos.GoTo(x,y);
    pos.prepare();
    pos.run;
end

function [v,changed]=toLim(v,maxv,minv)
    if(~exist('minv','var'))minv=-maxv;end
    changed=0;
    if(v>maxv)
        v=maxv;
        changed=1;
    end
        
    if(v<minv)
        v=minv;
        changed=1;
    end      
end

