%%% Test_DigitalIO_TekAWG

%Test_TekAWG.m

% create new TekAWG object with tcpip proto

V = TekAWGController('tcpip','172.16.1.183',4000);

% create null shape
binData = zeros(1000,1);

binData(1:100) = 0;
binData(101:200) = 1;
binData(201:300) = 2;
binData(301:400) = 3;
binData(401:500) = 4;
binData(501:600) = 5;
binData(601:700) = 6;
binData(701:800) = 7;
binData(801:900) = 8;

%open the socket
V.open();

% reset the device
V.reset();

% load the waveform
V.create_waveform_binary('test',binData)

V.close();
     
V.open();

% set marker voltage high/low
% CH1: MK1
V.setmarker(1,1,0,2.7);
% CH1: MK2
V.setmarker(1,2,0,2.7);

% set clock freq of AWG
V.setSourceFrequency(1e7);



V.setSourceWaveForm(1,'test');
V.setSourceOutput(1,1);
        
% Make a Sequence
V.initialize_sequence(1);
        
V.set_segment(1,{'test'},1000,[],[]);

V.close();