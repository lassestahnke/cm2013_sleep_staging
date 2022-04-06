function varargout = ChSelection(varargin)
% CHSELECTION M-file for ChSelection.fig
%      CHSELECTION, by itself, creates a new CHSELECTION or raises the existing
%      singleton*.
%
%      H = CHSELECTION returns the handle to a new CHSELECTION or the handle to
%      the existing singleton*.
%
%      CHSELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHSELECTION.M with the given input arguments.
%
%      CHSELECTION('Property','Value',...) creates a new CHSELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChSelection_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChSelection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChSelection

% Last Modified by GUIDE v2.5 01-Sep-2010 13:02:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChSelection_OpeningFcn, ...
                   'gui_OutputFcn',  @ChSelection_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ChSelection is made visible.
function ChSelection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChSelection (see VARARGIN)

% Choose default command line output for ChSelection

assignin('base','ChSelectionH',handles.figure1);
Temp = evalin('base','who');

FlagSelectedCh=0;
FlagChInfo=0;
for i=1:length(Temp)
    if strcmp(Temp{i},'SelectedCh')
        FlagSelectedCh=1;
    end
    if strcmp(Temp{i},'ChInfo')
        handles.ChInfo=evalin('base','ChInfo');
        FlagChInfo=1;
    end
end


handles.output = hObject;


if FlagSelectedCh && FlagChInfo
    UpdateList(handles)
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ChSelection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ChSelection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

uiwait(hObject);

varargout{1} = handles.output;


% --- Executes on selection change in SelectedList.
function SelectedList_Callback(hObject, eventdata, handles)
% hObject    handle to SelectedList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectedList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectedList


% --- Executes during object creation, after setting all properties.
function SelectedList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectedList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Add.
function Add_Callback(hObject, eventdata, handles)
% hObject    handle to Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


SelectedCh=evalin('base','SelectedCh');

Flag = 0;

if get(handles.PopMenuChType,'value')==1
    % ref mode
    
    Temp=[1:length(handles.ChInfo.nr)];
    Temp(SelectedCh((SelectedCh(:,2)==0),1))=[];
    
    
    if ~isempty(Temp)
        SelectedCh=[SelectedCh;[Temp(get(handles.MainList1,'Value')) 0]];
        Flag = 1;
    end

else
    % diff mode
    DiffCh1 =get(handles.MainList1,'value');
    Temp=[1:length(handles.ChInfo.nr)];
    Temp([SelectedCh(SelectedCh(:,1)==DiffCh1 & SelectedCh(:,2)~=0 ,2);DiffCh1])=[];
    
    TempCh = [get(handles.MainList1,'Value') Temp(get(handles.MainList2,'Value'))];
    
    if handles.ChInfo.nr(TempCh(1))==handles.ChInfo.nr(TempCh(2))
        SelectedCh=[SelectedCh;TempCh];
        Flag = 1;
    else
       warndlg('It is not possible to add these channels') 
    end
    
end

if Flag
    
    FilterPara = evalin('base','FilterPara');
    
    i = length(FilterPara)+1;
    
    FilterPara{i}.A=1;
    FilterPara{i}.B=1;
    FilterPara{i}.HighValue=1;
    FilterPara{i}.LowValue=1;
    FilterPara{i}.NotchValue=1;
    FilterPara{i}.ScalingFactor=1;
    assignin('base','FilterPara',FilterPara)
    assignin('base','SelectedCh',SelectedCh)
    
end


UpdateList(handles)







function UpdateList(handles)

SelectedCh=evalin('base','SelectedCh');

if get(handles.SelectedList,'value')>size(SelectedCh,1)
    set(handles.SelectedList,'value',size(SelectedCh,1))
end

SelectedChMap = [];
for i=1:size(SelectedCh,1)
    if SelectedCh(i,2)==0
        SelectedChMap{i,1} = handles.ChInfo.Labels(SelectedCh(i,1),:);
    else
        SelectedChMap{i,1} = [handles.ChInfo.Labels(SelectedCh(i,1),:) '-' handles.ChInfo.Labels(SelectedCh(i,2),:)];
    end
    SelectedChMap{i,1}((SelectedChMap{i,1}==' '))=[];
end
set(handles.SelectedList,'String',SelectedChMap);



if get(handles.MainList1,'value')==0
    set(handles.MainList1,'value',1)
end


if get(handles.MainList2,'value')==0
    set(handles.MainList2,'value',1)
end

if get(handles.SelectedList,'value')==0
    set(handles.SelectedList,'value',1)
end



if get(handles.PopMenuChType,'value')==1
    % ref mode
    Temp=[1:size(handles.ChInfo.nr,1)];
    Temp(SelectedCh((SelectedCh(:,2)==0),1))=[];

    if get(handles.MainList1,'value')>length(Temp)
        set(handles.MainList1,'value',length(Temp))
    end

    set(handles.MainList1,'String',handles.ChInfo.Labels(Temp,:));

else
    % diff mode
    
    set(handles.MainList1,'String',handles.ChInfo.Labels);
    
    DiffCh1 =get(handles.MainList1,'value');
    
    Temp=[1:length(handles.ChInfo.nr)];
    Temp([SelectedCh(SelectedCh(:,1)==DiffCh1 & SelectedCh(:,2)~=0 ,2);DiffCh1])=[];

    if get(handles.MainList2,'value')>length(Temp)
        set(handles.MainList2,'value',length(Temp))
    end
    
    set(handles.MainList2,'String',handles.ChInfo.Labels(Temp,:));
end



% --- Executes on button press in Remove.
function Remove_Callback(hObject, eventdata, handles)
% hObject    handle to Remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


SelectedCh=evalin('base','SelectedCh');
FilterPara=evalin('base','FilterPara');
Sel = get(handles.SelectedList,'value');

if ~isempty(SelectedCh)
    SelectedCh(Sel,:)=[];
    Index  = [1:length(FilterPara)];
    Index(Sel)=[];
    Temp = [];
    Counter = 0;
    for i=Index
        Counter = Counter + 1;
        Temp{Counter} = FilterPara{i};
    end
    
end
assignin('base','SelectedCh',SelectedCh);
assignin('base','FilterPara',Temp);

UpdateList(handles)




% --- Executes on selection change in PopMenuChType.
function PopMenuChType_Callback(hObject, eventdata, handles)
% hObject    handle to PopMenuChType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PopMenuChType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopMenuChType


if get(hObject,'value')==1
    set(handles.MainList2,'Visible','off');
else
    set(handles.MainList2,'Visible','on');
end
    
UpdateList(handles)


% --- Executes on selection change in MainList1.
function MainList1_Callback(hObject, eventdata, handles)
% hObject    handle to MainList1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns MainList1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MainList1

UpdateList(handles)


% --- Executes on button press in ButtonLoad.
function ButtonLoad_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,FilePath]=uigetfile('.mat')

load([FilePath FileName]);
assignin('base','SelectedCh',SelectedCh)
UpdateList(handles)

% --- Executes on button press in ButtonSave.
function ButtonSave_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SelectedCh=evalin('base','SelectedCh');

[FileName,FilePath,FilterIndex] = uiputfile('*.mat');

if FilterIndex
    save([FilePath FileName],'SelectedCh')
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure


delete(hObject);

