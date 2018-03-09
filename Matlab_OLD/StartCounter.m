                
        function StartCounter(hand,evt,obj)
            
            for k=1:100,
                obj.hCounterAcquisition.GetCountsPerSecond();
                set(obj.hText,'String',num2str(obj.hCounterAcquisition.CountsPerSecond));
            end
        end
      