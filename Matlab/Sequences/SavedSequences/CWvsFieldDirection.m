%Script to run the CW ESR as a function of magnetic field

for angle = 0:10:90

    %Set the field
    fieldMag = 2;
    handles.BFieldController.setCurrent(1,fieldMag*cos(angle*pi/180));
    handles.BFieldController.setCurrent(3,fieldMag*sin(angle*pi/180));
    
    %Do some tracking to make sure we are locked
    TrackingViewer(handles.Tracker);
    handles.Tracker.trackCenter(1);
    %Close the window so we don't accumulate listeners
    close(findobj(0,'name','TrackingViewer'));
    
    %Run the experiment
    pushbutton_start_Callback(handles.pushbutton_start, [], handles)
    
    %Check to see whether we stopped out
    if(handles.Counter.AvgIndex  ~= handles.expparams.numAverages)
        break
    end

    %Save the experiment
    Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.pulseSequence);
    fp = getpref('nv','DefaultExpSavePath');
    fn = sprintf('CWvsFieldDirection_XZ_%d_%s',angle,datestr(now,'dd-mmm-yyyy'));
    save([fp '\' fn],'Exp');
    
end

