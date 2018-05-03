tnc=test_notify_class();
tnc.addlistener('SE',@(s,e)error('lama'));
try
    tnc.notify('SE',EventStruct);
catch err
end