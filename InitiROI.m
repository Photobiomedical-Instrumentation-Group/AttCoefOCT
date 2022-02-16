% clear all
% clc

% % Raquel Pantojo de Souza e George Cardoso Cunha USP
% $Revision: 1.0 $ $Date: 2020/2/14 $

function [MatrixEfe_mean,SignalFilter,depthCorDerme,depth,depthCorEpiderme]=...
            InitiROI(janela_pixel,indices_largura_feixe,indiceRefracaoDerme,indiceRefracaoEpiderme,path,frame_start,frame_stop)

% LOAD AQUISITION
% FROM OCT TOOLBOX %indice do meio 
[M3D,~]=mainThorlabsOCT(path,0,frame_start,frame_stop); %Main_Thorlabs_SSOCT_DiegoEdit; 
 


% %Load signal from OCT

% MatrixEfe stores intensity values ??from the middle of the ROI
% Splits ROI in half

i_meio=round(size(M3D,2)/2); %middle index
MatrixEfe = M3D(:,i_meio-indices_largura_feixe/2:i_meio+indices_largura_feixe/2,:);

% subplot(132)
% imshow(MatrixEfe(:,120,60))


% Intensity per depth
for i=1:size(MatrixEfe,3)
j=1;

%MatrixEfe_mean (no more x axis) is "video", with moving average in y, has indices for y and time

while j*janela_pixel < size(MatrixEfe,1)
MatrixEfe_mean(j,i) = mean(mean(MatrixEfe(1+(j-1)*janela_pixel:j*janela_pixel,:,i)));
% MatrixEfe_mean(j,i) = (mean(MatrixEfe(janela_pixel:j*janela_pixel,:,i)));
j= j+1;
end

end

% subplot(133)
% plot(MatrixEfe_mean)

clear M3D

%% % Each "frame" which is now just the y line, is normalized (decay curves, typical)
% for i=1:size(MatrixEfe_mean,2)
% MatrixEfe_mean(:,i) = MatrixEfe_mean(:,i)./max(MatrixEfe_mean(:,i));
% end


%% Creat Graphs OCT and ROI

% subplot(121)
% imagesc(OCT_Display);
% colormap(gray); 
% xlabel('Frames','FontSize',20)
% ylabel('Pixel','FontSize',20)
% 
% set(gca,'FontSize',16) ; set(gcf,'color','w');

%subplot(122)
% imagesc(MatrixEfe(:,:,1));colormap(gray);
% xlabel('Pixel','FontSize',20)
% ylabel('Pixel','FontSize',20) 
% set(gca,'FontSize',16) ; set(gcf,'color','w');


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter:
% The first step of our algorithm is the surface detection of the OCT volume of the human skin.
% To determine the sample surface, the algorithm first locates the maximum intensity points of
% all the A-scans in a logarithmic cross-sectional image (B-scan)
%
% For surface detection using Canny method with threshold
threshold=0.900;
%threshold=0.80;
BW2 = edge(MatrixEfe_mean,'Canny',threshold) ;


% Realignment
% The realignment was performed using the highest position as the starting point.
% filter strength:

[~,Hlocs_Filter] = max(BW2); %  %posição de realinhamento 

% imagesc(BW2);colormap(gray); 
% xlabel('Pixel','FontSize',20)
% ylabel('Pixel','FontSize',20) 
% set(gca,'FontSize',16) ; set(gcf,'color','w');

SignalFilter=zeros(size(BW2,1),1);
%
for l=1:1:size(BW2,1)% lines
    for col=1:1:size(MatrixEfe_mean,2)% colluns % 60 frames
        
% for each column, there is a row size that will vary depending on
% of Hlocs_Filter position

           for ii=1:1:size(MatrixEfe_mean,1)-Hlocs_Filter(col);
            SignalFilter(1,col) = MatrixEfe_mean(Hlocs_Filter(col),col);
            SignalFilter(ii+1,col) = MatrixEfe_mean(Hlocs_Filter(col)+ii,col);
           end 
    end
end
%
% subplot(133)
% surf(SignalFilter)
% xlabel('Frames','FontSize',16)
% ylabel('Profundidade','FontSize',16)
% title('Realinhamento Laplaciano')

% % Figura2

figure
% subplot(141)
% imagesc(MatrixEfe(:,:,1))
% xlabel(' position (mm)','FontSize',20)
% ylabel('Pixel','FontSize',20)
% colormap(gray); 
% set(gca,'FontSize',16) ; set(gcf,'color','w');% mostra o primeiro frame já cortado

subplot(142)
surf(MatrixEfe_mean);colormap(gray); 
xlabel('Number of Frames','FontSize',20)
ylabel('Pixel','FontSize',20)
set(gca,'FontSize',16) ; set(gcf,'color','w');

subplot(143)
imagesc(BW2);colormap(gray); 
%imshow(BW2, 'ColorMap', [1 1 1; 0 0 1]);
xlabel('Number of Frames','FontSize',20)
ylabel('Pixel','FontSize',20)
set(gca,'FontSize',16);set(gcf,'color','w');

subplot(144)
imagesc(SignalFilter);colormap(gray); 
xlabel('Number of Frames','FontSize',20)
ylabel('Pixel','FontSize',20)
set(gca,'FontSize',16) ;set(gcf,'color','w');
%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transforms pixel to depth using transfom pixel dimension (0.005859375) .
% And corrects each region by the corresponding epidermis and deme refractive indices

Dim_pixel = 0.005859375;
Profundidade = size(MatrixEfe_mean,1);
depth = 0:Dim_pixel*janela_pixel:Dim_pixel*janela_pixel*(Profundidade-1);
depthCorDerme=depth/indiceRefracaoDerme;
depthCorEpiderme=depth/indiceRefracaoEpiderme;
