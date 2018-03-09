%%% quick and dirty awg upload
function [V] = qdawg(PulseSequence,ClockRate,Samples)

%% CONFIGURE AWG PULSES

        disp('Configuring AWG...');

        V = TekAWGController('tcpip','172.16.1.183',4000);
        
        [RawSequence,PSeq] = ProcessPulseProgramTekAWG(PulseSequence, [], ClockRate);
        
        %% NB! NO HARDWARE ROUTING YET!
        [WaveA, WaveB] = CreateShapes(RawSequence,PulseSequence);
        
        % NOTE when the sequence is finished, it writes the last Marker
        % Value to the default state of the line (e.g. High or Low).  Thus,
        % we must make sure to have the last points LOW.

        %open the socket
        V.open();

        % reset the device
        V.reset();

        % load the waveform
        if ~isempty(WaveA),
            V.create_waveform('NV_PSeq_A',WaveA.Shape,WaveA.Marker1,WaveA.Marker2)
        end
        
        if ~isempty(WaveB),
            V.create_waveform('NV_PSeq_B',WaveB.Shape,WaveB.Marker1,WaveB.Marker2)
        end
        
        
        
        % set marker voltage high/low
        % CH1: MK1
        V.setmarker(1,1,0,2.7);
        % CH1: MK2
        V.setmarker(1,2,0,2.7);
        
        % set marker voltage high/low
        % CH2: MK1
        V.setmarker(2,1,0,2.7);
        % CH2: MK2
        V.setmarker(2,2,0,2.7);

        % set clock freq of AWG
        V.setSourceFrequency(ClockRate);
        
        % assign waveform A to channel 1
        if ~isempty(WaveA),
            V.setSourceWaveForm(1,'NV_PSeq_A');
            % turn on the output to channel 1
            V.setSourceOutput(1,1);
        end
        
        if ~isempty(WaveB),
            V.setSourceWaveForm(1,'NV_PSeq_B');
            % turn on the output to channel 2
            V.setSourceOutput(2,1);
        end       
        
        % Make a Sequence
        V.initialize_sequence(1);
        
        % assign sequence waveform names
        if ~isempty(WaveA),
            waveforms{1} = 'NV_PSeq_A';
        end
        
        if ~isempty(WaveB),
            waveforms{2} = 'NV_PSeq_B';
        end
        
        V.set_segment(1,waveforms,Samples,[],[]);
        
        % set to sequence mode
        V.sendstr('AWGCONTROL:RMODE SEQUENCE');
               
        V.close();
        
        % wait until the device settles
        pause(2);
        
        function [WaveA, WaveB] = CreateShapes(RawSequence,PulseSequence)
            
            % for safety always set the sequence to low after running
            RawSequence(:,end+1) = 0;
            Sz = size(RawSequence,1);
            if Sz == 1,
                WaveA.Shape = RawSequence(1,:);
                WaveA.Marker1 = zeros(1,size(RawSequence,2));
                WaveA.Marker2 = zeros(1,size(RawSequence,2));
                WaveB = [];
            elseif Sz == 2,
                WaveA.Shape = RawSequence(1,:);
                WaveA.Marker1 = RawSequence(2,:);
                WaveA.Marker2 = zeros(1,size(RawSequence,2));
                WaveB = [];

            elseif Sz == 3,
                WaveA.Shape = RawSequence(1,:);
                WaveA.Marker1 = RawSequence(2,:);
                WaveA.Marker2 = RawSequence(3,:);
                WaveB = [];
            elseif Sz == 4,
                WaveA.Shape = RawSequence(1,:);
                WaveA.Marker1 = RawSequence(2,:);
                WaveA.Marker2 = RawSequence(3,:);
                WaveB.Shape = RawSequence(4,:);
                WaveB.Marker1 = zeros(1,size(RawSequence,2));
                WaveB.Marker2 = zeros(1,size(RawSequence,2));
            elseif Sz == 5,
                WaveA.Shape = RawSequence(1,:);
                WaveA.Marker1 = RawSequence(2,:);
                WaveA.Marker2 = RawSequence(3,:);
                WaveB.Shape = RawSequence(4,:);
                WaveB.Marker1 = RawSequence(5,:);
                WaveB.Marker2 = zeros(1,size(RawSequence,2));
            elseif Sz == 6,
                WaveA.Shape = RawSequence(1,:);
                WaveA.Marker1 = RawSequence(2,:);
                WaveA.Marker2 = RawSequence(3,:);
                WaveB.Shape = RawSequence(4,:);
                WaveB.Marker1 = RawSequence(5,:);
                WaveB.Marker2 = RawSequence(6,:);
            else,
                WaveA = [];
                WaveB = [];
            end
            
        