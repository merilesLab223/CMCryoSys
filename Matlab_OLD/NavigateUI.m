function [] = NavigateUI(hIA)

hCursorControl = findall(0,'Name','Cursor Control');

if hCursorControl,
    figure(hCursorControl);
    return;
end

scrnsz = get(0,'ScreenSize');
wd = 600;
ht = 150;

hFig = figure('Position',[scrnsz(3)/2 - wd/2 35 wd ht],'Toolbar','none','MenuBar','none','Name','Cursor Control','NumberTitle','off','IntegerHandle','off');
hPanel = uipanel('Parent',hFig,'Title','X/Y Control','Units','pixels','Position',[0 0 150 150]);

hpx1 = uicontrol(hPanel,'Style','pushbutton','String','+X','Position',[100 60 30 30],'Callback',@(src,evt)updateX(src,evt,+1,hIA));
hpy1 = uicontrol(hPanel,'Style','pushbutton','String','+Y','Position',[60 100 30 30],'Callback',@(src,evt)updateY(src,evt,+1,hIA));
hpx2 = uicontrol(hPanel,'Style','pushbutton','String','-X','Position',[20 60 30 30],'Callback',@(src,evt)updateX(src,evt,-1,hIA));
hpy2 = uicontrol(hPanel,'Style','pushbutton','String','-Y','Position',[60 20 30 30],'Callback',@(src,evt)updateY(src,evt,-1,hIA));

hPanel2 = uipanel('Parent',hFig,'Title','Z Control','Units','pixels','Position',[150 0 150 150]);


hpz1 = uicontrol(hPanel2,'Style','pushbutton','String','+Z','Position',[60 100 30 30],'Callback',@(src,evt)updateZ(src,evt,+1,hIA));
hpz2 = uicontrol(hPanel2,'Style','pushbutton','String','-Z','Position',[60 20 30 30],'Callback',@(src,evt)updateZ(src,evt,-1,hIA));

hPanel3 = uipanel('Parent',hFig,'Title','Step Size','Units','pixels','Position',[300 0 150 150]);

uicontrol(hPanel3,'Style','text','String','Z Step','Position',[20 20 50 20]);
uicontrol(hPanel3,'Style','text','String','X/Y Step','Position',[20 100 50 20]);

uicontrol(hPanel3,'Style','edit','String','0.0','Position',[80 20 50 20],'Tag','zStep');
uicontrol(hPanel3,'Style','edit','String','0.0','Position',[80 100 50 20],'Tag','xyStep');

hPanel4 = uipanel('Parent',hFig,'Title','Current Position','Units','pixels','Position',[450 0 150 150]);
uicontrol(hPanel4,'Style','text','String','X','HorizontalAlignment','left','Position',[30 100 10 20]);
uicontrol(hPanel4,'Style','text','String','Y','HorizontalAlignment','left','Position',[30 60 10 20]);
uicontrol(hPanel4,'Style','text','String','Z','HorizontalAlignment','left','Position',[30 20 10 20]);

xpos=uicontrol(hPanel4,'Style','text','String','','HorizontalAlignment','left','Position',[40 100 10 20]);
ypos=uicontrol(hPanel4,'Style','text','String','','HorizontalAlignment','left','Position',[40 60 10 20]);
zpos=uicontrol(hPanel4,'Style','text','String','','HorizontalAlignment','left','Position',[40 20 10 20]);

% register hIA event
hList = addlistener(hIA,'UpdateCursorPosition',@(src,evnt)updateXYZGUI(src,evnt,[xpos,ypos,zpos],hIA));

% make sure we kill the listener on window close
set(hFig,'CloseRequestFcn',@(src,evnt)closeAndClean(src,evnt,hList));

function closeAndClean(src,evnt,hList)
    % delete listener
    delete(hList);
    
    % delete figure
    delete(gcf);



function [] = updateX(src,evt,direction,hIA)
        
        hT = findobj(0,'Tag','xyStep');
        stepSize = get(hT,'String');
        hIA.CursorPosition = hIA.CursorPosition + [direction*str2double(stepSize) 0 0];
        hIA.SetCursor();
            

function [] = updateY(src,evt,direction,hIA)

        
        hT = findobj(0,'Tag','xyStep');
        stepSize = get(hT,'String');
        hIA.CursorPosition = hIA.CursorPosition + [0 direction*str2double(stepSize) 0];
        hIA.SetCursor();
            
function [] = updateZ(src,evt,direction,hIA)
        
        hT = findobj(0,'Tag','zStep');
        stepSize = get(hT,'String');
        hIA.CursorPosition = hIA.CursorPosition + [0 0 direction*str2double(stepSize)];
        hIA.SetCursor();
            
function [] = updateXYZGUI(src,evt,hands,hIA)
        set(hands(1),'String',hIA.CursorPosition(1));
        set(hands(2),'String',hIA.CursorPosition(2));
        set(hands(3),'String',hIA.CursorPosition(3));
