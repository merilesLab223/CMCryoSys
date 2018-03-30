function [t,data] = DisplayScanAsStream(rslts)
    tic;
    [t,data]=StreamToTimedData(rslts);
    comp=toc;
    if(comp>1000)
        disp(['Long display time for strea [ms]: ',num2str(comp)]);
    end
    plot(t,data);
    drawnow;
end

