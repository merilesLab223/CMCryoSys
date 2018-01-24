%Test_TekAWG.m

% create new TekAWG object with tcpip proto

V = TekAWGController('tcpip','172.16.1.183',4000);

% create null shape
Shape = sin([0:1e5-1]'*2*pi/1e3);
Marker1 = zeros(1e5,1);
Marker2 = zeros(1e5,1);

% add some structure to the markers
%
% Actual pulse sequence for ODMR
Marker1(1:100)= 1;
Marker2(50001:100000) = 1;

%open the socket
V.open();

% reset the device
V.reset();

% load the waveform
V.create_waveform('ODMR',Shape,Marker1,Marker2)

V.close();

V.open();

% set marker voltage high/low
% CH1: MK1
V.setmarker(1,1,0,2.7);
% CH1: MK2
V.setmarker(1,2,0,2.7);

% set clock freq of AWG
V.setSourceFrequency(1e7);

V.close();