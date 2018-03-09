%Test_WikiUpload

W = WikiUpload();
W.initialize();

W.url = 'http://jshodges.com/expwiki/';
W.login = 'Jhodges';
W.password = 'halflife';
W.files = {'C:\Documents and Settings\Administrator\My Documents\Downloads\Sweetie-BasePack-v3\Sweetie-BasePack-v3\png-8\12-em-cross.png',...
    'C:\Documents and Settings\Administrator\My Documents\Downloads\Sweetie-BasePack-v3\Sweetie-BasePack-v3\png-8\16-circle-blue.png'};

W.initBotAndLogin();

W.sendFiles();

W.datetime = now();
W.project = 'NV Lab Notes';
W.getPage();
W.addText();