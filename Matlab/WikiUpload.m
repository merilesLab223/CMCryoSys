classdef WikiUpload < handle
   
    properties
        hExperiment
        url
        login
        password
        project
        date
        time
        title
        notes
        files
        bot
        article
    end
    
    methods
        function [obj] = WikiUpload()
            
        end
        
        function [obj] = initialize(obj)
            
            % add the jars to the classpath
            lp = [pwd,'\','java\'];
            javaclasspath({[lp,'jwbf-core-1.3.0.jar'],[lp,'jwbf-mediawiki-1.3.0.jar'],...
                [lp,'log4j-1.2.14.jar'],...
                [lp,'jdom-1.1.jar'],...
                [lp,'commons-httpclient-3.1.jar'],...
                [lp,'commons-logging-1.0.4.jar'],...
                [lp,'commons-codec-1.2.jar'],[lp,'junit-4.5.jar'],...
                lp});


            
            % import the necessary java classes
            import net.sourceforge.jwbf.contentRep.mediawiki.SimpleFile;
            import net.sourceforge.jwbf.actions.mediawiki.editing.FileUpload;
            
        end
        
        function [obj] = initBotAndLogin(obj)
            import net.sourceforge.jwbf.bots.MediaWikiBot;
            obj.bot = MediaWikiBot(obj.url);
            obj.bot.login(obj.login,obj.password);
        end
        
        function [imgfiles] = processMatlabImageFiles(obj,handles)
            %We need handles so that the matlab code can be evaluated
            s = obj.notes;
            % convert lines of text to cell array
            s = cellstr(s);
            % find text between matlab tags
            s = regexp([s{:}],'<matlab>(.*?)</matlab>','tokens');
            % first, add the blank handle array
            s = {'h = [];',s{:}{:}};
            disp([s{:}])
            % now find anything that looks like a figure command and change it
            t = regexprep([s{:}],'($|;|;\s*?)figure;','$1h(end+1)=figure;');
            eval(t);

            dstr = datestr(now,'yyyymmdd-HHMMSS');
            for k=1:length(h),
                imgfiles{k} = fullfile(tempdir,sprintf('WUFig_%s_%d.svg',dstr,k));
                plot2svg(imgfiles{k},h(k));
            end
            close(h);
        end
        
        function [obj] = sendFiles(obj)
            import net.sourceforge.jwbf.bots.MediaWikiBot;
            import net.sourceforge.jwbf.contentRep.mediawiki.SimpleFile;
            import net.sourceforge.jwbf.actions.mediawiki.editing.FileUpload;
            
            for k=1:numel(obj.files)
                [p,n,e,v] = fileparts(obj.files{k});
                f = SimpleFile(obj.files{k});
                f.setText(sprintf('Automated File upload: %s',[n,e]));
                fUp = FileUpload(f,obj.bot) ;
                obj.bot.performAction(fUp);
            end
        end
        
        function [obj] = getPage(obj)
            import net.sourceforge.jwbf.contentRep.Article;
            s = [obj.project,'/',obj.date];
            obj.article = obj.bot.readContent(s);
        end
        
        function [obj] = addText(obj)
            obj.article.addText(sprintf('\n===%s',obj.time));
            if ~isempty(obj.title)
                   obj.article.addText(sprintf('- %s===\n',obj.title));
            else
                   obj.article.addText(sprintf('===\n'));
            end
            
            % add notes
            if iscell(obj.notes),
                s = '';
                for k=1:numel(obj.notes),
                    s = sprintf('%s\n%s',s,obj.notes{k});
                end
            else
                s = obj.notes;
            end
            
            % replace <matlab> with <pre><matlab>
            %s = cellstr(s); %Needed for copied text.
            s = regexprep(s,'<matlab>','<pre><matlab>');
            s = regexprep(s,'</matlab>','</matlab></pre>');
            %s = [s{:}]; %Needed for copied text. 
            obj.article.addText(sprintf('\n<br>\n%s',s));
            
            % loop over the files and add links to the entry
            if ~isempty(obj.files)
                obj.article.addText(sprintf('\n<br><b>Files</b>\n'));
            end
            
            for k=1:numel(obj.files)
                [p,n,e,v] = fileparts(obj.files{k});
                obj.article.addText(sprintf('\n<br>[[File:%s%s|%s%s]]',n,e,n,e));
                %if sum(strcmp(e,{'.png','.gif','.jpg','.jpeg'})),
                %    obj.article.addText(sprintf('\n[[Image:%s%s]]\n',n,e));
                %end
            end

            obj.article.save();
        end
    end
end