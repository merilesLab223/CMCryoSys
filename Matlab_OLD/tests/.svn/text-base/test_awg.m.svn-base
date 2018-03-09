
%create a tcpip socket to port 4000
fpTCP = tcpip('172.16.1.183',4000);

% give a hefty output buffer
 set(fpTCP,'InputBufferSize',1000000);
 set(fpTCP,'OutputBufferSize',1000000);

 % open socket
fopen(fpTCP);

% name of the waveform
WaveName = 'SINC';

% delete the waveform before creating a new one
fprintf(fpTCP,sprintf('WLIST:WAVEFORM:DELETE "%s"',WaveName));
                
% create new waveform, of type real with 1024 points
fprintf(fpTCP,sprintf('WLIST:WAVEFORM:NEW "%s", 1024, INT',WaveName));

x = (0:1023).*8*pi/1024;
data = sinc(x);
marker1 = zeros(1,1024);
P = pulse2AWG(data,marker1,marker1,'int');

%Instruct the instrument to write the file sin.wfm with Waveform File format, a total length of 2544 bytes, and a combined data and marker length of 2500 bytes.
%Note that the IEEE 488.2 block header
%depends on the type of the data being transferred. If it is integer type, the total
%bytes will be twice the size of the waveform and if it is a real waveform, the total
%bytes will be five times the size of the waveform.
%
binblockwrite(fpTCP,P,'uint16',sprintf('WLIST:WAVEFORM:DATA "%s", ',WaveName));

fclose(fpTCP);