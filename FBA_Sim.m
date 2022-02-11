orthog_stim = 1;
numContrasts = 30;
thetaWidth = 10; % 8
AxWidth = 400;
AthetaWidth = 15; % 15
IthetaWidth = 180;
cRange = [1e-6 1];
sigma = 1e-5;
if orthog_stim == 1
    Apeak = 1.5; % 2 for orthog, 5 for no orthog
else
    Apeak = 5;
end

% Sampling of space and orientation
x = [-100:100];
theta = [-90:90]'; % changes from [-180:180] because working with orientation

% Make stimuli
stimCenter = 0;
stimOrientation1 = -45;
stimOrientation2 = 45;

stim_loc = zeros(size(x));
stim_loc(abs(x) < 90) = 1;

stim1 = makeGaussian(theta,stimOrientation1,1,1) * stim_loc;
stim2 = makeGaussian(theta,stimOrientation2,1,1) * stim_loc; 

% Pick contrasts
logCRange = log10(cRange);
logContrasts = linspace(logCRange(1),logCRange(2),numContrasts);
contrasts = 10.^logContrasts;

%%

% We are interested in a neuron that prefers orientation 1. Orientation 2
% is its null stimulus.
j = find(theta==stimOrientation1);
RF_center = stimCenter;
i = find(x==RF_center);

attCRF = zeros(size(contrasts));
unattCRF_peak = zeros(size(contrasts));

for c = 1:numContrasts
    
    if orthog_stim == 1
        stim = contrasts(c) * stim1 + contrasts(c) * stim2;
    else
        stim = contrasts(c) * stim1;
    end
      
   
  % match
  [R1,Eraw1,AttnGain1,E1,I1] = attentionModel(x,theta,stim,'EthetaWidth',thetaWidth,...
    'Apeak',Apeak,'Ax',stimCenter,'AxWidth',AxWidth,'Atheta',stimOrientation1,'AthetaWidth',AthetaWidth,...
    'IthetaWidth',IthetaWidth,...
    'sigma',sigma,'showActivityMaps',0);

% mismatch
[R2,Eraw2,AttnGain2,E2,I2] = attentionModel(x,theta,stim,'EthetaWidth',thetaWidth,...
    'Apeak',Apeak,'Ax',stimCenter,'AxWidth',AxWidth,'Atheta',stimOrientation2,'AthetaWidth',AthetaWidth,...
    'IthetaWidth',IthetaWidth,...
    'sigma',sigma,'showActivityMaps',0);

if c == round(length(contrasts)/2)
    act_maps.R1 = R1;
    act_maps.Eraw1 = Eraw1;
    act_maps.AttnGain1 = AttnGain1;
    act_maps.E1 = E1;
    act_maps.I1 = I1;
    act_maps.R2 = R2;
    act_maps.Eraw2 = Eraw2;
    act_maps.AttnGain2 = AttnGain2;
    act_maps.E2 = E2;
    act_maps.I2 = I2;
end

attCRF_peak(c) = mean(R1(j,i));
unattCRF_peak(c) = mean(R2(j,i));

attCRF_mean(c) = mean(R1(:,i));
  unattCRF_mean(c) = mean(R2(:,i));
  
end

%%
if orthog_stim == 1
    save_dir = [pwd,'/Figures/orthog_stim/'];
else
    save_dir = [pwd,'/Figures/single_ori/'];
end

if ~exist(save_dir)
    mkdir(save_dir)
end

figure;
imshow(act_maps.Eraw1,[0,max(max(act_maps.Eraw1))]);
saveas(gcf,[save_dir,'stim_drive'],'svg')

figure;
imshow(act_maps.E1,[0,max(max(act_maps.E1))]);
saveas(gcf,[save_dir,'attn_by_stim_drive1'],'svg')

figure;
imshow(act_maps.E2,[0,max(max(act_maps.E2))]);
saveas(gcf,[save_dir,'attn_by_stim_drive2'],'svg')

figure;
imshow(act_maps.AttnGain1,[0,max(max(act_maps.AttnGain1))]);
saveas(gcf,[save_dir,'attn_gain1'],'svg')

figure;
imshow(act_maps.AttnGain2,[0,max(max(act_maps.AttnGain2))]);
saveas(gcf,[save_dir,'attn_gain2'],'svg')

figure;
imshow(act_maps.I1,[0,max(max(act_maps.I1))]);
saveas(gcf,[save_dir,'norm_factor'],'svg')

figure;
imshow(act_maps.R1,[0,max(max(act_maps.R1))])
saveas(gcf,[save_dir,'popn_resp1'],'svg')

figure;
imshow(act_maps.R2,[0,max(max(act_maps.R1))])
saveas(gcf,[save_dir,'popn_resp2'],'svg')



%%
% figure; clf;
% subplot(1,2,1)
% semilogx(contrasts,attCRF_peak,contrasts,unattCRF_peak);
% %ylim([0 7]);
% xlim(cRange);
% legend('match','mismatch');
% ylabel('Normalized response');
% xlabel('Log contrast');
% title('Peak Response');
% subplot(1,2,2);
% 
% semilogx(contrasts,attCRF_peak./max(attCRF_peak),contrasts,unattCRF_peak./max(unattCRF_peak));
% %ylim([0 100]);
% xlim(cRange);
% ylabel('Scaled');
% xlabel('Log contrast');
% drawnow
% 
% figure; clf;
% subplot(1,2,1)
% semilogx(contrasts,attCRF_mean,contrasts,unattCRF_mean);
% %ylim([0 7]);
% xlim(cRange);
% legend('match','mismatch');
% ylabel('Normalized response');
% xlabel('Log contrast');
% title('Population Average');
% subplot(1,2,2);
% semilogx(contrasts,attCRF_mean./max(attCRF_mean),contrasts,unattCRF_mean./max(unattCRF_mean));
% %ylim([0 100]);
% xlim(cRange);
% ylabel('Scaled');
% xlabel('Log contrast');
% drawnow

%% nice figure
FigHandle = figure('Position', [100, 100, 168, 120]);
semilogx(contrasts,unattCRF_peak,'Color','r','linewidth',1); hold on;
semilogx(contrasts,attCRF_peak,'Color','b','linewidth',1);
xlim(cRange);
set(gca,'xtick',[])
set(gca,'ytick',[])
box off
saveas(gcf,[save_dir,'CRF_Peak'],'svg')

FigHandle = figure('Position', [100, 100, 168, 120]);
semilogx(contrasts,unattCRF_mean,'Color','r','linewidth',1); hold on;
semilogx(contrasts,attCRF_mean,'Color','b','linewidth',1);
xlim(cRange);
set(gca,'xtick',[])
set(gca,'ytick',[])
box off
saveas(gcf,[save_dir,'CRF_PopnMean'],'svg')
