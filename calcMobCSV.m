function [mob, VT, vg_mat, id_mat, fit_fun] = calcMobCSV(filePath,varargin)

if isempty(varargin)
    sweepNum=0;
else
    sweepNum=varargin{1};
end

% --------------
% Hard coded device parameters

Cap = 1.15E-8;
L = 50;
W = 2000;

% --------------

% First read in all the csv cells to CC
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

% Also make a map of where each 'SetupTitle' occurs, which is the start of
% all of a sweep's metadata, and also the end of the previous sweep's data
token = 'SetupTitle';
setup_inds = cellfun(@(str) strcmp(str,token),CC(:,1),'UniformOutput',false);
setup_inds_bin = cell2mat(setup_inds);
setup_inds_list = find(setup_inds_bin);

% Find the row of the csv where the desired sweep starts
if sweepNum==0
    start_ind = iter_map(1,1)+140;
else
    start_ind = iter_map(find(iter_map(:,2)==sweepNum,1),1)+140;
    if isempty(start_ind)
        start_ind = iter_map(1,1)+140;
    end
end

% Find the column that contains VG/Idrain
id_find = cell2mat(cellfun(@(str) strcmp(str,'Idrain'),CC(start_ind-1,:),'UniformOutput',false));
[~,id_col] = find(id_find,1);
vg_find = cell2mat(cellfun(@(str) strcmp(str,'Vgate'),CC(start_ind-1,:),'UniformOutput',false));
[~,vg_col] = find(vg_find,1);

% Find the row where the sweep stops, which is the row before the next
% sweep's metadata, which happens before the next 'SetupTitle' cell
if not(any((setup_inds_list>start_ind)))
    stop_ind=length(CC);
else
    stop_ind = setup_inds_list(setup_inds_list>start_ind)-1;
end

% Extract VG and determine step size
vg_cell = CC(start_ind:stop_ind,vg_col);
vg_mat = cell2mat(cellfun(@(x) str2double(x),vg_cell,'UniformOutput',false));

% Extract the values for ID and VG
id_cell = CC(start_ind:stop_ind,id_col);
id_mat = cell2mat(cellfun(@(x) str2double(x),id_cell,'UniformOutput',false));

fit_stop = find(abs(vg_mat+20)<1,2);
fit_start = find(abs(vg_mat+80)<1,2);
fit_stop = fit_stop(2);
fit_start = fit_start(2);
[mob, VT, fit_fun] = fitSatMob(vg_mat(fit_start:fit_stop),id_mat(fit_start:fit_stop),Cap,W,L);

fclose(fid);

end

function [Mobility,VT,mfun] = fitSatMob(VGRange,IDRange,Cap,W,L)

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