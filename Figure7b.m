clear all
close all

% model params
numContrasts = 30;
thetaWidth = 20;
AxWidth = 400;
AthetaWidth = 20;
IthetaWidth = 180;
cRange = [1e-6 1];
sigma = 1e-5;
Apeak = 3;
save_dir = [pwd,'/Figures/Fig7b/'];
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
attCRF = nan(1,length(contrasts))
unattCRF = nan(1,length(contrasts));

% We are interested in a neuron that prefers orientation 1. Orientation 2
% is its null stimulus.
RF_center = stimCenter;
i = find(x==RF_center);
j = find(theta == stimOrientation1);

attCRF = zeros(size(contrasts));
unattCRF_peak = zeros(size(contrasts));

for c = 1:numContrasts
    
    stim = contrasts(c) * stim1 + contrasts(c) * stim2;
    
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
    
    attCRF(c) = R1(j,i);
    unattCRF(c) = R2(j,i);
    
end

cmap = colormap(cool(7));
col = cmap(2,:);

%% plots

imshow(act_maps.Eraw1,[0,max(max(act_maps.Eraw1))]);
if save_figs == 1
    saveas(gcf,[save_dir,'stim_drive'],'svg');
end

imshow(act_maps.AttnGain1,[0,max(max(act_maps.AttnGain1))]);
if save_figs == 1
    saveas(gcf,[save_dir,'attn_gain1'],'svg');
end

imshow(act_maps.AttnGain2,[0,max(max(act_maps.AttnGain2))]);
if save_figs == 1
    saveas(gcf,[save_dir,'attn_gain2'],'svg');
end

imshow(act_maps.R1,[0,max(max(act_maps.R1))]); hold on;
scatter(i,j,60,col,'Marker','x','LineWidth',3);
if save_figs == 1
    saveas(gcf,[save_dir,'popn_resp1'],'svg');
end
 
imshow(act_maps.R2,[0,max(max(act_maps.R1))]); hold on;
scatter(i,j,60,col,'Marker','x','LineWidth',3);
if save_figs == 1
    saveas(gcf,[save_dir,'popn_resp2'],'svg');
end

% CRFs
FigHandle = figure('Position', [100, 100, 120, 100]);
semilogx(contrasts,unattCRF,'Color','r','linewidth',1); hold on;
semilogx(contrasts,attCRF,'Color','b','linewidth',1);
xlim(cRange);
ylim([0, 1.2*max(attCRF)])
set(gca,'xtick',[])
set(gca,'ytick',[])
box off
if save_figs == 1
    saveas(gcf,[save_dir,'CRF_Peak'],'svg');
end