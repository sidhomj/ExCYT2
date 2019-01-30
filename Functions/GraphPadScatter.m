function GraphPadScatter(X,Labels);

%Change structure field name to val (allows for any structure field name to
%be input into the function
fieldname=fieldnames(X);
fieldnameold=fieldname{1};
v = struct2cell(X);
fieldname{strmatch(fieldnameold,fieldname,'exact')} = 'val';
X = cell2struct(v,fieldname);

figure
for i=1:size(X,2)
    r=normrnd(i,0.0,size(X(i).val,1),1);
    scatter(r,X(i).val,'filled');
    hold on;
end
xlim([0 size(X,2)+1]);

Labels=[{''},Labels,{''}];
xticklabels(Labels);
xtickangle(45);

hold off;


end