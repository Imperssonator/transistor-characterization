function [DD,ax] = mobility_map_fig(DD,max_mob)

MM = zeros(8,8);
VT_mat = zeros(8,8);
para_mob = []; perp_mob = [];

for i = 1:length(DD)
    
    if DD(i).good
        MM(DD(i).ChanRow,DD(i).ChanCol) = DD(i).mob;
        VT_mat(DD(i).ChanRow,DD(i).ChanCol) = DD(i).vt;
        if ismember(DD(i).ChanLetter,['B','D','F','H'])
            para_mob = [para_mob, DD(i).mob];
        else
            perp_mob = [perp_mob, DD(i).mob];
        end
    else
        MM(DD(i).ChanRow,DD(i).ChanCol) = 0;
        VT_mat(DD(i).ChanRow,DD(i).ChanCol) = 0;
    end
    
end

% Check for colorbar scale

if exist('max_mob')~=1
    max_mob = max(max(MM));
end
max_vt = max(max(VT_mat));

% Generate Heat Map

f1=figure;
ax=gca;
imagesc(MM,[0 max_mob]);

colorbar()
ax.YDir='reverse';
ax.Visible='off';
ax.FontSize=14;
f1.Position=[392.2000 510.6000 549.6000 480];

f2=figure;
ax2=gca;
imagesc(VT_mat,[0 50]);

colorbar()
ax2.YDir='reverse';
ax2.Visible='off';
ax2.FontSize=14;
f2.Position=[941 510.6000 549.6000 480];

figure;
histogram(para_mob,5);
figure;
histogram(perp_mob,5);

figure;
hold on
bar([mean(para_mob),mean(perp_mob)])
errorbar([mean(para_mob),mean(perp_mob)],[std(para_mob),std(perp_mob)],'.')

MM_perp = MM(:,1:2:end);
MM_para = MM(:,2:2:end);

