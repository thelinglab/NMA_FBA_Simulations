
titleString = 'Figure 6C (Martinez-Trujillo & Treue, 2004)';
stimWidth = 10; 
AxWidth = 30;
AthetaWidth = 60;
Ashape = 'cross';

% Sampling of space and orientation
x = [-200:200];
theta = [-180:180]';

% Make stimuli
stimCenter1 = 100;
stimOrientation1 = 0;
stimCenter2 = -100;
stimOrientation2 = 0;
stim1 = makeGaussian(theta,stimOrientation1,1,1) * makeGaussian(x,stimCenter1,stimWidth,1); 
stim2 = makeGaussian(theta,stimOrientation2,1,1) * makeGaussian(x,stimCenter2,stimWidth,1);

% Set contrast to 1 
contrast = 1;  
stim = contrast * stim1 * contrast + stim2;

% Population response when attending to fixation
R1 = attentionModel(x,theta,stim,'Ax',0,'AxWidth',AxWidth);

% Population response when attending stim 2
R2 = attentionModel(x,theta,stim,'Ashape','cross',...
  'Ax',stimCenter2,'AxWidth',AxWidth,...
  'Atheta',stimOrientation2,'AthetaWidth',AthetaWidth);

% Pick RF center, record from neurons with that RF center and all
% different feature preferences (same as tuning curve from any one of those
% neurons).
i = find(x==stimCenter1);
attCRF = R1(:,i);
unattCRF = R2(:,i);
  
figure; clf;
plot(theta,unattCRF,theta,attCRF);
xlim([-180 180]);
legend('Att Away','Att RF');
title(titleString);
drawnow
