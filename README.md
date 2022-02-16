# AttCoefOCT-
This program calculates the attenuation coefficient from OCT images of the skin surface. Developed in MATLAB

# Requirements
MATLAB R2015b 

## Open 
    MaiCode.m
    
## Uses functions:
    InitiROI
    CoefAttDermis
    mainThorlabsOCT:
        Open_File
        Frame_Locator
        Close_File
        IMG_write
        Load_Frame
     
## Exemple:

    [MatrixEfe_mean,SignalFilter,depthCorDerme,depth,depthCorEpiderme]=...
                 InitiROI(janela_pixel,indices_largura_feixe,indiceRefracaoDerme,indiceRefracaoEpiderme,path,frame_start,frame_stop)

    [coefAtt_mean,ErrorFit,curveMeanFilter] =...
                     CoefAttDermis(depthCorDerme,SignalFilter,FrameCorteInicial,FrameCorteFinal);

    [M3D,OCT_Display] = mainThorlabsOCT(path,ShowImagesWhenLoad,frame_start,frame_stop)


