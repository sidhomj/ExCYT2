function StatisticalToolBox(handles)

    I=handles.Ifinal;
    for i=1:size(handles.cohorts,2);
        CohortNames(i)=strcat({'Cohort '}, num2str(i));
    end
    
    fh = figure('units','pixels',...
                  'units','normalized',...
                  'position',[0.25 0.25 .3 .6],...
                  'menubar','none',...
                  'name','Statistical Tests',...
                  'numbertitle','off',...
                  'resize','off','Tag','stat_figure_window');
              
    guidata(fh,handles);
    

    cohortlist = uicontrol('Parent',fh,'Style','listbox',...
            'Value',1,...
            'units','normalized',...
            'String',CohortNames,...
            'Position', [0.1 0.50 0.3 0.35],...
            'Tag','cohortlist',...
            'Max',10^8,'Min',1); 
        
    cohortname=uicontrol('Parent',fh,'Style','text',...
        'units','normalized',...
        'Position',[0.075 0.85 0.3 0.1],...
        'String','Select Cohorts to Compare');
    
    select=uicontrol('Parent',fh,'Style','pushbutton',...
        'String','Select-->',...
        'units','normalized',...
        'Position',[0.4,0.65,0.2,0.05],...
        'Callback',@selectbutton,...
        'Tag','selectbutton');
    
    remove=uicontrol('Parent',fh,'Style','pushbutton',...
        'String','<--Remove',...
        'units','normalized',...
        'Position',[0.4,0.6,0.2,0.05],...
        'Callback',@removebutton,...
        'Tag','removebutton');
    
    cohortlist2 = uicontrol('Parent',fh,'Style','listbox',...
            'Value',[],...
            'units','normalized',...
            'Position', [0.6 0.50 0.3 0.35],...
            'Tag','cohortlist2',...
            'Max',10^8,'Min',1); 
        
    stat_test=uicontrol('Parent',fh,'Style','popupmenu',...
        'Value',1,...
        'units','normalized',...
        'Position',[0.35,0.45,0.30,0.05],...
        'Tag','stat_test_list',...
        'String',{'t-test','Mann-Whitney','Ordinal Regression'});
    
    analyze=uicontrol('Parent',fh,'Style','pushbutton',...
        'units','normalized',...
        'Position',[0.35,0.4,0.3,0.05],...
        'Tag','analyze_button',...
        'String','Analyze',...
        'Callback',@analyze_button); 
    
    results=uitable('Parent',fh,...
        'units','normalized',...
        'Position',[0.1,0.1,0.8,0.3],...
        'Tag','results_table');
    
    makegraphvar=uicontrol('Parent',fh,'Style','pushbutton',...
        'units','normalized',...
        'Position',[0.6 0.05, 0.3, 0.05],...
        'Tag','make_graph',...
        'Callback',@makegraph,...
        'String','Plot Data');
    
    
end
    
    function selectbutton(hObject,eventdata)
        sel=findobj('Tag','cohortlist');
        cohort2=findobj('Tag','cohortlist2');
        for i=1:size(sel.Value,2);
            cohort_add(i)=strcat({'Cohort '},num2str(sel.Value(i)));
        end
        cohort_add=transpose(cohort_add);
        
        if isempty(cohort2.String);
            cohort2.String=cohort_add;
        else
            cohort2.String=[cohort2.String;cohort_add];
        end      
    end
    
    function removebutton(hObject,eventdata)
        sel=findobj('Tag','cohortlist');
        cohort2=findobj('Tag','cohortlist2');
        removesel=cohort2.Value;
        cohort2.Value=[];
        cohort2.String=cohort2.String(setdiff(1:end,removesel));
        
    end
    
    function analyze_button(hObject,eventdata)
    test_sel=findobj('Tag','stat_test_list');
    test_sel=test_sel.Value;
    cohort_list=findobj('Tag','cohortlist2');
    cohort_list=cohort_list.String;
    handles=findobj('Tag','stat_figure_window');
    handles=guidata(handles);
    
    
    switch test_sel
        
        case 1
            if size(cohort_list,1) ~= 2
                msgbox('Only 2 Cohorts Can Be Analyzed by t-test','Error','error');
                return
            end
            
            I=handles.Ifinal;
            sel=handles.clusterplot.Value;
            I=I(sel);
            
             if ~isempty(I)
                maxconditions=max(handles.idx_cohort);
                ClusterNames={};
                for i=1:size(I,2)
                    incluster=handles.idx==I(i);
                    sample=handles.idx_cohort(incluster);
                    table_sample=tabulate(sample);
                    clear table_out
                    for j=1:maxconditions 
                            try
                                table_out(j)=100*(table_sample(j,2)/sum(handles.idx_cohort==j));
                            catch
                                table_out(j)=0;
                            end
                    end

                    table_out=transpose(table_out);
                    groups=size(cohort_list,1);
                    X=[];
                    Y=[];
                    for j=1:groups
                        cohort_sel=cohort_list{j};
                        cohort_sel=strsplit(cohort_sel,' ');
                        cohort_sel=str2num(cohort_sel{2});
                        sel=handles.cohorts(cohort_sel).index;
                        table_sel=table_out(sel);
                        if j==1
                            X1=table_sel;
                        else
                            X2=table_sel;
                        end
                    end
                    
                    [h,p,ci,stats] = ttest2(X1,X2);
                    PVal(i)=p;   
                    ClusterNames=[ClusterNames; strcat({'Cluster '},num2str(I(i)))];
                end
            else
                return
             end
            
             DataWrite=[ClusterNames,num2cell(transpose(PVal))];
            
            results_table=findobj('Tag','results_table');
            results_table.Data=DataWrite;

            
        case 2
             if size(cohort_list,1) ~= 2
                msgbox('Only 2 Cohorts Can Be Analyzed by Mann-Whitney','Error','error');
                return
            end
            
            I=handles.Ifinal;
            sel=handles.clusterplot.Value;
            I=I(sel);
            
             if ~isempty(I)
                maxconditions=max(handles.idx_cohort);
                ClusterNames={};
                for i=1:size(I,2)
                    incluster=handles.idx==I(i);
                    sample=handles.idx_cohort(incluster);
                    table_sample=tabulate(sample);
                    clear table_out
                    for j=1:maxconditions 
                            try
                                table_out(j)=100*(table_sample(j,2)/sum(handles.idx_cohort==j));
                            catch
                                table_out(j)=0;
                            end
                    end

                    table_out=transpose(table_out);
                    groups=size(cohort_list,1);
                    X=[];
                    Y=[];
                    for j=1:groups
                        cohort_sel=cohort_list{j};
                        cohort_sel=strsplit(cohort_sel,' ');
                        cohort_sel=str2num(cohort_sel{2});
                        sel=handles.cohorts(cohort_sel).index;
                        table_sel=table_out(sel);
                        if j==1
                            X1=table_sel;
                        else
                            X2=table_sel;
                        end
                    end
                    
                    p = ranksum(X1,X2);
                    PVal(i)=p;   
                    ClusterNames=[ClusterNames; strcat({'Cluster '},num2str(I(i)))];
                end
            else
                return
             end
            
             DataWrite=[ClusterNames,num2cell(transpose(PVal))];
            
            results_table=findobj('Tag','results_table');
            results_table.Data=DataWrite;
    
        case 3
            I=handles.Ifinal;
            sel=handles.clusterplot.Value;
            I=I(sel);
            
            
            if ~isempty(I)
                maxconditions=max(handles.idx_cohort);
                ClusterNames={};
                for i=1:size(I,2)
                    incluster=handles.idx==I(i);
                    sample=handles.idx_cohort(incluster);
                    table_sample=tabulate(sample);
                    clear table_out
                    for j=1:maxconditions 
                            try
                                table_out(j)=100*(table_sample(j,2)/sum(handles.idx_cohort==j));
                            catch
                                table_out(j)=0;
                            end
                    end

                    table_out=transpose(table_out);
                    groups=size(cohort_list,1);
                    X=[];
                    Y=[];
                    for j=1:groups
                        cohort_sel=cohort_list{j};
                        cohort_sel=strsplit(cohort_sel,' ');
                        cohort_sel=str2num(cohort_sel{2});
                        sel=handles.cohorts(cohort_sel).index;
                        table_sel=table_out(sel);
                        X=[X;table_sel];
                        Y=[Y;j*ones(size(table_sel,1),1)];  
                    end

                    Y=ordinal(Y);
                    [B,dev,stats]=mnrfit(X,Y,'model','ordinal');
                    PVal(i)=stats.p(end);   
                    ClusterNames=[ClusterNames; strcat({'Cluster '},num2str(I(i)))];
                    
                    mdl=fitlm(double(Y),X);
                    if mdl.Coefficients{2,1}>0;
                        Direction{i}='up';
                    else
                        Direction{i}='down';
                    end
                    
                end
            else
                return
            end
            
            DataWrite=[ClusterNames,num2cell(transpose(PVal)),transpose(Direction)];
            
            results_table=findobj('Tag','results_table');
            results_table.Data=DataWrite;
            javaaddpath('tablefilter-swing-java5-4.2.0-sources.jar');
            results_tablej=findjobj(results_table);
            results_tablej=results_tablej.getViewport.getView;
            filter=net.coderazzi.filters.gui.TableFilterHeader(results_tablej)
            
            
    end
    
    
    end
    
    function makegraph(hObject,eventdata)
        %cluster_sel=findobj('Tag','results_table');
        cluster_num=inputdlg('Enter Cluster You Want to Visualize');
        cluster_num=str2num(cluster_num{1});
        handles=findobj('Tag','stat_figure_window');
        handles=guidata(handles);
        cohort_list=findobj('Tag','cohortlist2');
        cohort_list=cohort_list.String;
        
        maxconditions=max(handles.idx_cohort);
        incluster=handles.idx==cluster_num;
        sample=handles.idx_cohort(incluster);
        table_sample=tabulate(sample);
        clear table_out
        for j=1:maxconditions 
                try
                    table_out(j)=100*(table_sample(j,2)/sum(handles.idx_cohort==j));
                catch
                    table_out(j)=0;
                end
        end

        table_out=transpose(table_out);
        groups=size(cohort_list,1);
        X=[];
        Y=[];
        for j=1:groups
            cohort_sel=cohort_list{j};
            cohort_sel=strsplit(cohort_sel,' ');
            cohort_sel=str2num(cohort_sel{2});
            sel=handles.cohorts(cohort_sel).index;
            table_sel=table_out(sel);
            X(j).values=table_sel;
        end
        
        GraphPadScatter(X,transpose(cohort_list));
        
    
    end
    
    
