function [] = plot_mob_fit_dir(dd,devNums)

f=figure;
ax=gca;
hold(ax,'on')

for d = devNums

    fit = dd(d).fit_fun;
    
    vg = dd(d).vg_mat;
    id = dd(d).id_mat;
    
    plot(vg,sqrt(abs(id)),'--r','LineWidth',1)
    fplot(ax,@(x) sqrt(-fit(x)),[dd(d).vt,max(vg)],'-b','LineWidth',1);
    
end

ax.FontSize = 20;
ax.XLim(1) = -80;
ax.Box='on'
ax.YScale='linear'
f.Position = [770 355 748 610];
xlabel('Gate Voltage (Volts)')
ylabel('(Drain Current)^{1/2} (A^{1/2})')


end