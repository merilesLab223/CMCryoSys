function [obj] = parseAndAssignFromVarargin(obj,props,vals)
    if(~isobject(obj) || iscell(obj))
        error('Can only be applied to matlab objects.');
    end
    if(ischar(props))
        props={props};
    end
    keys=vals(1:2:end-1);
    vals=vals(2:2:end);
    [keys,nidxs]=intersect(keys,props);
    vals=vals(nidxs);
    % values are assumed key val.
    for i=1:length(keys)
        obj.(keys{i})=vals{i};
    end
end

