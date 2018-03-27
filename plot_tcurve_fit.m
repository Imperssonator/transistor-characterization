function [ax, ax2] = plot_tcurve_fit(dd,devNums)

f=figure;
ax=gca;
hold(ax,'on')

for d = devNums

    fit = dd(d).fit_fun;
    
    vg = dd(d).vg;
    id = dd(d).id;
    
    ax2 = plotyy(vg,sqrt(abs(id)),vg,abs(id),'plot','semilogy');
    fplot(ax,@(x) sqrt(-fit(x)),[dd(d).vt,max(vg)],'-b','LineWidth',1);
    
end

ax.FontSize = 14;
ax.Box = 'off';
f.Position = [770 355 748 610];
xlabel('Gate Voltage (Volts)')
ylabel(ax2(1),'(Drain Current)^{1/2} (A^{1/2})')
ylabel(ax2(2),'Drain Current (A)')

lin_bounds = [0, max(sqrt(abs(id)))*1.3];
log_bounds = [10^floor(log10(min(abs(id)))), 10^ceil(log10(max(abs(id))))];
disp(log_bounds)
set(ax2(1),'YLim',lin_bounds);
set(ax2(1),'ytick',linspace(lin_bounds(1),lin_bounds(2),5));
set(ax2(2),'YLim',log_bounds);
set(ax2(2),'ytick',10.^(floor(log10(min(abs(id)))):ceil(log10(max(abs(id))))));
ytl = {};
for i = 1:length(ax2(2).YTick)
    ytl{i} = num2str(ax2(2).YTick(i));
end
set(ax2(2),'yticklabels',ytl);
set(ax2(2),'FontSize',14);

ax.Position(3) = 0.73;

end