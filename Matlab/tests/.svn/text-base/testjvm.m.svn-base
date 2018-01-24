javaclasspath({'C:\Control Software\java\commons-httpclient-3.1.jar',...
    'C:\Control Software\java\jwbf-core-1.3.0.jar',...
    'C:\Control Software\java\jwbf-mediawiki-1.3.0.jar',...
    'C:\Control Software\java\log4j-1.2.14.jar',...
    'C:\Control Software\java\commons-codec-1.2.jar',...
    'C:\Control Software\java\commons-logging-1.0.4.jar'...
  });

import net.sourceforge.jwbf.bots.MediaWikiBot;
import net.sourceforge.jwbf.contentRep.SimpleArticle;
import net.sourceforge.jwbf.actions.mediawiki.editing.FileUpload;
import net.sourceforge.jwbf.contentRep.mediawiki.SimpleFile;

%%
b = MediaWikiBot('http://jshodges.com/expwiki/');
b.login('Jhodges', 'halflife');

sf = SimpleFile('C:\Documents and Settings\Experiment\My Documents\ExperimentData\ImageScans\ExportedImages\Grid_b_05Oct2009.jpeg');
fup = FileUpload(sf,b);
b.performAction(fup);

%%

% see if you will overwrite an article by posting twice

sa = b.readContent('NV_Lab_Notes/18_November_2009');
sa.addText('This is a test entry.');
b.writeContent(sa);

sa = b.readContent('NV_Lab_Notes/18_November_2009');
sa.addText([char(13),'==New entry==',char(13),'<br>Here is more text']);
b.writeContent(sa);