function [t,data] = DisplayScanAsStream(rslts)
    tic;
    if(isempty(rslts))
        disp('Called display DisplayScanAsStream with no results');
        return;
    end
    if(isa(rslts,'StreamCollector'))
        [data,dt]=rslts.getData();
        if(~isempty(data))
            [t,data]=StreamToTimedData(data,1,dt);
        else
            return;            
        end
    else
        [t,data]=StreamToTimedData(rslts);
    end
    t=t(1:end-1);
    data=data(1:end-1);
    comp=toc;
    if(comp>1000)
        disp(['Long display time for strea [ms]: ',num2str(comp)]);
    end
    plot(t,data);
    drawnow;
end

