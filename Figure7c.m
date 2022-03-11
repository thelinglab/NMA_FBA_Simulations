clear all
close all

% model params
numContrasts = 30;
thetaWidth = 20;
AxWidth = 400;
AthetaWidth = 30;
IthetaWidth = 180;
cRange = [1e-6 1];
sigma = 1e-5;
Apeak = 3;
save_dir = [pwd,'/Figures/Fig7c/'];
save_figs = 1;

if save_figs == 1 & ~exist(save_dir)
    mkdir(save_dir)
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
oris = [-68,-45,-23,0,23,45,68]% REVIEW:

attCRF = nan(length(oris),length(contrasts)); % REVIEW: rename this!
unattCRF = nan(length(oris),length(contrasts));

% We are interested in a neuron that prefers orientation 1. Orientation 2
% is its null stimulus.

RF_center = stimCenter;
i = find(x==RF_center);

for c = 1:numContrasts
    
    stim = contrasts(c) * stim1;
    
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
    
    for o = 1:length(oris)
        j = find(theta == oris(o));
        attCRF(o,c) = R1(j,i);
        unattCRF(o,c) = R2(j,i);
    end
          
    attCRF_popn_ave(c) = mean(R1(:,i));
    unattCRF_popn_ave(c) = mean(R2(:,i));
    
end

%% plots

if ~exist(save_dir)
    mkdir(save_dir)
end

figure;
imshow(act_maps.Eraw1,[0,max(max(act_maps.Eraw1))]);
if save_figs == 1
saveas(gcf,[save_dir,'stim_drive'],'svg');
end

figure;
imshow(act_maps.AttnGain1,[0,max(max(act_maps.AttnGain1))]);
if save_figs == 1
saveas(gcf,[save_dir,'attn_gain1'],'svg');
end

figure;
imshow(act_maps.AttnGain2,[0,max(max(act_maps.AttnGain2))]);
if save_figs == 1
saveas(gcf,[save_dir,'attn_gain2'],'svg');
end

figure; 
col = colormap(cool(length(oris)));
imshow(act_maps.R1,[0,max(max(act_maps.R1))]); hold on;
for o = 1:length(oris)
    j = find(theta == oris(o));
    scatter(i,j,60,col(o,:),'Marker','x','LineWidth',3)
end
if save_figs == 1
    saveas(gcf,[save_dir,'popn_resp1'],'svg');
end
 
figure;
imshow(act_maps.R2,[0,max(max(act_maps.R1))]); hold on;
for o = 1:length(oris)
    j = find(theta == oris(o));
    scatter(i,j,60,col(o,:),'Marker','x','LineWidth',3)
end
if save_figs == 1
    saveas(gcf,[save_dir,'popn_resp2'],'svg');
end

% CRFs
FigHandle = figure('Position', [100, 100, 350, 40]);
ylims = [0, 1.1*max(max(attCRF))];
for o = 1:length(oris)
subplot(1,length(oris),o);
semilogx(contrasts,unattCRF(o,:),'Color','r','linewidth',1); hold on;
semilogx(contrasts,attCRF(o,:),'Color','b','linewidth',1);
xlim(cRange);
ylim(ylims)
set(gca,'xtick',[])
set(gca,'ytick',[])
box off
end
if save_figs == 1
    saveas(gcf,[save_dir,'CRFs_by_ori'],'svg');
end

FigHandle = figure('Position', [100, 100, 120, 100]);
semilogx(contrasts,unattCRF_popn_ave,'Color','r','linewidth',1); hold on;
semilogx(contrasts,attCRF_popn_ave,'Color','b','linewidth',1);
xlim(cRange);
set(gca,'xtick',[])
set(gca,'ytick',[])
box off
if save_figs == 1
    saveas(gcf,[save_dir,'CRF_PopnMean'],'svg');
end
