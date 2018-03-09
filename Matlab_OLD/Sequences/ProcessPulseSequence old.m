function [Sequence,tempPS] = ProcessPulseSequence(PSeq,SourceFreq)

% 23 July 2010
% jhodges
% adding phase processing to pulse blaster sequences


% 29 April 2010
% jhodges
% Changed the way that we handle loops and sweeps to make it work as
% expected.


tempPS = PSeq;

% if there are sweeps enabled, process the sweep
if numel(PSeq.Sweeps),
    [Sequence,tempPS] = PulseSequenceSweepToArray(PSeq,SourceFreq);
end

% process any groups/loops.  Note taht current parser only handles 1 loop
% and no nested loops

if numel(PSeq.Groups) == 1,
    [tempPS] = ExpandLoops(tempPS);
elseif numel(PSeq.Groups) > 2,
    error('Program can only handle single Groups for now.');
end


% given the clock rate of the parse out the Pulse Program, channel
% by channel and put into a data structure

Sequence =  PulseSequenceToArray(tempPS,SourceFreq);

end

function [Sequence] = PulseSequenceToArray(PSeq,SourceFreq)


    if strcmp(class(PSeq),'PulseBlasterPulseSequence'),
        %% Define relative parameters
        MicrowaveHardwareChannel = PSeq.MicrowaveHardwareChannel;
        PhaseBitResolution = PSeq.PhaseBitResolution;
        PhaseHardwareLines = PSeq.PhaseHardwareLines;
    else
        MicrowaveHardwareChannel = -1;
        PhaseHardwareLines = [];
        PhaseBitResolution = 0;
    end

    % get the max time of the sequence
    tmax = PSeq.GetMaxRiseTime;
    SeqPoints = ceil(tmax*SourceFreq);

    % sequence size is (number of channels + number of phase bits) x
    % (Number of Clock Cycles)
    
    NumChannels = numel(PSeq.Channels) + numel(PhaseHardwareLines);
    Sequence = zeros(NumChannels,SeqPoints);
    
    

    for k=1:numel(PSeq.Channels),
        
        
        % set Phase to 0 to start
        RisePhaseInt = 0;

        % loop over the rises
        for l=1:PSeq.Channels(k).NumberOfRises,
            
            
            % for each rise, check if the channel is a microwave channel
            % and then find the phase of the rise
            if PSeq.Channels(k).HWChannel == MicrowaveHardwareChannel,
                RisePhaseInt = PSeq.Channels(k).RisePhases(l);
            end;

            
            % calculate the binary phase representation
            
            PhaseUnit = 360/(2^PhaseBitResolution);
            NumberOfPhaseUnits = ceil(RisePhaseInt/PhaseUnit);
            RisePhaseBinString = dec2bin(NumberOfPhaseUnits,PhaseBitResolution);
            RisePhaseBin = str2num(RisePhaseBinString');
            
            
            startTime = PSeq.Channels(k).RiseTimes(l);
            
            % account for HW delay
            startTimeActual = startTime - PSeq.Channels(k).DelayOn;
            
            stopTime = startTime + PSeq.Channels(k).RiseDurations(l);
            % account for HW delay
            stopTimeActual = stopTime - PSeq.Channels(k).DelayOff;
            pStart = uint32(startTimeActual*SourceFreq);
            pStop = uint32(stopTimeActual*SourceFreq);

            % add one for Matlab type indexings
            Sequence(k,pStart+1:pStop+1) = 1; % set PSeq Channel high
            Sequence(k,pStart+1:pStop+1) = 1; % set PSeq Channel high
                
            % set phase lines to appropriate phase
            if PSeq.Channels(k).HWChannel == MicrowaveHardwareChannel,
                PrePhaseDelay = 40; %clock cycles
                PostPhaseDelay = 40; %clock cycles
                Sequence(numel(PSeq.Channels)+1:NumChannels,(pStart-PrePhaseDelay)+1:pStop+1+PostPhaseDelay) = repmat(RisePhaseBin,1,pStop+PostPhaseDelay-pStart+PrePhaseDelay+1);
            else
                %Sequence(numel(PSeq.Channels)+1:NumChannels,pStart+1:pStop+1) = repmat(RisePhaseBin,1,pStop-pStart+1);
            end

        end
    end
end

function [Sequence, tempPSeq] = PulseSequenceSweepToArray(PSeq,SourceFreq)
  
    % create a dummy sequence which we can copy in and modify
    tempPSeq = PSeq.clone();
    
    % loop thru the sweeps updating the channels
    for jj=1:numel(PSeq.Sweeps),
        
        switch PSeq.Sweeps(jj).SweepClass
            case 'Rise'
                ProcessRiseClass(PSeq,tempPSeq,jj);
            case 'Type'
                % use this for changing all pulses with the same "type"
                ProcessTypeClass(PSeq,tempPSeq,jj);
            case 'Group'
                warning('not implemented');
            otherwise
                warning('Sweep Class %s not recognized',PSeq.Sweeps(jj).SweepClass);
        end
        
    end
    
    
    Sequence =  PulseSequenceToArray(tempPSeq,SourceFreq);

end

function [] = ProcessRiseClass(PSeq,tempPSeq,jj)
    ind = PSeq.getSweepIndex();
    chn = PSeq.Sweeps(jj).Channels;
    rise = PSeq.Sweeps(jj).SweepRises;
    x = linspace(PSeq.Sweeps(jj).StartValue,PSeq.Sweeps(jj).StopValue,PSeq.Sweeps(jj).SweepPoints);
    switch PSeq.Sweeps(jj).SweepType,
        case 'Time'
           
                % always shift the sweep with respect to the original
                % template sequence, those the riseT for searching for
                % shifts should be the one before the adding was done
                oldRiseT = tempPSeq.Channels(chn).RiseTimes(rise);

                % shifts 
                if PSeq.Sweeps(jj).SweepShifts == 1,
                    inds = find(tempPSeq.Channels(chn).RiseTimes > oldRiseT);
                    tempPSeq.Channels.RiseTimes(inds) = tempPSeq.Channels.RiseTimes(inds) + x(ind(jj));
                elseif PSeq.Sweeps(jj).SweepShifts == 2, % shift all channels
                    for qq=1:numel(tempPSeq.Channels),
                        inds = find(tempPSeq.Channels(qq).RiseTimes > oldRiseT);
                        if inds,
                            tempPSeq.Channels(qq).RiseTimes(inds) = tempPSeq.Channels(qq).RiseTimes(inds) + x(ind(jj));
                        end
                    end
                end
                
                % increse the sweep time
                if PSeq.Sweeps(jj).SweepAdd
                    tempPSeq.Channels(chn).RiseTimes(rise) = tempPSeq.Channels(chn).RiseTimes(rise) + x(ind(jj));
                else
                    tempPSeq.Channels(chn).RiseTimes(rise) = x(ind(jj));
                end

        case 'Duration'
            % increase the sweep duration
            if PSeq.Sweeps(jj).SweepAdd,
                tempPSeq.Channels(chn).RiseDurations(rise) = tempPSeq.Channels(chn).RiseDurations(rise) + x(ind(jj));
            else
                tempPSeq.Channels(chn).RiseDurations(rise) = x(ind(jj));
            end

            if PSeq.Sweeps(jj).SweepShifts == 1,
                tempPSeq.Channels(chn).RiseTimes(rise+1:end) = tempPSeq.Channels(chn).RiseTimes(rise+1:end) + x(ind(jj));
            elseif PSeq.Sweeps(jj).SweepShifts == 2, % shift all channels
                % find all rise times occuring after the
                % beginning of this sweep
                riseT = tempPSeq.Channels(chn).RiseTimes(rise);
                for k=1:numel(tempPSeq.Channels),
                    inds = find(tempPSeq.Channels(k).RiseTimes > riseT);
                    if inds,
                        tempPSeq.Channels(k).RiseTimes(inds) = tempPSeq.Channels(k).RiseTimes(inds) + x(ind(jj));
                    end
                end
            end

        case 'Amplitude'
        case 'Phase'
    end
end

function [] = ProcessTypeClass(PSeq,tempPSeq,jj)

    % get current sweep index
    ind = PSeq.getSweepIndex();
    
    % get the channel for this sweep
    chn = PSeq.Sweeps(jj).Channels;
    
    % get the rises for this sweep, this will be a text field for the Type
    % Class
    rise = PSeq.Sweeps(jj).SweepRises;
    
    % get the channel and rise numbers associated with this rise type
    allTypeRises = zeros(0,2);
    allRiseTimes = zeros(0,1);
    % [chn, rise]
    % use inefficient looping (prob. a one line command for this)
    for k=1:numel(PSeq.Channels),
        for kk=1:numel(PSeq.Channels(k).RiseTypes),
            if strcmp(PSeq.Channels(k).RiseTypes(kk),rise),
                allTypeRises = [allTypeRises;k,kk];
                allRiseTimes = [allRiseTimes;PSeq.Channels(k).RiseTimes(kk)];
            end
        end
    end
            
    % order the rise times from smallest to largest
    [y,sortedInd] = sort(allRiseTimes,'ascend');
    allTypeRises = [allTypeRises(sortedInd,1),allTypeRises(sortedInd,2)];
    
    x = linspace(PSeq.Sweeps(jj).StartValue,PSeq.Sweeps(jj).StopValue,PSeq.Sweeps(jj).SweepPoints);
    switch PSeq.Sweeps(jj).SweepType,
        case 'Time'
            for k=1:length(allTypeRises),
                chn = allTypeRises(k,1);
                rise = allTypeRises(k,2);
                
                % always shift the sweep with respect to the original
                % template sequence, those the riseT for searching for
                % shifts should be the one before the adding was done
                oldRiseT = tempPSeq.Channels(chn).RiseTimes(rise);

                % shifts 
                if PSeq.Sweeps(jj).SweepShifts == 1,
                    inds = find(tempPSeq.Channels(chn).RiseTimes > oldRiseT);
                    tempPSeq.Channels(chn).RiseTimes(inds) = tempPSeq.Channels(chn).RiseTimes(inds) + x(ind(jj));
                elseif PSeq.Sweeps(jj).SweepShifts == 2, % shift all channels
                    for qq=1:numel(tempPSeq.Channels),
                        inds = find(tempPSeq.Channels(qq).RiseTimes > oldRiseT);
                        if inds,
                            tempPSeq.Channels(qq).RiseTimes(inds) = tempPSeq.Channels(qq).RiseTimes(inds) + x(ind(jj));
                        end
                    end
                end
                
                % increse the sweep time
                if PSeq.Sweeps(jj).SweepAdd
                    tempPSeq.Channels(chn).RiseTimes(rise) = tempPSeq.Channels(chn).RiseTimes(rise) + x(ind(jj));
                else
                    tempPSeq.Channels(chn).RiseTimes(rise) = x(ind(jj));
                end

            end

        case 'Duration'
            warning('Class: `Type`, Type:`Duration` not implemented');
        case 'Amplitude'
            warning('Amplitude Sweep Type not implemented');
        case 'Phase'
            warning('Phase Sweep Type not implemented');
    end
end

function [NewPS] = ExpandLoops(PSeq)

        % get all the events
        evnts = PSeq.CalculateEvents;

        % get the groups for the pulse sequence
        G = PSeq.Groups;

        % create a clone of the pulse sequence.  We will update the clone

        NewPS = PSeq.clone();


        for k=1:numel(G),

            % get absolute times for start and stop events
            eventStartTime = evnts(G(k).StartEvent);
            eventEndTime = evnts(G(k).EndEvent);

            % loop over all the channels
            for jj=1:numel(PSeq.Channels),

                % get channel
                C = PSeq.Channels(jj);

                % find all the rises that occur between the start and end event
                % times

                beforeInds = find(C.RiseTimes < eventStartTime);
                loopInds = find((C.RiseTimes >= eventStartTime) & (C.RiseTimes < eventEndTime));
                afterInds = find(C.RiseTimes >= eventEndTime);


                % reset arrays
                NewPS.Channels(jj).RiseTimes = [];
                NewPS.Channels(jj).RiseDurations = [];
                NewPS.Channels(jj).RiseTypes = {};
                NewPS.Channels(jj).RiseAmplitudes  =[];
                NewPS.Channels(jj).RisePhases = [];

                % set before Inds to be the same
                NewPS.Channels(jj).RiseTimes(beforeInds) = PSeq.Channels(jj).RiseTimes(beforeInds);
                NewPS.Channels(jj).RiseDurations(beforeInds) = PSeq.Channels(jj).RiseDurations(beforeInds);
                NewPS.Channels(jj).RiseTypes(beforeInds) = PSeq.Channels(jj).RiseTypes(beforeInds);
                NewPS.Channels(jj).RiseAmplitudes(beforeInds) = PSeq.Channels(jj).RiseAmplitudes(beforeInds);
                NewPS.Channels(jj).RisePhases(beforeInds) = PSeq.Channels(jj).RisePhases(beforeInds);
                % now expand the loop
                for ll=1:G(k).Loops,
                    len = length(NewPS.Channels(jj).RiseTimes);
                    NewPS.Channels(jj).RiseTimes(len+1:len+numel(loopInds)) = PSeq.Channels(jj).RiseTimes(loopInds) + (ll-1)*(eventEndTime-eventStartTime);
                    NewPS.Channels(jj).RiseDurations(len+1:len+numel(loopInds)) = PSeq.Channels(jj).RiseDurations(loopInds);
                    NewPS.Channels(jj).RiseTypes(len+1:len+numel(loopInds)) = PSeq.Channels(jj).RiseTypes(loopInds);
                    NewPS.Channels(jj).RiseAmplitudes(len+1:len+numel(loopInds)) = PSeq.Channels(jj).RiseAmplitudes(loopInds);
                    NewPS.Channels(jj).RisePhases(len+1:len+numel(loopInds)) = PSeq.Channels(jj).RisePhases(loopInds);
                end

                % now add the time to the after rises
                NewPS.Channels(jj).RiseTimes(end+1:end+numel(afterInds)) = PSeq.Channels(jj).RiseTimes(afterInds) + (G(k).Loops - 1)*(eventEndTime - eventStartTime);
                NewPS.Channels(jj).RiseDurations(end+1:end+numel(afterInds)) = PSeq.Channels(jj).RiseDurations(afterInds);
                NewPS.Channels(jj).RiseTypes(end+1:end+numel(afterInds)) = PSeq.Channels(jj).RiseTypes(afterInds);
                NewPS.Channels(jj).RiseAmplitudes(end+1:end+numel(afterInds)) = PSeq.Channels(jj).RiseAmplitudes(afterInds);
                NewPS.Channels(jj).RisePhases(end+1:end+numel(afterInds)) = PSeq.Channels(jj).RisePhases(afterInds);

                % update the Number of Rise
                NewPS.Channels(jj).NumberOfRises = numel(NewPS.Channels(jj).RiseTimes);
            end

        end

        % expanded PS should not have any groups
        NewPS.Groups = [];
        for k=1:numel(NewPS.Listeners{3,:}),
            delete(NewPS.Listeners{3,k});
            NewPS.Listeners{3,k} = [];
        end

end
        