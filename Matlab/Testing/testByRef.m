function [keys,vals] = testByRef()
    m=containers.Map;
    addByRef(m);
    keys=m.keys;
    vals=m.values;
end

function addByRef(a)
    a('asds')=32;
end

