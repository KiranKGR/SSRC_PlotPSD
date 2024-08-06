%% Plot
function PlotPSD(In)
% Create a new figure and set up the static plot variables
Fg1=figure;
Delta_T=minutes(10);
ytl={' ','N3','N2','N1','R','W','A'};
screensize = get(groot,'Screensize');
pos_fig1 = [0 0 screensize(3) screensize(4)];
set(Fg1,'Position',pos_fig1);
k=3;
% Hypnogram
h=subplot(k,1,1); % %
stairs(In.Hypnogram_Time,In.Hypnogram,'Color','k','LineWidth',1.5);
ylabel('Sleep Stages');
title('Hypnogram');
xlim([In.Hypnogram_Time(1)-Delta_T In.Hypnogram_Time(end)+Delta_T]);
xtickformat('HH:mm');
xt=xticks(h);
yticks(0:1:6);ylim([0 7]);
hold on;
xline(In.LightsOff,'-.k','LineWidth',1.5);xline(In.LightsOn,'-.r','LineWidth',1.5)

yticklabels(ytl);
Pos=get(h,'Position');
% Get xind
xt=datetime(xt','Format','dd-MMM-yyyy HH:mm:ss');
[~, xtick_ind] = ismember(xt,In.Hypnogram_Time);
if xtick_ind(end)==0
    xtick_ind=(xtick_ind(1):(diff(xtick_ind(1:2))):xtick_ind(1)+((diff(xtick_ind(1:2)))*(length(xt)-1)))';
end
set(h,'xticklabels',[]);
% Spectrogram
% 0 to 20 Hz is the spectrum plotted
[~,ind]=min(abs(In.f_vector-20));
f=In.f_vector(1:ind);
h2=subplot(k,1,2);
Pos2=get(h2,'Position');
imagesc(1:size(In.Spectrum,2),f,In.Spectrum(1:ind,:));
colormap(jet);% change the color map here
hcol = colorbar;
ylabel(hcol, 'Power (\muV^2/Hz)','FontSize',18);
hcol.Position(1) = hcol.Position(1)+0.02; % shift a bit to right
ylabel('Frequency (Hz)');
title('Spectrogram');
set(gca,'YDir','normal');
set(gca,'TickDir','in');
set(gca,'YLim',[0 20]);
set(gca,'ColorScale','log')
clim([0.01 100]); % Change here to improve contrast.
xlim([ 1-(minutes(Delta_T)*2) size(In.Spectrum,2)+(minutes(Delta_T)*2)]);
set(h2, 'XTick', xtick_ind);
set(h2,'xticklabels',[])
% SWA
h3=subplot(k,1,3);
Pos3=get(h3,'Position');
% Slow wave power
[~,swa1]=min(abs(In.f_vector-0.75));
[~,swa2]=min(abs(In.f_vector-4.5));
SWA=sum(In.Spectrum(swa1:swa2,:));
stem(h3,In.Hypnogram_Time,SWA,'Marker','.','MarkerSize',0.5);
xlim([In.Hypnogram_Time(1)-Delta_T In.Hypnogram_Time(end)+Delta_T]);
xtickformat('HH:mm');
ylim([1 In.SWAthreshold]); % SWA range
set(gca,'Clipping','on','ClippingStyle','rectangle');
ylabel('Power (\muV^2)');
title("Slow Wave Activity");
xline(In.LightsOff,'-.k','LineWidth',1.5);xline(In.LightsOn,'-.r','LineWidth',1.5)
xlh = xlabel('Time');
xlh.Position(2) = xlh.Position(2) + 3;
%
screensize = get(groot,'Screensize');
pos_fig1 = [0 0 screensize(3) screensize(4)];
set(Fg1,'Position',pos_fig1);
set(h,'Position',[Pos(1)-.02,Pos(2)-0.02,Pos(3),Pos(4)]);
set(h2,'Position',[Pos2(1)-.02,Pos2(2),Pos(3),Pos2(4)]);
set(h3,'Position',[Pos3(1)-.02,Pos3(2)+0.02,Pos(3),Pos3(4)]);
end