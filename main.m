clc;
clear all;
close all;

%%Datos del problema

lg=2e-3; %Longitud del entrehierro
x=0.2; % Largo y ancho del material ferromagn�tico
p=50e-3; %Profundidad y dimensiones del area transversal del material
fa=0.95; %Factor de apilamiento
n=500; %Numero de vueltas en la bobina
phi=4e-3; %Flujo magn�tico deseado
I=10; %Corriente en la bobina deseada
u0=1.256637061e-6; %permeabilidad magn�tica en el vacio/entrehierro

%Importar los datos para la interpolaci�n por Luis Leon
Material='35PN250'; %Nombre de los archivos txt
datos=importdata([Material,'.txt']);


fprintf(['Calculando la corriente para un flujo en el material de: ', num2str(phi),' Wb  \n']);
%Calculos previos a la interpolaci�n
Ae=fa*p^2; %Area efectiva del material ferromagn�tico
Ag=(p+lg)^2; %Area efectiva del entrehierro
lm=4*(x-p)-lg; %Longitud media del material ferromagn�tico

Bm=phi/Ae; %Densidad de flujo en el material ferromagn�tico
Bg=phi/Ag; %Densidad de flujo en el entrehierro

%Plot de las curvas de magnetizaci�n interpoladas
Bi=linspace(0,2,1000);
H=interp1(datos(:,2),datos(:,1),Bi,'spline','extrap');
figure;
plot(H,Bi);
xlim([0,max(H)]);
ylim([0,max(Bi)]);
title(['Curva de magnetizaci�n para el material: ',Material])

%PRIMERA PARTE 

%Interpolaci�n de los datos B-H para obtener la intensidad de campo
%magn�tico en el material y el entrehierro, los valores de Hm y Hg se 
%encuentran en las columnas para cada material.

 Hm=interp1(datos(:,2),datos(:,1),Bm,'spline','extrap');


%C�lculo de las corrientes

I_x=(Hm*lm+(Bg/u0)*lg)/n; %Corriente en la bobina

fprintf(['La corriente en la bobina, para el material ', Material,' debe ser de: ', num2str(I_x), ' A \n'])


%SEGUNDA PARTE:

%Definici�n de la recta de carga

syms B(h);
B(h)=(n*I-h*lm)*(u0*Ag)/(lg*Ae); %Recta de carga

err=0.0001; %limite aceptable del error
e=[1]; %error
hmax=max(H); %valor final
hx=min(H); %valor inicial

disp('...')
fprintf(['Calculando el flujo magn�tico para una corriente de : ', num2str(I),' A  \n']);
while ((e(end)>err) && (hx<hmax))
    B1=B(hx); %campo segun la recta de carga
    B1=eval(B1);

    B2=interp1(datos(:,1),datos(:,2),hx,'spline'); %calculo segun la curva de magnetizaci�n

    e=[e,abs((B1-B2))]; %calculo del error
    hx=hx+10*e(end); %el cambio es din�mico, el 10 es para acelerar el descenso
end

%Plot de la gr�fica de error
figure;
plot(e);
ylim([0,1])
title('Error absoluto en el c�lculo por iteraci�n')

%C�lculo del flujo magn�tico
Bx=(B1+B2)/2; %Densidad de campo obtenida por la iteraci�n
hx; %Intensidad del campo magn�tico, obtenida por iteraci�n.

phi_x=Bx*Ae; %flujo m�gnetico a traves del material ferromagn�tico

fprintf(['El flujo en el material ferromagn�tico ', Material,' debe ser de: ', num2str(phi_x), ' Wb \n'])
fprintf(['El error basoluto del c�lculo fue de: ', num2str(e(end))])






