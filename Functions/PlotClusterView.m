function PlotClusterView(handles,Y,colorscheme);

if ~exist('colorscheme')
    colorscheme=[0,0.447000000000000,0.741000000000000];
end

scatter(handles.cluster_view,Y(:,1),Y(:,2),15,colorscheme,'filled');
handles.cluster_view.XTickLabel={};
handles.cluster_view.YTickLabel={};

end