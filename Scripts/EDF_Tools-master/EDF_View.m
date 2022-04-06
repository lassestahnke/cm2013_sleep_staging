function varargout = EDF_View(varargin)
% EDF_VIEW MATLAB code for EDF_View.fig
%      EDF_VIEW, by itself, creates a new EDF_VIEW or raises the existing
%      singleton*.
%
%      H = EDF_VIEW returns the handle to a new EDF_VIEW or the handle to
%      the existing singleton*.
%
%      EDF_VIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDF_VIEW.M with the given input arguments.
%
%      EDF_VIEW('Property','Value',...) creates a new EDF_VIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EDF_View_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EDF_View_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EDF_View

% Last Modified by GUIDE v2.5 20-Jul-2012 18:18:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @EDF_View_OpeningFcn, ...
    'gui_OutputFcn',  @EDF_View_OutputFcn, ...
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


% --- Executes just before EDF_View is made visible.
function EDF_View_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EDF_View (see VARARGIN)

% Choose default command line output for EDF_View
handles.output = hObject;

assignin('base','c_axes',[]);

set(handles.axes1,'xTickLabel','','yTickLabel','');
set(handles.axes2,'xTickLabel','','yTickLabel','');

Temp = [];
assignin('base','ChSelectionH',Temp);
assignin('base','FilterSettingH',Temp);

handles.ActiveCh = [];

handles.Axes1OrgPos = get(handles.axes1,'outerposition');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EDF_View wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EDF_View_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function MenuOpenEDF_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName FilePath]=uigetfile('*.edf','Open EDF File');

if ~(length(FilePath)==1)
    
    set(handles.MenuOpenXML,'enable','on');
    
    handles.FileName=[FilePath FileName];
    
    Temp = EdfInfo(handles.FileName);
    
    handles.FileInfo = Temp.FileInfo;
    handles.ChInfo   = Temp.ChInfo;
    
    assignin('base','ChInfo',handles.ChInfo);
    assignin('base','FileInfo',handles.FileInfo);
    Temp = [[1:length(handles.ChInfo.nr)]' zeros(length(handles.ChInfo.nr),1)];
    assignin('base','SelectedCh',Temp);
    
    
    FilterPara = [];
    for i=1:length(handles.ChInfo.nr)
        FilterPara{i}.A              = 1;
        FilterPara{i}.B              = 1;
        FilterPara{i}.HighValue      = 1;
        FilterPara{i}.LowValue       = 1;
        FilterPara{i}.NotchValue     = 1;
        FilterPara{i}.ScalingFactor  = 1;
        Index=findstr(handles.ChInfo.Labels(i,:),'ECG');
        Index = [Index findstr(handles.ChInfo.Labels(i,:),'SaO2')];
        Index = [Index findstr(handles.ChInfo.Labels(i,:),'PLTH')];
        if ~isempty(Index)
            FilterPara{i}.Color      = 'r';
        else 
            Index=findstr(handles.ChInfo.Labels(i,:),'Leg');
            if ~isempty(Index)
                FilterPara{i}.Color      = 'g';
            else
                
                FilterPara{i}.Color      = 'k';
            end
        end
    end
    
    assignin('base','FilterPara',FilterPara);
    
    Temp=[];
    
    TempText = handles.FileInfo.LocalPatientID;
    TempText(TempText==32)=[];
    Temp{1}=['Patient Name : ' TempText];
    
    TempText = handles.FileInfo.LocalRecordID;
    TempText(TempText==32)=[];
    Temp{2}=['Patient ID   : ' TempText];
    
    Temp{3}=['Start Date   : ' handles.FileInfo.StartDate];
    Temp1=handles.FileInfo.StartTime;
    Temp1([3 6])='::';
    Temp{4}=['Start Time   : ' Temp1];
    
    
    Counter = 5;
    
    for i=1:length(handles.ChInfo.nr)
        Counter = Counter + 1;
        Temp1 = handles.ChInfo.Labels(i,:);
        if ~isempty(Temp1)
            while Temp1(end)==32 & length(Temp1)>1
                Temp1(end)=[];
            end
        end
        
        Temp2 = handles.ChInfo.PhyDim(i,:);
        if ~isempty(Temp2)
            while Temp2(end)==32 & length(Temp2)>1
                Temp2(end)=[];
            end
        end
        
        SamplingRate = fix(handles.ChInfo.nr(i)/handles.FileInfo.DataRecordDuration);
        
        Temp{Counter} = [Temp1 ' : ' num2str(handles.ChInfo.PhyMin(i)) ' to ' ... 
            num2str(handles.ChInfo.PhyMax(i)) ' ' Temp2 ' (' num2str(handles.ChInfo.DiMin(i)) ' to ' ... 
            num2str(handles.ChInfo.DiMax(i)) '), SR : ' num2str(SamplingRate)];
        
    end
    
    set(handles.ListBoxPatientInfo,'string',Temp);
    
    Temp = dir(handles.FileName);
    handles.TotalTime = (Temp.bytes - handles.FileInfo.HeaderNumBytes) ...
        / 2  / sum(handles.ChInfo.nr) * handles.FileInfo.DataRecordDuration ;
    
    
    Temp = get(handles.PopMenuWindowTime,'value');
    Temp1 = get(handles.PopMenuWindowTime,'string');
    Temp = Temp1{Temp};
    WindowTime = str2num(Temp(1:end-3));
    
    
    Temp = handles.TotalTime-WindowTime;
    set(handles.SliderTime,'max',Temp,'SliderStep',[0.2 1]*WindowTime/Temp,'value',0)
    
    handles.FlagAnn = 0 ;
    
    handles=DataLoad(handles);
    guidata(hObject,handles);
    UpDatePlot(handles)
    
    %%
    
    
end





% --- Executes on selection change in PopMenuWindowTime.
function PopMenuWindowTime_Callback(hObject, eventdata, handles)
% hObject    handle to PopMenuWindowTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopMenuWindowTime contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopMenuWindowTime

Temp = get(handles.PopMenuWindowTime,'value');
Temp1 = get(handles.PopMenuWindowTime,'string');
Temp = Temp1{Temp};
WindowTime = str2num(Temp(1:end-3));

Temp = handles.TotalTime-WindowTime;
if  Temp < get(handles.SliderTime,'value')
    set(handles.SliderTime,'max',Temp,'SliderStep',[0.2 1]*WindowTime/Temp,'value',Temp)
else
    set(handles.SliderTime,'max',Temp,'SliderStep',[0.2 1]*WindowTime/Temp)
end

handles=DataLoad(handles);
guidata(hObject,handles);
UpDatePlot(handles)



% --- Executes on slider movement.
function SliderTime_Callback(hObject, eventdata, handles)
% hObject    handle to SliderTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


Temp = get(hObject,'value');
set(hObject,'value',fix(Temp));

if handles.FlagAnn
    % find the closest comments
    Temp=[];
    for i=1:length(handles.ScoredEvent)
        Temp(i)=handles.ScoredEvent(i).Start;
    end
    Temp = Temp - get(handles.SliderTime,'value');
    [Temp Index]=min(abs(Temp));
    set(handles.ListBoxComments,'value',Index);
end



handles=DataLoad(handles);
guidata(hObject,handles);
UpDatePlot(handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=DataLoad(handles)

FileName= handles.FileName;

Temp = get(handles.PopMenuWindowTime,'value');
Temp1 = get(handles.PopMenuWindowTime,'string');
Temp = Temp1{Temp};
WindowTime = str2num(Temp(1:end-3));

Time = get(handles.SliderTime,'value');

fid=fopen(FileName,'r');

SkipByte=handles.FileInfo.HeaderNumBytes+fix(Time/handles.FileInfo.DataRecordDuration) ...
    *sum(handles.ChInfo.nr)*2;
fseek(fid,SkipByte,-1);

Data=[];
for i=1:handles.FileInfo.SignalNumbers
    Data{i}=[];
end

% Sec/handles.DatarecordDuration is the number of
for i=1 : WindowTime/handles.FileInfo.DataRecordDuration
    for j=1:handles.FileInfo.SignalNumbers
        Data{j}= [Data{j} fread(fid,[1 handles.ChInfo.nr(j)],'int16') ];
    end
end
fclose('all');



handles.Data = Data;

handles=DataNormalize(handles);

Data = handles.Data;

SelectedCh=evalin('base','SelectedCh');

handles.Data=[];

FilterPara = evalin('base','FilterPara');

% construct the selected referential and differential channels
for i=1:size(SelectedCh,1)
    if SelectedCh(i,2)==0
        % referential
        handles.Data{i}=Data{SelectedCh(i,1)};
    else
        % differential
        handles.Data{i}=Data{SelectedCh(i,1)}-Data{SelectedCh(i,2)};
    end
    
    % Filtering
    handles.Data{i} = filter(FilterPara{i}.B,FilterPara{i}.A,handles.Data{i});
end






function handles = DataNormalize(handles)

for i=1:length(handles.Data)
    % remove the mean
    handles.Data{i}=handles.Data{i}-(handles.ChInfo.DiMax(i)+handles.ChInfo.DiMin(i))/2;
    handles.Data{i}=handles.Data{i}./(handles.ChInfo.DiMax(i)-handles.ChInfo.DiMin(i));
    if handles.ChInfo.PhyMin(i)>0
        handles.Data{i}=-handles.Data{i};
    end
end



function UpDatePlot(handles)


% set the epoch number
% each epoch has been considered as 30 sec

Temp = get(handles.SliderTime,'value');
Temp = fix(Temp/30)+1;
set(handles.EditEpochNumber,'string',num2str(Temp));


% Plot the data
axes(handles.axes1);
c_axes = evalin('base','c_axes');
if ~isempty(c_axes)
    delete(c_axes)
end
cla
hold on

Temp = get(handles.PopMenuWindowTime,'value');
Temp1 = get(handles.PopMenuWindowTime,'string');
Temp = Temp1{Temp};
WindowTime = str2num(Temp(1:end-3));


SelectedCh = evalin('base','SelectedCh');

SelectedChMap=[];

for i=1:size(SelectedCh,1)
    if SelectedCh(i,2)==0
        SelectedChMap{i,1} = handles.ChInfo.Labels(SelectedCh(i,1),:);
    else
        SelectedChMap{i,1} = [handles.ChInfo.Labels(SelectedCh(i,1),:) '-' handles.ChInfo.Labels(SelectedCh(i,2),:)];
    end
    SelectedChMap{i,1}((SelectedChMap{i,1}==' '))=[];
end

if handles.FlagAnn
    % plot sleep stage line
    set(handles.LineSleepStage,'xData',[-1 -1 1 1 -1]*50+get(handles.SliderTime,'value'))
    
    
    Start = [];
    for i=1:length(handles.ScoredEvent)
        Start(i)=handles.ScoredEvent(i).Start;
    end
    
    CurrentTime = get(handles.SliderTime,'value');
    
    
    if ~handles.PlotType
        
        % Annotation plot
        
        % Forward Plot
        Index = find(Start>CurrentTime & ...
            Start < (CurrentTime+WindowTime));
        
        if ~isempty(Index)
            
            ChNum=3;
            Start =[];
            
            for i=1:length(Index)
                Start(i) = handles.ScoredEvent(Index(i)).Start-CurrentTime;
                Temp=Start(i) + handles.ScoredEvent(Index(i)).Duration;
                
                if Temp>WindowTime
                    Temp=WindowTime;
                end
                
                fill([Start(i)  Temp Temp Start(i)], ...
                    [-ChNum-3/2 -ChNum-3/2 -ChNum-1/2 -ChNum-1/2 ]...
                    ,[190 222 205]/255);
                
                plot([Start(i)  Temp Temp Start(i) Start(i)], ...
                    [-ChNum-3/2 -ChNum-3/2 -ChNum-1/2 -ChNum-1/2 -ChNum-3/2]...
                    ,'Color',[1 1 1]);
            end
        end
        
        % Annotation text
        if ~isempty(Index)
            for i=1:3:length(Index)
                text(Start(i),-ChNum-0.65,handles.ScoredEvent(Index(i)).EventConcept,'FontWeight','bold','FontSize',9)
            end
        end
        
    else
        
        
        % Forward Plot
        Index = find(Start>CurrentTime & ...
            Start < (CurrentTime+WindowTime));
        
        if ~isempty(Index)
            Start=Start(Index)-CurrentTime;
            ChNum=[];
            for j=Index
                for i=1:size(handles.ChInfo.Labels,1)
                    if  strncmp(handles.ChInfo.Labels(i,:),[handles.ScoredEvent(j).InputCh ' '],...
                            length(handles.ScoredEvent(j).InputCh+1))
                        ChNum=[ChNum i];
                    end
                end
            end
            
            for i=1:length(Index)
                Temp=Start(i)+handles.ScoredEvent(Index(i)).Duration;
                
                if Temp>WindowTime
                    Temp=WindowTime;
                end
                
                fill([Start(i)  Temp Temp Start(i)], ...
                    [-ChNum(i)-3/2 -ChNum(i)-3/2 -ChNum(i)-1/2 -ChNum(i)-1/2 ]+2 ...
                    ,[190 222 205]/255);
                
                plot([Start(i)  Temp Temp Start(i) Start(i)], ...
                    [-ChNum(i)-3/2 -ChNum(i)-3/2 -ChNum(i)-1/2 -ChNum(i)-1/2 -ChNum(i)-3/2]+2 ...
                    ,'Color',[1 1 1]);
                text(Start(i),-ChNum(i)-0.65+2,handles.ScoredEvent(Index(i)).EventConcept,'FontWeight','bold','FontSize',9)
            end
            
            
        end
        
        
        % Reverse Plot
        Temp = [];
        Start = [];
        for i=1:length(handles.ScoredEvent)
            Temp(i)=handles.ScoredEvent(i).Start+handles.ScoredEvent(i).Duration;
            Start(i)=handles.ScoredEvent(i).Start;
        end
        IndexReverse = find((Temp)>=CurrentTime & Temp <= (CurrentTime+WindowTime));
        IndexReverse = [IndexReverse find(Start<=CurrentTime & Temp >= (CurrentTime+WindowTime) )];
        
        
        for i=1:length(Index)
            IndexReverse(IndexReverse==Index(i))=[];
        end
        
        Start = Start(IndexReverse)-CurrentTime;
        if ~isempty(IndexReverse)
            
            ChNum=[];
            for j=IndexReverse
                for i=1:size(handles.ChInfo.Labels,1)
                    if  strncmp(handles.ChInfo.Labels(i,:),[handles.ScoredEvent(j).InputCh ' '],...
                            length(handles.ScoredEvent(j).InputCh+1))
                        ChNum=[ChNum i];
                    end
                end
            end
            
            for i=1:length(IndexReverse)
                Temp=Start(i)+handles.ScoredEvent(IndexReverse(i)).Duration;
                
                
                fill([0  Temp Temp 0], ...
                    [-ChNum(i)-3/2 -ChNum(i)-3/2 -ChNum(i)-1/2 -ChNum(i)-1/2 ]+2 ...
                    ,[190 222 205]/255);
                
                plot([0  Temp Temp 0 0], ...
                    [-ChNum(i)-3/2 -ChNum(i)-3/2 -ChNum(i)-1/2 -ChNum(i)-1/2 -ChNum(i)-3/2]+2 ...
                    ,'Color',[1 1 1]);
                text(0,-ChNum(i)-0.65+2,handles.ScoredEvent(IndexReverse(i)).EventConcept,'FontWeight','bold','FontSize',9)
            end
            
            
        end
        
        
        
        
        
        
        
    end
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Signals Plot
FilterPara = evalin('base','FilterPara');
Counter = 0;
for i=1:size(SelectedCh,1)
    
    Time = [0:size(handles.Data{i},2)-1]/size(handles.Data{i},2)*WindowTime;
    PlotColor = FilterPara{i}.Color;
    plot(Time,handles.Data{i}*FilterPara{i}.ScalingFactor-Counter,'LineWidth',0.01,'color',PlotColor);
    Counter = Counter + 1 ;
end



if handles.FlagAnn
    % plot sleep states
    Temp=handles.SleepStages([1:WindowTime]+get(handles.SliderTime,'value'));
    Temp = Temp - min(Temp);
    if max(Temp)>0
        Temp = Temp / max(Temp) - 0.25;
    end
    plot([0:length(Temp)-1],Temp+1,'linewidth',1.5,'color','k')
    
    % comment for sleep stage
    if sum(abs(diff(Temp))>0)
        % there is more than one sleep state
        Index = [1 find(diff(Temp))+1];
        
        for i=1:length(Index)
            TempState = (handles.SleepStages(get(handles.SliderTime,'value')+Index(i)));
            switch TempState
                case 5
                    TempState = 'W';
                case 4
                    TempState = 'N1';
                case 3
                    TempState = 'N2';
                case 2
                    TempState = 'N3';
                case 1
                    TempState = 'N4';
                case 0
                    TempState = 'N5';
            end
            
            if Temp(Index(i))>0
                text(Index(i),Temp(Index(i))+0.75,['State: ' TempState],'fontweight','bold');
            else
                text(Index(i),Temp(Index(i))+1.25,['State: ' TempState],'fontweight','bold');
            end
        end
        
    else
        TempState = handles.SleepStages(get(handles.SliderTime,'value')+1);
        switch TempState
            case 5
                TempState = 'W';
            case 4
                TempState = 'N1';
            case 3
                TempState = 'N2';
            case 2
                TempState = 'N3';
            case 1
                TempState = 'N4';
            case 0
                TempState = 'N5';
        end
        
        text(WindowTime/2,1.5,['State ' TempState],'fontweight','bold')
    end
    
end

% Set the yTick
YTick=[(-length(handles.Data)+1):0];
set(handles.axes1,'YTick',YTick);

% Set the ylim

ylim([-length(handles.Data) 2]);
set(handles.axes1,'YTickLabel',SelectedChMap([length(SelectedChMap):-1:1]))


% Set the xTick
XTick=[0:0.2:1]*WindowTime;
Temp = XTick + get(handles.SliderTime,'value');
Temp = datestr(Temp/86400,'HH:MM:SS');
set(handles.axes1,'XTick',XTick,'xTickLabel',Temp,'xlim',[0 WindowTime]);



hold off

grid on

%%
% change the color of xtick and ytick

xtick = get(handles.axes1,'XTick');
ytick = get(handles.axes1,'YTick');
xlim = get(handles.axes1,'XLim');
ylim1 = get(handles.axes1,'YLim');
% Copy the existing axis along with children
set(handles.axes1,'TickLength',[1e-100 1])
c_axes = copyobj(handles.axes1,handles.figure1);

assignin('base','c_axes',c_axes);

% Remove copy of objects
delete(get(c_axes,'Children'))
% Set color XColor to red and only show the grid
set(c_axes, 'Color', 'none', 'XColor', [192 192 1]/255, 'XGrid', 'on', 'YColor',[192 192 1]/255,...
    'YGrid','on','XTickLabel',[],'YTickLabel',[],'XTick',xtick,'YTick',ytick,'XLim',xlim,'YLim',ylim1);








% --------------------------------------------------------------------
function MenuChSelection_Callback(hObject, eventdata, handles)
% hObject    handle to MenuChSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ChSelection;
handles=DataLoad(handles);
guidata(hObject,handles);
UpDatePlot(handles);
Temp = [];
assignin('base','ChSelectionH',Temp);


% --------------------------------------------------------------------
function MenuFilter_Callback(hObject, eventdata, handles)
% hObject    handle to MenuFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

FilterSettings
handles=DataLoad(handles);
guidata(hObject,handles);
UpDatePlot(handles)
assignin('base','FilterSettingH',[]);


% --- Executes on selection change in ListBoxComments.
function ListBoxComments_Callback(hObject, eventdata, handles)
% hObject    handle to ListBoxComments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ListBoxComments contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListBoxComments

Sel = get(hObject,'value');

Temp = get(handles.PopMenuWindowTime,'value');
Temp1 = get(handles.PopMenuWindowTime,'string');
Temp = Temp1{Temp};
WindowTime = str2num(Temp(1:end-3));

Temp = WindowTime - handles.ScoredEvent(Sel).Duration;

if Temp>0
    Time = handles.ScoredEvent(Sel).Start-Temp/2;
else
    Time = handles.ScoredEvent(Sel).Start;
end
set(handles.SliderTime,'value',fix(Time));

handles=DataLoad(handles);
guidata(hObject,handles);
UpDatePlot(handles)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
Temp=evalin('base','ChSelectionH');
if ~isempty(Temp)
    delete(Temp);
end

Temp=evalin('base','FilterSettingH');
if ~isempty(Temp)
    delete(Temp);
end

delete(hObject);



function EditEpochNumber_Callback(hObject, eventdata, handles)
% hObject    handle to EditEpochNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditEpochNumber as text
%        str2double(get(hObject,'String')) returns contents of EditEpochNumber as a double



Temp = get(handles.PopMenuWindowTime,'value');
Temp1 = get(handles.PopMenuWindowTime,'string');
Temp = Temp1{Temp};
WindowTime = str2num(Temp(1:end-3));

if WindowTime<30
    WindowTime = 30;
end

EpochNumber = str2num(get(hObject,'string'));
MaxEpoch = (handles.TotalTime - WindowTime)/30+1;

if EpochNumber>MaxEpoch
    EpochNumber = MaxEpoch;
    set(hObject,'string',num2str(EpochNumber));
end


set(handles.SliderTime,'value',(EpochNumber-1)*30);

if handles.FlagAnn
    % find the closest comments
    Temp=[];
    for i=1:length(handles.ScoredEvent)
        Temp(i)=handles.ScoredEvent(i).Start;
    end
    Temp = Temp - get(handles.SliderTime,'value');
    [Temp Index]=min(abs(Temp));
    set(handles.ListBoxComments,'value',Index);
end



handles=DataLoad(handles);
guidata(hObject,handles);
UpDatePlot(handles)


% --------------------------------------------------------------------
function MenuOpenXML_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOpenXML (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Temp = handles.FileName;
Temp([-3:0]+end)=[];
[FileNameAnn FilePath]=uigetfile([Temp '*.xml'],'Open XML File');

handles.FlagAnn=1;
% if there is ann file
if ~(sum(FileNameAnn==0))
    % check for the version of xml
    Fid = fopen([FilePath FileNameAnn],'r');
    Temp = fread(Fid,[1 inf],'uint8');
    fclose(Fid);
    Temp = strfind(Temp,'Compumedics');
    
    if isempty(Temp)
        % it is compumedics ann file
        handles.FlagAnnType = 1;
        [handles.ScoredEvent, handles.SleepStages, handles.EpochLength] = readXML_Com([FilePath FileNameAnn]);
        handles.PlotType = 1;
        Temp = [];
        
        for i=1:length(handles.SleepStages)
            Temp = [Temp ones(1,30)*handles.SleepStages(i)];
        end
        handles.SleepStages = Temp;
        
    else
        % it is PhysiMIMI file
        handles.FlagAnnType = 0;
        [handles.ScoredEvent, handles.SleepStages, handles.EpochLength, annotation] = readXML([FilePath FileNameAnn]);
        handles.PlotType = 0;
        
    end
    
    
    
    
    % ListBox Comments annotation
    Temp = [];
    for i=1:length(handles.ScoredEvent)
        Temp1 = fix(handles.ScoredEvent(i).Start/30)+1;
        Temp{i}= [num2str(Temp1) ' - ' datestr(handles.ScoredEvent(i).Start/86400,'HH:MM:SS - ') handles.ScoredEvent(i).EventConcept];
    end
    set(handles.ListBoxComments,'string',Temp);
    
    
    axes(handles.axes2)
    cla
    hold off
    plot(handles.SleepStages,'LineWidth',1.5,'color','k');
    hold on
    set(handles.axes2,'xTick',[0 length(handles.SleepStages)],'xlim',[0 length(handles.SleepStages)],'xticklabel',''...
        ,'fontweight','bold','yTick',[0:5],'ylim',[-0.5 5.5],'color',[205 224 247]/255,'yTickLabel',{'R','','N3','','N1','W'})
    
    
    
    x = [-1 -1 1 1 -1]*20+1000;
    y = [0 5 5 0 0];
    
    handles.LineSleepStage =  fill(x,y,'r');
    
else
    axes(handles.axes2)
    cla
    hold off
    set(handles.ListBoxComments,'string','');
    handles.FlagAnn=0;
    
end

handles=DataLoad(handles);
guidata(hObject,handles);
UpDatePlot(handles)



% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

clc
Loc=get(handles.axes1,'CurrentPoint');
Sel = round(Loc(1,2));
if Sel>0
    Sel = 0;
end
Sel = abs(Sel)+1;


Temp = get(hObject,'CurrentCharacter')+0;

% up arrow
if Temp == 30
    FilterPara = evalin('base','FilterPara');
    FilterPara{Sel}.ScalingFactor = fix(FilterPara{Sel}.ScalingFactor * 115)/100;
    assignin('base','FilterPara',FilterPara);
    UpDatePlot(handles)
end
    
% down arrow
if Temp == 31
    FilterPara = evalin('base','FilterPara');
    FilterPara{Sel}.ScalingFactor = fix(FilterPara{Sel}.ScalingFactor * 85)/100;
    assignin('base','FilterPara',FilterPara);
    UpDatePlot(handles)
end

% right arrow
if Temp == 29
    
    Value = get(handles.SliderTime,'value');
    
    Temp = get(handles.PopMenuWindowTime,'value');
    Temp1 = get(handles.PopMenuWindowTime,'string');
    Temp = Temp1{Temp};
    WindowTime = str2num(Temp(1:end-3));
    
    Max = get(handles.SliderTime,'max');
    
    if Value<=(Max-WindowTime)
        
        set(handles.SliderTime,'value',fix(Value+WindowTime));
        
        if handles.FlagAnn
            % find the closest comments
            Temp=[];
            for i=1:length(handles.ScoredEvent)
                Temp(i)=handles.ScoredEvent(i).Start;
            end
            Temp = Temp - get(handles.SliderTime,'value');
            [Temp Index]=min(abs(Temp));
            set(handles.ListBoxComments,'value',Index);
        end
        
        handles=DataLoad(handles);
        guidata(hObject,handles);
        UpDatePlot(handles);
    end
end


% left arrow
if Temp == 28
    
    Value = get(handles.SliderTime,'value');
    
    Temp = get(handles.PopMenuWindowTime,'value');
    Temp1 = get(handles.PopMenuWindowTime,'string');
    Temp = Temp1{Temp};
    WindowTime = str2num(Temp(1:end-3));
    
    
    
    if Value>=WindowTime
        set(handles.SliderTime,'value',fix(Value-WindowTime));
        
        if handles.FlagAnn
            % find the closest comments
            Temp=[];
            for i=1:length(handles.ScoredEvent)
                Temp(i)=handles.ScoredEvent(i).Start;
            end
            Temp = Temp - get(handles.SliderTime,'value');
            [Temp Index]=min(abs(Temp));
            set(handles.ListBoxComments,'value',Index);
        end
        
        handles=DataLoad(handles);
        guidata(hObject,handles);
        UpDatePlot(handles);
    end
end




% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


Loc=get(handles.axes2,'CurrentPoint');

xLim = get(handles.axes2,'xlim');
yLim = get(handles.axes2,'ylim');
% Click to go to sleep point of sleep axes
if (Loc(3)>yLim(1) & Loc(3)<yLim(2) & Loc(1)>xLim(1) & Loc(1)<xLim(2))

    Max = get(handles.SliderTime,'max');
    Time = fix(Loc(1));
    if Time<0
        Time = 0;
    end
    if Time> Max
        Time = Max;
    end
    set(handles.SliderTime,'value',Time);
    
    if handles.FlagAnn
        % find the closest comments
        Temp=[];
        for i=1:length(handles.ScoredEvent)
            Temp(i)=handles.ScoredEvent(i).Start;
        end
        Temp = Temp - get(handles.SliderTime,'value');
        [Temp Index]=min(abs(Temp));
        set(handles.ListBoxComments,'value',Index);
    end
    
    handles=DataLoad(handles);
    guidata(hObject,handles);
    UpDatePlot(handles);
end


%%%%

Loc=get(handles.axes1,'CurrentPoint');
xLim = get(handles.axes1,'xlim');
yLim = get(handles.axes1,'ylim');

if (Loc(3)>yLim(1) & Loc(3)<yLim(2) & Loc(1)>xLim(1) & Loc(1)<xLim(2))
    
    
    Sel = round(Loc(1,2));
    if Sel>0
        Sel = 0;
    end
    Sel = abs(Sel)+1;
    
    handles.ActiveCh = Sel;
    
    ChInfo = evalin('base','ChInfo');
    SelectedCh = evalin('base','SelectedCh');
    
    if Sel > size(SelectedCh,1)
        Sel = size(SelectedCh,1);
    end
    
    SelectedChMap=[];
    
    for i=1:size(SelectedCh,1)
        if SelectedCh(i,2)==0
            SelectedChMap{i,1} = handles.ChInfo.Labels(SelectedCh(i,1),:);
        else
            SelectedChMap{i,1} = [handles.ChInfo.Labels(SelectedCh(i,1),:) '-' handles.ChInfo.Labels(SelectedCh(i,2),:)];
        end
        SelectedChMap{i,1}((SelectedChMap{i,1}==' '))=[];
    end
    
    set(handles.TextInfo,'string',['Active Ch : ' SelectedChMap{Sel,1}]);
    
    
end

if Loc(1)<0
    FilterSettings(Sel);
    handles=DataLoad(handles);
    
    UpDatePlot(handles)
    assignin('base','FilterSettingH',[]);
    
end

guidata(hObject,handles);


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Loc=get(handles.axes1,'CurrentPoint');

Temp = get(handles.PopMenuWindowTime,'value');
Temp1 = get(handles.PopMenuWindowTime,'string');
Temp = Temp1{Temp};
WindowTime = str2num(Temp(1:end-3));


if ~isempty(handles.ActiveCh) & Loc(1)>0 & Loc(1)<WindowTime
     

    Sel=fix(Loc(1)/WindowTime*length(handles.Data{handles.ActiveCh}));
    
    if Sel ==0
        Sel = 1;
    end
    
    Data = handles.Data{handles.ActiveCh}(Sel);
    
    SelectedCh = evalin('base','SelectedCh');
    
    Ch = SelectedCh(handles.ActiveCh,1);

    % get back the digital value
    if handles.ChInfo.PhyMin(Ch)>0
        Data=-Data;
    end
    Data = Data*(handles.ChInfo.DiMax(Ch)-handles.ChInfo.DiMin(Ch));
    Data = Data+(handles.ChInfo.DiMax(Ch)+handles.ChInfo.DiMin(Ch))/2;
    
    % scale the data to get the actual value
    Slope  = (handles.ChInfo.PhyMax(Ch)-handles.ChInfo.PhyMin(Ch))/(handles.ChInfo.DiMax(Ch)-handles.ChInfo.DiMin(Ch));
    
    Value = (Data-handles.ChInfo.DiMin(Ch))*Slope + handles.ChInfo.PhyMin(Ch);
    
    Text = ['Signal value : ' num2str(Value,'%.2f') ' ' handles.ChInfo.PhyDim(Ch,:) ];
    
    set(handles.TextSignalValue,'string',Text);
    
    
end


% --- Executes on button press in CheckBoxSleepAxes.
function CheckBoxSleepAxes_Callback(hObject, eventdata, handles)
% hObject    handle to CheckBoxSleepAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckBoxSleepAxes
clc

TempAxes1  = get(handles.axes1,'outerposition');
TempAxes2  = get(handles.axes2,'outerposition');


if get(hObject,'value')
    set(handles.axes2,'visible','off');
    
        Temp = [TempAxes1(1) -0.029 TempAxes1(3) 0.94];
       
        set(handles.axes1,'outerposition',Temp);
else
    set(handles.axes2,'visible','on');
    set(handles.axes1,'outerposition',handles.Axes1OrgPos);
end
    
UpDatePlot(handles)