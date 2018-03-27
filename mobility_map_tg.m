function [DD,ax] = mobility_map_tg(folderPath,t_gate,max_mob)

% Build directory of txt files

ad=pwd;
cd(folderPath)
DD=dir('*.iv');
cd(ad);

for i =1:length(DD)
    DD(i).path = fullfile(DD(i).folder, DD(i).name);
end

% Map channel lengths and positions to directory and calculate mobilities

MM = zeros(8,8);
VT_mat = zeros(8,8);

vg_lims = [40,59];
DE = 2.1; % Dielectric Constant of CYTOP
L_vec = fliplr([50,100,50,100,50,100,50,100]);
% L_vec = [50,100,50,100,50,100,50,100];
L2N = struct('A',1,...
    'B',2,...
    'C',3,...
    'D',4,...
    'E',5,...
    'F',6,...
    'G',7,...
    'H',8,...
    'J',9);

for i = 1:length(DD)
    disp(DD(i).path)
    DD(i).ChanRow = str2num(DD(i).name(end-3));
    DD(i).ChanLetter = DD(i).name(end-4);
    DD(i).ChanCol = L2N.(DD(i).ChanLetter);
    DD(i).ChanLen = L_vec(DD(i).ChanRow)*1E-6;
    
    [mob, VT, vg, id, fit_fun, leak] = calcMobIV(DD(i).path,t_gate,1E-3,DD(i).ChanLen,DE);
    
    DD(i).mob=mob;
    DD(i).vt=VT;
    DD(i).vg=vg;
    DD(i).id=id;
    DD(i).fit_fun=fit_fun;
    DD(i).leak=leak;
    
    MM(DD(i).ChanRow,DD(i).ChanCol) = mob;
    VT_mat(DD(i).ChanRow,DD(i).ChanCol) = VT;
    
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