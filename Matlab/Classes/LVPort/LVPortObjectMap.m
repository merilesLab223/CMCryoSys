classdef LVPortObjectMap < handle
    %LVPORTOBJECMAP An object map that represents the state of an object.
    %an object map cannot be uploaded.
    
    methods
        function obj = LVPortObjectMap(omap,compareTo)
            o.ValMap=omap;
            if(exist(compareTo,'var')&&isa(comapreTo,'containers.Map'))
                obj.removeUnchanged(compareTo,compareTo);
            end
        end        
    end
    
    properties (SetAccess = protected)
        ValMap=[]; % must be defined
        ValIndexMap=containers.Map;
    end
    
    methods        
        function [hasval,val,vsize,idxs]=GetNampathInfo(obj,namepath)
            hasval=0;
            val=[];
            vsize=[];
            idxs=[];
            if(~obj.ValMap.isKey(namepath))
                return;
            end
            hasval=1;
            val=obj.ValMap(namepath);
            if(obj.ValIndexMap.iskey(namepath))
                idxsInfo=obj.ValIndexMap(namepath);
                idxs=idxsInfo.idxs;
                vsize=idxsInfo.orgSize;
            else
                idxs=[];
                vsize=size(val);
            end
        end
        
        function removeUnchanged(obj,compareToMap)
            namepaths=compareToMap.keys;
            vals=compareToMap.values;
            
            for i=1:length(namepaths)
                namepath=namepaths{i};
                if(~obj.ValMap.isKey(namepath))
                    continue;
                end
                val=vals{i};
                do_remove_similar=false;
                do_set_update_idxs=[];
                
                if(ismatrix(val))
                    % must be the same size to compare.
                    if(all(size(val)==size(obj.ValMap(namepath))))
                        % find index to update.
                        oldmat=obj.ValMap(namepath);
                        do_set_update_idxs=find(val(:)~=oldmat(:));
                        if(isempty(do_set_update_idxs))
                            do_remove_similar=true;
                        elseif(length(do_set_update_idxs)==length(oldmat(:)))
                            do_set_update_idxs=[]; % there are all diffrent.
                        end 
                    end
                else
                    do_remove_similar=val==obj.ValMap(namepath);
                end
                
                % we need to update?
                if(do_remove_similar)
                    obj.ValMap.remove(namepath);
                elseif(~isempty(do_set_update_idxs))
                    idxinfo={};
                    idxinfo.idxs=do_set_update_idxs;
                    idxinfo.orgSize=size(val);
                    obj.ValIndexMap(namepath)=idxinfo;
                end
            end
        end
    end
end

