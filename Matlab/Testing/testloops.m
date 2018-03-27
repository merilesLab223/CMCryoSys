mvmul=100000000;
na=1*mvmul;
nb=2*mvmul;
mv=5;
vec=[ones(na,1);5;5;5;ones(nb,1)*10];
comp=[];
disp(['For vector of ',num2str(length(vec)),'...']);

% check by min.
tic;
[~,idx]=min(abs(vec-mv));
comp(end+1)=toc;
disp(['By min search: v=',num2str(idx),' t=',num2str(comp(end))]);

tic;
idx=1;
svec=size(vec);
while(idx<svec(1)-1 && ~(vec(idx)>=mv && vec(idx+1)<mv))
    idx=idx+1;
end
comp(end+1)=toc;
disp(['By loop search: v=',num2str(idx),' t=',num2str(comp(end))]);