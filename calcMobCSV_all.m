function [mob, VT, iter_map, vg_mat, id_mat, reg] = calcMobCSV_all(filePath)

% --------------
% Hard coded device parameters

Cap = 1.15E-8;
L = 50;
W = 2000;

% --------------

% Open file and read to a cell array
fid = fopen(filePath);
c = textscan(fid,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s','delimiter',',');
CC = cell(length(c{1}),size(c,2));

for i = 1:7
    CC(:,i) = c{i};
end


% make a map of where each sweep starts (IterationIndex + 140)
token = 'TestRecord.IterationIndex';
iter_inds = cellfun(@(str) strcmp(str,token),CC(:,2),'UniformOutput',false);
iter_inds_bin = cell2mat(iter_inds);
vals = CC(:,3);
iter_vals = vals(iter_inds_bin);
iter_vals = cellfun(@(x) str2num(x),iter_vals);
iter_map = [find(iter_inds_bin),iter_vals];
iter_map = iter_map(1:2:end,:);
iter_map = flipud(iter_map);

iter_map(:,1) = iter_map(:,1)+140;


% Find the column that contains VG/Idrain
id_find = cell2mat(cellfun(@(str) strcmp(str,'Idrain'),CC(iter_map(1,1)-1,:),'UniformOutput',false));
[~,id_col] = find(id_find,1);
vg_find = cell2mat(cellfun(@(str) strcmp(str,'Vgate'),CC(iter_map(1,1)-1,:),'UniformOutput',false));
[~,vg_col] = find(vg_find,1);


% Extract VG and determine step size
vg_cell_init = CC(iter_map(1,1):iter_map(1,1)+1,vg_col);
vg_mat_init = cell2mat(cellfun(@(x) str2double(x),vg_cell_init,'UniformOutput',false));
step = abs(diff(vg_mat_init));

vg_mat = zeros(round(160/step)+1,1);
id_mat = zeros(round(160/step)+1,size(iter_map,1));
mob = zeros(1,size(iter_map,1));
VT = zeros(1,size(iter_map,1));


% Extract a good set of VG values and find where to start and stop fitting
was_good = 0;
tt=1;
while ~was_good
    start_ind = iter_map(tt,1);
    stop_ind = round(iter_map(tt,1)+160/step);
    vg_cell = CC(start_ind:stop_ind,vg_col);
    vg_mat = cell2mat(cellfun(@(x) str2double(x),vg_cell,'UniformOutput',false));
    fit_start = find(vg_mat==-20,1);
    fit_stop = find(vg_mat==-80,1);
    if not(any(isnan(vg_mat)))
        was_good=1;
    end
    tt=tt+1;
end

bad_sweeps = zeros(1,size(iter_map,1));

for i = 1:size(iter_map,1)

    start_ind = iter_map(i,1);
    stop_ind = round(start_ind+160/step);
    % Extract the values for ID and VG
    id_cell = CC(start_ind:stop_ind,id_col);
    id_mat(:,i) = cell2mat(cellfun(@(x) str2double(x),id_cell,'UniformOutput',false));
    
    if not(any(isnan(id_mat(:,i))))
        [mob(i), VT(i), ~, reg] = fitSatMob(vg_mat(fit_start:fit_stop),id_mat(fit_start:fit_stop,i),Cap,W,L);
        if reg.RSquare <0.6
            bad_sweeps(i) = 1;
        end
    else
        bad_sweeps(i) = 1;
    end

end

bad_sweeps = ~~(bad_sweeps + VT<-50 + VT>500);
mob = mob(~bad_sweeps);
VT = VT(~bad_sweeps);
iter_map = iter_map(~bad_sweeps,:);
    
end

function [Mobility,VT,mfun,reg] = fitSatMob(VGRange,IDRange,Cap,W,L)

Y= sqrt(abs(IDRange));
K = (W*Cap)/(L*2);
X = VGRange;
reg = MultiPolyRegress(X,Y,1);
M = reg.Coefficients(2);
B = reg.Coefficients(1);
Mobility = M^2/K;
VT = B/-M;

mfun = @(x) -(x.*M + B).^2;

end