classdef WikiUpload_MindTouch < handle
    
    properties
        URL
        authCookie
        client
    end
    
    
    methods
        
        function wikiObj = WikiUpload_MindTouch(URL)
          
            import org.apache.commons.httpclient.*

            if(nargin == 1)
                wikiObj.URL = URL;
            end
            wikiObj.client = HttpClient();
        end
        
        function authenticate(wikiObj,username,password)

           import org.apache.commons.httpclient.*

           %Grab a cookie 
           tmpGetMethod = methods.GetMethod(sprintf('%s/@api/deki/users/authenticate',wikiObj.URL));
           tmpAuth = auth.AuthScope('ordi1.uwaterloo.ca',-1,'DekiWiki');
           tmpPass = UsernamePasswordCredentials(username,password);
           wikiObj.client.getState().setCredentials(tmpAuth,tmpPass);
           result = wikiObj.client.executeMethod(tmpGetMethod);
           
           %Check that we got it.
           if result ~= 200
               error('Unable to get authentication cookie.');
           end
           
           %Create the cookie
           wikiObj.authCookie = Cookie();
           wikiObj.authCookie.setValue(tmpGetMethod.getResponseBodyAsString());
        end
        
        function [result,responseBody] = uploadFile(wikiObj,filename,wikipage,wikiname)
            
            import org.apache.commons.httpclient.*

            %Try and sort out file type for Content-Type header
            [pathstr, name, ext] = fileparts(filename);
            
            switch ext
                case '.png'
                    contentType = 'image/png';
                case {'.jpg','jpeg'}
                    contentType = 'image/jpeg';
                otherwise
                    contentType = 'text/plain';
            end
                    
            tmpPutMethod = methods.PutMethod(sprintf('%s/@api/deki/pages/=%s/files/=%s',wikiObj.URL,wikiObj.doubleEncodeURI(wikipage),wikiname));
            tmpPutMethod.addRequestHeader('Set-Cookie',wikiObj.authCookie.getValue());
            tmpPutMethod.addRequestHeader('Content-Type',contentType)
            tmpPutMethod.setRequestBody(java.io.FileInputStream(filename));
            %We seem to have real trouble uploading files (MindTouch API not so
            %hot?) so try a few times.
            result = 0;
            tryct = 0;
            while (result ~= 200 && tryct < 10)
                result = wikiObj.client.executeMethod(tmpPutMethod);
                tryct = tryct+1;
            end
            responseBody = tmpPutMethod.getResponseBodyAsString();
            if(result ~= 200)
                error('Unable to upload file with error %s.',char(responseBody));
            end
            
        end
        
        function [result,responseBody] = getContent(wikiObj,wikipage)
            import org.apache.commons.httpclient.*
            
            %Setup the method
            tmpGetMethod = methods.GetMethod(sprintf('%s/@api/deki/pages/=%s/contents',wikiObj.URL,wikiObj.doubleEncodeURI(wikipage)));
            tmpGetMethod.addRequestHeader('Set-Cookie',wikiObj.authCookie.getValue());
            tmpGetMethod.setQueryString('?mode=edit');
            
            result = wikiObj.client.executeMethod(tmpGetMethod);
            
            responseBody = char(tmpGetMethod.getResponseBodyAsString);
            
        end
        
        function [result,responseBody] = addContent(wikiObj,wikipage,newContent)
           
            %Try and get any previous content
            [result,oldContent] = wikiObj.getContent(wikipage);
            
            %If we failed check that we failed because page doesn't exist
            if(result~=200)
                if(~isempty(strfind(oldContent,'Could not find requested page')))
                    oldContent = '';
                end
            %Otherwise extract the content from between the body tags
            else
                oldContent = regexp(oldContent,'<body>(.*)</body>','tokens','once');
                oldContent = oldContent{1};
                %Clean it up (the sometimes double encoded html data)
                oldContent = strrep(oldContent,'&amp;','&');
                oldContent = strrep(oldContent,'&lt;','<');
                oldContent = strrep(oldContent,'&gt;','>');
            end
            
            newContent = [oldContent char(13) newContent];
            
            %Setup the POST method
            import org.apache.commons.httpclient.*
            
            %Timestamp for EST
            timeStamp = datestr(now+5/24,'yyyymmddHHMMSS');

            %Setup the method
            tmpPostMethod = methods.PostMethod(sprintf('%s/@api/deki/pages/=%s/contents/?edittime=%s',wikiObj.URL,wikiObj.doubleEncodeURI(wikipage),timeStamp));
            tmpPostMethod.addRequestHeader('Set-Cookie',wikiObj.authCookie.getValue());
            tmpPostMethod.addRequestHeader('Content-Type','application/x-www-form-urlencoded');
            
            tmpPostMethod.setRequestBody(newContent);
            
            result = wikiObj.client.executeMethod(tmpPostMethod);
            responseBody = tmpPostMethod.getResponseBodyAsString;
            
        end
        
        %Function to add a Notebook entry
        function addLabBookEntry(wikiObj,wikipage,title,notes,figures,files,datestamp)
            
            %Try to create the page if necessary
            wikiObj.createPage(wikipage);
            
            %Convert the figures to SVG 
            dstr = datestr(now,'yyyymmdd-HHMMSS');
            for figct=1:length(figures),
                imgfiles{figct} = fullfile(tempdir,sprintf('WUFig_%s_%d.png',dstr,figct));
                saveas(figures(figct),imgfiles{figct});
            end
            
            %Create the content
            %Write the title
            newContent = sprintf('<h2> %s %s </h2>',datestr(datestamp,'HH:MM'), title);
            
            %Write the notes
            %First wrap and matlab code in <pre> tags
            if(ischar(notes))
                notes = cellstr(notes);
            end
            notes = regexprep(notes,'<matlab>','<pre><matlab>');
            notes = regexprep(notes,'</matlab>','</matlab></pre>');
            newContent = [newContent char(13) [notes{:}]];
            
            %Display the images
            if(~isempty(figures))
                newContent = [newContent char(13) '<h3> Images: </h3>'];
                %Upload the figures and and display it
                for figct = 1:length(imgfiles)
                    [pathstr, name, ext] = fileparts(imgfiles{figct});
                    [result,responseBody] = wikiObj.uploadFile(imgfiles{figct},wikipage,[name ext]);
                    %Use the responseBody to get the URL of the figure
                    href = regexp(char(responseBody),'href="(.*?)"','tokens');
                    newContent = [newContent char(13) sprintf('<p><a class="internal" rel="internal" href="%s"><img style="width: 500px; height: 400px;" alt="%s" class="internal default" src ="%s?size=webview" /></a></p>',href{2}{1}, [name ext], href{2}{1})];
                end
            end
            %Upload the files and link to them 
            if(~isempty(files))
                newContent = [newContent char(13) '<h3> Files: </h3>'];
                for filect = 1:length(files)
                    [pathstr, name, ext] = fileparts(files{filect});
                    [result,responseBody] = wikiObj.uploadFile(files{filect},wikipage,[name ext]);
                    %Use the responseBody to get the URL of the files
                    href = regexp(char(responseBody),'href="(.*?)"','tokens');
                    newContent = [newContent char(13) sprintf('<a class="internal" href="%s" title="%s">%s</a></li>',href{2}{1},name,[name ext])];
                end
            end
            %Add the content to the page
            wikiObj.addContent(wikipage,newContent);
        end
        
        %Function to create a new page if it doesn't exist
        function createPage(wikiObj,wikipage)
            
             %Try and get any previous content
            [result,oldContent] = wikiObj.getContent(wikipage);
            
            %If we failed check that we failed because page doesn't exist
            %and then create it by adding empty content
            if(result~=200)
                if(~isempty(strfind(oldContent,'Could not find requested page')))
                    wikiObj.addContent(wikipage,'');
                end
            end
        end
        
    end
    
    methods(Static)
        
        %Helper function to encode the URI
        function resultString = doubleEncodeURI(string)
           
            resultString = char(java.net.URLEncoder.encode(string, 'UTF-8'));
            resultString = strrep(resultString,'+','%20');
            resultString = char(java.net.URLEncoder.encode(resultString, 'UTF-8'));
            
            %.replaceAll('\\+', '%20').replaceAll('\\%21', '!').replaceAll('\\%27', '''').replaceAll('\\%28', '(').replaceAll('\\%29', ')').replaceAll('\\%7E', '~');
            
        end
        
     
        
    end
        
    
end
   