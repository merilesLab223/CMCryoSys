classdef ViewCounterAcquisition < handle
    
    properties
        hCounterAcquisition
        hFig
        hText
        hStart
        hStop
        hReset
        hTraceButton
        hOverride
        hDC
        hDW
        CounterStatus = 0
        hTrace = 0
        hTraceAxes
        CounterHistory = [];
    end
    
    
    methods
    
        function [obj] = ViewCounterAcquisition(CA)
            obj.hCounterAcquisition = CA;
            obj.Init();
        end
   
        function [] = Init(obj)
            
            % open of the figure
            obj.hFig = figure('Visible','on','Position',[20,40,200,150],'MenuBar','none','Toolbar','none','Name','Counter','NumberTitle','off');
            obj.hTrace = figure('Visible','on','Position',[20,195,200,100],'Name','Counter Trace','MenuBar','none','Toolbar','none','NumberTitle','off');
            obj.hTraceAxes = axes('Parent',obj.hTrace);
            
            % add CPS text box
            obj.hText = uicontrol(obj.hFig,'Style','text','String','0',...
            'FontSize',30,'Position',[10,95,190,50]);
            
            align(obj.hText,'Center','Middle');
                
            % add start and stop buttons

            obj.hStart = uicontrol(obj.hFig,'Style','pushbutton','String','Start','Position',[10,65,50,20],'Callback',@(src,event)StartCounter(obj));
            obj.hTrace = uicontrol(obj.hFig,'Style','pushbutton','String','Trace','Position',[75 65 50 20],'Callback',@(src,event)ShowTrace(obj));
            obj.hStop = uicontrol(obj.hFig,'Style','pushbutton','String','Stop','Position',[140 65 50 20],'Callback',@(src,event)StopCounter(obj));
            obj.hReset = uicontrol(obj.hFig,'Style','pushbutton','String','Reset','Position',[75 40 50 20],'Callback',@(src,event)ResetTrace(obj));
            
            obj.hOverride = uicontrol(obj.hFig,'Style','checkbox','String','Override','Position',[10 10 70 20]);
            uicontrol(obj.hFig,'Style','text','String','DC','Position',[80 7 20 20]);
            obj.hDC = uicontrol(obj.hFig,'Style','edit','String','0.5','Position',[110 10 30 20]);
            uicontrol(obj.hFig,'Style','text','String','DW','Position',[140 7 20 20]);
            obj.hDW = uicontrol(obj.hFig,'Style','edit','String','0.01','Position',[160 10 30 20]);
        end

        function ShowTrace(obj)
            if strcmp(get(obj.hTrace,'Visible'),'on')
                set(obj.hTrace,'Visible','off');
            else
                set(obj.hTrace,'Visible','on');
            end
        end
        
        function ResetTrace(obj)
            obj.CounterHistory = [];
        end
        
        
        
         function StartCounter(obj)
             
             % start counter ok
            obj.CounterStatus = 0;
            
            % should we over-ride the counter?
            if get(obj.hOverride,'Value');
                Dwell = str2double(get(obj.hDW,'String'));
                DutyCycle = str2double(get(obj.hDC,'String'));
                obj.hCounterAcquisition.DwellTime = Dwell;
                obj.hCounterAcquisition.DutyCycle = DutyCycle;
            end
            
            for k=1:obj.hCounterAcquisition.LoopsUntilTimeOut,
                if ~obj.CounterStatus,
                    obj.hCounterAcquisition.GetCountsPerSecond();
                    obj.CounterHistory(end+1) = obj.hCounterAcquisition.CountsPerSecond;
                    set(obj.hText,'String',num2str(round(obj.hCounterAcquisition.CountsPerSecond)));
                    
                    % update plot
                    plot(obj.CounterHistory,'b-','Parent',obj.hTraceAxes);
                else
                    obj.CounterStatus = 0;
                    break;
                end
            end
         end
      
         function StopCounter(obj)
             obj.CounterStatus = 1;
         end
         
         function delete(obj)
             close(obj.hFig);
         end
    end
end

