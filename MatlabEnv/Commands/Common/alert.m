function alert(exp,msg,category)
    if(~exist('category','var'))category='matlab';end
    exp.ExpInfo.PostEvent('malert',msg,category);
end

