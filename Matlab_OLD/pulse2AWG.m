function pulseout = pulse2AWG(pulsein,marker1in,marker2in,format)

%This function converts pulses to the AWG format for sending to AWG
%
% pulseout = pulse2AWG(pulsein,marker1in,marker2in,format);
% pulsein - double vector with pulse data scaled between -1 and 1
% marker1in - logical vector with marker 1 data
% marker2in - logical vector with marker 1 data
% format - string with 'int' for integer style and 'real' for real

%Written by Colm Ryan December 2008

%Check pulse-in to make sure it is between -1 and 1
if(max(abs(pulsein)) > 1)
    warning('Absolute value of input pulse is greater than 1 and is being limited.');
end

pulsein = min(pulsein,1-1/(2^13));
pulsein = max(pulsein,-1);

if(strcmp(format,'int'))
  pulseout = 2^13 + round(2^13*pulsein) + 2^14*logical(marker1in) + 2^15*logical(marker2in);
elseif(strcmp(format,'real'))
	error('`real` type data format not yet implemented');
else
    error(['Unknown format in ''' format '''; should be ''int'' or ''real''.']);
end

%Reverse the byte order
tmpmat = dec2bin(pulseout,16);
tmpmat = [tmpmat(:,9:16) tmpmat(:,1:8)];
pulseout = bin2dec(tmpmat);





   


