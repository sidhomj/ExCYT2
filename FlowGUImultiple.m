function varargout = FlowGUImultiple(varargin)
% FLOWGUIMULTIPLE MATLAB code for FlowGUImultiple.fig
%      FLOWGUIMULTIPLE, by itself, creates a new FLOWGUIMULTIPLE or raises the existing
%      singleton*.
%
%      H = FLOWGUIMULTIPLE returns the handle to a new FLOWGUIMULTIPLE or the handle to
%      the existing singleton*.
%
%      FLOWGUIMULTIPLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLOWGUIMULTIPLE.M with the given input arguments.
%
%      FLOWGUIMULTIPLE('Property','Value',...) creates a new FLOWGUIMULTIPLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FlowGUImultiple_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FlowGUImultiple_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FlowGUImultiple

% Last Modified by GUIDE v2.5 17-Nov-2017 16:56:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FlowGUImultiple_OpeningFcn, ...
                   'gui_OutputFcn',  @FlowGUImultiple_OutputFcn, ...
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


% --- Executes just before FlowGUImultiple is made visible.
function FlowGUImultiple_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FlowGUImultiple (see VARARGIN)

% Choose default command line output for FlowGUImultiple
handles.output = hObject;
handles.clustermethods.String={'Hard KMEANS (on t-SNE)','Hard KMEANS (on HD Data)',...
    'DBSCAN','Hierarchical Clustering','Network Graph-Based','Self Organized Map',...
    'GMM - Expectation Minimization','Variational Bayesian Inference for GMM'};

addpath('Functions/');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FlowGUImultiple wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FlowGUImultiple_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in selectfiles.
function selectfiles_Callback(hObject, eventdata, handles)
% hObject    handle to selectfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=ResetGUI(handles);
[filename,folder]=uigetfile({'*.fcs'},'Select file','MultiSelect','on');
handles.files.String=filename;
handles.filesoriginal=filename;

if ~iscell(filename)
    filename=cellstr(filename);
end

if strcmp(handles.events_per_file.String,'Events Per File') || isempty(handles.events_per_file.String)
    subsample=0;
else
    subsample=1;
    sampleamnt=str2num(handles.events_per_file.String);
end

for i=1:size(filename,2)
    filenamequery=filename(i);
    filenamequery=fullfile(folder,filenamequery);
    try 
        [data, marker_names, channel_names, scaled_data, compensated_data, fcshdr] = readfcs_v2(filenamequery{1});
        data=single(transpose(data+1));
        compensated_data=single(transpose(compensated_data+1));
        if subsample==1
            if size(data,1)>sampleamnt || size(compensated_data,1)>sampleamnt
                data=datasample(data,sampleamnt);
                compensated_data=datasample(compensated_data,sampleamnt);
            end 
        end
        
        %Remove All Cells with negative data
        data=data(~any(data<0,2),:);
        %compensated_data=compensated_data(~any(compensated_data<0,2),:);
        handles.num(i).num=compensated_data; %num is used to store compensated data
        handles.num2(i).num=data; %num2 is used to store uncompensated data
        header=marker_names;
    catch
        [data, fcshdr, fcsdatscaled, compensated_data] = fca_readfcs(filenamequery{1});
        data=single(double(data+1));
        if subsample==1
            if size(data,1)>sampleamnt
                data=datasample(data,sampleamnt);
            end 
        end
        
        headerdata=fcshdr.par;
        for j=1:size(headerdata,2);
            if ~isempty(headerdata(j).name2)
                header{j}=headerdata(j).name2;
            else
                header{j}=headerdata(j).name;
            end
        end
        
        %Remove All Cells with negative data
        data=data(~any(data<0,2),:);
        
        handles.num(i).num=data;
        handles.num2(i).num=data;
    end

end

%header{3}='FoxP3';header{4}='L/D';header{5}='CTLA4';header{6}='CD4';header{7}='CD40L';header{8}='PD1';header{9}='Gal3';header{10}='Thy1.2';header{11}='CD8';header{12}='Tim3';
%header{3}='EOMES';header{4}='CD8';header{5}='CTLA4';header{6}='CD4';header{7}='Lag3';header{8}='Tbet';header{9}='Thy1.2';header{10}='PD1';header{11}='L/D';header{12}='Tim3'; 
%header{3}='MHCII';header{4}='L/D';header{5}='CD86';header{6}='Ly6C';header{7}='F480';header{8}='CD11c';header{9}='CD11b';header{10}='CD8';header{11}='Ly6G';
handles.ChannelsAll=header;
handles.channel_select.String=header;
handles.popupmenu1.String=header;
handles.popupmenu2.String=header;
handles.cvxplot.String=header;
handles.cvyplot.String=header;
handles.cvxscale.String={'linear','log10','arcsinh'};
handles.cvyscale.String={'linear','log10','arcsinh'};
handles.heatmaptsne.String=header;
guidata(hObject,handles);
msgbox('Data Imported');

    function handles=ResetGUI(handles)
        fieldremove={'filesoriginal','num','num2','ChannelsAll','fileselect','ActiveGates','idx_cohort','y2',...
            'transy2','Y','transy','idx_cohort_new','ChannelsOut','y','colorspec1','tsne_xlim','tsne_ylim','idx','num_clusters','HeatMapData',...
            'RowLabels','SizeCluster','Ifinal','assigned','cohorts','Value','thresholdcurrent','ClusterContrib',...
            'I','Imod','thresholdbook','threshold_count','redo'};
        
        handles.files.Value=[];
        handles.channel_select.Value=[];
        handles.channel_select.String={};
        handles.numevents.String='';
        handles.perc_of_file.String='';
        handles.clusterbreakdown.Data={};
        handles.clusterbreakdown2.Data={};
        handles.threshlist.String={};
        handles.clustersel.String={};
        handles.clustersel.Value=[];
        handles.clusterplot.String={};
        handles.clusterplot.Value=[];
        handles.popupmenu1.Value=1;
        handles.popupmenu2.Value=2;
        cla(handles.tsneplot); cla(handles.cluster_view);
        
        for i=1:size(fieldremove,2);
            if isfield(handles,fieldremove{i})
                handles=rmfield(handles,fieldremove{i});
            end
        end
        
      

% --- Executes on selection change in files.
function files_Callback(hObject, eventdata, handles)
% hObject    handle to files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from files


% --- Executes during object creation, after setting all properties.
function files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numevents_Callback(hObject, eventdata, handles)
% hObject    handle to numevents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numevents as text
%        str2double(get(hObject,'String')) returns contents of numevents as a double

handles.totalevents.String=str2double(get(hObject,'String'))*size(handles.filesoriginal,2);
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function numevents_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numevents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel_select.
function channel_select_Callback(hObject, eventdata, handles)
% hObject    handle to channel_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel_select


% --- Executes during object creation, after setting all properties.
function channel_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in gate.
function gate_Callback(hObject, eventdata, handles)
% hObject    handle to gate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    fileselect=handles.files.Value;
    if isempty(fileselect)
        msgbox('No files selected','Error','error');
        return
    end
    
    handles.fileselect=fileselect;
    positiongui=handles.figure1.Parent.PointerLocation;
    
    fhgat = figure('units','pixels',...
                  'position',[positiongui 600 600],...
                  'menubar','none',...
                  'name','Clean Data (Gating)',...
                  'numbertitle','off',...
                  'resize','off');
              
    guidata(fhgat,handles);
    num=handles.num(fileselect).num;
    ChannelsAll=handles.ChannelsAll;
    
    h=axes('Parent',fhgat,'Position',[0.25 0.15 0.7 0.7]);
    
    title=uicontrol('Parent',fhgat,'Style','text',...
        'String','Gating Strategy',...
        'Position',[250,525,200,40],...
        'FontSize',16);
    
    xoption=uicontrol('Parent',fhgat,'Style','pop',...
        'String',ChannelsAll,...
        'Position',[325,35,100,24],...
        'Value',1,...
        'Tag','xoption',...
        'Callback',@xoptionfunc1);
    
    yoption=uicontrol('Parent',fhgat,'Style','pop',...
        'String',ChannelsAll,...
        'Position',[20,300,100,24],...
        'Value',2,...
        'Tag','yoption',...
        'Callback',@yoptionfunc1);
    
    xscalegat=uicontrol('Parent',fhgat,'Style','pop',...
        'String',{'Linear','Log10','arcsinh'},...
        'Position',[325,15,100,24],...
        'Value',1,...
        'Tag','xscalegat',...
        'Callback',@xscalegatfunc);
    
    yscalegat=uicontrol('Parent',fhgat,'Style','pop',...
        'String',{'Linear','Log10','arcsinh'},...
        'Position',[20,276,100,24],...
        'Value',1,...
        'Tag','yscalegat',...
        'Callback',@yscalegatfunc);
    
    gatebutton=uicontrol('Parent',fhgat,'Style','push',...
        'String','Gate Population',...
        'Position',[20,570,150,50],...
        'Tag','gatepop',...
        'Callback',@gatepop);
    
    donegate=uicontrol('Parent',fhgat,'Style','push',...
        'String','Apply Gates to Single File',...
        'Position',[200,570,200,50],...
        'FontUnits','normalized',...
        'Tag','donegate',...
        'Callback',@donegatefunc);
    
    donegate2=uicontrol('Parent',fhgat,'Style','push',...
        'String','Apply Gates to All Files',...
        'Position',[400,570,200,50],...
        'FontUnits','normalized',...
        'Tag','donegate2',...
        'Callback',@donegatefunc2);
    
    GatePlot(num)
    guidata(fhgat,handles);
        
    
        function GatePlot(num)
            xscale=findobj('Tag','xscalegat');
            yscale=findobj('Tag','yscalegat');
            xoption=findobj('Tag','xoption');
            yoption=findobj('Tag','yoption');

            if xscale.Value==1
                 plotx=num(:,xoption.Value);
            elseif xscale.Value==2
                plotx=log10forflow(num(:,xoption.Value));
            else
                plotx=asinh(num(:,xoption.Value));
            end

            if yscale.Value==1
                ploty=num(:,yoption.Value);
            elseif yscale.Value==2
                 ploty=log10forflow(num(:,yoption.Value));
            else
                ploty=asinh(num(:,yoption.Value));
            end
            
            dscatter(plotx,ploty);
                

        function xscalegatfunc(hObject,eventdata)
            handles=guidata(hObject);
            fileselect=handles.fileselect;
            GatePlot(handles.num(fileselect).num)

        function yscalegatfunc(hObject,eventdata)
            handles=guidata(hObject);
             fileselect=handles.fileselect;
            GatePlot(handles.num(fileselect).num)

        function gatepop(hObject,eventdata)
            handles=guidata(hObject);
            fileselect=handles.fileselect;
            [sel,xsel,ysel]=selectdata('SelectionMode','Lasso','Verify','on');
            handles.num(fileselect).num=handles.num(fileselect).num(sel,:);
            k=boundary(xsel,ysel);
            boundx=xsel(k);
            boundy=ysel(k);
            xoption=findobj('Tag','xoption');
            yoption=findobj('Tag','yoption');
            xscale=findobj('Tag','xscalegat');
            yscale=findobj('Tag','yscalegat');
            
            if xscale.Value==2
                boundx=10.^boundx;
            elseif xscale.Value==3
                boundx=sinh(boundx);
            end
            
            if yscale.Value==2
                boundy=10.^boundy;
            elseif yscale.Value==3
                boundy=sinh(boundy);
            end
            
            if ~isfield(handles,'ActiveGates')
                n=1;
            else
                n=size(handles.ActiveGates,2)+1;
            end
            
                handles.ActiveGates(n).xparam=xoption.Value;
                handles.ActiveGates(n).yparam=yoption.Value;
                handles.ActiveGates(n).boundx=boundx;
                handles.ActiveGates(n).boundy=boundy;
  
            guidata(findobj('Tag','gatepop'),handles);
            GatePlot(handles.num(fileselect).num)

            
        function xoptionfunc1(hObject,eventdata)
            handles=guidata(hObject);
             fileselect=handles.fileselect;
            GatePlot(handles.num(fileselect).num)
            
        function yoptionfunc1(hObject,eventdata)
            handles=guidata(hObject);
             fileselect=handles.fileselect;
            GatePlot(handles.num(fileselect).num)
            
        function donegatefunc(hObject,eventdata)
            handles=guidata(hObject);
            guidata(findobj('Tag','gate'),handles);
            closereq
            
        function donegatefunc2(hObject,eventdata)
            hbox=msgbox('Applying Gates to All Files.. Please Wait');
            handles=guidata(hObject);
            ActiveGates=handles.ActiveGates;
            for i=1:size(handles.num,2)
                if i~=handles.fileselect
                    numtemp=handles.num(i).num;
                    inpass=ones(size(numtemp,1),1);
                    for j=1:size(ActiveGates,2)
                        in=inpolygon(numtemp(:,ActiveGates(j).xparam),numtemp(:,ActiveGates(j).yparam),ActiveGates(j).boundx,ActiveGates(j).boundy);
                        inpass=inpass.*in;
                    end
                    handles.num(i).num=numtemp(find(inpass),:); 
                end
            end
   
            guidata(findobj('Tag','gate'),handles);
            close(hbox);
            closereq
            

% --- Executes on button press in tsne.
function tsne_Callback(hObject, eventdata, handles)
% hObject    handle to tsne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hbox=msgbox('Running t-SNE Analysis');
ResetToBeforeDM(handles);


cla(handles.tsneplot)
cla(handles.cluster_view)

if ~isempty(handles.perc_of_file.String) && ~isempty(handles.numevents.String)
    msgbox('Select Only One Sampling Criteria','Error','error');
    return
end

if ~isfield(handles,'redo')

    num=handles.num;
    idx=[];
    if ~isempty(handles.numevents.String)
            numout=[];
            for i=1:size(num,2)
                numsel=num(i).num;
                if str2num(handles.numevents.String)<size(numsel,1)
                    numsel=datasample(numsel,str2num(handles.numevents.String));
                end
                numout=[numout;numsel];
                idx=[idx;i*ones(size(numsel,1),1)];
            end
            num=numout;
    elseif ~isempty(handles.perc_of_file.String)
         numout=[];
         for i=1:size(num,2)
             numsel=num(i).num;
             selcount=round((str2num(handles.perc_of_file.String)/100)*size(numsel,1));
             if selcount<size(numsel,1)
                numsel=datasample(numsel,selcount);
             end
             numout=[numout;numsel];
             idx=[idx;i*ones(size(numsel,1),1)];
         end
         num=numout;
    end

    handles.idx_cohort=idx;

    if isfield(handles,'cohorts')
        idxnew=zeros(size(idx,1),1);
        for i=1:size(handles.cohorts,2)
            sel=handles.cohorts(i).index;
            idxnew=idxnew+ismember(idx,sel).*i;
        end
        idx=idxnew;
    end


    y=num;
    handles.y2=y;
    if handles.instrument.Value==1
        y2=asinh(y/150);
    elseif handles.instrument.Value==2;
        y2=asinh(y/5);
    end
    handles.transy2=y2;


    handles.idx_cohort_new=idx;

    if ~isfield(handles,'channel_select')
        msgbox('Select Channels For Analysis','Error','error');
    end

    y=y(:,handles.channel_select.Value);

    handles.ChannelsOut=handles.ChannelsAll(handles.channel_select.Value);
  

    handles.y=y;
    if handles.instrument.Value==1
        y=asinh(y/150);
    elseif handles.instrument.Value==2;
        y=asinh(y/5);
    end
    handles.transy=y;
else
    y=handles.y;
    
end


normalizetsne=1;
if handles.radiobutton1.Value==0
    Y=tsne(y,'Standardize',normalizetsne);
else
    Y=tsne(y,'Standardize',normalizetsne,'NumDimensions',3);
end

close(hbox);
handles.Y=Y;

[colorspec1,colorspec2]=CreateColorTemplate(size(handles.num,2));
handles.colorspec1=colorspec1;

clear colorscheme
for i=1:size(handles.idx_cohort_new,1);
    colorscheme(i,:)=colorspec1(handles.idx_cohort_new(i)).spec;
end

if handles.radiobutton1.Value==0
    scatter(handles.tsneplot,Y(:,1),Y(:,2),15,colorscheme,'filled','MarkerFaceAlpha',0.75,'MarkerEdgeColor',[0 0 0],'MarkerEdgeAlpha',0.6);
else 
    scatter3(handles.tsneplot,Y(:,1),Y(:,2),Y(:,3),15,colorscheme,'filled','MarkerFaceAlpha',0.75,'MarkerEdgeColor',[0 0 0],'MarkerEdgeAlpha',0.6);
    rotate3d on
end

handles.tsneplot.XTickLabel={};
handles.tsneplot.YTickLabel={};
handles.tsne_xlim=handles.tsneplot.XLim;
handles.tsne_ylim=handles.tsneplot.YLim;
if handles.radiobutton1.Value==1
    handles.tsneplot.ZTickLabel={};
    handles.tsne_zlim=handles.tsneplot.ZLim;
    handles.tsne_zlim=handles.tsneplot.ZLim;
end

PlotClusterView(handles,Y);

guidata(hObject,handles);

    function ResetToBeforeDM(handles);
        

% --- Executes on button press in diffusionmap.
function diffusionmap_Callback(hObject, eventdata, handles)
% hObject    handle to diffusionmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    hbox=msgbox('Running Diffusion Map Analysis');
cla(handles.tsneplot)
cla(handles.cluster_view)

if ~isempty(handles.perc_of_file.String) && ~isempty(handles.numevents.String)
    msgbox('Select Only One Sampling Criteria','Error','error');
    return
end


if ~isfield(handles,'redo')

    num=handles.num;
    idx=[];
    if ~isempty(handles.numevents.String)
            numout=[];
            for i=1:size(num,2)
                numsel=num(i).num;
                if str2num(handles.numevents.String)<size(numsel,1)
                    numsel=datasample(numsel,str2num(handles.numevents.String));
                end
                numout=[numout;numsel];
                idx=[idx;i*ones(size(numsel,1),1)];
            end
            num=numout;
    elseif ~isempty(handles.perc_of_file.String)
         numout=[];
         for i=1:size(num,2)
             numsel=num(i).num;
             selcount=round((str2num(handles.perc_of_file.String)/100)*size(numsel,1));
             if selcount<size(numsel,1)
                numsel=datasample(numsel,selcount);
             end
             numout=[numout;numsel];
             idx=[idx;i*ones(size(numsel,1),1)];
         end
         num=numout;
    end

    handles.idx_cohort=idx;

    if isfield(handles,'cohorts')
        idxnew=zeros(size(idx,1),1);
        for i=1:size(handles.cohorts,2)
            sel=handles.cohorts(i).index;
            idxnew=idxnew+ismember(idx,sel).*i;
        end
        idx=idxnew;
    end


    y=num;
    handles.y2=y;
    if handles.instrument.Value==1
        y2=asinh(y/150);
    elseif handles.instrument.Value==2;
        y2=asinh(y/5);
    end
    handles.transy2=y2;


    handles.idx_cohort_new=idx;

    if ~isfield(handles,'channel_select')
        msgbox('Select Channels For Analysis','Error','error');
    end

    y=y(:,handles.channel_select.Value);

    handles.ChannelsOut=handles.ChannelsAll(handles.channel_select.Value);

    normalizetsne=1;

    handles.y=y;
    if handles.instrument.Value==1
        y=asinh(y/150);
    elseif handles.instrument.Value==2;
        y=asinh(y/5);
    end
    handles.transy=y;
    
else
        y=handles.y;
    
end


addpath('drtoolbox/techniques');
if handles.radiobutton1.Value==0
    Y=diffusion_maps(y,2,1,1);
else
    Y=diffusion_maps(y,3,1,1);
end
rmpath('drtoolbox/techniques');
close(hbox);
handles.Y=Y;

[colorspec1,colorspec2]=CreateColorTemplate(size(handles.num,2));
handles.colorspec1=colorspec1;

clear colorscheme
for i=1:size(handles.idx_cohort_new,1);
    colorscheme(i,:)=colorspec1(handles.idx_cohort_new(i)).spec;
end

if handles.radiobutton1.Value==0
    scatter(handles.tsneplot,Y(:,1),Y(:,2),15,colorscheme,'filled','MarkerFaceAlpha',0.75,'MarkerEdgeColor',[0 0 0],'MarkerEdgeAlpha',0.6);
else 
    scatter3(handles.tsneplot,Y(:,1),Y(:,2),Y(:,3),15,colorscheme,'filled','MarkerFaceAlpha',0.75,'MarkerEdgeColor',[0 0 0],'MarkerEdgeAlpha',0.6);
    rotate3d on
end

handles.tsneplot.XTickLabel={};
handles.tsneplot.YTickLabel={};
handles.tsne_xlim=handles.tsneplot.XLim;
handles.tsne_ylim=handles.tsneplot.YLim;
if handles.radiobutton1.Value==1
    handles.tsneplot.ZTickLabel={};
    handles.tsne_zlim=handles.tsneplot.ZLim;
    handles.tsne_zlim=handles.tsneplot.ZLim;
end
colorscheme=[0,0.447000000000000,0.741000000000000];
PlotClusterView(handles,Y,colorscheme);

guidata(hObject,handles);

    function num=CombineData(handles,numevents)
        num=handles.num;
        numout=[];
        for i=1:size(num,2)
            numsel=num(i).num;
            numsel=datasample(numsel,numevents);
            numout=[numout;numsel];
        end
        num=numout;
        
     function num=CombineData2(handles,numevents)
        num=handles.num;
        numout=[];
        for i=1:size(num,2)
            numsel=num(i).num;
            numsel=datasample(numsel,numevents);
            numout=[numout;numsel];
        end
        num=numout;

        


% --- Executes on button press in selclusters.
function selclusters_Callback(hObject, eventdata, handles)
% hObject    handle to selclusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dcm_obj=datacursormode(handles.cluster_view.Parent);
set(dcm_obj,'Enable','off');

if ~isfield(handles,'ManualClusterCount')
    if isfield(handles,'idx')
        handles=rmfield(handles,'idx');
        handles=rmfield(handles,'colorspec1');
    end
    [colorspec1,colorspec2]=CreateColorTemplate(100);
    handles.colorspec1=colorspec1;
    handles.cluster_sel.String={};
    Y=handles.Y;
    scatter(handles.cluster_view,Y(:,1),Y(:,2),'filled');
    handles.cluster_view.XTickLabel={};
    handles.cluster_view.YTickLabel={};
    hold(handles.cluster_view)
    handles.ManualClusterCount=1;
    I=1;
else
    Y=handles.Y;
    handles.ManualClusterCount=handles.ManualClusterCount+1;
    colorspec1=handles.colorspec1;
    idx=handles.idx;
    I=handles.I;
    I=[I,I(end)+1];
    handles.I=I;
    handles.Imod=I;
    ClusterContrib=handles.ClusterContrib;
end

sel=selectdata('SelectionMode','Lasso','Verify','on');
if handles.ManualClusterCount~=1
    sel=sel{handles.ManualClusterCount};
end
in=zeros(size(handles.Y,1),1);
in(sel)=1;
in=logical(in);
Yplot=handles.Y(in,:);
%hold(handles.cluster_view);
scatter(handles.cluster_view,Yplot(:,1),Yplot(:,2),[],colorspec1(handles.ManualClusterCount).spec,'filled');
handles.cluster_view.XLim=handles.tsne_xlim;
handles.cluster_view.YLim=handles.tsne_ylim;
hold(handles.cluster_view);

ClusterContrib(handles.ManualClusterCount,1)=handles.ManualClusterCount;
ClusterContrib(handles.ManualClusterCount,2)=sum(in);
ClusterContrib(handles.ManualClusterCount,3)=100*(sum(in)/size(in,1));
handles.ClusterContrib=ClusterContrib;

sortedlist=cell(1,size(I,2));
for i=1:size(I,2);
    sortedlist(i)=strcat({'Cluster '},num2str(I(i)),{' - '},num2str(ClusterContrib(I(i),3)),{'%'});
end


if handles.ManualClusterCount==1;
    handles.clustersel.Value=[];
    handles.clustersel.String=sortedlist;
    handles.idx=double(in);
    handles.I=I;
    handles.Imod=I;
else
    p=handles.ManualClusterCount;
    idx=handles.idx+p*double(in);
    handles.idx=double(idx);
    handles.clustersel.Value=[];
    handles.clustersel.String=sortedlist;
    handles=HeatMap_CallbackManual(hObject, eventdata, handles);
end

guidata(hObject,handles);

function handles=HeatMap_CallbackManual(hObject, eventdata, handles)
% hObject    handle to HeatMapClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    ChannelsOut=handles.ChannelsOut;
    idx=handles.idx;
    ClusterIter=[1:max(idx)];
    y=handles.y;
    
    for j=ClusterIter
            clusterselect=idx==j;
            SizeCluster(j)=sum(clusterselect);
            clusterselect2=y(clusterselect,:);
            clusterselect2=log10(clusterselect2);
            HeatMapData(j,:)=real(median(clusterselect2)); 
            RowLabels{j}=strcat('Cluster ',num2str(j),' = ',num2str(100*(SizeCluster(j)/size(y,1))),'%');
    end
    
    handles.HeatMapData=HeatMapData;
    handles.RowLabels=RowLabels;
    ClusterContrib=tabulate(idx);
    if ClusterContrib(1,1)==0
        ClusterContrib=ClusterContrib(2:end,:);
    end
    handles.SizeCluster=SizeCluster;
    handles.ClusterContrib=ClusterContrib;
    handles.I=ClusterIter;
    handles.num_clusters=max(idx);



% --- Executes on selection change in clustersel.
function clustersel_Callback(hObject, eventdata, handles)
% hObject    handle to clustersel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns clustersel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from clustersel


% --- Executes during object creation, after setting all properties.
function clustersel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clustersel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in clusterplot.
function clusterplot_Callback(hObject, eventdata, handles)
% hObject    handle to clusterplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns clusterplot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from clusterplot



% --- Executes during object creation, after setting all properties.
function clusterplot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clusterplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select.
function select_Callback(hObject, eventdata, handles)
% hObject    handle to select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sel=handles.clustersel.Value;
Imod=handles.Imod;
I=Imod(sel);
ClusterContrib=handles.ClusterContrib;

sortedlist=cell(1,size(I,2));
for i=1:size(sel,2);
    sortedlist(i)=strcat({'Cluster '},num2str(I(i)),{' - '},num2str(ClusterContrib(I(i),3)),{'%'});
end

currentlist=transpose(handles.clusterplot.String);
finallist=[currentlist,sortedlist];
finallist=unique(finallist,'stable');
handles.clusterplot.Value=[1];
handles.clusterplot.String=finallist;
if isfield(handles,'Ifinal');
    handles.Ifinal=unique([handles.Ifinal,I],'stable');
else
    handles.Ifinal=I;
end

handles=UpdateTable1(handles);
 
guidata(hObject,handles);

    function handles=UpdateTable1(handles)
        I=handles.Ifinal;
         if ~isempty(I)
            maxconditions=max(handles.idx_cohort);
            for i=1:size(I,2)
                incluster=handles.idx==I(i);
                sample=handles.idx_cohort(incluster);
                table_sample=tabulate(sample);
                for j=1:maxconditions
                    try
                        table_out(j,i)=100*(table_sample(j,2)/sum(handles.idx_cohort==j));
                    catch
                        table_out(j,i)=0;
                    end
                end
            end

            sampleid=transpose(handles.filesoriginal);
            datawrite=[sampleid,num2cell(table_out)];
            
            data_out=[];
            data_out2=[];
            %%reorganize table into cohorts
            for i=1:size(handles.cohorts,2);
                clear name_temp
                sel=handles.cohorts(i).index;
                data_sel=datawrite(sel,:);
                data_mean=mean(cell2mat(data_sel(:,2:end)),1);
                [name_temp{1:size(data_sel,1)}]=deal(strcat('Cohort ',num2str(i)));
                data_sel=[transpose(name_temp),data_sel];
                data_out=[data_out;data_sel];
                data_sel2=[transpose(name_temp(1)),num2cell(data_mean)];
                data_out2=[data_out2;data_sel2];
            end
            
            rownames=['Cohort','Filename',num2cell(I)];
            datawrite=[rownames;data_out];
            handles.clusterbreakdown2.Data=datawrite;
            handles.clusterbreakdown2.RowName='';
            
            rownames=['Cluster #',num2cell(I)];
            datawrite=[rownames;data_out2];
            handles.clusterbreakdown.Data=datawrite;
            handles.clusterbreakdown.ColumnName='';
            
        else
            handles.clusterbreakdown2.Data={};
            handles.clusterbreakdown.Data={};
        end
        
        
        
       
        

    function handles=UpdateTable1old(handles)
        I=handles.Ifinal;
        
        if ~isempty(I)
            maxconditions=max(handles.idx_cohort_new);
            for i=1:size(I,2)
                incluster=handles.idx==I(i);
                sample=handles.idx_cohort_new(incluster);
                table_sample=tabulate(sample);
                for j=1:maxconditions 
                        try
                       table_out(j,i)=100*(table_sample(j,2)/sum(handles.idx_cohort_new==j));
                        catch
                            table_out(j,i)=0;
                        end
                end
            end

            for i=1:maxconditions
                sampleid(i)=strcat({'Cohort '},num2str(i));
            end
            sampleid=transpose(sampleid);
            datawrite=[sampleid,num2cell(table_out)];
            rownames=['Cluster #',num2cell(I)];
            datawrite=[rownames;datawrite];
            handles.clusterbreakdown.Data=datawrite;
            %handles.clusterbreakdown.RowName='';
            handles.clusterbreakdown.ColumnName='';
        else
            handles.clusterbreakdown.Data={};
        end
        
    function handles=UpdateTable2(handles)
        I=handles.Ifinal;
        if ~isempty(I)
            maxconditions=max(handles.idx_cohort);
            for i=1:size(I,2)
                incluster=handles.idx==I(i);
                sample=handles.idx_cohort(incluster);
                table_sample=tabulate(sample);
                for j=1:maxconditions
                    try
                        table_out(j,i)=100*(table_sample(j,2)/sum(handles.idx_cohort==j));
                    catch
                        table_out(j,i)=0;
                    end
                end
            end

            sampleid=transpose(handles.filesoriginal);
            datawrite=[sampleid,num2cell(table_out)];
            
            data_out=[];
            %%reorganize table into cohorts
            for i=1:size(handles.cohorts,2);
                clear name_temp
                sel=handles.cohorts(i).index;
                data_sel=datawrite(sel,:);
                [name_temp{1:size(data_sel,1)}]=deal(strcat('Cohort ',num2str(i)));
                data_sel=[transpose(name_temp),data_sel];
                data_out=[data_out;data_sel];
            end
            
            rownames=['Cohort','Filename',num2cell(I)];
            datawrite=[rownames;data_out];
            handles.clusterbreakdown2.Data=datawrite;
            %handles.clusterbreakdown2.ColumnName='';
            handles.clusterbreakdown2.RowName='';
        else
            handles.clusterbreakdown2.Data={};
        end

        
       

% --- Executes on button press in remove.
function remove_Callback(hObject, eventdata, handles)
% hObject    handle to remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sel=handles.clusterplot.Value;
currentlist=transpose(handles.clusterplot.String);
removelist=transpose(handles.clusterplot.String(sel));

newlist=setdiff(currentlist,removelist,'stable');
handles.clusterplot.Value=[1];
handles.clusterplot.String=newlist;

handles.Ifinal=setdiff(handles.Ifinal,handles.Ifinal(sel),'stable');

handles=UpdateTable1(handles);


guidata(hObject,handles);


% --- Executes on button press in boxplot.
function boxplot_Callback(hObject, eventdata, handles)
% hObject    handle to boxplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

y=log10(handles.y);
ChannelsOut=handles.ChannelsOut;
figure
selection=1;
clusterselect2=datasample(y,round(selection*size(y,1)));
for z=1:size(clusterselect2,2);
    r=normrnd(z,0.15,size(clusterselect2,1),1);
    dscatter(r,clusterselect2(:,z));
    hold on;
end

if isfield(handles,'Ifinal')
    I=handles.Ifinal;
    idx=handles.idx;
    select=handles.clusterplot.Value;
    I=I(select);
    colorspec1=handles.colorspec1;
    

    if size(I,2)==2
        ChannelsOut=DetermineSigChannels(I,y,idx,ChannelsOut);
    end

    %n=2;
    for j=I
        clusterselect=idx==j;
        clusterselect2=y(clusterselect,:);
        %clusterselect2=real(log10(clusterselect2));
        bp=boxplot(clusterselect2,'Colors',colorspec1(j).spec,'Symbol','','Whisker',0,'Notch','on'); 
        for i = 1:size(bp,2), set(bp(:,i),'linewidth',3); end
        %n=n+1;
    end
end

title('Phenotypic Characterization of Clusters')
xlabel('Marker');
ylabel('MFI (log10)');
xtickangle(45);
xticks(1:size(y,2));
set(gca,'xticklabel',ChannelsOut);
set(gca,'TickLabelInterpreter','none');
hold off


% --- Executes on button press in hdflowplot.
function hdflowplot_Callback(hObject, eventdata, handles)
% hObject    handle to hdflowplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% for select=1:size(handles.clusterplot.String,1);
    
    %y=handles.transy;
    y=log10(handles.y);
    ChannelsOut=handles.ChannelsOut;
         %h=figure
         h=figure('units','normalized','outerposition',[0 0 1 1]);

        for z=1:size(y,2);
            r=normrnd(z,0.15,size(y,1),1);
            rkeep(:,z)=r;
            dscatter(r,y(:,z));
            hold on;

        end

    if isfield(handles,'Ifinal')
        I=handles.Ifinal;
        idx=handles.idx;
        select=handles.clusterplot.Value;
        I=I(select);
        colorspec1=handles.colorspec1;

        Num_Channels=size(y,2);

        if size(I,2)==2
            ChannelsOut=DetermineSigChannels(I,y,idx,ChannelsOut);
        end

        for j=I
            clusterselect=idx==j;
            clusterselect2=y(clusterselect,:);
            rkeep2=rkeep(clusterselect,:);
            for z=1:size(clusterselect2,2);
                scatter(rkeep2(:,z),clusterselect2(:,z),20,colorspec1(j).spec,'filled');
                hold on;
            end
        end
     end

    title('Phenotypic Characterization of Clusters')
    xlabel('Marker');
    ylabel('MFI (log10)');
    xtickangle(45);
    xticks(1:size(y,2));
    set(gca,'xticklabel',ChannelsOut);
    set(gca,'TickLabelInterpreter','none');
    hold off
    %saveas(h,strcat(handles.clusterplot.String{select},'.png'))
    %close(h)



% --- Executes on button press in cvflowplot.
function cvflowplot_Callback(hObject, eventdata, handles)
% hObject    handle to cvflowplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


I=handles.Ifinal;
idx=handles.idx;
select=handles.clusterplot.Value;
I=I(select);
colorspec1=handles.colorspec1;
xscale=handles.cvxscale.Value;
yscale=handles.cvyscale.Value;

ChannelsAll=handles.ChannelsAll;
xplotnum=handles.cvxplot.Value;
yplotnum=handles.cvyplot.Value;
y=handles.y2;
ytrans=handles.transy2;


if xscale==1
     plotx=y(:,xplotnum);
elseif xscale==2
    plotx=log10forflow(y(:,xplotnum));
else
     plotx=ytrans(:,xplotnum);
%     objx=logicleTransform(max(y(:,xplotnum)),2,5,1);
%     plotx=objx.transform(y(:,xplotnum));
end

if yscale==1
    ploty=y(:,yplotnum);
elseif yscale==2
    ploty=log10forflow(y(:,yplotnum));
    
     %ploty=subplus(real(log10(y(:,yplotnum))));
else
    ploty=ytrans(:,yplotnum);
%     objy=logicleTransform(max(y(:,yplotnum)),2,5,1);
%     ploty=objy.transform(y(:,yplotnum));
end

figure
hold on
dscatter(plotx,ploty);

% if xscale==3
%     ax = gca;
%     ax.XTick = objx.Tick;
%     ax.XTickLabel = objx.TickLabel;
% end
% 
% if yscale==3
%     ax = gca;
%     ax.YTick = objy.Tick;
%     ax.YTickLabel = objy.TickLabel;
% end

  
    n=1;
    for j=I
        clusterselect=idx==j;
        xclusterplot=plotx(clusterselect);
        yclusterplot=ploty(clusterselect);
        scatter(xclusterplot,yclusterplot,10,colorspec1(j).spec,'filled','MarkerFaceAlpha',1);
    end
    


    title('Phenotypic Characterization of Clusters')
    xlabel(ChannelsAll(xplotnum));
    ylabel(ChannelsAll(yplotnum));
    hold off



% --- Executes on button press in savetsne.
function savetsne_Callback(hObject, eventdata, handles)
% hObject    handle to savetsne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%Separate Images by cohort
colorspec1=handles.colorspec1;
clear colorscheme
for i=1:size(handles.idx_cohort_new,1);
    colorscheme(i,:)=colorspec1(handles.idx_cohort_new(i)).spec;
end

cohorts=unique(handles.idx_cohort_new);
for i = 1:size(cohorts,1);
    sel=handles.idx_cohort_new==cohorts(i);
    figure
    scatter(handles.Y(sel,1),handles.Y(sel,2),15,colorspec1(i).spec,'filled','MarkerFaceAlpha',0.75,'MarkerEdgeColor',[0 0 0],'MarkerEdgeAlpha',0.6);
    xticks([])
    yticks([])
    title(cohorts(i))
end

% %%%Separate Images by cohort and cluster
% cohorts=unique(handles.idx_cohort_new);
% figure
% for i = 1:size(cohorts,1);
%     sel=handles.idx_cohort_new==cohorts(i);
%     clear colorscheme
%     for i=1:size(handles.idx,1);
%         colorscheme(i,:)=colorspec1(handles.idx(i)).spec;
%     end
%     colorscheme=colorscheme(sel,:);
%     scatter(handles.Y(sel,1),handles.Y(sel,2),15,colorscheme,'filled','MarkerFaceAlpha',0.75,'MarkerEdgeColor',[0 0 0],'MarkerEdgeAlpha',0.6);  
%     hold on
%     xticks([])
%     yticks([])
%     xlim(handles.tsne_xlim)
%     ylim(handles.tsne_ylim)
%     
% end



% [file,path,filetype]=uiputfile({'*.bmp','BMP';'*.jpeg','JPEG';'*.png','PNG'},'Save Image As');
% F=getframe(handles.tsneplot);
% Image=frame2im(F);
% imwrite(Image,strcat(path,file));




% --- Executes on button press in clearclusters.
function clearclusters_Callback(hObject, eventdata, handles)
% hObject    handle to clearclusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fieldremove={'colorspec1','idx','num_clusters','HeatMapData','RowLabels','SizeCluster',...
    'Ifinal','thresholdcurrent','ClusterContrib','I','Imod','ManualClusterCount','thresholdbook','threshold_count'};

for i=1:size(fieldremove,2);
    if isfield(handles,fieldremove{i})
        handles=rmfield(handles,fieldremove{i});
    end
end

handles.threshlist.String={};
handles.clustersel.Value=[];
handles.clustersel.String={};
handles.clusterplot.Value=[];
handles.clusterplot.String={};
handles.popupmenu1.Value=1;
handles.popupmenu2.Value=1;
handles.clusterfreq.String='';
handles.clusterbreakdown.Data={};
handles.clusterbreakdown2.Data={};
Y=handles.Y;
PlotClusterView(handles,Y);

guidata(hObject,handles);


% --- Executes on selection change in cvxplot.
function cvxplot_Callback(hObject, eventdata, handles)
% hObject    handle to cvxplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cvxplot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cvxplot


% --- Executes during object creation, after setting all properties.
function cvxplot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cvxplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cvyplot.
function cvyplot_Callback(hObject, eventdata, handles)
% hObject    handle to cvyplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cvyplot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cvyplot


% --- Executes during object creation, after setting all properties.
function cvyplot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cvyplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cvxscale.
function cvxscale_Callback(hObject, eventdata, handles)
% hObject    handle to cvxscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cvxscale contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cvxscale


% --- Executes during object creation, after setting all properties.
function cvxscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cvxscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cvyscale.
function cvyscale_Callback(hObject, eventdata, handles)
% hObject    handle to cvyscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cvyscale contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cvyscale


% --- Executes during object creation, after setting all properties.
function cvyscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cvyscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in assign_to_cohort.
function assign_to_cohort_Callback(hObject, eventdata, handles)
% hObject    handle to assign_to_cohort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



sel=handles.files.Value;

if isfield(handles,'cohorts')
    if sum(ismember(sel,handles.assigned))>0
        msgbox('Sample Already Assigned','Error','error');
        return
    end
    current_num=size(handles.cohorts,2);
    handles.assigned=[handles.assigned,sel];
else
    current_num=0;
    handles.assigned=sel;
end


handles.cohorts(current_num+1).index=sel;

current_string=handles.files.String;

for i=sel
    temp=current_string{i};
    temp2=strcat(num2str(current_num+1),'-',temp);
    current_string{i}=temp2;
end

handles.files.String=current_string;
guidata(hObject,handles);



% --- Executes on selection change in instrument.
function instrument_Callback(hObject, eventdata, handles)
% hObject    handle to instrument (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns instrument contents as cell array
%        contents{get(hObject,'Value')} returns selected item from instrument


% --- Executes during object creation, after setting all properties.
function instrument_CreateFcn(hObject, eventdata, handles)
% hObject    handle to instrument (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function events_per_file_Callback(hObject, eventdata, handles)
% hObject    handle to events_per_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of events_per_file as text
%        str2double(get(hObject,'String')) returns contents of events_per_file as a double


% --- Executes during object creation, after setting all properties.
function events_per_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to events_per_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in autocomp.
function autocomp_Callback(hObject, eventdata, handles)
% hObject    handle to autocomp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function perc_of_file_Callback(hObject, eventdata, handles)
% hObject    handle to perc_of_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of perc_of_file as text
%        str2double(get(hObject,'String')) returns contents of perc_of_file as a double

numcount=0;
for i=1:size(handles.num,2);
    numcount=numcount+round(size(handles.num(i).num,1)*(str2double(get(hObject,'String'))/100));
end


handles.totalevents.String=num2str(numcount);



% --- Executes during object creation, after setting all properties.
function perc_of_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to perc_of_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clear_assignments.
function clear_assignments_Callback(hObject, eventdata, handles)
% hObject    handle to clear_assignments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
handles=rmfield(handles,'cohorts');handles=rmfield(handles,'assigned');
handles.files.String=handles.filesoriginal;
catch
    return
end
guidata(hObject,handles);


% --- Executes on button press in saveworkspace.
function saveworkspace_Callback(hObject, eventdata, handles)
% hObject    handle to saveworkspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path,filetype]=uiputfile({'*.mat','MAT'});
hbox=msgbox('Saving Workspace...');
save(strcat(path,file),'handles');
close(hbox);


% --- Executes on button press in loadworkspace.
function loadworkspace_Callback(hObject, eventdata, handles)
% hObject    handle to loadworkspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path,filetype]=uigetfile({'*.mat','MAT'});
load(strcat(path,file),'handles');
currentobjects=findall(0);

n=1;
for i=1:size(currentobjects,1);
    try
    nametemp=currentobjects(i).Name;
    indx(n)=i;
    n=n+1;
    catch
        continue
    end
end

close(currentobjects(indx(end)));


% --- Executes on selection change in heatmaptsne.
function heatmaptsne_Callback(hObject, eventdata, handles)
% hObject    handle to heatmaptsne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns heatmaptsne contents as cell array
%        contents{get(hObject,'Value')} returns selected item from heatmaptsne

contents=cellstr(get(hObject,'String'));
sel=get(hObject,'Value');
Y=handles.Y;
y2=handles.transy2;
channel=y2(:,sel);

cutofftop=prctile(channel,100);
cutoffbottom=prctile(channel,0);
replace=(channel>cutofftop);
channel(replace)=cutofftop;
replace=channel<cutoffbottom;
channel(replace)=cutoffbottom;


figure('Name',contents{sel},'NumberTitle','off');
if size(Y,2)==2
    scatter(Y(:,1),Y(:,2),15,channel,'filled');
    xticks([])
    yticks([])
else
    scatter3(Y(:,1),Y(:,2),Y(:,3),5,channel,'filled');
    rotate3d on
end
colormap('jet');
title(contents(sel),'FontSize',20,'Interpreter','none')


% --- Executes during object creation, after setting all properties.
function heatmaptsne_CreateFcn(hObject, eventdata, handles)
% hObject    handle to heatmaptsne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in savetsne2.
function savetsne2_Callback(hObject, eventdata, handles)
% hObject    handle to savetsne2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



[file,path,filetype]=uiputfile({'*.bmp','BMP';'*.jpeg','JPEG';'*.png','PNG'},'Save Image As');
F=getframe(handles.cluster_view);
Image=frame2im(F);
imwrite(Image,strcat(path,file));


% --- Executes on button press in update_assignments.
function update_assignments_Callback(hObject, eventdata, handles)
% hObject    handle to update_assignments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


Y=handles.Y;
colorspec1=handles.colorspec1;

idx=handles.idx_cohort;
if isfield(handles,'cohorts')
    idxnew=zeros(size(idx,1),1);
    for i=1:size(handles.cohorts,2)
        sel=handles.cohorts(i).index;
        idxnew=idxnew+ismember(idx,sel).*i;
    end
    idx=idxnew;
end

handles.idx_cohort_new=idx;

clear colorscheme
for i=1:size(idx,1);
    colorscheme(i,:)=colorspec1(idx(i)).spec;
end

scatter(handles.tsneplot,Y(:,1),Y(:,2),[],colorscheme,'filled','MarkerFaceAlpha',0.75,'MarkerEdgeColor',[0 0 0],'MarkerEdgeAlpha',0.6);
handles.tsneplot.XTickLabel={};
handles.tsneplot.YTickLabel={};
guidata(hObject,handles);



function totalevents_Callback(hObject, eventdata, handles)
% hObject    handle to totalevents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalevents as text
%        str2double(get(hObject,'String')) returns contents of totalevents as a double


% --- Executes during object creation, after setting all properties.
function totalevents_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalevents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in clustermethods.
function clustermethods_Callback(hObject, eventdata, handles)
% hObject    handle to clustermethods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns clustermethods contents as cell array
%        contents{get(hObject,'Value')} returns selected item from clustermethods

sel=handles.clustermethods.Value;
if ismember(sel,[1 2 6 7 8])
    set(handles.clusterparameter,'String','# of Clusters');
elseif ismember(sel,[3 4])
    set(handles.clusterparameter,'String','Distance Factor');
elseif ismember(sel,[5])
    set(handles.clusterparameter,'String','k-nearest neighbors');
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function clustermethods_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clustermethods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function clusterparameter_Callback(hObject, eventdata, handles)
% hObject    handle to clusterparameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clusterparameter as text
%        str2double(get(hObject,'String')) returns contents of clusterparameter as a double


% --- Executes during object creation, after setting all properties.
function clusterparameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clusterparameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clusterbutton.
function clusterbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clusterbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


clearclusters_Callback(hObject, eventdata, handles);

Y=handles.Y;
ClusterMethod=handles.clustermethods.Value;
clusterparameter=str2num(handles.clusterparameter.String);

switch ClusterMethod

    case 1
        
        hbox=msgbox('Clustering Events...');
        num_clusters=clusterparameter;
        idx=kmeans(Y,num_clusters,'Start','uniform');
    case 2
        
        hbox=msgbox('Clustering Events...');
        num_clusters=clusterparameter;
        idx=kmeans(handles.transy,num_clusters,'Start','uniform');
    
    case 3
        hbox=msgbox('Clustering Events...');
        epsilonf=clusterparameter/100;
        D=pdist(Y);
        epsilon=(epsilonf)*median(D); %.02 default
        MinPoints=1;%(0.0001)*size(Y,1); %.0001 default
        [idx,isnoise]=DBSCAN(Y,epsilon,MinPoints);
        num_clusters=max(idx);
    case 4
        hbox=msgbox('Clustering Events...');
        dm=pdist(handles.transy);
        z=linkage(dm);
        idx=cluster(z,'cutoff',clusterparameter);
        num_clusters=max(idx);
    case 5
        NetworkGui(handles);
        waitfor(findobj('Tag','networkgui'));
        
        hbox=msgbox('Creating Graph...');
        [G,GGraph]=CreateGraph(handles.transy,clusterparameter);
        close(hbox);
        
        handles=guidata(findobj('Tag','clusterbutton'));
     
        switch handles.graphclustermethod  
            case 1      
                hbox=msgbox('Clustering Events...');
                N=length(G);
                W=PermMat(N);                     % permute the graph node labels
                A=W*G*W';
                
                [COMTY ending] = cluster_jl_cppJW(A,1);
                J=size(COMTY.COM,2);
                VV=COMTY.COM{J}';
                idx=W'*VV;      
                              
            case 2
                hbox=msgbox('Clustering Events...');
                idx=GCModulMax2(G); 
            case 3
                hbox=msgbox('Clustering Events...');
                idx=GCModulMax3(G);
            case 4
                hbox=msgbox('Clustering Events...');
                idx=GCDanon(G);
            case 5
                clusterparameter2=inputdlg('Enter # of Clusters');
                hbox=msgbox('Clustering Events...');
                clusterparameter2=str2num(clusterparameter2{1});
                idx=GCSpectralClust1(G,clusterparameter2);
                idx=idx(:,clusterparameter2);
                
        end
        num_clusters=max(idx);
    case 6
        hbox=msgbox('Clustering Events...');
        net=selforgmap([round(sqrt(clusterparameter)),round(sqrt(clusterparameter))]);
        net.trainParam.showWindow = false;
        net=train(net,transpose(handles.transy));
        idx=transpose(vec2ind(net(transpose(handles.transy))));
        num_clusters=max(idx);
    case 7
        hbox=msgbox('Clustering Events...');
        try 
         idx=transpose(mixGaussEm(transpose(handles.transy),clusterparameter));
        num_clusters=max(idx); 
        catch
            msgbox('Enter smaller # of Clusters');
        end
        
    case 8
        hbox=msgbox('Clustering Events...');
        try
        idx=transpose(mixGaussVb(transpose(handles.transy),clusterparameter));
        num_clusters=max(idx);
        catch
            msgbox('Enter smaller # of Clusters');
        end
        
        end
    close(hbox);
    
    [colorspec1,colorspec2]=CreateColorTemplate(num_clusters);
    handles.colorspec1=colorspec1;
    
    clear colorscheme
    for i=1:size(idx,1);
        colorscheme(i,:)=colorspec1(idx(i)).spec;
    end
    PlotClusterView(handles,Y,colorscheme);
 
    y=handles.transy;
    ClusterContrib=tabulate(idx);
    
    for i=1:num_clusters
        ClusterNames(i)=strcat('Cluster ',num2str(i),{' - '},num2str(ClusterContrib(i,3)),{'%'});
    end

    [HeatMapData,RowLabels,SizeCluster]=GetHeatMapData(num_clusters,idx,y,ClusterMethod,ClusterContrib);
    
    handles.clustersel.String=ClusterNames;
    handles.idx=idx; 
    handles.ClusterContrib=ClusterContrib;
    handles.num_clusters=num_clusters;
    handles.HeatMapData=HeatMapData;
    handles.RowLabels=RowLabels;
    handles.SizeCluster=SizeCluster;
    handles.I=[1:num_clusters];
    handles.Imod=handles.I;
    guidata(hObject,handles);
    datacursormode on
    dcm_obj=datacursormode(handles.cluster_view.Parent);
    set(dcm_obj,'UpdateFcn',{@myupdatefcn,idx,Y})
    %rotate3d on
    
    function NetworkGui(handles)
        
         fh = figure('units','pixels',...
                  'units','normalized',...
                  'position',[0.25 0.25 .175 .125],...
                  'menubar','none',...
                  'name','Select Graph Clustering Method',...
                  'tag','networkgui',...
                  'numbertitle','off',...
                  'resize','off');
        guidata(fh,handles);
    
              
        clusteroptions=uicontrol('Style','listbox',...
        'String',{'Modularity Max - Louvain';'Modularity Max - Fast Greedy';'Modularity Max - Newman';...
        'Danon Method';'Spectral Clustering'},...
        'units','normalized',...
        'Position',[.1,.3,0.8,0.6],...
        'Tag','graphclusteropt');
    
        selectbutton=uicontrol('Style','pushbutton',...
            'String','Select',...
            'units','normalized',...
            'Position',[0.75,.1,.2,0.2],...
            'Tag','selectgraphcluster',...
            'Callback',@selectgraphcluster);
        
        function selectgraphcluster(hObject, eventdata)
            temp=findobj('Tag','graphclusteropt');
            clustergraphmethod=temp.Value;
            handles=guidata(hObject);
            handles.graphclustermethod=clustergraphmethod;
            guidata(findobj('Tag','clusterbutton'),handles);
            closereq;


function handles=popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

handles=SortClusters(handles);
handles=ApplyCurrentThresh(handles);
handles=ClusterCut(handles);
PlotSelectClusters(handles);
guidata(hObject,handles);

function handles=SortClusters(handles)
    
    HeatMapData=handles.HeatMapData;
    ListC=[1:size(HeatMapData,1)];
    clear HeatMapData
    
    for j=ListC;
        clusterselect=handles.idx==j;
        SizeCluster(j)=sum(clusterselect);
        clusterselect2=handles.transy2(clusterselect,:);
        if size(clusterselect2,1)==1
            HeatMapData(j,:)=clusterselect2;
        else
            HeatMapData(j,:)=median(clusterselect2); 
        end
    end
    
    channelsel=handles.popupmenu1.Value;
    ClusterContrib=handles.ClusterContrib;
    channelselstring=handles.ChannelsAll{channelsel};
    valsort=strmatch(channelselstring,handles.ChannelsAll,'exact');
    I=handles.I;


    if handles.sortbutton.Value==0
        [B,I2]=sortrows(HeatMapData,-valsort);
    else
        [B,I2]=sortrows(HeatMapData,valsort);
    end

    I2=transpose(intersect(I2,I,'stable'));
    I=I2;

    sortedlist=cell(1,size(I,2));
    for i=1:size(I,2);
        sortedlist(i)=strcat({'Cluster '},num2str(I(i)),{' - '},num2str(ClusterContrib(I(i),3)),{'%'});
    end

    handles.clustersel.Value=[];    
    handles.clustersel.String=sortedlist;
    handles.Imod=I;

function handles=ApplyCurrentThresh(handles)

if isfield(handles,'thresholdbook')
    thresholdbook=handles.thresholdbook;
    HeatMapData=handles.HeatMapData;

    for i=1:size(thresholdbook,2);
        threshold_indx(i)=strmatch(thresholdbook(i).Channel,handles.ChannelsAll,'exact');
        threshold_dir{i}=thresholdbook(i).direction;
        threshold_val(i)=thresholdbook(i).threshold;
    end

    ListC=[1:size(HeatMapData,1)];
    clear HeatMapData
    thresh_cut_ind=ListC;
    
    for j=ListC;
            clusterselect=handles.idx==j;
            SizeCluster(j)=sum(clusterselect);
            clusterselect2=handles.transy2(clusterselect,:);
            if size(clusterselect2,1)==1
                HeatMapData(j,:)=clusterselect2;
            else
                HeatMapData(j,:)=median(clusterselect2); 
            end
    end
    
    for i=1:size(threshold_indx,2);
            thresh_cut=HeatMapData(:,threshold_indx(i));
            eval(['thresh_cut=thresh_cut' threshold_dir{i} 'threshold_val(i);'])
            thresh_cut_ind=intersect(ListC(thresh_cut),thresh_cut_ind);
    end

    I=handles.Imod;
    I=intersect(I,thresh_cut_ind,'stable');
    sortedlist=cell(1,size(I,2));
    for i=1:size(I,2);
        sortedlist(i)=strcat({'Cluster '},num2str(I(i)),{' - '},num2str(handles.ClusterContrib(I(i),3)),{'%'});
    end

    handles.clustersel.Value=[];
    handles.clustersel.String=sortedlist;
    handles.Imod=I;
end

function handles=ClusterCut(handles)
    SizeCluster=handles.SizeCluster;
    ClusterContrib=handles.ClusterContrib;
    I=handles.Imod;
    cut=str2num(handles.clusterfreq.String)/100;
    if isempty(cut);
        cut=0;
    end
    FreqCluster=SizeCluster./size(handles.y,1);
    Keep=(FreqCluster>cut).*[1:size(FreqCluster,2)];
    Keep(Keep==0)=[];
    I=intersect(I,Keep,'stable');
    handles.Imod=I;

    if ~isempty(I)
        for i=1:size(I,2);
        sortedlist(i)=strcat({'Cluster '},num2str(I(i)),{' - '},num2str(ClusterContrib(I(i),3)),{'%'});
        end
    end

    if ~exist('sortedlist')
        sortedlist={};
    end

    handles.clustersel.Value=[];
    handles.clustersel.String=sortedlist;
    PlotSelectClusters(handles);

    function PlotSelectClusters(handles)
    Imod=handles.Imod;
    I=handles.I;
    idx=handles.idx;
    colorspec1=handles.colorspec1;
    Y=handles.Y;
    
    if isfield(handles,'ManualClusterCount');
         Ybase=Y(idx==0,:);
         scatter(handles.cluster_view,Ybase(:,1),Ybase(:,2),'filled');
         hold(handles.cluster_view);
         Y=Y(idx>0,:);
         idx=idx(idx>0);
         
         selidx=ismember(idx,Imod);
         
         
         clear colorscheme
         for i=1:size(idx,1);
            colorscheme(i,:)=colorspec1(idx(i)).spec;
         end
         
       
        YNL=Y(~selidx,:);
        colorschemeNL=colorscheme(~selidx,:);
        scatter(handles.cluster_view,YNL(:,1),YNL(:,2),[],colorschemeNL,'filled','MarkerFaceAlpha',0.05);
        YHL=Y(selidx,:);
        colorschemeHL=colorscheme(selidx,:);
        scatter(handles.cluster_view,YHL(:,1),YHL(:,2),[],colorschemeHL,'filled');
        handles.cluster_view.XLim=handles.tsne_xlim;
        handles.cluster_view.YLim=handles.tsne_ylim;
        handles.cluster_view.XTickLabel={};
        handles.cluster_view.YTickLabel={};
        
        hold(handles.cluster_view);
        
    else

        clear colorscheme
        for i=1:size(idx,1);
            colorscheme(i,:)=colorspec1(idx(i)).spec;
        end

        selclusteridx=ismember(idx,Imod);
        YHL=Y(selclusteridx,:);
        colorschemeHL=colorscheme(selclusteridx,:);
        scatter(handles.cluster_view,YHL(:,1),YHL(:,2),[],colorschemeHL,'filled');
        hold(handles.cluster_view);
        YNL=Y(~selclusteridx,:);
        colorschemeNL=colorscheme(~selclusteridx,:);
        scatter(handles.cluster_view,YNL(:,1),YNL(:,2),[],colorschemeNL,'filled','MarkerFaceAlpha',0.05);
       
        handles.cluster_view.XTickLabel={};
        handles.cluster_view.YTickLabel={};
        handles.cluster_view.XLim=handles.tsne_xlim;
        handles.cluster_view.YLim=handles.tsne_ylim;
        hold(handles.cluster_view);
    
    end



% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2

contents=cellstr(get(hObject,'String'));
Value=contents{get(hObject,'Value')};
gui_pop(handles,Value);


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gui_pop(handles,Value)
    positiongui=handles.figure1.Parent.PointerLocation;
    
    fh = figure('units','pixels',...
                  'units','normalized',...
                  'position',[0.25 0.25 .3 .6],...
                  'menubar','none',...
                  'name','Define Threshold',...
                  'numbertitle','off',...
                  'resize','off');
              
    guidata(fh,handles);
    
    handles.Value=Value;

    h=axes('Parent',fh,'Position',[0.05 0.1 0.55 0.8]);
    h.XTickLabel={};
    h.YTickLabel={};
    handles.h=h;

    sld = uicontrol('Parent',fh,'Style','slider',...
            'Min',0,'Max',1,'Value',0.5,...
            'units','normalized',...
            'Position', [0.65 0.1 0.05 0.8],...
            'Callback', @slider,...
            'Tag','slider1'); 
        
    handles.sld=sld;

    thresholdval=uicontrol('Parent',fh,'Style','edit',...
        'String','Threshold Value',...
        'units','normalized',...
        'Position',[.1,.03,0.2,0.05],...
        'Callback',@thresholdvaluetag,...
        'Tag','thresholdvalue');
    
    handles.thresholdval=thresholdval;

    yscalelocvar=uicontrol('Style','pop',...
        'String',{'arcsinh';'linear'},...
        'units','normalized',...
        'Position',[.4,0.03,0.2,0.05],...
        'Tag','yscale',...
        'Callback',@yscaleloc);
    
    handles.yscaleloc=yscalelocvar;
    
    addabovevar=uicontrol('Style','push',...
        'String','Add Above Threshold',...
        'units','normalized',...
        'Position',[0.75,.65,.2,.1],...
        'Tag','addabove',...
        'Callback',@addabove);
    
    handles.addabove=addabovevar;
    
    addbelowvar=uicontrol('Style','push',...
    'String','Add Below Threshold',...
    'units','normalized',...
    'Position',[.75,.45,0.2,0.1],...
    'Tag','addbelow',...
    'Callback',@addbelow);

    handles.addbelow=addbelowvar;

    title=uicontrol('Style','text',...
        'String',handles.popupmenu2.String{handles.popupmenu2.Value},...
        'units','normalized',...
        'Position',[.225,.925,0.2,0.05],...
        'FontSize',16);
    
    y=handles.y2;
    ytrans=handles.transy2;
    if handles.yscaleloc.Value==1
        %clusterselect2=subplus(log10(subplus(clusterselect2)));
        clusterselect2=ytrans;
    else
        clusterselect2=y;
    end
    r=normrnd(1,0.15,size(clusterselect2,1),1);
    index=strmatch(Value,handles.ChannelsAll,'exact');
    axes(h);
    dscatter(r,clusterselect2(:,index));
    h.XTickLabel={};
    h.XLim=[0,2];
    dataquery=clusterselect2(:,index);
    h.YLim=[prctile(dataquery,0),prctile(dataquery,100)];
    guidata(fh,handles);

    
function thresholdvaluetag(hObject, eventdata)
    % hObject    handle to thresholdvaluetag (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of thresholdvaluetag as text
    %        str2double(get(hObject,'String')) returns contents of thresholdvaluetag as a double
    handles=guidata(hObject);
    if isfield(handles,'line')
        delete(handles.line);
    end
    linepos=str2num(get(hObject,'String'));
    h=imline(handles.h,[-10 10],[linepos linepos]);
    handles.line=h;
    handles.sld.Value=linepos/5;
    guidata(hObject,handles);

function slider(hObject, eventdata)
    % hObject    handle to slider3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    handles=guidata(hObject);
    if isfield(handles,'line')
        delete(handles.line);
    end
    index=strmatch(handles.Value,handles.ChannelsAll,'exact');
    
    if handles.yscaleloc.Value==1
        dataquery=handles.transy2(:,index);
        up=prctile(dataquery,100);
        down=prctile(dataquery,0);
        factor=(up-down);
        linepos=get(hObject,'Value')*factor+down;
    else
        dataquery=handles.y2(:,index);
        up=prctile(dataquery,100);
        down=prctile(dataquery,0);
        factor=(up-down);
        linepos=get(hObject,'Value')*factor+down;
    end
    
    h=imline(handles.h,[-10 10],[linepos linepos]);
    handles.line=h;
    hpos=getPosition(h);
    if handles.yscaleloc.Value==1
        handles.thresholdcurrent=hpos(1,2);
    else
        handles.thresholdcurrent=hpos(1,2);
    end
    handles.thresholdval.String=num2str(handles.thresholdcurrent);
    guidata(hObject,handles);

function yscaleloc(hObject,eventdata)
        handles=guidata(hObject);
        ytrans=handles.transy2;
        ylin=handles.y2;
        if get(hObject,'Value')==1
            clusterselect2=ytrans;
        else
            clusterselect2=ylin;
        end
        r=normrnd(1,0.15,size(clusterselect2,1),1);
        index=strmatch(handles.Value,handles.ChannelsAll,'exact');
        axes(handles.h);
        dscatter(r,clusterselect2(:,index));
        handles.h.XTickLabel={};
        handles.h.XLim=[0,2];
        dataquery=clusterselect2(:,index);
        handles.h.YLim=[prctile(dataquery,0),prctile(dataquery,100)];
        guidata(hObject,handles);
        
    function addabove(hObject,eventdata)
        handles=guidata(hObject);
        handles=SortClusters(handles);
        thresholdvalue=str2num(handles.thresholdval.String);
        channelselstring=handles.Value;

        if ~isfield(handles,'threshold_count')
            handles.thresholdbook(1).Channel=channelselstring;
            handles.thresholdbook(1).threshold=thresholdvalue;
            handles.thresholdbook(1).direction='>';
            handles.threshlist.String=strcat(channelselstring,{' , '},num2str(thresholdvalue),{' , '},'>');
            handles.threshold_count=1;
        else
            currentlist=handles.threshlist.String;
            count=handles.threshold_count;
            handles.thresholdbook(count+1).Channel=channelselstring;
            handles.thresholdbook(count+1).threshold=thresholdvalue;
            handles.thresholdbook(count+1).direction='>';
            currentlist=[currentlist;strcat(channelselstring,{' , '},num2str(thresholdvalue),{' , '},'>')];
            handles.threshlist.String=currentlist;
            handles.threshold_count=count+1;
        end
        handles=ApplyCurrentThresh(handles);
        handles=ClusterCut(handles);
        guidata(findobj('Tag','popupmenu2'),handles);
        closereq
        
    function addbelow(hObject,eventdata)
        handles=guidata(hObject);
        handles=SortClusters(handles);
        thresholdvalue=str2num(handles.thresholdval.String);
        channelselstring=handles.Value;

        if ~isfield(handles,'threshold_count')
            handles.thresholdbook(1).Channel=channelselstring;
            handles.thresholdbook(1).threshold=thresholdvalue;
            handles.thresholdbook(1).direction='<';
            handles.threshlist.String=strcat(channelselstring,{' , '},num2str(thresholdvalue),{' , '},'<');
            handles.threshold_count=1;
        else
            currentlist=handles.threshlist.String;
            count=handles.threshold_count;
            handles.thresholdbook(count+1).Channel=channelselstring;
            handles.thresholdbook(count+1).threshold=thresholdvalue;
            handles.thresholdbook(count+1).direction='<';
            currentlist=[currentlist;strcat(channelselstring,{' , '},num2str(thresholdvalue),{' , '},'<')];
            handles.threshlist.String=currentlist;
            handles.threshold_count=count+1;
        end
        handles=ApplyCurrentThresh(handles);
        handles=ClusterCut(handles);
        guidata(findobj('Tag','popupmenu2'),handles);
        closereq




function clusterfreq_Callback(hObject, eventdata, handles)
% hObject    handle to clusterfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clusterfreq as text
%        str2double(get(hObject,'String')) returns contents of clusterfreq as a double

handles=SortClusters(handles);
handles=ApplyCurrentThresh(handles);
handles=ClusterCut(handles);
PlotSelectClusters(handles)
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function clusterfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clusterfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in clearthresh.
function clearthresh_Callback(hObject, eventdata, handles)
% hObject    handle to clearthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'thresholdbook')
    handles=rmfield(handles,'thresholdbook');
    handles=rmfield(handles,'threshold_count');
end
handles.threshlist.Value=[1];
handles.threshlist.String=[];
handles.I=[1:handles.num_clusters];
guidata(hObject,handles);
popupmenu1_Callback(hObject, eventdata, handles)


% --- Executes on button press in sortbutton.
function sortbutton_Callback(hObject, eventdata, handles)
% hObject    handle to sortbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sortbutton

if get(hObject,'Value')
    handles.sortbutton.String='Ascending';
else
    handles.sortbutton.String='Descending';
end

popupmenu1_Callback(hObject, eventdata, handles);


% --- Executes on button press in heatmapind.
function heatmapind_Callback(hObject, eventdata, handles)
% hObject    handle to heatmapind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ChannelsOut=handles.ChannelsAll(handles.channel_select);
y=handles.transy;
hbox=msgbox('Calculating HeatMap...');
PlotHeatMap(y,[],ChannelsOut);
close(hbox);


% --- Executes on button press in HeatMapClusters.
function HeatMapClusters_Callback(hObject, eventdata, handles)
% hObject    handle to HeatMapClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    

if ~isfield(handles,'ManualClusterCount')
    ChannelsOut=handles.ChannelsOut;
    RowLabels=handles.RowLabels;
    HeatMapData=handles.HeatMapData;
    idx=handles.idx;
    y=handles.transy;
    
    
    select=handles.clusterplot.Value;
    if isfield(handles,'Ifinal')
        I=handles.Ifinal(select);
        if size(I,2)==2
            ChannelsOut=DetermineSigChannels(I,y,idx,ChannelsOut);
        end
        HeatMapData=HeatMapData(I,:);
        RowLabels=I;
    end
    
    hmobj=PlotHeatMap(HeatMapData,RowLabels,ChannelsOut);
    else
    ChannelsOut=handles.ChannelsOut;
    idx=handles.idx;
    ClusterIter=[1:max(idx)];
    y=handles.transy;
    
    for j=ClusterIter
            clusterselect=idx==j;
            SizeCluster(j)=sum(clusterselect);
            clusterselect2=y(clusterselect,:);
            HeatMapData(j,:)=median(clusterselect2); 
            RowLabels{j}=strcat('Cluster ',num2str(j),' = ',num2str(100*(SizeCluster(j)/size(y,1))),'%');
    end
    

    PlotHeatMap(HeatMapData,RowLabels,ChannelsOut);
    handles.HeatMapData=HeatMapData;
    handles.RowLabels=RowLabels;
    ClusterContrib=tabulate(idx);
    if ClusterContrib(1,1)==0
        ClusterContrib=ClusterContrib(2:end,:);
    end
    handles.SizeCluster=SizeCluster;
    handles.ClusterContrib=ClusterContrib;
    handles.I=ClusterIter;
    handles.num_clusters=max(idx);
    guidata(hObject,handles);
    
    
end
    
    


% --- Executes on selection change in threshlist.
function threshlist_Callback(hObject, eventdata, handles)
% hObject    handle to threshlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns threshlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from threshlist


% --- Executes during object creation, after setting all properties.
function threshlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cluster_stat.
function cluster_stat_Callback(hObject, eventdata, handles)
% hObject    handle to cluster_stat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    StatisticalToolBox(handles);

   


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in gatevis.
function gatevis_Callback(hObject, eventdata, handles)
% hObject    handle to gatevis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if size(handles.Y,2)>2
    msgbox('You cannot gate 3D data. Redo t-SNE or Diffusion Map in 2D before gating');
    return
end


dcm_obj=datacursormode(handles.cluster_view.Parent);
set(dcm_obj,'Enable','off');
rotate3d off

sel=selectdata('Axes',handles.cluster_view,'SelectionMode','Lasso','Verify','on');
if iscell(sel)
    sel=sel{end};
end

if isfield(handles,'Imod');
    Imod=handles.Imod;
    idx=handles.idx;
    selclusteridx=ismember(idx,Imod);
    selclusteridx=find(selclusteridx);
    sel2=selclusteridx(sel);
    sel=sel2;
end

handles.y2=handles.y2(sel,:);
handles.y=handles.y(sel,:);
handles.transy2=handles.transy2(sel,:);
handles.transy=handles.transy(sel,:);
handles.idx_cohort_new=handles.idx_cohort_new(sel);
handles.idx_cohort=handles.idx_cohort(sel);
handles.redo=1;

handles.num_samples=size(handles.y,1);
handles.totalevents.String=num2str(handles.num_samples);

choice = questdlg('What type of dimensionality reduction apply?','DMTechnique','t-SNE','Diffusion Map','t-SNE');

switch choice
    case 't-SNE'
        tsne_Callback(hObject, eventdata, handles);
    case 'Diffusion Map'
        diffusionmap_Callback(hObject, eventdata, handles)
end

guidata(hObject,handles);


