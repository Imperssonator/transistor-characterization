function [DD,ax] = mobility_map(folderPath,max_mob)


% Build directory of txt files

ad=pwd;
cd(folderPath)
DD=dir('*.txt');
cd(ad);

for i =1:length(DD)
DD(i).path=[DD(i).folder, '/', DD(i).name];
end

% Map channel lengths and positions to directory and calculate mobilities

MM = zeros(7,9);
VT_mat = zeros(7,9);

L_vec = [5,10,20,25,50,80,100];
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
    
DD(i).ChanRow = str2num(DD(i).name(end-4));
DD(i).ChanLetter = DD(i).name(end-5);
DD(i).ChanCol = L2N.(DD(i).ChanLetter); % This is a wizard-level MATLAB trick to get around the lack of dictionaries
DD(i).ChanLen = L_vec(DD(i).ChanRow-2)*1E-6;

[mob, VT, vg_mat, id_mat, fit_fun] = calcMobIV(DD(i).path,200E-9,1E-3,DD(i).ChanLen);

DD(i).mob=mob;
DD(i).vt=VT;
DD(i).vg_mat=vg_mat;
DD(i).id_mat=id_mat;
DD(i).fit_fun=fit_fun;

MM(DD(i).ChanRow,DD(i).ChanCol) = mob;
VT_mat(DD(i).ChanRow,DD(i).ChanCol) = VT;

end

% Check for colorbar scale

if exist('max_mob')~=1
    max_mob = max(max(MM));
end
max_vt = max(max(VT_mat));

% Generate Heat Map

figure;
ax=gca;
imagesc(MM(3:end,:),[0 max_mob]);

colorbar()
ax.YDir='reverse';
ax.Visible='off';
ax.FontSize=20;


figure;
ax2=gca;
imagesc(VT_mat(3:end,:),[0 max_vt]);

colorbar()
ax2.YDir='reverse';
ax2.Visible='off';
ax2.FontSize=20;