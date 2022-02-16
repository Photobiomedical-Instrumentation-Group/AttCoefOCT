
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Uses functions:
% InitiROI
% CoefAttDermis
% mainThorlabsOCT:
    % Open_File
    % Frame_Locator
    % Close_File
    % IMG_write
    % Load_Frame
%     
% %Exemple:
% % [MatrixEfe_mean,SignalFilter,depthCorDerme,depth,depthCorEpiderme]=...
% %             InitiROI(janela_pixel,indices_largura_feixe,indiceRefracaoDerme,indiceRefracaoEpiderme,path,frame_start,frame_stop)
%
% [coefAtt_mean,ErrorFit,curveMeanFilter] =...
%                     CoefAttDermis(depthCorDerme,SignalFilter,FrameCorteInicial,FrameCorteFinal);
%
% [M3D,OCT_Display] = mainThorlabsOCT(path,ShowImagesWhenLoad,frame_start,frame_stop)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
clc
close all

% To save in file
filename = 'teste.xlsx';
sheet = 1;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h=warndlg('Select .IMG file','Attention!!');
path='...';  %Select .IMG file


[~,SignalFilter,depthCorDerme,~,~]=InitiROI(1,120,1.41,1.34,path,1,60);

[coefAtt_mean,ErrorFit,~] =...
                   CoefAttDermis(depthCorDerme,SignalFilter,3,2,0.12);
         
% Resultado=[coefAtt_mean,ErrorFit]; 
% xlRange = 'B2:c2'; 
% xlswrite(filename,Resultado,sheet,xlRange)
delete(h)