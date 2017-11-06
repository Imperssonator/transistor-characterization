function [all_mob, avg_mob] = do_the_mob(Folder)

% Open folder and build directory of csv files
ad=pwd;
cd(Folder)
all_mob=dir('*.csv');
cd(ad)

% Calculate mobility, threshold voltage and extract sweep data for each
% file
for i = 1:length(all_mob)
[mob, VT, vg_mat, id_mat, fit_fun]=calcMobCSV([Folder,all_mob(i).name]);
all_mob(i).mob = mob;
all_mob(i).vt=VT;
all_mob(i).vg=vg_mat;
all_mob(i).id=id_mat;
all_mob(i).fit=fit_fun;
end

% Make a list of the unique device names, including horizontal and vertical
% channels
[name_list,unique_starts,unique_map]=...    % Find the unique chips
    unique( cellfun(@(x) x(1:end-5),...     % Assumes name ends in 'H1.csv', for example
                    {all_mob(:).name},...
                    'UniformOutput',false...
                    )...
          );

avg_mob = struct();

for i = 1:length(name_list)
    channels = all_mob(unique_map==i);
    avg_mob(i).name = name_list{i};
    avg_mob(i).mean_mob = mean([channels(:).mob]);
    avg_mob(i).std_mob = std([channels(:).mob]);
    avg_mob(i).mean_vt = mean([channels(:).vt]);
    avg_mob(i).std_vt = std([channels(:).vt]);
end
    
end