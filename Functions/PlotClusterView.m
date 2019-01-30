function PlotClusterView(handles,Y,colorscheme);

if ~exist('colorscheme')
    colorscheme=[0,0.447000000000000,0.741000000000000];
end

if handles.radiobutton1.Value==0
    scatter(handles.cluster_view,Y(:,1),Y(:,2),15,colorscheme,'filled');
    handles.cluster_view.XTickLabel={};
    handles.cluster_view.YTickLabel={};
else
    scatter3(handles.cluster_view,Y(:,1),Y(:,2),Y(:,3),15,colorscheme,'filled');
    handles.cluster_view.XTickLabel={};
    handles.cluster_view.YTickLabel={};
    handles.cluster_view.ZTickLabel={};
    rotate3d on
end


end