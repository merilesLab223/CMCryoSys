classdef channel < handle
    
    properties
        logicalName
        physicalName
        type
        delayOn
        delayOff
        AWGData
    end
    
    methods
        %Constructor
        function obj = channel(logicalName,physicalName,type,delayOn,delayOff)
            if(nargin > 0)
                obj.logicalName = logicalName;
                obj.physicalName = physicalName;
                switch type
                    case {'marker','analog','quadrature'}
                        obj.type = type;
                    otherwise
                        error('Unknown channel type %s.  Must be marker,analog or quadrature.',type);
                end
                obj.delayOn = delayOn;
                obj.delayOff = delayOff;
            end
        end
        
        %Method to add AWGData
        function addAWGData(obj,newAmpData,newPhaseData)
            if(strcmp(obj.type,'marker'))
                obj.AWGData = [obj.AWGData; logical(newAmpData)];
            elseif(strcmp(obj.type,'analog'))
                obj.AWGData = [obj.AWGData; newAmpData];
            elseif(strcmp(obj.type,'quadrature'))
                obj.AWGData = [obj.AWGData; [newAmpData newPhaseData]];
            end
        end
        
        %Method to clear AWGData
        function clearAWGData(obj)
            obj.AWGData = [];
        end
        
        %Function to get quadrature data
        function quadData = getQuadData(obj)
            if(strcmp(obj.type,'quadrature'))
                quadData = [obj.AWGData(:,1).*cos(2*pi*obj.AWGData(:,2)) obj.AWGData(:,1).*sin(2*pi*obj.AWGData(:,2))];
            else
                error('This channel does not have quadrature data');
            end
        end
        
    end %methods
end



