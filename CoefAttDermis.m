%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Inicio do desenvolvimento: 08-02-2021 
% % Atualizado dia 16-08-2021
% % Ajusta Lei de Beer-Lambert (single-scattering) para calculo de coeficiente 
% % de atenuação a partir da curva do OCT 
% % Faz cortes Automáticos Derme definir ponto de máximo
% % A curva de intensidade em dB
% % Raquel Pantojo de Souza e George Cardoso Cunha USP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 function [coefAtt,ErrorFit,curveMeanFFT]=...
                    CoefAttDermis(depth,SignalFilter,FrameCorteInicial,FrameCorteFinal,MaxDepthDerme)
% FrameCorteInicial=3;
% FrameCorteFinal=2;
% MaxDepthDerme=0.10;
% depth=depthCorDerme;

%%%%%

curveFFTzero=zeros();
curveMeanFFT=zeros();

%% Média das linhas
for j=1:1:length(SignalFilter(:,2)) % Linhas : intensidade 
   for i=FrameCorteInicial:1:(size(SignalFilter,2)-FrameCorteFinal) % Colunas : Frames
 
% Retiramos os 2 frames iniciais e os 2 ultimos pois o filtro não gera bons
% resultados na borda, fizemos isso para evitar que na média tivesse
% interferencia desses frames.  

curveFFTzero(j,i)=SignalFilter(j,i);
curveFFT=curveFFTzero;
curveFFT( :, ~any(curveFFT,1) ) = [];  %columns
curveMeanFFT(j,:)=mean(curveFFT(j,:));
% curveMeanFFT(j,:)=median(curveFFT(j,:));
    end 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Seleção automática para realizar o corte
% Range do corte
% pointInit=0.15;
% pointmax=0.49;
% 
% rinit=find(depth>=pointInit); % Corte mínimo 
% rfinal=find(depth<=pointmax); % Corte máximo 

% Pico da derme
% PointM=max(curveMeanFilter(rinit:rfinal(end)));
% PointM=find(curveMeanFilter==PointM);

%%
figure
% subplot(121)
set(gca,'FontSize',18)
plot(depth,curveMeanFFT,'color','b','LineWidth',3);
xlabel('Depth (mm)','FontSize',18)
ylabel('Signal(dB)','FontSize',18)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Seleção Manual para realizar o corte
X=depth;
uiwait(msgbox('Selecione o ponto que marca o começo da Derme ','modal'));
[x_min1, ~] = ginput(1); % Let the user select an x-value from which to crop.
% X(X<x_min1) = [];
% 
% %Encontra a posição entre apontada anteriormente 
% Max=find(depth<=x_max1);
PointM=find(depth>=x_min1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Corte até a profundidade máxima definida
PointMin=find(depth<=(depth(PointM(1))+MaxDepthDerme));

%Sinal gerado pelo OCT
X_GrayColor=depth(PointM(1):PointMin(end));
Y_GrayColor=curveMeanFFT(PointM(1):PointMin(end));
%%%
%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %  Curva Média
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % Gera valores do coeficiente de atenuação:
% Equação usada pelo Matheus:
% zr=0.3;
% % ModelFun = @(u,x) u(1)+(2.*u(2).*x - 0.5.*(1+((x-zr)./zr).^2));beta0 = [0.10,-0.50];  


% ModelFun = @(p,x) (p(1)) - ((2.*p(2).*x)); beta0 = [1,1]; 

ModelFun = @(p,x) (p(1)) - ((2.*p(2).*x)); beta0 = [10,10];  


X_GrayColorCut=X_GrayColor; 
y_GrayColorCut=Y_GrayColor';


%objective least squares cost function
options = optimoptions('lsqcurvefit','Algorithm', 'levenberg-marquardt');
lb=[10 15];
up=[-10 -10];
pars = lsqcurvefit(ModelFun,beta0,X_GrayColorCut,y_GrayColorCut,lb,up,options);

% pars =lsqcurvefit(ModelFun,beta0,xdB,ydB,[],[],options);

beta02=pars;
% opts.RobustWgtFun = 'bisquare';
opts.RobustWgtFun = 'logistic';

[p_x,resid,J,~,~,~] = nlinfit(X_GrayColorCut,y_GrayColorCut,ModelFun,beta02,opts); 
% ErrorFit=ErrorModelInfo.ErrorParameters;

% Calcula erro:
J=full(J);
alpha = 0.05; % this is for 95% confidence intervals
pars_ci = nlparci(p_x,resid,'jacobian',J,'alpha',alpha);
incertezs=(pars_ci(:,2) - pars_ci(:,1))/2;


ErrorFit=(incertezs(2)./(20*0.4343) ).*(50/255);
coefAtt=( p_x(2)./(20*0.4343) ).*(50/255);

ModelFun =(p_x(1)) - ((2.*p_x(2).*X_GrayColorCut));


axes('Position',[.7 .7 .2 .2]);
box on

plot(X_GrayColorCut,y_GrayColorCut,'-d','color','b','markerfacecolor','b','markersize',10)
xlabel('Depth,z (mm)','FontSize',16)
ylabel('Logarithmic OCT Signal','FontSize',16)
hold on

plot(X_GrayColorCut,ModelFun,'r','markersize',20);
title([ '\mu_(_t_) = ',num2str(coefAtt,'%0.2f '),...
    '  \sigma = ',num2str(ErrorFit,'%0.2f')])
legend('Dermes','Exponential Fit ')
% axis([ min(x) max(x) 0 1])
hold off
set(gcf,'color','w');



 