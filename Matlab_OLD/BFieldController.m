classdef BFieldController < handle
    
    properties
        Supplies  %Array of hardware handles to the power supplies
        
    end
    
    methods
        
        %Constructor
        function obj = BFieldController()
        end
        
       %Method to open all connections
        function openConnections(obj)
            fopen(obj.Supplies)
        end
        
        %Method to close all connections
        function closeConnections(obj)
            fclose(obj.Supplies)
        end
        
        %Method to reset the controller
        function reset(obj)
            for ct = 1:length(obj.Supplies)
                obj.sendStr(ct,'*RST');
            end
        end
        
        %Method to send a control string to an instrument
        function sendStr(obj,direction,string2send)
            fprintf(obj.Supplies(direction),string2send);
        end
        
        %Method to query an instrument
        function result = queryStr(obj,direction,queryStr)
            result = query(obj.Supplies(direction),queryStr);
        end
        
        %Method to set a voltage
        function setVoltage(obj,direction,voltage)
            obj.sendStr(direction,sprintf('SOURCE:VOLTAGE %fV',voltage));
        end
        
        %Method to get the current voltage setting
        function result = getVoltage(obj,direction)
            result = str2double(obj.queryStr(direction,'SOURCE:VOLTAGE?'));
        end
        
        %Method to set a current
        function setCurrent(obj,direction,current)
            obj.sendStr(direction,sprintf('SOURCE:CURRENT %fA',current));
        end
        
        %Method to get the current current setting
        function result = getCurrent(obj,direction)
            result = str2double(obj.queryStr(direction,'SOURCE:CURRENT?'));
        end
        
        %Method to set voltages for all the supplies
        function setVoltages(obj,voltages)
            %Make sure the number of voltages matches the number of
            %supplies
            if(length(voltages) == length(obj.Supplies))
                for ct = 1:length(obj.Supplies)
                    obj.setVoltage(ct,voltages(ct));
                end
            else
                error('Number of voltages requested does not match number of supplies')
            end
        end
        
        %Method to set currents for all the supplies
        function setCurrents(obj,currents)
            %Make sure the number of currents matches the number of
            %supplies
            if(length(currents) == length(obj.Supplies))
                for ct = 1:length(obj.Supplies)
                    obj.setCurrent(ct,currents(ct));
                end
            else
                error('Number of currents requested does not match number of supplies')
            end
        end
        
        %Method to turn the output on 
        function setOutput(obj,direction,output)
            obj.sendStr(direction,sprintf('OUTPUT:STATE %d',output));
        end
        
        %Method to turn all the outputs on
        function setOutputsOn(obj)
            for ct = 1:length(obj.Supplies)
                obj.setOutput(ct,1);
            end
        end
        
        %Method to turn all the outputs off
        function setOutputsOff(obj)
            for ct = 1:length(obj.Supplies)
                obj.setOutput(ct,0);
            end
        end
        
        
        
    end
end

