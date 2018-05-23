%%
binn=3;
ticn=10;
chann=2;
data=[];
for i=1:chann
    data(:,i)=repmat((1:binn*2)*i,1,ticn/2)';
end

if(length(data(:))~=binn*chann*ticn)
    error('Length mismatch.');
end

sumr=sum(reshape(data,binn,chann,ticn),1);
sumr=reshape(sumr,ticn,chann);