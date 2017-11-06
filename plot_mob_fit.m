function [] = plot_mob_fit(sp,devNum)

load(sp)

V = expt.dev(devNum).electrical.transfer.VG;
ID = expt.dev(devNum).electrical.transfer.ID;
IDfit = expt.dev(devNum).electrical.transfer.IDfit;

figure;
hp = plot(V,ID,'ob',V,IDfit,'-k');
hax = gca;
hax.FontSize = 20;
hax.XTick = [-80 -40 0 40 80];
f = gcf;
f.Position = [770 355 748 610];
xlabel('VG (Volts)')
ylabel('ID (Amps)')


end