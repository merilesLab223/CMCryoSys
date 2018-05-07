%% remake the object.
pID=LVPort.MakePort('testLVPortHeavyPorperties.m');
p=mlvport(pID);
po=mlvportobj(pID);
tid=p.SetTempObject({});
% p.SetNamepathValue(tid,'SomeVal@numeric',23)
% p.SetNamepathValue(tid,'SomeVal@string','aaa')
% p.SetNamepathValue(tid,'SomeVal@numarr',[1,2,3])
% atid=p.SetTempObject(5);
% [ok,rtid]=p.InvokeMethod('someMethod',atid);
% p.GetTempObject(rtid)
