function [mob, VT, vg_mat, id_mat, fit_fun] = calcMobIV(filePath,d_gate,W,L)

% Provide d_gate (thickness of gate dielectric), W, L in meters

% eps_rel * eps_0 / thickness gives capacitance per unit area in m^-2
Cap = 3.9 * 8.854e-12 / d_gate / (100^2);   % convert to F/cm^2

[vg_mat,id_mat] = read_iv_txt(filePath);

fit_stop = find(abs(vg_mat)>79,1);
fit_start = find(abs(vg_mat)>40,1);
[mob, VT, fit_fun] = fitSatMob(vg_mat(fit_start:fit_stop),id_mat(fit_start:fit_stop),Cap,W,L);

end

function [Mobility,VT,mfun] = fitSatMob(VGRange,IDRange,Cap,W,L)

Y= sqrt(abs(IDRange));
K = (W*Cap)/(2*L);
X = VGRange;
reg = MultiPolyRegress(X,Y,1);
M = reg.Coefficients(2);
B = reg.Coefficients(1);
Mobility = M^2/K;
VT = B/-M;

mfun = @(x) -(x.*M + B).^2;

end