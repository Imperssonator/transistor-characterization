function [] = plot_mob_fit_2(ms,devNums)

f=figure;
ax=gca;
hold(ax,'on')

for d = devNums

    fit = ms(d).fit;
    
    vg = ms(d).vg(67:end);
    id = ms(d).id(67:end);
    
    plot(vg,sqrt(-id),'ok','MarkerSize',8,'LineWidth',1)
    fplot(ax,@(x) sqrt(-fit(x)),[-80,0],'-b','LineWidth',2);
    
end

ax.FontSize = 20;
ax.XLim(1) = -80;
ax.Box='on'
ax.YScale='linear'
f.Position = [770 355 748 610];
xlabel('Gate Voltage (Volts)')
ylabel('(Drain Current)^{1/2} (A^{1/2})')


end