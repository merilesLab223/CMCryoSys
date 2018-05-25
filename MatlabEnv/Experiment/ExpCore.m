classdef ExpCore < handle
    methods (Static)
        function [srv]=GetServer()
            persistent server;
            if(isempty(server))
                server= ExperimentCore();
            end            
            srv=server;
        end
        % validates the that the experiment server is running.
        function ValidateServer(traceLogs)
            if(~exist('traceLogs','var'))
                traceLogs=false;
            end
            
            server=ExpCore.GetServer();
            
            if(~server.IsListening)
                server.TraceLogs=traceLogs;
                server.Listen();
            end
        end
        
        function [exp]=GetExperiment(expID)
            server=ExpCore.GetServer();
            exp=[];
            if(server.WebsocketBindings.contains(expID))
                exp=server.WebsocketBindings(expID);
            end
        end
        
        function [exp]=GetLastExperiment()
            server=ExpCore.GetServer();
            if(isempty(server.LastExperimentOpenedID))
                exp=[];
            else
                exp=ExpCore.GetExperiment(server.LastExperimentOpenedID);
            end
        end
    end
end

