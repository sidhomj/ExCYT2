function ChannelsOut=DetermineSigChannels(I,y,idx,ChannelsOut);
        
        cluster1=idx==I(1);
        cluster1=y(cluster1,:);
        
        cluster2=idx==I(2);
        cluster2=y(cluster2,:);
        
        n=1;
        for j=1:size(y,2)
            %[h,p]=ttest2(cluster1(:,j),cluster2(:,j));
            [p,h]=ranksum(cluster1(:,j),cluster2(:,j));
            pval(j)=p;   
        end
        
        
        Q = mafdr(pval,'BHFDR',true);
        
        for j=1:size(y,2)
             if Q(j)<0.05 && Q(j)>=0.01
                    temp=ChannelsOut{j};
                    temp=strcat(temp,'*');
                    ChannelsOut{j}=temp;
             elseif Q(j)<0.01 && Q(j)>=0.001
                 temp=ChannelsOut{j};
                 temp=strcat(temp,'**');
                 ChannelsOut{j}=temp;
             elseif Q(j)<0.001
                 temp=ChannelsOut{j};
                 temp=strcat(temp,'***');
                 ChannelsOut{j}=temp;
             end
        end