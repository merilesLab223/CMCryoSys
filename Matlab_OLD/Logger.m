classdef Logger < handle
    
    properties
        fileName
        logName
        loggerHandle
        fileHandler
        
    end
    
    methods
        %Constructor
        function obj = Logger(fileName,logName)
            obj.fileName = fileName;
            obj.logName = logName;
            obj.fileHandler = java.util.logging.FileHandler(obj.fileName,1e6,10,1);
            obj.fileHandler.setFormatter(java.util.logging.SimpleFormatter);
            obj.loggerHandle = java.util.logging.Logger.getLogger(obj.logName);
            obj.loggerHandle.addHandler(obj.fileHandler);
        end
        
        %Destructor
        function delete(obj)
            obj.fileHandler.close();
        end
        
        %Method to add INFO
        function info(obj,message)
            obj.loggerHandle.info(message);
        end
        
        %Method to add WARNING
        function warn(obj,message)
            obj.loggerHandle.warning(message);
        end

        %Method to add SEVERE
        function error(obj,message)
            obj.loggerHandle.severe(message);
        end

        
    end
    
end


        
        