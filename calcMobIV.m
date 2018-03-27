function [mob, VT, vg, id, fit_fun, leak] = calcMobIV(filePath,d_gate,W,L,de_const,vg_lims)

% Provide d_gate (thickness of gate dielectric), W, L in meters

% eps_rel * eps_0 / thickness gives capacitance per unit area in m^-2
Cap = de_const * 8.854e-12 / d_gate / (100^2);   % convert to F/cm^2

ivtable = readtable(filePath,'filetype','text');
disp(size(ivtable))
vg = ivtable{:,end-1};
id = ivtable{:,end-4};
leak = ivtable{:,end}+ivtable{:,end-2}+ivtable{:,end-4};

if exist('vg_lims')==1
    fit_stop = find(abs(vg)>vg_lims(2),1);
    fit_start = find(abs(vg)>vg_lims(1),1);
else
    fit_start = 86;
    fit_stop = 116;
end

% disp(vg_mat)
% disp(id_mat)
[mob, VT, fit_fun] = fitSatMob(vg(fit_start:fit_stop),id(fit_start:fit_stop),Cap,W,L);
% onoff = id_mat(fit_stop) / 

end

function [Mobility,VT,mfun] = fitSatMob(VGRange,IDRange,Cap,W,L)

Y= sqrt(abs(IDRange));
K = (W*Cap)/(2*L);
X = VGRange;
% disp(X')
% disp(Y')
reg = MultiPolyRegress(X,Y,1);
M = reg.Coefficients(2);
B = reg.Coefficients(1);
Mobility = M^2/K;
VT = B/-M;

mfun = @(x) -(x.*M + B).^2;

end