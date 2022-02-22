save_figs = 1;
save_dir = [pwd,'/Figures/Fig7a/'];

if save_figs == 1 & ~exist(save_dir)
    mkdir(save_dir)
end

% simulation params
thetaWidth = 20;
AxWidth = 400;
AthetaWidth = 20;
Apeak = 2;
IthetaWidth = 180;
cRange = [1e-6 1];
sigma = 1e-5
orthog_stim = 1;

% Sampling of space and orientation
x = [-100:100];
theta = [-90:90]'; % changes from [-180:180] because working with orientation

% Make stimuli
stimCenter = 0;
stimOrientation1 = -45;
stimOrientation2 = 45;
stim_loc = zeros(size(x));
stim_loc(abs(x) < 90) = 1;

%%

stim1 = makeGaussian(theta,stimOrientation1,1,1) * stim_loc;
stim2 = makeGaussian(theta,stimOrientation2,1,1) * stim_loc; 

% We are interested in a neuron that prefers orientation 1. Orientation 2
% is its null stimulus.
j = find(theta==stimOrientation1);
RF_center = stimCenter;
i = find(x==RF_center);


if orthog_stim == 1
    stim = stim1  + stim2;
else
    stim = stim1;
end

% attend ori1
[R1,Eraw1,AttnGain1,E1,I1] = attentionModel(x,theta,stim,'EthetaWidth',thetaWidth,...
    'Apeak',Apeak,'Ax',stimCenter,'AxWidth',AxWidth,'Atheta',stimOrientation1,'AthetaWidth',AthetaWidth,...
    'IthetaWidth',IthetaWidth,...
    'sigma',sigma,'showActivityMaps',0);


%% plot and save figures

figure;
imshow(Eraw1,[0,max(max(Eraw1))]);
if save_figs == 1
    saveas(gcf,[save_dir,'stim_drive'],'svg')
end

figure;
imshow(AttnGain1,[0,max(max(AttnGain1))]);
if save_figs == 1
    saveas(gcf,[save_dir,'attn_gain'],'svg')
end

figure;
imshow(E1,[0,max(max(E1))]);
if save_figs == 1
    saveas(gcf,[save_dir,'gain_x_stim_drive'],'svg')
end

figure;
imshow(I1,[0,max(max(I1))]);
if save_figs == 1
    saveas(gcf,[save_dir,'norm_factor'],'svg')
end

figure;
imshow(R1,[0,max(max(R1))])
if save_figs == 1
    saveas(gcf,[save_dir,'popn_resp'],'svg')
end